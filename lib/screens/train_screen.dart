import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:teman_asa/theme.dart';

class TrainScreen extends StatefulWidget {
  const TrainScreen({super.key});

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Latihan & Bermain")),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            "Pilih Latihan",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kDarkGrey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          _menuCard("Fokus & Kontrol", "Latihan menahan impuls.", Icons.timer, Colors.orangeAccent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FocusGame()))),
          _menuCard("Relaksasi Napas", "Teknik pernapasan 4-4-4.", Icons.air, Colors.lightBlueAccent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BreathingGame()))),
          _menuCard("Tangkap Si Bulat", "Cetak skor tertinggi!", Icons.touch_app, Colors.pinkAccent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReflexGame()))),
        ],
      ),
    );
  }

  Widget _menuCard(String title, String desc, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
          border: Border.all(color: color.withOpacity(0.5), width: 1)
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 32)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kDarkGrey)), const SizedBox(height: 4), Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey))])),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ==================================================
// GAME 1: FOKUS (TETAP)
// ==================================================
class FocusGame extends StatefulWidget { const FocusGame({super.key}); @override State<FocusGame> createState() => _FocusGameState(); }
class _FocusGameState extends State<FocusGame> {
  double prog = 0.0; Timer? t; bool isComplete = false;
  void start() { if (isComplete) return; t = Timer.periodic(const Duration(milliseconds: 50), (_) { setState(() { prog += 0.015; if (prog >= 1) { t?.cancel(); prog = 1; isComplete = true; _showSuccessDialog(); } }); }); }
  void stop() { if (isComplete) return; t?.cancel(); setState(() { prog = 0; }); }
  void _showSuccessDialog() { showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(title: const Text("Hebat! 🎉"), content: const Text("Kamu berhasil fokus sampai selesai."), actions: [TextButton(onPressed: () { Navigator.pop(context); setState(() { isComplete = false; prog = 0; }); }, child: const Text("Main Lagi")), ElevatedButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text("Selesai"))])); }
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text("Latihan Fokus")), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("Tekan & Tahan Tombol", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 10), const Text("Jangan lepas sampai penuh!", style: TextStyle(color: Colors.grey)), const SizedBox(height: 50), GestureDetector(onTapDown: (_) => start(), onTapUp: (_) => stop(), child: Container(width: 240, height: 240, decoration: BoxDecoration(color: isComplete ? Colors.green : Colors.orangeAccent, shape: BoxShape.circle, boxShadow: [BoxShadow(color: (isComplete ? Colors.green : Colors.orangeAccent).withOpacity(0.4), blurRadius: 30, spreadRadius: 10)]), child: Center(child: isComplete ? const Icon(Icons.check, size: 80, color: Colors.white) : const Text("TAHAN", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))))), const SizedBox(height: 60), Padding(padding: const EdgeInsets.symmetric(horizontal: 50), child: LinearProgressIndicator(value: prog, minHeight: 25, borderRadius: BorderRadius.circular(20), color: Colors.green, backgroundColor: Colors.grey[200]))]))); }
}

// ==================================================
// GAME 2: PERNAPASAN (POLA 4-4-4 & UI STABIL)
// ==================================================
class BreathingGame extends StatefulWidget {
  const BreathingGame({super.key});
  @override State<BreathingGame> createState() => _BreathingGameState();
}

class _BreathingGameState extends State<BreathingGame> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _sizeAnimation;
  
  bool isRunning = false;
  int selectedDuration = 1;
  int remainingSeconds = 60;
  Timer? _timer;
  String _instruction = "Siap?"; // Teks instruksi dinamis

  @override 
  void initState() { 
    super.initState(); 
    // Durasi animasi tarik/hembus adalah 4 detik
    _animController = AnimationController(vsync: this, duration: const Duration(seconds: 4)); 
    _sizeAnimation = Tween<double>(begin: 150.0, end: 300.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut)
    ); 
  }

  void _startExercise() { 
    setState(() { 
      isRunning = true; 
      remainingSeconds = selectedDuration * 60;
      _instruction = "Tarik Napas..."; 
    });
    
    // Jalankan Siklus Napas
    _runBreathingCycle();

    // Timer Mundur Global
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) { 
      setState(() { 
        if (remainingSeconds > 0) remainingSeconds--; 
        else _stopExercise(); 
      }); 
    }); 
  }

  // Logika Siklus: Tarik (4s) -> Tahan (4s) -> Hembus (4s)
  Future<void> _runBreathingCycle() async {
    if (!mounted || !isRunning) return;

    // 1. TARIK NAPAS (4 Detik) -> Animasi Membesar
    setState(() => _instruction = "Tarik Napas...");
    await _animController.forward(); // Memakan waktu 4 detik sesuai duration controller

    if (!mounted || !isRunning) return;

    // 2. TAHAN (4 Detik) -> Diam
    setState(() => _instruction = "Tahan...");
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted || !isRunning) return;

    // 3. HEMBUSKAN (4 Detik) -> Animasi Mengecil
    setState(() => _instruction = "Hembuskan...");
    await _animController.reverse(); // Memakan waktu 4 detik

    if (!mounted || !isRunning) return;

    // Ulangi Siklus
    _runBreathingCycle();
  }

  void _stopExercise() { 
    _timer?.cancel(); 
    _animController.stop(); 
    _animController.reset(); 
    setState(() { 
      isRunning = false; 
      remainingSeconds = selectedDuration * 60; 
      _instruction = "Siap?";
    }); 
    
    if (mounted) {
      showDialog(
        context: context, 
        builder: (_) => AlertDialog(
          title: const Text("Latihan Selesai 🧘"), 
          content: const Text("Semoga pikiranmu lebih tenang sekarang."), 
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))]
        )
      );
    } 
  }
  
  @override void dispose() { _animController.dispose(); _timer?.cancel(); super.dispose(); }
  
  @override Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(title: const Text("Relaksasi")), 
      body: isRunning ? _buildRunningUI() : _buildSetupUI()
    ); 
  }

  Widget _buildRunningUI() { 
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          // Timer
          Text(
            "${(remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds % 60).toString().padLeft(2, '0')}", 
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: kDarkGrey)
          ),
          const SizedBox(height: 20),
          
          // Instruksi
          Text(
            _instruction, 
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kMainTeal)
          ),
          const SizedBox(height: 30),
          
          // AREA ANIMASI YANG STABIL (DIKUNCI UKURANNYA)
          // SizedBox ini mencegah elemen lain bergeser saat lingkaran membesar
          SizedBox(
            width: 320,
            height: 320,
            child: Center(
              child: AnimatedBuilder(
                animation: _animController, 
                builder: (context, child) {
                  return Container(
                    width: _sizeAnimation.value, 
                    height: _sizeAnimation.value, 
                    decoration: BoxDecoration(
                      color: kMainTeal.withOpacity(0.3), 
                      shape: BoxShape.circle, 
                      border: Border.all(color: kMainTeal, width: 2)
                    ), 
                    child: Center(
                      child: Container(
                        width: _sizeAnimation.value * 0.8, 
                        height: _sizeAnimation.value * 0.8, 
                        decoration: const BoxDecoration(color: kMainTeal, shape: BoxShape.circle), 
                        child: const Icon(Icons.spa, color: Colors.white, size: 50)
                      )
                    )
                  );
                }
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          OutlinedButton(
            onPressed: _stopExercise, 
            child: const Text("Berhenti", style: TextStyle(color: Colors.red))
          )
        ]
      ),
    ); 
  }

  Widget _buildSetupUI() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.self_improvement, size: 100, color: kMainTeal),
            const SizedBox(height: 24),
            const Text("Pilih Durasi Latihan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            // Wrap agar tidak overflow di layar kecil
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [1, 2, 3].map((min) {
                bool isSelected = selectedDuration == min;
                return GestureDetector(
                  onTap: () => setState(() => selectedDuration = min),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: isSelected ? kMainTeal : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kMainTeal),
                      boxShadow: [if(isSelected) const BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,4))]
                    ),
                    child: Text("$min Menit", style: TextStyle(color: isSelected ? Colors.white : kMainTeal, fontWeight: FontWeight.bold)),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, 
              child: ElevatedButton(
                onPressed: _startExercise, 
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18), 
                  backgroundColor: kMainTeal, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                ), 
                child: const Text("MULAI", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
              )
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================
// GAME 3: REFLEKS (TETAP)
// ==================================================
class ReflexGame extends StatefulWidget { const ReflexGame({super.key}); @override State<ReflexGame> createState() => _ReflexGameState(); }
class _ReflexGameState extends State<ReflexGame> {
  final Random _random = Random(); bool isPlaying = false; int score = 0; int timeLeft = 30; Timer? _gameTimer; double top = 150; double left = 100; Color ballColor = Colors.pinkAccent; int highScore = 0; List<String> history = [];
  @override void initState() { super.initState(); _loadData(); }
  void _loadData() async { final prefs = await SharedPreferences.getInstance(); setState(() { highScore = prefs.getInt('reflex_highscore') ?? 0; history = prefs.getStringList('reflex_history') ?? []; }); }
  void _saveData(int newScore) async { final prefs = await SharedPreferences.getInstance(); if (newScore > highScore) { highScore = newScore; await prefs.setInt('reflex_highscore', highScore); } history.insert(0, "$newScore Poin - ${DateTime.now().hour}:${DateTime.now().minute}"); if (history.length > 5) history.removeLast(); await prefs.setStringList('reflex_history', history); setState(() {}); }
  void _startGame() { setState(() { isPlaying = true; score = 0; timeLeft = 30; _moveBall(); }); _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) { setState(() { if (timeLeft > 0) timeLeft--; else _endGame(); }); }); }
  void _endGame() { _gameTimer?.cancel(); setState(() => isPlaying = false); _saveData(score); _showGameOverDialog(); }
  void _moveBall() { setState(() { double maxWidth = MediaQuery.of(context).size.width - 100; double maxHeight = MediaQuery.of(context).size.height - 300; top = _random.nextDouble() * maxHeight + 100; left = _random.nextDouble() * maxWidth + 20; ballColor = Color.fromARGB(255, _random.nextInt(200), _random.nextInt(200), _random.nextInt(200)); }); }
  void _onTapBall() { if (isPlaying) { setState(() => score++); _moveBall(); } }
  void _showGameOverDialog() { showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(title: const Text("Waktu Habis! ⏰"), content: Column(mainAxisSize: MainAxisSize.min, children: [Text("Skor Kamu: $score", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kMainTeal)), const SizedBox(height: 8), Text("High Score: $highScore", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup")), ElevatedButton(onPressed: () { Navigator.pop(context); _startGame(); }, child: const Text("Main Lagi"))])); }
  @override void dispose() { _gameTimer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text("Tangkap Si Bulat")), body: isPlaying ? _buildGameUI() : _buildMenuUI()); }
  Widget _buildMenuUI() { return Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.touch_app, size: 80, color: Colors.pinkAccent), const SizedBox(height: 16), const Text("Tangkap Si Bulat!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const Text("Ketuk bola sebanyak mungkin dalam 30 detik.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)), const SizedBox(height: 30), Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.emoji_events, color: Colors.orange), const SizedBox(width: 8), Text("High Score: $highScore", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange))])), const SizedBox(height: 20), if (history.isNotEmpty) ...[const Align(alignment: Alignment.centerLeft, child: Text("Riwayat Skor Terakhir:", style: TextStyle(fontWeight: FontWeight.bold))), const SizedBox(height: 8), Container(height: 150, decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)), child: ListView.builder(itemCount: history.length, itemBuilder: (context, index) => ListTile(dense: true, leading: const Icon(Icons.history, size: 16, color: kIconGrey), title: Text(history[index]))))], const Spacer(), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _startGame, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.pinkAccent), child: const Text("MULAI MAIN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))))])); }
  Widget _buildGameUI() { return Stack(children: [Positioned(top: 20, left: 20, right: 20, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.pinkAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text("Skor: $score", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pinkAccent))), Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)), child: Row(children: [const Icon(Icons.timer, size: 20, color: kDarkGrey), const SizedBox(width: 4), Text("$timeLeft dtk", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kDarkGrey))]))])), Positioned(top: top, left: left, child: GestureDetector(onTap: _onTapBall, child: AnimatedContainer(duration: const Duration(milliseconds: 100), width: 70, height: 70, decoration: BoxDecoration(color: ballColor, shape: BoxShape.circle, boxShadow: [BoxShadow(color: ballColor.withOpacity(0.5), blurRadius: 10, spreadRadius: 2)]), child: const Icon(Icons.touch_app, color: Colors.white))))]); }
}