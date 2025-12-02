import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // PENTING: Untuk inisialisasi locale
import 'package:teman_asa/theme.dart';
import 'package:teman_asa/screens/behavior_analytics_screen.dart'; // PENTING: Pastikan file ini ada

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  List<Map<String, dynamic>> _logs = [];

  // Opsi Perilaku (Challenging Behaviors)
  final List<String> _behaviorTypes = [
    "Tantrum (Menangis/Teriak)",
    "Agresi (Memukul/Menendang)",
    "Self-Injurious (Menyakiti Diri)",
    "Repetitif (Flapping/Rocking)",
    "Non-compliance (Menolak Instruksi)",
    "Lainnya"
  ];

  final Map<String, IconData> _moodIcons = {
    "Senang": Icons.sentiment_very_satisfied,
    "Tenang": Icons.sentiment_neutral,
    "Cemas": Icons.sentiment_dissatisfied,
    "Marah": Icons.sentiment_very_dissatisfied,
    "Takut": Icons.error_outline
  };

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null); // PENTING: Mencegah error "Locale not initialized"
    _loadLogs();
  }

  void _loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? logsString = prefs.getString('behavior_logs');
    if (logsString != null) {
      setState(() {
        _logs = List<Map<String, dynamic>>.from(jsonDecode(logsString));
        _logs.sort((a, b) {
           // Handle sorting dengan aman (cegah crash jika format tanggal salah)
           try {
             return DateTime.parse(b['date']).compareTo(DateTime.parse(a['date']));
           } catch (e) {
             return 0; 
           }
        });
      });
    }
  }

  void _saveLogs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('behavior_logs', jsonEncode(_logs));
  }

  // --- FORM INPUT LOG ---
  // ... kode sebelumnya di dalam class _DiaryScreenState ...

  void _showAddLogForm() {
    String selectedBehavior = _behaviorTypes[0]; 
    TextEditingController antecedentController = TextEditingController();
    TextEditingController consequenceController = TextEditingController(); 
    String selectedMood = "Tenang";
    DateTime selectedTime = DateTime.now();
    TimeOfDay timeOfDay = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // WAJIB TRUE agar bisa full screen/resize
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding( // <--- TAMBAHKAN PADDING INI
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom // <--- INI KUNCINYA (Tinggi Keyboard)
            ),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85, // Kurangi dikit biar ga mentok atas banget
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
              child: Column(
                children: [
                  // Handle Bar
                  Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)), margin: const EdgeInsets.only(bottom: 20)),
                  
                  Text("Entry Jurnal Baru", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView( // ListView akan otomatis scroll jika keyboard muncul
                      children: [
                        // ... (LOGIKA INPUT WAKTU TETAP SAMA) ...
                        _buildSectionTitle("Waktu Kejadian"),
                        InkWell(
                          onTap: () async {
                             // ... (Kode DatePicker tetap sama) ...
                             final date = await showDatePicker(context: context, initialDate: selectedTime, firstDate: DateTime(2020), lastDate: DateTime.now());
                             if (date != null) {
                               final time = await showTimePicker(context: context, initialTime: timeOfDay);
                               if (time != null) {
                                 setModalState(() {
                                   selectedTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                                   timeOfDay = time;
                                 });
                               }
                             }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(15)),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, color: kMainTeal, size: 20),
                                const SizedBox(width: 12),
                                Text(DateFormat('EEEE, d MMM yyyy • HH:mm', 'id_ID').format(selectedTime), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ... (LOGIKA DROPDOWN BEHAVIOR TETAP SAMA) ...
                         _buildSectionTitle("Jenis Perilaku (Behavior)"),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(color: kSoftBeige, borderRadius: BorderRadius.circular(15)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedBehavior,
                              isExpanded: true,
                              items: _behaviorTypes.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
                              onChanged: (val) => setModalState(() => selectedBehavior = val!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // INPUT TEXT PEMICU (Keyboard aman disini)
                        _buildSectionTitle("Pemicu (Antecedent)"),
                        TextField(
                          controller: antecedentController,
                          decoration: const InputDecoration(hintText: "Apa yang terjadi SEBELUM perilaku?"),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),

                        // INPUT TEXT KONSEKUENSI (Keyboard aman disini)
                        _buildSectionTitle("Respon/Konsekuensi"),
                        TextField(
                          controller: consequenceController,
                          decoration: const InputDecoration(hintText: "Apa yang dilakukan SETELAHNYA?"),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),

                        // ... (LOGIKA MOOD TETAP SAMA) ...
                        _buildSectionTitle("Mood Anak"),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _moodIcons.entries.map((entry) {
                              bool isSelected = selectedMood == entry.key;
                              return GestureDetector(
                                onTap: () => setModalState(() => selectedMood = entry.key),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 16),
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: isSelected ? kMainTeal : Colors.grey.shade100,
                                        child: Icon(entry.value, color: isSelected ? Colors.white : Colors.grey),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(entry.key, style: TextStyle(fontSize: 12, color: isSelected ? kMainTeal : Colors.grey))
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20), // Tambahan space bawah biar ga mentok
                      ],
                    ),
                  ),

                  // TOMBOL SIMPAN
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                         // ... (LOGIKA SIMPAN TETAP SAMA) ...
                         setState(() {
                          _logs.insert(0, {
                            'id': DateTime.now().millisecondsSinceEpoch.toString(),
                            'date': selectedTime.toIso8601String(),
                            'behavior': selectedBehavior,
                            'antecedent': antecedentController.text,
                            'consequence': consequenceController.text,
                            'mood': selectedMood,
                          });
                          _logs.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
                        });
                        _saveLogs();
                        Navigator.pop(context);
                      },
                      child: const Text("SIMPAN LOG"),
                    ),
                  )
                ],
              ),
            ),
          );
        });
      }
    );
  }

  void _deleteLog(int index) {
    setState(() {
      _logs.removeAt(index);
    });
    _saveLogs();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kDarkGrey)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Logbook Perilaku"),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BehaviorAnalyticsScreen())),
            icon: const Icon(Icons.insights, color: kMainTeal),
            tooltip: "Lihat Analisis",
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddLogForm,
        backgroundColor: kMainTeal,
        icon: const Icon(Icons.add),
        label: const Text("Catat Perilaku"),
      ),
      body: _logs.isEmpty 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book_rounded, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text("Jurnal kosong.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                final date = DateTime.parse(log['date']);
                Color stripColor = kMainTeal;
                if (log['behavior'].contains("Agresi")) stripColor = Colors.redAccent;
                if (log['behavior'].contains("Tantrum")) stripColor = Colors.orangeAccent;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Container(width: 8, decoration: BoxDecoration(color: stripColor, borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)))),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(DateFormat('EEEE, d MMM • HH:mm', 'id_ID').format(date), 
                                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                                    GestureDetector(
                                      onTap: () => _deleteLog(index),
                                      child: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(log['behavior'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kDarkGrey)),
                                if (log['antecedent'].isNotEmpty) ...[
                                   const SizedBox(height: 8),
                                   Text("Pemicu: ${log['antecedent']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ]
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}