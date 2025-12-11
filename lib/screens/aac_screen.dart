import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:teman_asa/theme.dart';

class AacScreen extends StatefulWidget {
  const AacScreen({super.key});

  @override
  State<AacScreen> createState() => _AacScreenState();
}

class _AacScreenState extends State<AacScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final TextEditingController _customTextController = TextEditingController();
  bool isSpeaking = false;

  // Data Tombol AAC yang SUDAH DITAMBAH (Total 16 Kata)
  final List<Map<String, dynamic>> _aacItems = [
    // Kebutuhan Dasar
    {"label": "Makan", "icon": Icons.restaurant_menu_rounded, "color": Colors.orange},
    {"label": "Minum", "icon": Icons.local_cafe_rounded, "color": Colors.blue},
    {"label": "Sakit", "icon": Icons.sick_rounded, "color": Colors.red},
    {"label": "Tidur", "icon": Icons.bedtime_rounded, "color": kAccentPurple},
    {"label": "Toilet", "icon": Icons.wc_rounded, "color": kMainTeal},
    {"label": "Main", "icon": Icons.toys_rounded, "color": kAccentYellow},
    
    // Jawaban Cepat
    {"label": "Ya", "icon": Icons.check_circle_rounded, "color": Colors.green},
    {"label": "Tidak", "icon": Icons.cancel_rounded, "color": kAccentCoral},
    
    // Permintaan & Ekspresi (BARU)
    {"label": "Mau", "icon": Icons.pan_tool_alt_rounded, "color": Colors.cyan},
    {"label": "Tolong", "icon": Icons.volunteer_activism_rounded, "color": Colors.pink},
    {"label": "Suka", "icon": Icons.favorite_rounded, "color": Colors.pinkAccent},
    {"label": "Stop", "icon": Icons.back_hand_rounded, "color": Colors.redAccent},
    
    // Emosi (BARU)
    {"label": "Senang", "icon": Icons.sentiment_very_satisfied_rounded, "color": Colors.amber},
    {"label": "Sedih", "icon": Icons.sentiment_dissatisfied_rounded, "color": Colors.blueGrey},
    {"label": "Marah", "icon": Icons.sentiment_very_dissatisfied_rounded, "color": Colors.deepOrange},
    
    // Lainnya (BARU)
    {"label": "Pulang", "icon": Icons.home_rounded, "color": Colors.brown},
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  @override
  void dispose() {
    flutterTts.stop();
    _customTextController.dispose();
    super.dispose();
  }

  void _initTts() async {
    await flutterTts.awaitSpeakCompletion(true);
    var isAvailable = await flutterTts.isLanguageAvailable("id-ID");
    if (isAvailable) {
      await flutterTts.setLanguage("id-ID");
    }
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    flutterTts.setStartHandler(() => setState(() => isSpeaking = true));
    flutterTts.setCompletionHandler(() => setState(() => isSpeaking = false));
    flutterTts.setCancelHandler(() => setState(() => isSpeaking = false));
  }

  void _speak(String text) async {
    if (text.isNotEmpty) {
      await flutterTts.setLanguage("id-ID");
      await flutterTts.speak(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSoftBeige, 
      appBar: AppBar(
        title: const Text("Bantu Bicara"),
        backgroundColor: kSoftBeige,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. INPUT TEXT MANUAL
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: kSoftBeige,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _customTextController,
                      decoration: const InputDecoration(
                        hintText: "Ketik ucapan di sini...",
                        border: InputBorder.none,
                        icon: Icon(Icons.keyboard, color: kIconGrey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _speak(_customTextController.text),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: kMainTeal,
                    child: Icon(isSpeaking ? Icons.graphic_eq : Icons.volume_up_rounded, color: Colors.white),
                  ),
                )
              ],
            ),
          ),

          // 2. HEADER KECIL
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Kartu Cepat", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kDarkGrey)),
            ),
          ),

          // 3. GRID TOMBOL AAC
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1, 
              ),
              itemCount: _aacItems.length,
              itemBuilder: (context, index) {
                final item = _aacItems[index];
                return _buildAacCard(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAacCard(Map<String, dynamic> item) {
    Color baseColor = item['color'];
    
    return GestureDetector(
      onTap: () {
        _speak(item['label']);
      },
      child: Container(
        decoration: BoxDecoration(
          color: baseColor.withOpacity(0.15), 
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: baseColor.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(item['icon'], size: 32, color: baseColor),
            ),
            const SizedBox(height: 12),
            Text(
              item['label'],
              style: const TextStyle(
                fontFamily: 'NerkoOne',
                fontSize: 22,
                color: kDarkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}