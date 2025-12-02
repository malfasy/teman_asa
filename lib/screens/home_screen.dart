import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teman_asa/screens/diary_screen.dart';
import 'package:teman_asa/screens/music_screen.dart';
import 'package:teman_asa/screens/profile_screen.dart';
import 'package:teman_asa/theme.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "Bunda";
  
  // --- VARIABEL JADWAL ---
  List<Map<String, dynamic>> scheduleList = [];
  DateTime selectedDate = DateTime.now(); // Tanggal yang sedang dilihat

  // --- VARIABEL ANALISIS ---
  Map<String, int> moodCounts = {
    "Senang": 0, "Sedih": 0, "Marah": 0, 
    "Tantrum": 0, "Tenang": 0, "Cemas": 0,
  };
  int totalLogs = 0;
  String dominantMood = "-";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSchedule(); // Load jadwal sesuai tanggal (hari ini)
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

  String get _scheduleKey {
    return 'daily_schedule_${DateFormat('yyyy-MM-dd').format(selectedDate)}';
  }

  bool get _isToday {
    final now = DateTime.now();
    return selectedDate.year == now.year && 
           selectedDate.month == now.month && 
           selectedDate.day == now.day;
  }

  void _loadSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final String? scheduleString = prefs.getString(_scheduleKey);
    
    setState(() {
      if (scheduleString != null) {
        scheduleList = List<Map<String, dynamic>>.from(jsonDecode(scheduleString));
      } else {
      
        if (_isToday) {
          scheduleList = [
            {"time": "07:00", "activity": "Mandi Pagi", "isDone": false},
            {"time": "08:00", "activity": "Sarapan", "isDone": false},
          ];
        } else {
          scheduleList = [];
        }
      }
    });
  }

  void _saveSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_scheduleKey, jsonEncode(scheduleList));
  }

  // Ganti Hari (Prev/Next)
  void _changeDate(int days) {
    DateTime newDate = selectedDate.add(Duration(days: days));
    // Cegah pindah ke masa depan (besok dst)
    if (newDate.isAfter(DateTime.now())) return;

    setState(() {
      selectedDate = newDate;
    });
    _loadSchedule(); // Reload data sesuai tanggal baru
  }

  // Pilih Tanggal dari Kalender
  void _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020), // Bisa lihat sampai tahun 2020
      lastDate: DateTime.now(),  // Maksimal hari ini
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: kMainTeal),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _loadSchedule();
    }
  }

  // Tambah atau Edit Item Jadwal
  void _showScheduleDialog({int? index}) {
    TimeOfDay initialTime = TimeOfDay.now();
    TextEditingController activityController = TextEditingController();

    // Jika Edit (index tidak null), isi data lama
    if (index != null) {
      activityController.text = scheduleList[index]['activity'];
      // Parse jam lama "HH:mm"
      final parts = scheduleList[index]['time'].split(':');
      initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    TimeOfDay selectedTime = initialTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( // StatefulBuilder agar jam bisa update di dialog
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(index == null ? "Tambah Jadwal" : "Edit Jadwal"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: activityController,
                  decoration: const InputDecoration(hintText: "Nama Aktivitas"),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text("Jam: "),
                    TextButton(
                      onPressed: () async {
                        final TimeOfDay? time = await showTimePicker(context: context, initialTime: selectedTime);
                        if (time != null) {
                          setDialogState(() => selectedTime = time);
                        }
                      },
                      child: Text(
                        selectedTime.format(context),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: kMainTeal, fontSize: 16),
                      ),
                    ),
                  ],
                )
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
              ElevatedButton(
                onPressed: () {
                  if (activityController.text.isNotEmpty) {
                    final timeString = "${selectedTime.hour.toString().padLeft(2,'0')}:${selectedTime.minute.toString().padLeft(2,'0')}";
                    
                    setState(() {
                      if (index == null) {
                        // TAMBAH BARU
                        scheduleList.add({
                          "time": timeString,
                          "activity": activityController.text,
                          "isDone": false
                        });
                      } else {
                        // UPDATE LAMA
                        scheduleList[index]['time'] = timeString;
                        scheduleList[index]['activity'] = activityController.text;
                      }
                      // Sort ulang biar urut jam
                      scheduleList.sort((a, b) => a['time'].compareTo(b['time']));
                    });
                    _saveSchedule();
                    Navigator.pop(context);
                  }
                },
                child: const Text("Simpan"),
              )
            ],
          );
        }
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

  // --- LOGIKA ANALISIS (SAMA SEPERTI SEBELUMNYA) ---
  void _loadDiaryAnalysis() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('user_diaries');
    if (data != null) {
      List<dynamic> diaries = jsonDecode(data);
      Map<String, int> counts = { "Senang": 0, "Sedih": 0, "Marah": 0, "Tantrum": 0, "Tenang": 0, "Cemas": 0 };
      for (var item in diaries) {
        String mood = item['mood'] ?? "Senang";
        if (counts.containsKey(mood)) counts[mood] = (counts[mood] ?? 0) + 1;
      }
      String dom = "-";
      int maxVal = 0;
      counts.forEach((k, v) { if (v > maxVal) { maxVal = v; dom = k; } });

      if (mounted) {
        setState(() { moodCounts = counts; totalLogs = diaries.length; dominantMood = totalLogs > 0 ? dom : "-"; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String initial = (userName.isNotEmpty) ? userName[0].toUpperCase() : "M";

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
                    Text("How's Today?", style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())).then((_) => _loadUserData()),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: kMainTeal,
                    child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- SHORTCUTS ---
            Row(
              children: [
                Expanded(
                  child: _shortcutCard(
                    "Diary Anak", Icons.book, kAccentCoral, 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiaryScreen())).then((_) => _loadDiaryAnalysis())
                  )
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _shortcutCard(
                    "Musik & Relaksasi", Icons.music_note, kAccentPurple, 
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MusicScreen()))
                  )
                ),
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
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: kMainTeal, size: 28),
                          onPressed: () => _showScheduleDialog(),
                        )
                      ],
                    ),
                    const Divider(),
                    
                    // NAVIGASI TANGGAL (BARU)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 18, color: kIconGrey),
                          onPressed: () => _changeDate(-1), // Mundur 1 hari
                        ),
                        GestureDetector(
                          onTap: _pickDate, // Klik tanggal buat buka kalender
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: kMainTeal),
                              const SizedBox(width: 8),
                              Text(
                                _isToday 
                                  ? "Hari Ini, ${DateFormat('d MMM').format(selectedDate)}"
                                  : DateFormat('EEEE, d MMM yyyy', 'id_ID').format(selectedDate), // Perlu locale ID kalau mau nama hari Indo, atau default English
                                style: const TextStyle(fontWeight: FontWeight.bold, color: kDarkGrey),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 18),
                          // Disable jika hari ini (cegah ke masa depan)
                          onPressed: _isToday ? null : () => _changeDate(1), 
                          color: _isToday ? Colors.grey.withOpacity(0.3) : kIconGrey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    // LIST JADWAL
                    if (scheduleList.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            _isToday ? "Belum ada jadwal hari ini." : "Tidak ada jadwal pada tanggal ini.", 
                            style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)
                          )
                        ),
                      ),
                    
                    ...scheduleList.asMap().entries.map((entry) {
                      int idx = entry.key;
                      var item = entry.value;
                      return Dismissible(
                        key: Key("${item['time']}_${item['activity']}_$idx"), // Key unik
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                           // Konfirmasi hapus
                           return await showDialog(
                             context: context,
                             builder: (ctx) => AlertDialog(
                               title: const Text("Hapus Jadwal?"),
                               actions: [
                                 TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
                                 TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
                               ],
                             )
                           );
                        },
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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
                          // Tombol Edit
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, size: 18, color: kIconGrey),
                            onPressed: () => _showScheduleDialog(index: idx),
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

  // --- WIDGET GRAFIK ---
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
                const Text(
                  "Belum ada data perilaku.",
                  style: TextStyle(fontWeight: FontWeight.bold, color: kDarkGrey),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Catat mood anak di Diary untuk melihat grafik perkembangan.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Mood Dominan", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(dominantMood, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _getMoodColor(dominantMood))),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: kMainTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text("$totalLogs Catatan", style: const TextStyle(color: kMainTeal, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
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
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 14,
                        height: barHeight < 5 && entry.value > 0 ? 5 : barHeight,
                        decoration: BoxDecoration(color: _getMoodColor(entry.key), borderRadius: BorderRadius.circular(4)),
                      ),
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
      case "Marah": return Colors.red;
      case "Tantrum": return Colors.redAccent;
      case "Sedih": return Colors.orange;
      case "Cemas": return Colors.amber;
      case "Senang": return Colors.green;
      case "Tenang": return kMainTeal;
      default: return Colors.grey;
    }
  }

  Widget _shortcutCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}