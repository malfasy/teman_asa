import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; 
import 'package:intl/date_symbol_data_local.dart'; 
import 'package:teman_asa/screens/diary_screen.dart';
import 'package:teman_asa/screens/music_screen.dart';
import 'package:teman_asa/screens/video_player_screen.dart';
import 'package:teman_asa/screens/profile_screen.dart';
import 'package:teman_asa/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "Bunda";
  Map<String, List<dynamic>> _allSchedules = {};
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null); 
    _loadUserData();
    _loadSchedules();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? "Bunda";
    });
  }

  void _loadSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    final String? dataString = prefs.getString('schedule_history');
    if (dataString != null) {
      setState(() {
        _allSchedules = Map<String, List<dynamic>>.from(jsonDecode(dataString));
      });
    }
  }

  void _saveSchedules() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('schedule_history', jsonEncode(_allSchedules));
  }

  String _getDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  List<dynamic> get _currentScheduleList {
    String key = _getDateKey(_selectedDate);
    return _allSchedules[key] ?? [];
  }
  
  // --- FORM JADWAL ---
  void _showScheduleForm({int? indexToEdit}) {
    String key = _getDateKey(_selectedDate);
    List<dynamic> currentList = List.from(_allSchedules[key] ?? []);

    TimeOfDay selectedTime = indexToEdit != null 
        ? _parseTime(currentList[indexToEdit]['time']) 
        : TimeOfDay.now();
    
    TextEditingController activityController = TextEditingController(
        text: indexToEdit != null ? currentList[indexToEdit]['activity'] : ""
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 10
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50, height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  
                  Text(
                    indexToEdit != null ? "Edit Jadwal" : "Tambah Kegiatan Baru",
                    style: Theme.of(context).textTheme.titleMedium
                  ),
                  const SizedBox(height: 20),
                  
                  TextField(
                    controller: activityController,
                    autofocus: true, 
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText: "Nama aktivitas (misal: Makan Siang)",
                      filled: true,
                      fillColor: kSoftBeige,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.event_note, color: kMainTeal),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  InkWell(
                    onTap: () async {
                      final TimeOfDay? time = await showTimePicker(context: context, initialTime: selectedTime);
                      if (time != null) {
                        setModalState(() => selectedTime = time);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: kDarkGrey),
                          const SizedBox(width: 12),
                          const Text("Pukul: ", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            "${selectedTime.hour.toString().padLeft(2,'0')}:${selectedTime.minute.toString().padLeft(2,'0')}",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kMainTeal),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (activityController.text.isNotEmpty) {
                          String timeString = "${selectedTime.hour.toString().padLeft(2,'0')}:${selectedTime.minute.toString().padLeft(2,'0')}";
                          
                          setState(() {
                            Map<String, dynamic> newItem = {
                              "time": timeString,
                              "activity": activityController.text,
                              "isDone": indexToEdit != null ? currentList[indexToEdit]['isDone'] : false
                            };

                            if (indexToEdit != null) {
                              currentList[indexToEdit] = newItem; 
                            } else {
                              currentList.add(newItem);
                            }

                            currentList.sort((a, b) => a['time'].compareTo(b['time']));
                            _allSchedules[key] = currentList;
                          });
                          _saveSchedules();
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("SIMPAN"),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  void _deleteSchedule(int index) {
    String key = _getDateKey(_selectedDate);
    List<dynamic> currentList = List.from(_allSchedules[key] ?? []);
    setState(() {
      currentList.removeAt(index);
      if (currentList.isEmpty) {
        _allSchedules.remove(key);
      } else {
        _allSchedules[key] = currentList;
      }
    });
    _saveSchedules();
  }

  void _toggleSchedule(int index) {
    String key = _getDateKey(_selectedDate);
    List<dynamic> currentList = List.from(_allSchedules[key] ?? []);
    setState(() {
      currentList[index]['isDone'] = !currentList[index]['isDone'];
      _allSchedules[key] = currentList;
    });
    _saveSchedules();
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year && 
           _selectedDate.month == now.month && 
           _selectedDate.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    String initial = (userName.isNotEmpty) ? userName[0].toUpperCase() : "M";
    String dateTitle = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Header Profil
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Halo, $userName! 👋", style: Theme.of(context).textTheme.bodyLarge),
                    Text("Tetap Semangat!", style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: kMainTeal,
                    child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- WIDGET JADWAL (FIX OVERFLOW: FITTEDBOX + FONT KECIL) ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: kMainTeal),
                        onPressed: () => _changeDate(-1),
                      ),
                      
                      // SOLUSI UTAMA DI SINI:
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              _isToday ? "Jadwal Hari Ini" : "Riwayat Jadwal",
                              style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            // FittedBox akan mengecilkan teks secara otomatis jika terlalu lebar
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                dateTitle, 
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 14, // Font dikecilkan sedikit dari 16 ke 14
                                  color: kDarkGrey
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: kMainTeal),
                        onPressed: () => _changeDate(1),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  if (_currentScheduleList.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 40, color: kMainTeal.withOpacity(0.3)),
                          const SizedBox(height: 8),
                          Text(
                            _isToday ? "Belum ada jadwal.\nYuk tambah kegiatan!" : "Tidak ada jadwal.",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._currentScheduleList.asMap().entries.map((entry) {
                      int idx = entry.key;
                      var item = entry.value;
                      bool isDone = item['isDone'] ?? false;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDone ? kSoftBeige : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDone ? Colors.transparent : Colors.grey.shade200)
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () => _toggleSchedule(idx),
                              child: Container(
                                width: 24, height: 24,
                                decoration: BoxDecoration(
                                  color: isDone ? kMainTeal : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: isDone ? kMainTeal : kIconGrey, width: 2)
                                ),
                                child: isDone ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['activity'], 
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 16,
                                      decoration: isDone ? TextDecoration.lineThrough : null,
                                      color: isDone ? Colors.grey : kDarkGrey
                                    )
                                  ),
                                  Text(item['time'], style: const TextStyle(color: kMainTeal, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),

                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20, color: Colors.orange),
                                  onPressed: () => _showScheduleForm(indexToEdit: idx),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                  onPressed: () => _deleteSchedule(idx),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    }),

                  if (_selectedDate.isAfter(DateTime.now().subtract(const Duration(days: 1))))
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showScheduleForm(),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("Tambah Kegiatan"),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: const BorderSide(color: kMainTeal)
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(child: _shortcutCard("Diary Anak", Icons.book, kAccentCoral, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DiaryScreen())))),
                const SizedBox(width: 16),
                Expanded(child: _shortcutCard("Musik & Relaksasi", Icons.music_note, kAccentPurple, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MusicScreen())))),
              ],
            ),
            const SizedBox(height: 20),

            Text("Direkomendasikan", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            _videoCard("Memahami Tantrum", "Video 5 menit oleh Psikolog", "u-s5rCzx4bY"),
          ],
        ),
      ),
    );
  }

  Widget _shortcutCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))]
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kDarkGrey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _videoCard(String title, String subtitle, String videoId) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPlayerScreen(videoId: videoId, title: '',))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))]
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12), 
              decoration: BoxDecoration(color: kMainTeal.withOpacity(0.15), borderRadius: BorderRadius.circular(16)), 
              child: const Icon(Icons.play_arrow_rounded, color: kMainTeal, size: 28)
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kDarkGrey)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}