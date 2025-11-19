import 'package:flutter/material.dart';
import 'package:teman_asa/screens/music_screen.dart';
import 'package:teman_asa/screens/video_player_screen.dart';
import 'package:teman_asa/theme.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});
  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 2 Tab: Video & Artikel
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edukasi & Tips"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: kMainTeal,
          unselectedLabelColor: kIconGrey,
          indicatorColor: kMainTeal,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
          tabs: const [
            Tab(text: "Video"),
            Tab(text: "Artikel"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MusicScreen()));
        }, 
        label: const Text("Buka Musik"),
        icon: const Icon(Icons.music_note),
        backgroundColor: kAccentPurple,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: VIDEO
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _videoCard(
                "Apa itu Autisme?", 
                "Penjelasan dasar tentang autisme.", 
                "DwXRIu0esT0", 
                kMainTeal
              ),
              _videoCard(
                "Mengatasi Tantrum", 
                "Tips praktis saat anak tantrum.", 
                "Nf5GlbRkRys", 
                kAccentCoral
              ),
              _videoCard(
                "Apa itu Repetitive Behaviours?", 
                "Penjelasan tentang perilaku berulang pada autisme.", 
                "2LhI23QPoi8", 
                kAccentYellow
              ),
            ],
          ),

          // TAB 2: ARTIKEL (TIPS)
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _articleCard(
                "Tips Membuat Jadwal Visual", 
                "Anak dengan autisme sangat terbantu dengan rutinitas yang terprediksi. Gunakan gambar...",
                Icons.calendar_today
              ),
              _articleCard(
                "Mengenal Sensory Overload", 
                "Ketika anak menutup telinga atau menangis tiba-tiba, mungkin ia mengalami kelebihan sensori...",
                Icons.hearing_disabled
              ),
              _articleCard(
                "Diet & Nutrisi Anak", 
                "Beberapa studi menyarankan diet bebas gluten dan kasein (GFCF) untuk mengurangi hiperaktivitas...",
                Icons.restaurant
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _videoCard(String title, String desc, String videoId, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => VideoPlayerScreen(videoId: videoId, title: title))
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                height: 60, width: 60,
                decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                child: Icon(Icons.play_arrow_rounded, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _articleCard(String title, String snippet, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          _showArticleDetail(title, snippet);
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: kDarkGrey, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(snippet, style: const TextStyle(fontSize: 14, color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    const Text("Baca selengkapnya...", style: TextStyle(color: kMainTeal, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showArticleDetail(String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, color: Colors.grey[300]),
            const SizedBox(height: 20),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            Text(
              "$content\n\n(Ini adalah konten lengkap artikel. Di aplikasi nyata, bagian ini akan berisi teks edukasi yang panjang dan detail untuk membantu orang tua memahami topik ini lebih dalam.)",
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}