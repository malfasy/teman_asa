import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:teman_asa/theme.dart';

class BehaviorAnalyticsScreen extends StatefulWidget {
  const BehaviorAnalyticsScreen({super.key});

  @override
  State<BehaviorAnalyticsScreen> createState() => _BehaviorAnalyticsScreenState();
}

class _BehaviorAnalyticsScreenState extends State<BehaviorAnalyticsScreen> {
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;

  // Variabel untuk menyimpan hasil analisis
  List<int> _weeklyCounts = List.filled(7, 0); 
  Map<String, int> _behaviorCounts = {};
  Map<String, int> _timeOfDayCounts = {
    "Pagi (06-11)": 0,
    "Siang (12-15)": 0,
    "Sore (16-18)": 0,
    "Malam (19-22)": 0,
    "Lainnya": 0
  };
  String _topAntecedent = "-";

  @override
  void initState() {
    super.initState();
    _loadAndAnalyzeData();
  }

  void _loadAndAnalyzeData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? logsString = prefs.getString('behavior_logs');
    
    if (logsString != null) {
      List<dynamic> decoded = jsonDecode(logsString);
      setState(() {
        _logs = List<Map<String, dynamic>>.from(decoded);
        _processAnalytics();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _processAnalytics() {
    if (_logs.isEmpty) return;
    
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    startOfWeek = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 7));

    // Reset counters
    _weeklyCounts = List.filled(7, 0);
    _behaviorCounts = {};
    _timeOfDayCounts = {
      "Pagi (06-11)": 0, "Siang (12-15)": 0, "Sore (16-18)": 0, "Malam (19-22)": 0, "Lainnya": 0
    };
    Map<String, int> antecedentCounts = {};

    for (var log in _logs) {
      try {
        DateTime logDate = DateTime.parse(log['date']);

        // 1. Analisis Tren Mingguan (Hanya data minggu ini)
        if (logDate.isAfter(startOfWeek) && logDate.isBefore(endOfWeek)) {
          int dayIndex = logDate.weekday - 1; // 0 = Senin
          if (dayIndex >= 0 && dayIndex < 7) {
            _weeklyCounts[dayIndex]++;
          }
        }

        // 2. Analisis Jenis Perilaku (Semua data)
        String behavior = log['behavior'].split(" ")[0]; 
        _behaviorCounts[behavior] = (_behaviorCounts[behavior] ?? 0) + 1;

        // 3. Analisis Waktu (Semua data)
        int hour = logDate.hour;
        if (hour >= 6 && hour <= 11) _timeOfDayCounts["Pagi (06-11)"] = _timeOfDayCounts["Pagi (06-11)"]! + 1;
        else if (hour >= 12 && hour <= 15) _timeOfDayCounts["Siang (12-15)"] = _timeOfDayCounts["Siang (12-15)"]! + 1;
        else if (hour >= 16 && hour <= 18) _timeOfDayCounts["Sore (16-18)"] = _timeOfDayCounts["Sore (16-18)"]! + 1;
        else if (hour >= 19 && hour <= 22) _timeOfDayCounts["Malam (19-22)"] = _timeOfDayCounts["Malam (19-22)"]! + 1;
        else _timeOfDayCounts["Lainnya"] = _timeOfDayCounts["Lainnya"]! + 1;

        // 4. Analisis Pemicu (Antecedent)
        String ant = log['antecedent'].toString().trim().toLowerCase();
        if (ant.isNotEmpty) {
          antecedentCounts[ant] = (antecedentCounts[ant] ?? 0) + 1;
        }
      } catch (e) {
        debugPrint("Error parsing log date: $e");
      }
    }

    if (antecedentCounts.isNotEmpty) {
      var sortedAnt = antecedentCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      _topAntecedent = sortedAnt.first.key;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Analisis Pola Perilaku")),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: kMainTeal)) 
        : _logs.isEmpty 
          ? const Center(child: Text("Belum ada data untuk dianalisis.", style: TextStyle(color: Colors.grey)))
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Highlight Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: kMainTeal, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const Icon(Icons.analytics, color: Colors.white, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Total Kejadian", style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text("${_logs.length} Kali", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("Pemicu Utama: $_topAntecedent", style: const TextStyle(color: Colors.white, fontSize: 12, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text("Tren Minggu Ini", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 180,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(7, (index) {
                            int count = _weeklyCounts[index];
                            int maxVal = _weeklyCounts.reduce((curr, next) => curr > next ? curr : next);
                            if (maxVal == 0) maxVal = 1;
                            
                            double maxBarH = 120; 
                            double heightFactor = (count / maxVal) * maxBarH;
                            final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Angka
                                if (count > 0) 
                                  Text(count.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                
                                const SizedBox(height: 6),
                                
                                // Batang
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeOut,
                                  width: 16,
                                  height: heightFactor > 5 ? heightFactor : 5,
                                  decoration: BoxDecoration(
                                    color: count > 0 ? kAccentCoral : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // Hari
                                Text(days[index], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),

                Text("Jenis Perilaku Terbanyak", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                 Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    children: _behaviorCounts.entries.map((entry) {
                      double pct = entry.value / _logs.length;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kDarkGrey)),
                                Text("${entry.value}x", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Stack(
                              children: [
                                Container(height: 8, decoration: BoxDecoration(color: kSoftBeige, borderRadius: BorderRadius.circular(4))),
                                FractionallySizedBox(
                                  widthFactor: pct,
                                  child: Container(height: 8, decoration: BoxDecoration(color: kMainTeal.withOpacity(0.8), borderRadius: BorderRadius.circular(4))),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}