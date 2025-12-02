import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teman_asa/screens/diary_screen.dart';
import 'package:teman_asa/screens/music_screen.dart';
import 'package:teman_asa/screens/profile_screen.dart';
import 'package:teman_asa/theme.dart';
import 'package:intl/intl.dart'; // Pastikan package intl sudah ditambahkan di pubspec.yaml

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "Bunda";
  List<Map<String, dynamic>> scheduleList = [];
  
  // Variabel untuk data Analisis
  Map<String, int> moodCounts = {
    "Senang": 0, "Sedih": 0, "Marah": 0, "Tantrum": 0, "Tenang": 0, "Cemas": 0,
  };
  int totalLogs = 0;
  String dominantMood = "-";

  // Variabel Tanggal Jadwal
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadScheduleForDate(_selectedDate); // Load jadwal tanggal hari ini
    _loadDiaryAnalysis();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserData();
    _loadDiaryAnalysis();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? "Bunda";
    });
  }

  // --- LOGIKA JADWAL PER TANGGAL ---
  String _getDateKey(DateTime date) {
    return 'daily_schedule_${DateFormat('yyyy-MM-dd').format(date)}';
  }

  void _loadScheduleForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final String key = _getDateKey(date);
    final String? scheduleString = prefs.getString(key);
    
    setState(() {
      if (scheduleString != null) {
        scheduleList = List<Map<String, dynamic>>.from(jsonDecode(scheduleString));
      } else {
        // Jika jadwal tanggal ini kosong,
        // Opsi A: Kosongkan list
        scheduleList = []; 
        
        // Opsi B (Opsional): Jika hari ini, kasih template default
        if (isSameDay(date, DateTime.now())) {
           scheduleList = [
            {"time": "07:00", "activity": "Mandi Pagi", "isDone": false},
            {"time": "08:00", "activity": "Sarapan", "isDone": false},
          ];
          _saveSchedule(); // Simpan template default ini
        }
      }
    });
  }

  void _saveSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final String key = _getDateKey(_selectedDate);
    prefs.setString(key, jsonEncode(scheduleList));
  }

  void _changeDate(int days) {
    DateTime newDate = _selectedDate.add(Duration(days: days));
    
    // Aturan: Tidak bisa ke masa depan (besok dst)
    // Cek apakah newDate > Hari Ini (abaikan jam/menit)
    DateTime today = DateTime.now();
    DateTime todayMidnight = DateTime(today.year, today.month, today.day);
    DateTime newDateMidnight = DateTime(newDate.year, newDate.month, newDate.day);

    if (newDateMidnight.isAfter(todayMidnight)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Belum bisa melihat jadwal masa depan.")));
      return;
    }

    setState(() {
      _selectedDate = newDate;
    });
    _loadScheduleForDate(newDate);
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(), // Maksimal hari ini
    );
    if (picked != null && !isSameDay(picked, _selectedDate)) {
      setState(() {
        _selectedDate = picked;
      });
      _loadScheduleForDate(picked);
    }
  }

  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  // --- LOGIKA JADWAL ---
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
              decoration: const InputDecoration(hintText: "Nama Aktivitas"),
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

  void _editSchedule(int index) {
    var item = scheduleList[index];
    TextEditingController activityController = TextEditingController(text: item['activity']);
    // Parse jam lama
    var timeParts = item['time'].split(':');
    TimeOfDay selectedTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Jadwal"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: activityController, decoration: const InputDecoration(hintText: "Nama Aktivitas")),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final TimeOfDay? time = await showTimePicker(context: context, initialTime: selectedTime);
                if (time != null) selectedTime = time;
              },
              child: const Text("Ubah Jam"),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              if (activityController.text.isNotEmpty) {
                setState(() {
                  scheduleList[index] = {
                    "time": "${selectedTime.hour.toString().padLeft(2,'0')}:${selectedTime.minute.toString().padLeft(2,'0')}",
                    "activity": activityController.text,
                    "isDone": item['isDone'] // Status centang tetap
                  };
                  scheduleList.sort((a, b) => a['time'].compareTo(b['time']));
                });
                _saveSchedule();
                Navigator.pop(context);
              }
            },
            child: const Text("Update"),
          )
        ],
      ),
    );
  }

  // --- LOGIKA ANALISIS ---
  void _loadDiaryAnalysis() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('user_diaries');
    if (data != null) {
      List<dynamic> diaries = jsonDecode(data);
      Map<String, int> counts = {"Senang": 0, "Sedih": 0, "Marah": 0, "Tantrum": 0, "Tenang": 0, "Cemas": 0};
      for (var item in diaries) {
        String mood = item['mood'] ?? "Senang";
        if (counts.containsKey(mood)) counts[mood] = (counts[mood] ?? 0) + 1;
      }
      String dom = "-";
      int maxVal = 0;
      counts.forEach((k, v) {
        if (v > maxVal) { maxVal = v; dom = k; }
      });
      if (mounted) setState(() { moodCounts = counts; totalLogs = diaries.length; dominantMood = totalLogs > 0 ? dom : "-"; });
    }
  }

  @override
  Widget build(BuildContext context) {
    String initial = (userName.isNotEmpty) ? userName[0].toUpperCase() : "M";
    String dateText = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // --- HEADER ---
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
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())).then((_) => _loadUserData()),
                  child: CircleAvatar(radius: 28, backgroundColor: kMainTeal, child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- KARTU ANALISIS ---
            const Text("Analisis Perkembangan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildAnalysisCard(),
            
            const SizedBox(height: 24),

            // --- SHORTCUT ---
            Row(
              children: [
                Expanded(child: _shortcutCard("Diary Anak", Icons.book, kAccentCoral, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiaryScreen())).then((_) => _loadDiaryAnalysis()))),
                const SizedBox(width: 16),
                Expanded(child: _shortcutCard("Musik & Relaksasi", Icons.music_note, kAccentPurple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MusicScreen())))),
              ],
            ),
            const SizedBox(height: 24),

            // --- JADWAL HARIAN (DENGAN NAVIGASI TANGGAL) ---
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Jadwal Visual", style: Theme.of(context).textTheme.titleMedium),
                        IconButton(icon: const Icon(Icons.add_circle, color: kMainTeal), onPressed: _addScheduleItem),
                      ],
                    ),
                    
                    // Navigasi Tanggal
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(color: kSoftBeige, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, color: kDarkGrey), 
                            onPressed: () => _changeDate(-1), // Mundur 1 hari
                          ),
                          GestureDetector(
                            onTap: _pickDate, // Pilih tanggal lewat kalender
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: kMainTeal),
                                const SizedBox(width: 8),
                                Text(dateText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: kDarkGrey)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.chevron_right, color: isSameDay(_selectedDate, DateTime.now()) ? Colors.grey : kDarkGrey), 
                            onPressed: () => _changeDate(1), // Maju 1 hari
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    if (scheduleList.isEmpty)
                      const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Text("Belum ada jadwal.", style: TextStyle(color: Colors.grey))),
                    
                    // List Item Jadwal
                    ...scheduleList.asMap().entries.map((entry) {
                      int idx = entry.key;
                      var item = entry.value;
                      return Dismissible(
                        key: Key("${item['time']}_${item['activity']}"), // Key unik
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _deleteSchedule(idx),
                        background: Container(
                          alignment: Alignment.centerRight, 
                          padding: const EdgeInsets.only(right: 20), 
                          decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.delete, color: Colors.white)
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Checkbox(
                            value: item['isDone'],
                            activeColor: kMainTeal,
                            onChanged: (val) => _toggleSchedule(idx),
                          ),
                          title: Text(
                            "${item['time']} - ${item['activity']}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: item['isDone'] ? TextDecoration.lineThrough : null,
                              color: item['isDone'] ? Colors.grey : kDarkGrey
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                            onPressed: () => _editSchedule(idx),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ... (Widget _buildAnalysisCard, _getMoodColor, _shortcutCard SAMA seperti sebelumnya) ...
  Widget _buildAnalysisCard() {
    if (totalLogs == 0) {
      return Card(
        elevation: 2,
        color: kMainTeal.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.bar_chart_rounded, size: 48, color: kMainTeal.withOpacity(0.5)),
                const SizedBox(height: 12),
                const Text("Belum ada data perilaku.", style: TextStyle(fontWeight: FontWeight.bold, color: kDarkGrey)),
                const SizedBox(height: 4),
                const Text("Catat mood anak di Diary untuk melihat grafik perkembangan.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ),
      );
    }

    String dominantMood = moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    double dominantPercent = (moodCounts[dominantMood]! / totalLogs) * 100;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("Mood Dominan", style: TextStyle(fontSize: 12, color: Colors.grey)), Text(dominantMood, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _getMoodColor(dominantMood)))]),
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: kMainTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text("$totalLogs Catatan", style: const TextStyle(color: kMainTeal, fontWeight: FontWeight.bold, fontSize: 12))),
              ],
            ),
            const Divider(height: 24),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: moodCounts.entries.map((entry) {
                  double percentage = totalLogs > 0 ? (entry.value / totalLogs) : 0;
                  double barHeight = percentage * 100; 
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(duration: const Duration(milliseconds: 500), width: 14, height: barHeight < 5 && entry.value > 0 ? 5 : barHeight, decoration: BoxDecoration(color: _getMoodColor(entry.key), borderRadius: BorderRadius.circular(4))),
                      const SizedBox(height: 8),
                      Text(entry.key.substring(0, 3), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

   Color _getMoodColor(String mood) {
    switch (mood) {
      case "Marah": return Colors.redAccent;
      case "Sedih": return Colors.blueGrey;
      case "Senang": return Colors.green;
      case "Tenang": return Colors.lightBlue;
      case "Cemas": return Colors.purpleAccent;
      case "Tantrum": return Colors.black;
      default: return kMainTeal;
    }
  }

  Widget _shortcutCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Card(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Padding(padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16), child: Column(children: [Icon(icon, size: 32, color: color), const SizedBox(height: 12), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center)]))));
  }
}