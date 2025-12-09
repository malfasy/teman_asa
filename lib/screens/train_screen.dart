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
      backgroundColor: kSoftBeige, // Background konsisten
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 10),
            // HEADER
            Text(
              "Latihan di Rumah",
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 32, color: kDarkGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Aktivitas seru untuk melatih fokus & emosi",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // --- ROW 1: DUA KARTU KOTAK (SQUARE) ---
            Row(
              children: [
                Expanded(
                  child: _buildSquareCard(
                    title: "Fokus & Kontrol",
                    subtitle: "Melatih Impuls",
                    duration: "15 SEC",
                    icon: Icons.timer,
                    // Warna kartu: Coral (variasi), tapi aksennya Teal
                    cardColor: kAccentCoral.withOpacity(0.15), 
                    iconColor: kAccentCoral,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FocusGame())),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSquareCard(
                    title: "Relaksasi Napas",
                    subtitle: "Latihan Tenang",
                    duration: "1-3 MIN",
                    icon: Icons.air,
                    // Warna kartu: Light Blue (variasi)
                    cardColor: Colors.lightBlue.withOpacity(0.15),
                    iconColor: Colors.lightBlue,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BreathingGame())),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),

            // --- ROW 2: KARTU LEBAR (WIDE) ---
            _buildWideCard(
              title: "Tangkap Si Bulat",
              subtitle: "Melatih Refleks & Motorik",
              duration: "30 DETIK",
              icon: Icons.touch_app,
              // Warna kartu: Pink/Red (variasi)
              cardColor: Colors.redAccent.withOpacity(0.1),
              iconColor: Colors.redAccent,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReflexGame())),
            ),

            const SizedBox(height: 16),

            // --- ROW 3: KARTU LEBAR (COMING SOON) ---
             _buildWideCard(
              title: "Memory Game",
              subtitle: "Segera Hadir",
              duration: "? MIN",
              icon: Icons.extension,
              // Warna kartu: Purple (variasi)
              cardColor: kAccentPurple.withOpacity(0.15),
              iconColor: kAccentPurple,
              onTap: () {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Modul ini sedang dikembangkan!")));
              },
            ),
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGET KARTU KOTAK (SQUARE) - ANTI OVERFLOW ---
  Widget _buildSquareCard({
    required String title,
    required String subtitle,
    required String duration,
    required IconData icon,
    required Color cardColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      // Tinggi dibuat sedikit lebih fleksibel agar tidak terlalu mepet
      constraints: const BoxConstraints(minHeight: 210), 
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        // Border halus dengan warna ikon agar serasi
        border: Border.all(color: iconColor.withOpacity(0.2)), 
      ),
      child: Stack(
        children: [
          // Dekorasi Blob
          Positioned(
            right: -20, top: -20,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.4), shape: BoxShape.circle),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            // Gunakan Column dengan MainAxisSize.min agar pas dengan konten
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Header
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                
                const SizedBox(height: 40), // Jarak flexible ke teks

                // Teks Judul (FittedBox mencegah overflow jika teks terlalu panjang)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: kDarkGrey,
                      fontFamily: 'NerkoOne'
                    ),
                  ),
                ),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: kDarkGrey)),
                
                const SizedBox(height: 12),
                
                // Footer: Durasi & Tombol Start
                // Gunakan Wrap atau Flexible agar tidak overflow di layar kecil
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(duration, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: kDarkGrey)),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          // WARNA TOMBOL DIUBAH KE kMainTeal (Dominan)
                          color: kMainTeal, 
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text("START", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET KARTU LEBAR (WIDE) - ANTI OVERFLOW ---
  Widget _buildWideCard({
    required String title,
    required String subtitle,
    required String duration,
    required IconData icon,
    required Color cardColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Stack(
        children: [
          // Dekorasi Gelombang
          Positioned(
            right: -10, top: 0, bottom: 0,
            child: Container(
              width: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(60), bottomLeft: Radius.circular(60)),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              children: [
                // Icon Besar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),
                
                // Teks (Expanded agar mengisi ruang)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // FittedBox untuk judul agar aman
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kDarkGrey, fontFamily: 'NerkoOne')),
                      ),
                      // Flexible untuk subtitle agar bisa wrap jika kepanjangan
                      Flexible(
                        child: Text(subtitle, style: const TextStyle(fontSize: 12, color: kDarkGrey), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),

                // Tombol Start
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      // WARNA TOMBOL DIUBAH KE kMainTeal (Dominan)
                      color: kMainTeal, 
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text("START", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================
// GAME LOGIC (FocusGame, BreathingGame, ReflexGame) 
// TETAP SAMA SEPERTI SEBELUMNYA
// ==================================================
class FocusGame extends StatefulWidget { const FocusGame({super.key}); @override State<FocusGame> createState() => _FocusGameState(); }
class _FocusGameState extends State<FocusGame> {
  double prog = 0.0; Timer? t; bool isComplete = false;
  void start() { if (isComplete) return; t = Timer.periodic(const Duration(milliseconds: 150), (_) { setState(() { prog += 0.015; if (prog >= 1) { t?.cancel(); prog = 1; isComplete = true; _showSuccessDialog(); } }); }); }
  void stop() { if (isComplete) return; t?.cancel(); setState(() { prog = 0; }); }
  void _showSuccessDialog() { showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(title: const Text("Hebat! 🎉"), content: const Text("Kamu berhasil fokus sampai selesai."), actions: [TextButton(onPressed: () { Navigator.pop(context); setState(() { isComplete = false; prog = 0; }); }, child: const Text("Main Lagi")), ElevatedButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: const Text("Selesai"))])); }
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text("Latihan Fokus")), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Text("Tekan & Tahan Tombol", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 10), const Text("Jangan lepas sampai penuh!", style: TextStyle(color: Colors.grey)), const SizedBox(height: 50), GestureDetector(onTapDown: (_) => start(), onTapUp: (_) => stop(), child: Container(width: 240, height: 240, decoration: BoxDecoration(color: isComplete ? Colors.green : Colors.orangeAccent, shape: BoxShape.circle, boxShadow: [BoxShadow(color: (isComplete ? Colors.green : Colors.orangeAccent).withOpacity(0.4), blurRadius: 30, spreadRadius: 10)]), child: Center(child: isComplete ? const Icon(Icons.check, size: 80, color: Colors.white) : const Text("TAHAN", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))))), const SizedBox(height: 60), Padding(padding: const EdgeInsets.symmetric(horizontal: 50), child: LinearProgressIndicator(value: prog, minHeight: 25, borderRadius: BorderRadius.circular(20), color: Colors.green, backgroundColor: Colors.grey[200]))]))); }
}

class BreathingGame extends StatefulWidget {
  const BreathingGame({super.key});
  @override State<BreathingGame> createState() => _BreathingGameState();
}
class _BreathingGameState extends State<BreathingGame> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _sizeAnimation;
  bool isRunning = false; int selectedDuration = 1; int remainingSeconds = 60; Timer? _timer; String _instruction = "Siap?";
  @override void initState() { super.initState(); _animController = AnimationController(vsync: this, duration: const Duration(seconds: 4)); _sizeAnimation = Tween<double>(begin: 150.0, end: 300.0).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut)); }
  void _startExercise() { setState(() { isRunning = true; remainingSeconds = selectedDuration * 60; _instruction = "Tarik Napas..."; }); _runBreathingCycle(); _timer = Timer.periodic(const Duration(seconds: 1), (timer) { setState(() { if (remainingSeconds > 0) remainingSeconds--; else _stopExercise(); }); }); }
  Future<void> _runBreathingCycle() async { if (!mounted || !isRunning) return; setState(() => _instruction = "Tarik Napas..."); await _animController.forward(); if (!mounted || !isRunning) return; setState(() => _instruction = "Tahan..."); await Future.delayed(const Duration(seconds: 4)); if (!mounted || !isRunning) return; setState(() => _instruction = "Hembuskan..."); await _animController.reverse(); if (!mounted || !isRunning) return; _runBreathingCycle(); }
  void _stopExercise() { _timer?.cancel(); _animController.stop(); _animController.reset(); setState(() { isRunning = false; remainingSeconds = selectedDuration * 60; _instruction = "Siap?"; }); if (mounted) showDialog(context: context, builder: (_) => AlertDialog(title: const Text("Selesai 🧘"), content: const Text("Semoga lebih tenang."), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))])); }
  @override void dispose() { _animController.dispose(); _timer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text("Relaksasi")), body: isRunning ? _buildRunningUI() : _buildSetupUI()); }
  Widget _buildRunningUI() { return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text("${(remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds % 60).toString().padLeft(2, '0')}", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: kDarkGrey)), const SizedBox(height: 20), Text(_instruction, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kMainTeal)), const SizedBox(height: 30), SizedBox(width: 320, height: 320, child: Center(child: AnimatedBuilder(animation: _animController, builder: (context, child) { return Container(width: _sizeAnimation.value, height: _sizeAnimation.value, decoration: BoxDecoration(color: kMainTeal.withOpacity(0.3), shape: BoxShape.circle, border: Border.all(color: kMainTeal, width: 2)), child: Center(child: Container(width: _sizeAnimation.value * 0.8, height: _sizeAnimation.value * 0.8, decoration: const BoxDecoration(color: kMainTeal, shape: BoxShape.circle), child: const Icon(Icons.spa, color: Colors.white, size: 50)))); }))), const SizedBox(height: 30), OutlinedButton(onPressed: _stopExercise, child: const Text("Berhenti", style: TextStyle(color: Colors.red)))])); }
  Widget _buildSetupUI() { return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.self_improvement, size: 100, color: kMainTeal), const SizedBox(height: 24), const Text("Pilih Durasi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 24), Row(mainAxisAlignment: MainAxisAlignment.center, children: [1, 2, 3].map((min) => Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: ChoiceChip(label: Text("$min Menit"), selected: selectedDuration == min, onSelected: (b) => setState(() => selectedDuration = min), selectedColor: kMainTeal, labelStyle: TextStyle(color: selectedDuration == min ? Colors.white : Colors.black)))).toList()), const SizedBox(height: 40), ElevatedButton(onPressed: _startExercise, child: const Text("MULAI"))])); }
}

class ReflexGame extends StatefulWidget { const ReflexGame({super.key}); @override State<ReflexGame> createState() => _ReflexGameState(); }
class _ReflexGameState extends State<ReflexGame> {
  final Random _random = Random(); bool isPlaying = false; int score = 0; int timeLeft = 30; Timer? _gameTimer; double top = 150; double left = 100; Color ballColor = Colors.pinkAccent; int highScore = 0;
  @override void initState() { super.initState(); _loadData(); }
  void _loadData() async { final prefs = await SharedPreferences.getInstance(); setState(() { highScore = prefs.getInt('reflex_highscore') ?? 0; }); }
  void _saveData() async { final prefs = await SharedPreferences.getInstance(); if (score > highScore) { highScore = score; await prefs.setInt('reflex_highscore', highScore); } }
  void _startGame() { setState(() { isPlaying = true; score = 0; timeLeft = 30; _moveBall(); }); _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) { setState(() { if (timeLeft > 0) timeLeft--; else _endGame(); }); }); }
  void _endGame() { _gameTimer?.cancel(); setState(() => isPlaying = false); _saveData(); _showGameOverDialog(); }
  void _moveBall() { setState(() { double maxWidth = MediaQuery.of(context).size.width - 100; double maxHeight = MediaQuery.of(context).size.height - 300; top = _random.nextDouble() * maxHeight + 100; left = _random.nextDouble() * maxWidth + 20; ballColor = Color.fromARGB(255, _random.nextInt(200), _random.nextInt(200), _random.nextInt(200)); }); }
  void _onTapBall() { if (isPlaying) { setState(() => score++); _moveBall(); } }
  void _showGameOverDialog() { showDialog(context: context, barrierDismissible: false, builder: (_) => AlertDialog(title: const Text("Waktu Habis!"), content: Text("Skor: $score\nHigh Score: $highScore"), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup")), ElevatedButton(onPressed: () { Navigator.pop(context); _startGame(); }, child: const Text("Main Lagi"))])); }
  @override void dispose() { _gameTimer?.cancel(); super.dispose(); }
  @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text("Tangkap Si Bulat")), body: isPlaying ? _buildGameUI() : _buildMenuUI()); }
  Widget _buildMenuUI() { return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.touch_app, size: 80, color: Colors.pinkAccent), const SizedBox(height: 16), Text("High Score: $highScore", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)), const SizedBox(height: 30), ElevatedButton(onPressed: _startGame, child: const Text("MULAI MAIN"))])); }
  Widget _buildGameUI() { return Stack(children: [Positioned(top: 20, left: 20, child: Text("Skor: $score", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))), Positioned(top: 20, right: 20, child: Text("$timeLeft dtk", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))), Positioned(top: top, left: left, child: GestureDetector(onTap: _onTapBall, child: CircleAvatar(radius: 35, backgroundColor: ballColor, child: const Icon(Icons.touch_app, color: Colors.white))))]); }
}