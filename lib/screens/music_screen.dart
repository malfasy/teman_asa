import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:teman_asa/theme.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  
  int _currentIndex = 0;

  final List<Map<String, String>> _playlist = [
    {"title": "White Noise", "file": "sounds/white_noise.mp3", "desc": "Suara statis untuk ketenangan"},
    {"title": "Hujan Lembut", "file": "sounds/rain.mp3", "desc": "Suara hujan untuk relaksasi"},
    {"title": "Piano Tidur", "file": "sounds/piano.mp3", "desc": "Melodi lambat pengantar tidur"},
  ];

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => isPlaying = state == PlayerState.playing);
    });
    _player.onDurationChanged.listen((newDuration) {
      if (mounted) setState(() => duration = newDuration);
    });
    _player.onPositionChanged.listen((newPosition) {
      if (mounted) setState(() => position = newPosition);
    });
  }

  Future<void> _playMusic(int index) async {
    try {
      if (_currentIndex != index) {
        await _player.stop();
        _currentIndex = index;
      }
      await _player.play(AssetSource(_playlist[_currentIndex]['file']!));
      _player.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("File audio tidak ditemukan")));
    }
  }

  Future<void> _togglePlay() async {
    if (isPlaying) {
      await _player.pause();
    } else {
      await _playMusic(_currentIndex);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var currentSong = _playlist[_currentIndex];

    return Scaffold(
      backgroundColor: kSoftBeige,
      appBar: AppBar(
        title: const Text("Musik Relaksasi"),
        centerTitle: true,
        backgroundColor: kSoftBeige,
      ),
      body: Stack(
        children: [
          // --- LAYER 1: PLAYER (FULL SCREEN BACKGROUND) ---
          Positioned.fill(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 180),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      height: 240, width: 240,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [BoxShadow(color: kMainTeal.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: Icon(Icons.music_note_rounded, size: 100, color: isPlaying ? kMainTeal : kIconGrey),
                    ),
                    const SizedBox(height: 30),
                    
                    Text(currentSong['title']!, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 24), textAlign: TextAlign.center),
                    Text(currentSong['desc']!, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                    const SizedBox(height: 30),

                    Slider(
                      activeColor: kMainTeal,
                      inactiveColor: kMainTeal.withOpacity(0.2),
                      min: 0,
                      max: duration.inSeconds.toDouble(),
                      value: position.inSeconds.toDouble().clamp(0, duration.inSeconds.toDouble()),
                      onChanged: (value) async => await _player.seek(Duration(seconds: value.toInt())),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text(_formatTime(position)), Text(_formatTime(duration))],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(icon: const Icon(Icons.skip_previous_rounded, size: 40, color: kDarkGrey), onPressed: () => _playMusic(_currentIndex > 0 ? _currentIndex - 1 : _playlist.length - 1)),
                        const SizedBox(width: 20),
                        CircleAvatar(
                          radius: 35, backgroundColor: kMainTeal,
                          child: IconButton(icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 40, color: Colors.white), onPressed: _togglePlay),
                        ),
                        const SizedBox(width: 20),
                        IconButton(icon: const Icon(Icons.skip_next_rounded, size: 40, color: kDarkGrey), onPressed: () => _playMusic(_currentIndex < _playlist.length - 1 ? _currentIndex + 1 : 0)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- LAYER 2: DAFTAR LAGU (BISA DITARIK DARI GAGANGNYA) ---
          DraggableScrollableSheet(
            initialChildSize: 0.12,
            minChildSize: 0.12,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]
                ),
                // PENTING: Semua isi ada di dalam ListView agar bisa ditarik
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(0), // Padding 0 biar header nempel atas
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 40, height: 5,
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Center(child: Text("Daftar Putar", style: TextStyle(fontWeight: FontWeight.bold, color: kDarkGrey))),
                    const Divider(),
                    
                    // List Lagu
                    ...List.generate(_playlist.length, (index) {
                        bool isActive = _currentIndex == index;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                          leading: Icon(Icons.play_circle_fill_rounded, color: isActive ? kMainTeal : kIconGrey),
                          title: Text(_playlist[index]['title']!, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? kMainTeal : kDarkGrey)),
                          subtitle: Text(_playlist[index]['desc']!, style: const TextStyle(fontSize: 12)),
                          onTap: () => _playMusic(index),
                        );
                    }),
                    const SizedBox(height: 20), // Spacer bawah
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }
}