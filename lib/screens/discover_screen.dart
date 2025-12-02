import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_generative_ai/google_generative_ai.dart'; // Pake library ini
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teman_asa/theme.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Discover"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: kMainTeal,
          unselectedLabelColor: kIconGrey,
          indicatorColor: kMainTeal,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
          tabs: const [
            Tab(text: "Cari Fasilitas"),
            Tab(text: "Chat Asisten"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          NearbySearchTab(), // Tab 1: Fasilitas (Maps)
          AiChatTab(),       // Tab 2: Gemini AI (Gratis)
        ],
      ),
    );
  }
}

// ==========================================
// TAB 1: PENCARIAN TANPA API (TETAP SAMA)
// ==========================================
class NearbySearchTab extends StatefulWidget {
  const NearbySearchTab({super.key});

  @override
  State<NearbySearchTab> createState() => _NearbySearchTabState();
}

class _NearbySearchTabState extends State<NearbySearchTab> {
  String _currentAddress = "Mencari lokasi Anda...";
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() {
        _currentAddress = "GPS mati. Aktifkan GPS untuk akurasi.";
        _isLoadingLocation = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() {
          _currentAddress = "Izin lokasi ditolak.";
          _isLoadingLocation = false;
        });
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        if (mounted) setState(() {
          _currentAddress = "${place.street}, ${place.subLocality}, ${place.locality}";
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() {
        _currentAddress = "Gagal mendeteksi alamat.";
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _launchGoogleMapsSearch(String keyword) async {
    final Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(keyword)}");
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tidak dapat membuka Google Maps")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kMainTeal.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kMainTeal.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.my_location, color: kMainTeal, size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Posisi Anda Sekarang:", style: TextStyle(fontSize: 12, color: kDarkGrey)),
                    const SizedBox(height: 4),
                    _isLoadingLocation 
                      ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2, color: kMainTeal))
                      : Text(_currentAddress, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: kMainTeal),
                onPressed: () {
                  setState(() => _isLoadingLocation = true);
                  _determinePosition();
                },
              )
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Text("Cari Fasilitas Terdekat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text("Pilih kategori untuk membuka hasil di Google Maps", style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 20),
        _buildSearchButton(icon: Icons.local_hospital, color: Colors.redAccent, title: "Klinik Tumbuh Kembang", keyword: "klinik tumbuh kembang anak terdekat"),
        _buildSearchButton(icon: Icons.psychology, color: Colors.orange, title: "Psikolog Anak", keyword: "psikolog anak terdekat"),
        _buildSearchButton(icon: Icons.record_voice_over, color: Colors.blue, title: "Terapi Wicara", keyword: "terapi wicara terdekat"),
        _buildSearchButton(icon: Icons.accessibility_new, color: Colors.green, title: "Terapi Okupasi", keyword: "terapi okupasi anak terdekat"),
        _buildSearchButton(icon: Icons.school, color: Colors.purple, title: "Sekolah Luar Biasa (SLB)", keyword: "sekolah luar biasa SLB terdekat"),
      ],
    );
  }

  Widget _buildSearchButton({required IconData icon, required Color color, required String title, required String keyword}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _launchGoogleMapsSearch(keyword),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kDarkGrey))),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// TAB 2: CHAT AI (MENGGUNAKAN GOOGLE GEMINI)
// ==========================================
class AiChatTab extends StatefulWidget {
  const AiChatTab({super.key});

  @override
  State<AiChatTab> createState() => _AiChatTabState();
}

class _AiChatTabState extends State<AiChatTab> {
  // === GANTI DENGAN API KEY DARI GOOGLE AI STUDIO (GRATIS) ===
  static const String _geminiApiKey = 'AIzaSyB8S6Ouywt7kqbmNWkgMSCWXUKYnmMfJJA'; 
  
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Menyimpan pesan dalam format UI kita
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  bool _isModelInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeGemini();
  }

  Future<void> _initializeGemini() async {
    // Cek apakah API Key sudah diisi
    if (_geminiApiKey == 'AIzaSyB8S6Ouywt7kqbmNWkgMSCWXUKYnmMfJJA' || _geminiApiKey.isEmpty) {
      return;
    }

    try {
      _model = GenerativeModel(
        model: 'gemini-pro', 
        apiKey: _geminiApiKey,
      );
      _chat = _model.startChat();
      
      final prefs = await SharedPreferences.getInstance();
      String userName = prefs.getString('userName') ?? "Bunda";

      setState(() {
        _isModelInitialized = true;
        _messages.add({
          "role": "model",
          "text": "Halo $userName! Saya asisten TemanAsa. Ada yang bisa saya bantu?"
        });
      });
    } catch (e) {
      debugPrint("Error Init Gemini: $e");
    }
  }

  Future<void> _sendMessage() async {
    final message = _textController.text;
    if (message.trim().isEmpty) return;
    if (!_isModelInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("API Key belum diisi atau inisialisasi gagal.")));
      return;
    }

    setState(() {
      _messages.add({"role": "user", "text": message});
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    try {
      final response = await _chat.sendMessage(Content.text(message));
      final text = response.text;
      
      if (text != null && mounted) {
        setState(() {
          _messages.add({"role": "model", "text": text});
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({"role": "model", "text": "Maaf, terjadi kesalahan: $e"});
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan jika API Key belum diisi
    if (!_isModelInitialized && (_geminiApiKey == 'AIzaSyB8S6Ouywt7kqbmNWkgMSCWXUKYnmMfJJA' || _geminiApiKey.isEmpty)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.vpn_key_off, size: 60, color: Colors.orange),
              const SizedBox(height: 20),
              const Text(
                "API Key Belum Diatur",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Silakan masukkan API Key Google Gemini (Gratis) di kode discover_screen.dart",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                   final Uri url = Uri.parse("https://aistudio.google.com/app/apikey");
                   if (!await launchUrl(url)) {
                     // handle error
                   }
                },
                child: const Text("Dapatkan API Key di Sini"),
              )
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isUser = msg['role'] == 'user';
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(
                    color: isUser ? kMainTeal : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isUser ? const Radius.circular(20) : Radius.zero,
                      bottomRight: isUser ? Radius.zero : const Radius.circular(20),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]
                  ),
                  child: Text(
                    msg['text']!,
                    style: TextStyle(color: isUser ? Colors.white : kDarkGrey, height: 1.4),
                  ),
                ),
              );
            },
          ),
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: LinearProgressIndicator(color: kMainTeal, minHeight: 2),
          ),
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: "Tanya sesuatu...",
                    filled: true,
                    fillColor: kSoftBeige,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: kMainTeal,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}