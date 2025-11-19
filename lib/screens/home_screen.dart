import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teman_asa/screens/diary_screen.dart'; // Kita buat nanti
import 'package:teman_asa/screens/music_screen.dart'; // Kita buat nanti
import 'package:teman_asa/screens/video_player_screen.dart'; // Kita buat nanti
import 'package:teman_asa/screens/profile_screen.dart';
import 'package:teman_asa/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "Bunda";
  List<Map<String, dynamic>> scheduleList = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSchedule();
  }

  // 1. Load Data User & Jadwal dari HP
  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? "Bunda";
    });
  }

  void _loadSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final String? scheduleString = prefs.getString('daily_schedule');
    if (scheduleString != null) {
      setState(() {
        scheduleList = List<Map<String, dynamic>>.from(jsonDecode(scheduleString));
      });
    } else {
      // Data default jika kosong
      scheduleList = [
        {"time": "07:00", "activity": "Mandi Pagi", "isDone": false},
        {"time": "08:00", "activity": "Sarapan", "isDone": false},
      ];
    }
  }

  // 2. Fungsi Tambah Jadwal
  void _addScheduleItem() {
    TimeOfDay selectedTime = TimeOfDay.now();
    TextEditingController activityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Tambah Jadwal", style: Theme.of(context).textTheme.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: activityController,
              decoration: const InputDecoration(hintText: "Nama Aktivitas (misal: Terapi)"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final TimeOfDay? time = await showTimePicker(context: context, initialTime: selectedTime);
                if (time != null) selectedTime = time;
              },
              child: const Text("Pilih Jam"),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              if (activityController.text.isNotEmpty) {
                setState(() {
                  scheduleList.add({
                    "time": "${selectedTime.hour.toString().padLeft(2,'0')}:${selectedTime.minute.toString().padLeft(2,'0')}",
                    "activity": activityController.text,
                    "isDone": false
                  });
                  // Urutkan berdasarkan waktu
                  scheduleList.sort((a, b) => a['time'].compareTo(b['time']));
                });
                _saveSchedule();
                Navigator.pop(context);
              }
            },
            child: const Text("Simpan"),
          )
        ],
      ),
    );
  }

  void _saveSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('daily_schedule', jsonEncode(scheduleList));
  }

  void _toggleSchedule(int index) {
    setState(() {
      scheduleList[index]['isDone'] = !scheduleList[index]['isDone'];
    });
    _saveSchedule();
  }

  void _deleteSchedule(int index) {
    setState(() {
      scheduleList.removeAt(index);
    });
    _saveSchedule();
  }

  @override
  Widget build(BuildContext context) {
    // Fix Profile Icon: Ambil huruf pertama, handle jika kosong
    String initial = (userName.isNotEmpty) ? userName[0].toUpperCase() : "M";

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Halo, $userName!", style: Theme.of(context).textTheme.bodyLarge),
                    Text("Apa kabar hari ini?", style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: kMainTeal,
                    child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Jadwal Harian (INTERAKTIF) ---
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Jadwal Hari ini", style: Theme.of(context).textTheme.titleMedium),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: kMainTeal),
                          onPressed: _addScheduleItem,
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    // List Jadwal
                    if (scheduleList.isEmpty)
                      const Text("Belum ada jadwal.", style: TextStyle(color: Colors.grey)),
                    
                    ...scheduleList.asMap().entries.map((entry) {
                      int idx = entry.key;
                      var item = entry.value;
                      return Dismissible(
                        key: Key(item['time'] + item['activity']),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _deleteSchedule(idx),
                        background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            "${item['time']} - ${item['activity']}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: item['isDone'] ? TextDecoration.lineThrough : null,
                              color: item['isDone'] ? Colors.grey : kDarkGrey
                            ),
                          ),
                          value: item['isDone'],
                          activeColor: kMainTeal,
                          onChanged: (val) => _toggleSchedule(idx),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Shortcut ---
            Row(
              children: [
                Expanded(
                  child: _shortcutCard(
                    "Diary Anak", 
                    Icons.book, 
                    kAccentCoral, 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiaryScreen()))
                  )
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _shortcutCard(
                    "Musik & Relaksasi", 
                    Icons.music_note, 
                    kAccentPurple, 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MusicScreen()))
                  )
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- Rekomendasi Video (Playable) ---
            Text("Direkomendasikan", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            _videoCard(
              "Memahami Tantrum", 
              "Video 5 menit oleh Psikolog", 
              "u-s5rCzx4bY" // ID YouTube
            ),
          ],
        ),
      ),
    );
  }

  Widget _shortcutCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _videoCard(String title, String subtitle, String videoId) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPlayerScreen(videoId: videoId, title: '',))),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(10), 
            decoration: BoxDecoration(color: kMainTeal.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), 
            child: const Icon(Icons.play_arrow_rounded, color: kMainTeal, size: 30)
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
        ),
      ),
    );
  }
}