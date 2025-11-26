import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Pastikan package intl sudah ada di pubspec.yaml
import 'package:teman_asa/theme.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  List<Map<String, dynamic>> diaries = [];
  
  // Controller
  final TextEditingController _noteController = TextEditingController();
  String _selectedMood = "Senang";

  @override
  void initState() {
    super.initState();
    _loadDiaries();
  }

  // 1. Load Data dari HP
  void _loadDiaries() async {
    final prefs = await SharedPreferences.getInstance();
    String? data = prefs.getString('user_diaries');
    if (data != null) {
      setState(() {
        diaries = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  // 2. Simpan Data ke HP
  void _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user_diaries', jsonEncode(diaries));
  }

  // 3. Tambah atau Edit Diary
  void _saveDiary({int? index}) {
    if (_noteController.text.isEmpty) return;

    final entry = {
      "date": DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now()),
      "mood": _selectedMood,
      "note": _noteController.text,
    };

    setState(() {
      if (index != null) {
        // EDIT: Update data di posisi index
        diaries[index] = entry;
      } else {
        // BARU: Masukkan ke paling atas
        diaries.insert(0, entry);
      }
    });

    _saveToPrefs();
    _noteController.clear();
    Navigator.pop(context); // Tutup dialog
  }

  // 4. Hapus Diary
  void _deleteDiary(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Catatan?"),
        content: const Text("Catatan ini akan dihapus permanen."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                diaries.removeAt(index);
              });
              _saveToPrefs();
              Navigator.pop(ctx);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 5. Tampilkan Dialog Form (Bisa untuk Baru atau Edit)
  void _showFormDialog({int? index}) {
    // Jika Edit (index ada), isi form dengan data lama
    if (index != null) {
      _selectedMood = diaries[index]['mood'];
      _noteController.text = diaries[index]['note'];
    } else {
      // Jika Baru, reset form
      _selectedMood = "Senang";
      _noteController.clear();
    }

    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        // --- SOLUSI UTAMA: scrollable: true ---
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(index != null ? "Edit Catatan" : "Catat Hari Ini"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedMood,
              items: ["Senang", "Sedih", "Marah", "Tantrum", "Tenang", "Cemas"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedMood = val!),
              decoration: const InputDecoration(
                labelText: "Mood Anak",
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Ceritakan perilaku anak...", 
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                alignLabelWithHint: true,
              ),
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () => _saveDiary(index: index), 
            child: Text(index != null ? "Update" : "Simpan")
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Diary Anak")),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kMainTeal,
        onPressed: () => _showFormDialog(), // Mode Tambah Baru
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: diaries.isEmpty 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 80, color: kMainTeal.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text("Belum ada catatan.\nYuk mulai menulis!", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: diaries.length,
              itemBuilder: (context, index) {
                final item = diaries[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Chip Mood
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getMoodColor(item['mood']).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                item['mood'], 
                                style: TextStyle(fontWeight: FontWeight.bold, color: _getMoodColor(item['mood']))
                              ),
                            ),
                            
                            // Menu Titik Tiga (Edit/Hapus)
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showFormDialog(index: index);
                                } else if (value == 'delete') {
                                  _deleteDiary(index);
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [Icon(Icons.edit, size: 20, color: Colors.grey), SizedBox(width: 8), Text('Edit')],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('Hapus', style: TextStyle(color: Colors.red))],
                                  ),
                                ),
                              ],
                              icon: const Icon(Icons.more_vert, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(item['note'], style: Theme.of(context).textTheme.bodyLarge),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(item['date'], style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case "Marah": case "Tantrum": return Colors.redAccent;
      case "Sedih": case "Cemas": return Colors.orangeAccent;
      case "Senang": case "Tenang": return kMainTeal;
      default: return kAccentPurple;
    }
  }
}