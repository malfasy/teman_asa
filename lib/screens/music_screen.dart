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

  // Playlist Musik (Pastikan file ada di assets/sounds/)
  final List<Map<String, String>> _playlist = [
    {"title": "White Noise", "file": "sounds/white_noise.mp3", "desc": "Suara statis untuk ketenangan"},
    {"title": "Hujan Lembut", "file": "sounds/rain.mp3", "desc": "Suara alam untuk relaksasi"},
    {"title": "Piano Tidur", "file": "sounds/piano.mp3", "desc": "Melodi lambat pengantar tidur"},
  ];

  @override
  void initState() {
    super.initState();
    
    // Listener Status Player
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => isPlaying = state == PlayerState.playing);
    });

    // Listener Durasi Lagu
    _player.onDurationChanged.listen((newDuration) {
      if (mounted) setState(() => duration = newDuration);
    });

    // Listener Posisi Lagu
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
      
      // Play dari aset
      await _player.play(AssetSource(_playlist[_currentIndex]['file']!));
      _player.setReleaseMode(ReleaseMode.loop); // Loop otomatis
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("File audio tidak ditemukan di assets/sounds/")));
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
      body: Column(
        children: [
          // --- AREA PEMUTAR MUSIK (ATAS) ---
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Cover Art (Visualisasi)
                  Container(
                    height: 220,
                    width: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: kMainTeal.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Icon(
                      Icons.music_note_rounded,
                      size: 100,
                      color: isPlaying ? kMainTeal : kIconGrey,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Judul Lagu
                  Text(
                    currentSong['title']!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 24),
                  ),
                  Text(
                    currentSong['desc']!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  
                  const SizedBox(height: 30),

                  // Slider Progress
                  Slider(
                    activeColor: kMainTeal,
                    inactiveColor: kMainTeal.withOpacity(0.2),
                    min: 0,
                    max: duration.inSeconds.toDouble(),
                    value: position.inSeconds.toDouble().clamp(0, duration.inSeconds.toDouble()),
                    onChanged: (value) async {
                      await _player.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                  
                  // Waktu
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatTime(position)),
                        Text(_formatTime(duration)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tombol Kontrol
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded, size: 40, color: kDarkGrey),
                        onPressed: () {
                          int newIndex = _currentIndex > 0 ? _currentIndex - 1 : _playlist.length - 1;
                          _playMusic(newIndex);
                        },
                      ),
                      const SizedBox(width: 20),
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: kMainTeal,
                        child: IconButton(
                          icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 40, color: Colors.white),
                          onPressed: _togglePlay,
                        ),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, size: 40, color: kDarkGrey),
                        onPressed: () {
                          int newIndex = _currentIndex < _playlist.length - 1 ? _currentIndex + 1 : 0;
                          _playMusic(newIndex);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- PLAYLIST (BAWAH) ---
          Expanded(
            flex: 2,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _playlist.length,
                itemBuilder: (context, index) {
                  bool isActive = _currentIndex == index;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isActive ? kMainTeal.withOpacity(0.1) : kSoftBeige,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_circle_fill_rounded, 
                        color: isActive ? kMainTeal : kIconGrey
                      ),
                    ),
                    title: Text(
                      _playlist[index]['title']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isActive ? kMainTeal : kDarkGrey,
                      ),
                    ),
                    subtitle: Text(_playlist[index]['desc']!),
                    trailing: isActive ? const Icon(Icons.graphic_eq, color: kMainTeal) : null,
                    onTap: () => _playMusic(index),
                  );
                },
              ),
            ),
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