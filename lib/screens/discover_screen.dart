import 'dart:async'; // Untuk simulasi "sedang mengetik"
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
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
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: kMainTeal,
          unselectedLabelColor: kIconGrey,
          indicatorColor: kMainTeal,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
          tabs: const [
            Tab(text: "Cari Fasilitas"),
            Tab(text: "Asisten Asa"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          NearbySearchTab(), // Tab 1: Peta (Tetap Sama)
          OfflineChatTab(),  // Tab 2: Chatbot Offline (BARU)
        ],
      ),
    );
  }
}

// ==========================================
// TAB 1: PENCARIAN (TETAP SAMA)
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
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if(mounted) setState(() { _currentAddress = "GPS mati."; _isLoadingLocation = false; });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if(mounted) setState(() { _currentAddress = "Izin ditolak."; _isLoadingLocation = false; });
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        if(mounted) setState(() { _currentAddress = "${place.street}, ${place.subLocality}"; _isLoadingLocation = false; });
      }
    } catch (e) {
      if(mounted) setState(() { _currentAddress = "Gagal deteksi."; _isLoadingLocation = false; });
    }
  }

  Future<void> _launchGoogleMapsSearch(String keyword) async {
    final Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(keyword)}");
    try { await launchUrl(url, mode: LaunchMode.externalApplication); } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: kMainTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            const Icon(Icons.my_location, color: kMainTeal),
            const SizedBox(width: 10),
            Expanded(child: Text(_currentAddress, style: const TextStyle(fontWeight: FontWeight.bold))),
            IconButton(icon: const Icon(Icons.refresh, color: kMainTeal), onPressed: _determinePosition)
          ]),
        ),
        const SizedBox(height: 20),
        _btn(Icons.local_hospital, Colors.red, "Klinik Tumbuh Kembang", "klinik tumbuh kembang anak terdekat"),
        _btn(Icons.psychology, Colors.orange, "Psikolog Anak", "psikolog anak terdekat"),
        _btn(Icons.record_voice_over, Colors.blue, "Terapi Wicara", "terapi wicara terdekat"),
        _btn(Icons.accessibility_new, Colors.green, "Terapi Okupasi", "terapi okupasi anak terdekat"),
        _btn(Icons.school, Colors.purple, "Sekolah Luar Biasa", "sekolah luar biasa SLB terdekat"),
      ],
    );
  }

  Widget _btn(IconData i, Color c, String t, String k) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(i, color: c),
        title: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _launchGoogleMapsSearch(k),
      ),
    );
  }
}

// ==========================================
// TAB 2: CHATBOT OFFLINE (GRATIS & CANGGIH)
// ==========================================
class OfflineChatTab extends StatefulWidget {
  const OfflineChatTab({super.key});

  @override
  State<OfflineChatTab> createState() => _OfflineChatTabState();
}

class _OfflineChatTabState extends State<OfflineChatTab> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false; // Efek "sedang mengetik" biar terasa nyata

  @override
  void initState() {
    super.initState();
    _loadWelcomeMessage();
  }

  Future<void> _loadWelcomeMessage() async {
    final prefs = await SharedPreferences.getInstance();
    String userName = prefs.getString('userName') ?? "Bunda";
    
    setState(() {
      _messages.add({
        "role": "bot",
        "text": "Halo $userName! 👋 Saya Asisten Asa.\n\nSaya bisa bantu jawab pertanyaan seputar:\n• Penanganan Tantrum\n• Terapi (Wicara/Okupasi)\n• Pola Makan / GTM\n• Tips Tidur\n\nMau tanya apa hari ini?"
      });
    });
  }

  void _handleMessage() {
    String text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
      _isTyping = true; // Munculkan indikator loading
    });
    _textController.clear();
    _scrollToBottom();

    // Simulasi delay biar kayak mikir (1 detik)
    Timer(const Duration(seconds: 1), () {
      String reply = _generateSmartReply(text);
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({"role": "bot", "text": reply});
        });
        _scrollToBottom();
      }
    });
  }

  // --- OTAK DARI CHATBOT OFFLINE ---
  String _generateSmartReply(String input) {
    String text = input.toLowerCase();

    // 1. Topik TANTRUM
    if (text.contains('tantrum') || text.contains('marah') || text.contains('nangis') || text.contains('ngamuk')) {
      return "Menghadapi anak tantrum memang menantang. Coba langkah ini:\n\n1. Tetap Tenang: Anak butuh kita tenang saat mereka 'badai'.\n2. Validasi Emosi: Katakan 'Adik marah ya? Tidak apa-apa marah, tapi tidak boleh pukul'.\n3. Jangan Banyak Bicara: Saat tantrum, otak logikanya sedang mati. Peluk atau diam di dekatnya sampai reda.\n4. Cek Pemicu: Apakah dia lapar, lelah, atau *sensory overload*?";
    }

    // 2. Topik TERAPI
    if (text.contains('terapi') || text.contains('wicara') || text.contains('okupasi') || text.contains('bicara')) {
      return "Terapi sangat bagus untuk perkembangan! 🧩\n\n• Terapi Wicara: Fokus melatih komunikasi dan otot mulut.\n• Terapi Okupasi: Melatih kemandirian (pakai baju, makan) dan sensorik.\n• Terapi Perilaku (ABA): Membentuk kebiasaan baik.\n\nIngat, terapi terbaik adalah yang dilanjutkan orang tua di rumah melalui bermain.";
    }

    // 3. Topik MAKAN / GTM
    if (text.contains('makan') || text.contains('gtm') || text.contains('lapar') || text.contains('sayur')) {
      return "Masalah makan umum terjadi pada anak autis karena sensitivitas tekstur.\n\nTips:\n• Food Chaining: Mulai dari makanan kesukaannya, lalu kenalkan makanan yang mirip teksturnya sedikit demi sedikit.\n• Jangan Paksa: Memaksa malah bikin trauma.\n• Ajak Main: Biarkan dia menyentuh atau mencium makanan baru tanpa harus memakannya dulu (eksplorasi sensorik).";
    }

    // 4. Topik TIDUR
    if (text.contains('tidur') || text.contains('begadang') || text.contains('bangun')) {
      return "Susah tidur? Coba rutinitas ini 😴:\n\n1. Matikan gadget 1 jam sebelum tidur.\n2. Redupkan lampu kamar.\n3. Pijatan lembut atau selimut berat (weighted blanket) bisa membantu menenangkan sistem sarafnya.\n4. Pastikan jadwal tidur konsisten setiap hari.";
    }
    
    // 5. Sapaan
    if (text.contains('halo') || text.contains('hi') || text.contains('pagi') || text.contains('malam')) {
      return "Halo juga! Ada yang bisa saya bantu tentang si kecil?";
    }
    
    // 6. Terimakasih
    if (text.contains('makasih') || text.contains('thanks') || text.contains('trims')) {
      return "Sama-sama! Semangat terus ya, kamu orang tua hebat! 💪";
    }

    // DEFAULT (Jika tidak mengerti)
    return "Maaf, saya masih belajar. 🤔\n\nCoba tanya tentang:\n- 'Cara atasi tantrum'\n- 'Tips anak susah makan'\n- 'Apa itu terapi wicara?'\n- 'Anak susah tidur'";
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
    return Column(
      children: [
        // --- CHAT LIST ---
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              // Tampilkan indikator typing di item terakhir jika sedang loading
              if (_isTyping && index == _messages.length) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
                    child: const Text("Sedang mengetik...", style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
                  ),
                );
              }

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

        // --- INPUT FIELD ---
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: "Tanya tentang tantrum, makan...",
                    filled: true,
                    fillColor: kSoftBeige,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onSubmitted: (_) => _handleMessage(),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: kMainTeal,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _handleMessage,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}