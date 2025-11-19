import 'dart:convert'; // Untuk mengolah data JSON dari Google
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Wajib untuk koneksi ke Google Maps
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
            Tab(text: "Tempat Terdekat"),
            Tab(text: "Tanya AI"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          NearbyPlacesTab(), // Tab 1: Google Maps Places Asli
          AiChatTab(),       // Tab 2: Gemini AI
        ],
      ),
    );
  }
}

// ==========================================
// TAB 1: REAL GOOGLE PLACES (LIVE DATA)
// ==========================================
class NearbyPlacesTab extends StatefulWidget {
  const NearbyPlacesTab({super.key});

  @override
  State<NearbyPlacesTab> createState() => _NearbyPlacesTabState();
}

class _NearbyPlacesTabState extends State<NearbyPlacesTab> {
  // --- API KEY GOOGLE MAPS (PLACES) ---
  // Masukkan API Key Google Maps Anda di sini
  static const String _googleMapsApiKey = 'AIzaSyATqfNVRECUygWKkoErnjSRmQwd8jLJ9Ws'; 

  // ignore: unused_field
  Position? _currentPosition;
  String _currentAddress = "Mencari lokasi...";
  String _statusMessage = "Menyiapkan GPS...";
  bool _isLoading = true;
  
  // Menyimpan hasil pencarian asli dari Google
  List<dynamic> _realPlaces = [];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // 1. Cek GPS & Ambil Koordinat
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _statusMessage = "GPS mati. Mohon aktifkan GPS Anda.";
        _isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _statusMessage = "Izin lokasi ditolak.";
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _statusMessage = "Izin lokasi ditolak permanen.";
        _isLoading = false;
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      _getAddressFromLatLng(position);
      
      // PANGGIL DATA ASLI GOOGLE
      if (_googleMapsApiKey != 'AIzaSyATqfNVRECUygWKkoErnjSRmQwd8jLJ9Ws') {
        _fetchRealPlacesFromGoogle(position);
      } else {
        setState(() {
          _statusMessage = "API Key Google Maps belum dipasang di kodingan.";
          _isLoading = false;
        });
      }

      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Gagal mengambil lokasi: $e";
        _isLoading = false;
      });
    }
  }

  // 2. Reverse Geocoding (Koordinat -> Alamat)
  Future<void> _getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = (await placemarkFromCoordinates(
        position.latitude,
        position.longitude
      )).cast<Placemark>();
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentAddress = "${place.street}, ${place.subLocality}, ${place.locality}";
        });
      }
    } catch (e) {
      setState(() => _currentAddress = "Alamat tidak terdeteksi");
    }
  }

  // 3. FETCH DATA DARI GOOGLE PLACES API
  Future<void> _fetchRealPlacesFromGoogle(Position pos) async {
    setState(() => _statusMessage = "Mencari klinik & terapis terdekat...");

    // Kata kunci pencarian yang relevan untuk autisme
    String keyword = "terapi tumbuh kembang anak psikolog psikiater"; 
    String type = "health"; // Kategori kesehatan
    int radius = 10000; // 10 KM

    // URL Request ke Google Places API (Nearby Search)
    final String url = 
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        "location=${pos.latitude},${pos.longitude}"
        "&radius=$radius"
        "&keyword=$keyword"
        "&type=$type"
        "&key=$_googleMapsApiKey";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          setState(() {
            _realPlaces = data['results'];
            _isLoading = false;
          });
        } else if (data['status'] == 'ZERO_RESULTS') {
           setState(() {
            _statusMessage = "Tidak ada tempat terapi/psikolog ditemukan di radius $radius meter.";
            _isLoading = false;
          });
        } else {
          setState(() {
            _statusMessage = "Error dari Google: ${data['status']}. Cek API Key/Billing.";
            _isLoading = false;
          });
        }
      } else {
        throw Exception("Gagal koneksi ke Google Maps");
      }
    } catch (e) {
      setState(() {
        _statusMessage = "Gagal memuat data: $e";
        _isLoading = false;
      });
    }
  }

  // 4. Buka Google Maps App
  Future<void> _openGoogleMaps(double lat, double lng) async {
    final Uri googleMapsUrl = Uri.parse("google.navigation:q=$lat,$lng");
    final Uri browserUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else {
        await launchUrl(browserUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tidak bisa membuka peta")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: kMainTeal),
          const SizedBox(height: 16),
          Text(_statusMessage, textAlign: TextAlign.center, style: const TextStyle(color: kDarkGrey)),
        ],
      ));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // --- KARTU LOKASI SAYA ---
        Card(
          color: kMainTeal.withOpacity(0.1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: kMainTeal)
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.my_location, color: kMainTeal, size: 30),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Lokasi Anda:", style: TextStyle(fontSize: 12, color: kDarkGrey)),
                      const SizedBox(height: 4),
                      Text(_currentAddress, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        const Text("Fasilitas Terdekat (Real-Time)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        // --- LIST TEMPAT GOOGLE ---
        if (_realPlaces.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(child: Text(_statusMessage, textAlign: TextAlign.center)),
          )
        else
          ..._realPlaces.map((place) => _buildGooglePlaceCard(place)),
      ],
    );
  }

  Widget _buildGooglePlaceCard(dynamic place) {
    // Parse data dari Google
    String name = place['name'] ?? "Tanpa Nama";
    String address = place['vicinity'] ?? "Alamat tidak tersedia";
    double rating = (place['rating'] ?? 0).toDouble();
    int userRatingsTotal = place['user_ratings_total'] ?? 0;
    double lat = place['geometry']['location']['lat'];
    double lng = place['geometry']['location']['lng'];
    bool isOpen = place['opening_hours']?['open_now'] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _openGoogleMaps(lat, lng),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ikon
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: kAccentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: const Icon(Icons.location_on, color: kAccentPurple, size: 28),
              ),
              const SizedBox(width: 16),
              
              // Detail Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(address, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    
                    // Rating & Status Buka
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text("$rating ($userRatingsTotal)", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        if (isOpen)
                          const Text("Buka", style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold))
                        else
                          const Text("Tutup/Tidak diketahui", style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
              const Icon(Icons.directions, color: kMainTeal),
            ],
          ),
        ),
      ),
    );
  }
}

// Removed local Placemark class to avoid shadowing geocoding.Placemark from package:geocoding
// The Placemark type from package:geocoding provides the 'street', 'subLocality', 'locality', etc. getters.

// ==========================================
// TAB 2: CHAT AI ASSISTANT (GEMINI)
// ==========================================
class AiChatTab extends StatefulWidget {
  const AiChatTab({super.key});

  @override
  State<AiChatTab> createState() => _AiChatTabState();
}

class _AiChatTabState extends State<AiChatTab> {
  // --- API KEY GEMINI (WAJIB DIISI) ---
  static const String _geminiApiKey = 'AIzaSyB8S6Ouywt7kqbmNWkgMSCWXUKYnmMfJJA'; 
  
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  bool _isApiKeyValid = false;

  @override
  void initState() {
    super.initState();
    // Cek apakah API Key sudah diganti
    if (_geminiApiKey != 'AIzaSyB8S6Ouywt7kqbmNWkgMSCWXUKYnmMfJJA' && _geminiApiKey.isNotEmpty) {
      _isApiKeyValid = true;
      _model = GenerativeModel(model: 'gemini-pro', apiKey: _geminiApiKey);
      _chat = _model.startChat();
    }
    _loadUserNameAndGreet();
  }

  Future<void> _loadUserNameAndGreet() async {
    final prefs = await SharedPreferences.getInstance();
    String userName = prefs.getString('userName') ?? "Bunda";

    setState(() {
      _messages.add({
        "role": "model",
        "text": "Halo $userName! Saya asisten TemanAsa. Silakan tanya apa saja seputar pengasuhan anak, terapi, atau kesehatan mental."
      });
    });
  }

  Future<void> _sendMessage() async {
    final message = _textController.text;
    if (message.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": message});
      _isLoading = true;
    });
    _textController.clear();
    _scrollToBottom();

    if (!_isApiKeyValid) {
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _messages.add({"role": "model", "text": "ERROR: API Key Gemini belum dipasang. Harap masukkan API Key di kode program."});
        _isLoading = false;
      });
      _scrollToBottom();
      return;
    }

    try {
      final response = await _chat.sendMessage(Content.text(message));
      final text = response.text;
      
      if (text != null) {
        setState(() {
          _messages.add({"role": "model", "text": text});
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      setState(() {
        _messages.add({"role": "model", "text": "Maaf, terjadi kesalahan koneksi. Coba lagi ya."});
        _isLoading = false;
      });
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
            child: LinearProgressIndicator(color: kMainTeal),
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