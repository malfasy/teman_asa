import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
import 'package:teman_asa/screens/music_screen.dart';
import 'package:teman_asa/screens/video_player_screen.dart';
import 'package:teman_asa/theme.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  String _selectedCategory = "Semua";
  final List<String> _categories = ["Semua", "Autisme", "Perilaku", "Sensori", "Terapi"];
  final List<Map<String, dynamic>> _videos = [
    {
      "type": "video",
      "category": "Autisme",
      "title": "Apa itu Autisme?",
      "desc": "Perspektif tentang autisme.",
      "source": "Video Edukasi",
      "videoId": "DwXRIu0esT0",
      "color": kMainTeal.withOpacity(0.15), 
      "accent": kMainTeal,
      "icon": Icons.play_circle_filled_rounded
    },
    {
      "type": "video",
      "category": "Perilaku",
      "title": "Mengatasi Tantrum",
      "desc": "Tips praktis saat anak tantrum.",
      "source": "Video Edukasi",
      "videoId": "Nf5GlbRkRys",
      "color": kAccentCoral.withOpacity(0.15),
      "accent": kAccentCoral,
      "icon": Icons.play_circle_filled_rounded
    },
    {
      "type": "video",
      "category": "Perilaku",
      "title": "Perilaku Berulang",
      "desc": "Penjelasan stimming & repetitif.",
      "source": "Video Edukasi",
      "videoId": "2LhI23QPoi8",
      "color": kAccentPurple.withOpacity(0.15),
      "accent": kAccentPurple,
      "icon": Icons.play_circle_filled_rounded
    },
  ];

  final List<Map<String, dynamic>> _articles = [
    {
      "type": "article",
      "category": "Perilaku",
      "title": "Membangun Rutinitas Harian",
      "desc": "Panduan membuat jadwal visual agar anak merasa aman & produktif.",
      "source": "TAMTAM.CO.ID",
      "color": kAccentYellow.withOpacity(0.2),
      "accent": const Color(0xFFE6B800),
      "icon": Icons.schedule_rounded,
      "content": """
Anak-anak dengan Autism Spectrum Disorder (ASD) sering kali memiliki kebutuhan yang kuat akan prediktabilitas. Dunia bisa terasa sangat kacau dan membingungkan bagi mereka. Dengan pendekatan yang tepat, rutinitas harian dapat menjadi "jangkar" yang mendukung perkembangan sosial, kognitif, dan emosional anak.

**Mengapa Rutinitas Itu Sangat Vital?**

Bagi anak dengan ASD, perubahan yang mendadak atau ketidakpastian dapat menyebabkan kecemasan dan ketegangan. Mereka cenderung lebih mudah mengelola perasaan dan beradaptasi dengan aktivitas harian jika mereka tahu apa yang akan terjadi selanjutnya. Rutinitas yang konsisten memberikan rasa aman dan membantu anak merasa lebih terkontrol.

Berikut beberapa alasan mengapa rutinitas penting bagi anak dengan ASD:

**1. Mengurangi Kecemasan dan Frustrasi**

Rutinitas yang jelas mengurangi ketidakpastian, yang sering kali menjadi pemicu kecemasan pada anak dengan ASD. Ketika anak tahu apa yang diharapkan dari mereka setiap hari, mereka akan merasa lebih tenang.
  
**2. Meningkatkan Kemampuan Mengelola Waktu**

Dengan rutinitas yang terstruktur, anak dapat belajar mengelola waktu dengan lebih baik. Mereka akan belajar bahwa ada waktu untuk bermain, belajar, makan, dan tidur, yang membantu mereka mengembangkan keterampilan perencanaan dan organisasi.

**3. Meningkatkan Kemandirian**

Anak yang terbiasa dengan rutinitas akan lebih mampu melakukan kegiatan secara mandiri, seperti berpakaian, makan, atau menyelesaikan tugas-tugas tertentu, tanpa perlu banyak bantuan.

**4. Meningkatkan Perilaku Positif**

Rutinitas yang konsisten memberi anak kesempatan untuk mengembangkan perilaku yang positif. Anak dengan ASD sering kali merasa lebih baik dalam lingkungan yang terstruktur, karena mereka tahu apa yang diharapkan dari mereka.

---

**Langkah-Langkah Membangun Rutinitas di Rumah**

**1. Buat Jadwal Visual (Visual Schedule)**

Anak dengan ASD sering kali lebih mudah memahami dan mengikuti rutinitas yang disajikan dalam bentuk visual. Buatlah jadwal harian yang menunjukkan apa yang akan dilakukan pada setiap waktu, baik menggunakan gambar, simbol, atau tulisan. Jadwal visual ini bisa dipasang di tempat yang mudah dijangkau oleh anak, seperti di dinding kamar tidur atau ruang bermain.

Contoh:
* **Pagi:** Gambar anak bangun tidur, mandi, sarapan.
* **Siang:** Gambar sekolah, waktu belajar, waktu bermain.
* **Sore:** Gambar makan malam, waktu keluarga, waktu tidur.

Menggunakan gambar atau simbol yang sesuai dengan kegiatan dapat membantu anak mengenali dan mempersiapkan diri untuk setiap aktivitas.

**2. Tentukan Waktu untuk Aktivitas yang Dikenal dan Baru**
Rutinitas harian harus mencakup waktu untuk aktivitas yang sudah dikenal anak, seperti bermain dengan mainan favorit, menonton acara TV, atau kegiatan lain yang mereka nikmati. Namun, sangat penting juga untuk mengenalkan aktivitas baru yang bermanfaat, seperti belajar keterampilan sosial, keterampilan motorik, atau tugas rumah tangga.

Mulailah dengan memperkenalkan kegiatan baru dalam waktu yang singkat dan beri kesempatan anak untuk beradaptasi. Pastikan kegiatan baru tersebut diberi penjelasan terlebih dahulu dengan cara yang sederhana dan jelas agar anak merasa nyaman.

**3. Berikan Waktu untuk Transisi yang Mulus**

Anak dengan ASD sering kali kesulitan saat berpindah dari satu kegiatan ke kegiatan lain, yang sering memicu kecemasan dan tantrum. Untuk membantu transisi yang lebih lancar, berikan peringatan beberapa menit sebelum kegiatan berakhir. Misalnya, Anda bisa menggunakan timer atau pengingat verbal seperti “Lima menit lagi, kita akan beralih ke waktu makan siang.”

Memberikan transisi yang mulus antara kegiatan akan membantu anak merasa lebih siap untuk berpindah ke kegiatan berikutnya tanpa merasa terkejut atau cemas.

**4. Ciptakan Waktu Tenang untuk Anak**

Selain rutinitas yang terstruktur, penting juga untuk menyediakan waktu tenang dalam sehari, terutama jika anak merasa kewalahan. Waktu tenang bisa berupa kegiatan yang menenangkan seperti mendengarkan musik lembut, beristirahat, atau bermain dengan mainan yang menenangkan seperti bola bertekstur atau benda yang dapat diperas.

Waktu tenang sangat penting untuk membantu anak mengatur diri mereka sendiri dan menghindari stres berlebih. Rutinitas harian yang baik akan mencakup waktu untuk relaksasi dan pemulihan dari aktivitas yang lebih intens.

**5. Libatkan Anak dalam Penyusunan Rutinitas**

Sebagian anak dengan ASD mungkin merasa lebih terlibat dan termotivasi ketika mereka dilibatkan dalam menyusun rutinitas mereka sendiri. Ajak anak untuk memilih aktivitas atau kegiatan yang mereka nikmati dan ingin masukkan dalam rutinitas harian. Anda bisa memberikan beberapa pilihan, seperti memilih antara bermain di luar atau melakukan kerajinan tangan, dan memberi anak kesempatan untuk memutuskan.

Libatkan mereka dalam membuat keputusan kecil ini, dan mereka akan merasa memiliki kontrol atas rutinitas mereka, yang dapat meningkatkan rasa tanggung jawab dan kemandirian.
"""
    },
    {
      "type": "article",
      "category": "Sensori",
      "title": "Memahami Sensory Overload",
      "desc": "Kenali tanda-tanda anak kelebihan sensori dan cara menenangkannya.",
      "source": "AUTISM-DISCOVERY.COM",
      "color": kMainTeal.withOpacity(0.15),
      "accent": kMainTeal,
      "icon": Icons.hearing_disabled_rounded,
      "content": """
Bayangkan berjalan ke dalam supermarket yang terang benderang. Lampu neon berkedip di atas, musik berdengung dari speaker, troli berderak di lantai, dan suara serta percakapan saling tumpang tindih. Bagi kebanyakan orang, ini mungkin hanya sedikit mengganggu. Tapi bagi banyak individu autis, pemandangan ini bisa terasa tak tertahankan, banjir suara, cahaya, dan sensasi yang otak tidak bisa saring atau kendalikan. Pengalaman ini dikenal sebagai kelebihan sensorik, dan ini adalah salah satu aspek autisme yang paling umum dan menantang.

*Sensory Overload* bukan hanya ketidaknyamanan. Ini bisa mengganggu kehidupan sehari-hari, menimbulkan stres, dan menyebabkan shutdown atau ledakan emosional. Namun, dengan pemahaman yang lebih baik dan strategi pengelolaan, baik individu autis maupun komunitas mereka dapat belajar untuk mengurangi dampaknya.
---
**Apa itu Sensory Overload?**

Sensory Overload terjadi ketika otak dibombardir dengan lebih banyak input daripada yang dapat diproses. Meskipun semua orang mungkin merasa kewalahan oleh kebisingan atau keramaian pada saat tertentu, orang dengan autisme sering memiliki pemrosesan sensorik yang lebih tinggi atau tidak biasa. Ini berarti mereka mungkin memperhatikan suara yang diabaikan orang lain, merasakan tekstur lebih intens, atau merasa tidak nyaman oleh lampu yang berkedip yang tidak diperhatikan oleh kebanyakan orang.

**Pemicu umum meliputi:**

* Suara keras atau bertumpuk (sirene, ruangan penuh orang, percakapan yang tumpang tindih)
* Lampu terang atau berkedip
* Bau kuat, seperti parfum atau produk pembersih
* Tekstur pakaian atau label yang tidak nyaman
* Lingkungan yang kacau dengan terlalu banyak input sekaligus

**Dampak Sensory Overload**

Bagi individu dengan autisme, overload sensorik bukan hanya gangguan sementara. Efeknya bisa meluas ke kehidupan sehari-hari:

**1.Kesalahpahaman dari Orang Lain**

Secara tidak adil, sensitivitas sensorik yang terlihat sering disalahartikan sebagai ketidaksopanan atau kurangnya disiplin. Orang luar mungkin menganggap bahwa orang tersebut melebih-lebihkan atau mencari perhatian. Kesalahpahaman ini bisa menambah rasa malu atau stigma pada pengalaman yang sudah menyulitkan.

**2.  Kecemasan dan Penghindaran**

Jika overload sensorik terjadi sering, individu mungkin mulai menghindari tempat atau aktivitas tertentu. Seorang anak mungkin takut menghadiri apel sekolah, atau seorang dewasa mungkin menghindari transportasi umum, bukan karena mereka tidak menyukai aktivitas tersebut, tetapi karena itu terlalu membebani.

**3.  Ledakan Emosi dan Penarikan Diri**

Ketika otak mencapai batasnya, seseorang bisa mengalami ledakan emosi, ekspresi luar dari rasa kewalahan yang bisa terlihat seperti menangis, berteriak, atau mondar-mandir. Orang lain mungkin mengalami penarikan diri, menjadi diam atau menjauh sebagai cara untuk mengatasinya.

**Mengenali Tanda-Tanda Sensory Overload**

Memahami tanda-tanda peringatan dapat membantu mengelola kelebihan beban sebelum meningkat. Tanda-tandanya dapat meliputi:

* Meningkatnya rasa mudah tersinggung atau gelisah
* Menutupi telinga atau mata
* Kesulitan berkonsentrasi atau merespons
* Pernapasan cepat atau ketegangan fisik
* Menarik diri atau menjadi pendiam
* Tanda-tanda distres, seperti mondar-mandir atau bergoyang

Karena kelebihan beban sensorik berbeda pada setiap orang, kesadaran diri dan komunikasi adalah kuncinya. Beberapa individu autis belajar mengenali pemicu mereka dan mengomunikasikannya, sementara yang lain mungkin membutuhkan dukungan dari pengasuh, guru, atau teman untuk mengidentifikasi polanya.

**Strategi untuk Mengelola Sensory Overload**

Meskipun tidak mungkin untuk menghindari setiap pemicu, ada cara efektif untuk mengurangi intensitas dan dampak kelebihan sensorik.

**1. Penyesuaian Lingkungan**

* Gunakan headphone peredam bising di lingkungan yang bising.
* Pertimbangkan untuk mencoba earbud peredam bising in-ear.
* Redupkan pencahayaan yang terlalu terang atau kenakan kacamata hitam di dalam ruangan jika perlu.
* Pilih pakaian yang terbuat dari bahan lembut dan bebas label.
* Ciptakan ruang yang tenang dan aman di rumah atau tempat kerja yang memungkinkan untuk beristirahat.

**2. Perencanaan Ke Depan**

* Kunjungi tempat-tempat ramai selama jam-jam yang lebih tenang.
* Bawalah alat sensorik seperti mainan fidget, benda berbobot, atau aroma yang menenangkan.
* Petakan pintu keluar atau sudut yang tenang sebelum memasuki lingkungan yang ramai.

**3. Teknik Pengaturan Diri**

* Pernapasan dalam atau latihan mindfulness dapat membantu menenangkan sistem saraf.
* Strategi grounding, seperti berfokus pada satu objek atau masukan sensorik, dapat membantu mengalihkan perhatian.
* Aktivitas fisik, seperti berjalan atau peregangan, dapat membantu melepaskan ketegangan.

**4. Komunikasi dan Advokasi**

* Beri tahu orang lain tentang kebutuhan sensorik. Misalnya, mintalah pencahayaan yang lebih redup di tempat kerja atau mintalah untuk bertemu di tempat yang lebih tenang.
* Untuk anak-anak, guru dapat menawarkan waktu istirahat sensorik atau tempat duduk yang fleksibel.
* Dalam skala yang lebih luas, mengadvokasi ruang ramah sensorik dapat bermanfaat bagi seluruh komunitas.
"""
    },
    {
      "type": "article",
      "category": "Terapi",
      "title": "Terapi Anak Autis di Rumah",
      "desc": "Tips praktis terapi wicara dan okupasi sederhana oleh orang tua.",
      "source": "WICARAKU.ID",
      "color": kMainTeal.withOpacity(0.15),
      "accent": kMainTeal,
      "icon": Icons.home_rounded,
      "content": """
Berbeda dengan terapi di klinik, terapi di rumah memungkinkan anak belajar dengan lebih rileks dan konsisten. Selain itu, orang tua memiliki kesempatan untuk ikut berpartisipasi langsung dalam setiap proses perkembangan anak. Dengan pendekatan yang tepat, perubahan positif sering kali terlihat lebih cepat karena stimulasi dapat diberikan setiap hari dalam suasana penuh kasih.

Terapi anak autis di rumah tidak hanya sekadar memindahkan sesi klinik ke ruang keluarga. Pendekatan ini berfokus pada personalisasi dan kenyamanan anak. Anak dengan autisme sering kali lebih mudah menerima pembelajaran di tempat yang mereka kenal baik.

Suasana rumah yang tenang dan akrab membantu anak menyesuaikan diri dengan terapi tanpa kecemasan. Selain itu, keterlibatan langsung keluarga memperkuat hasil terapi karena anak merasa didukung, bukan dipaksa. Melalui rutinitas sehari-hari, orang tua bisa menerapkan strategi terapi dalam bentuk kegiatan bermain, berbicara, atau aktivitas sensorik yang menyenangkan.
---
**Jenis Terapi yang Dapat Diterapkan di Rumah:**

Tidak semua terapi harus dilakukan di klinik khusus. Beberapa metode dapat dijalankan di rumah dengan panduan profesional. Terapi perilaku, terapi wicara, terapi okupasi, dan terapi sensorik merupakan contoh pendekatan yang bisa disesuaikan dengan kebutuhan anak.

Orang tua dapat bekerja sama dengan terapis untuk menentukan aktivitas terbaik dan memastikan setiap langkah dilakukan dengan benar. Hal yang terpenting adalah konsistensi dan kesabaran. Setiap anak autis berkembang dengan ritme berbeda, sehingga pemantauan dan penyesuaian berkelanjutan sangat dibutuhkan.

**1. Terapi Wicara untuk Meningkatkan Kemampuan Komunikasi**

Terapi wicara berfokus pada peningkatan kemampuan anak dalam memahami dan mengekspresikan bahasa. Di rumah, orang tua dapat membantu dengan berbicara perlahan, menggunakan intonasi lembut, serta memperkuat makna kata melalui gestur atau gambar. Misalnya, menunjuk benda sambil menyebutkan namanya dapat membantu anak mengaitkan kata dengan objek nyata.

Aktivitas sederhana seperti bernyanyi bersama, membaca buku bergambar, atau bermain peran juga bermanfaat untuk memperluas kosa kata anak. Dengan latihan rutin, anak belajar memahami struktur bahasa, ekspresi wajah, dan intonasi yang berperan penting dalam komunikasi sehari-hari.

**2. Terapi Perilaku (Applied Behavior Analysis / ABA)**

Terapi ABA adalah metode yang terbukti efektif dalam meningkatkan perilaku positif dan kemampuan sosial anak autis. Di rumah, orang tua bisa menerapkannya dengan memberikan pujian atau hadiah kecil setiap kali anak menunjukkan perilaku baik.

Pendekatan ini mengajarkan anak untuk memahami hubungan antara tindakan dan konsekuensinya. Dengan latihan konsisten, anak akan terbiasa dengan rutinitas yang baik, belajar fokus, serta mampu menyesuaikan diri dengan lingkungan sekitarnya tanpa tekanan berlebih.

**3. Terapi Okupasi untuk Melatih Kemandirian**

Terapi okupasi membantu anak menguasai keterampilan dasar seperti makan sendiri, berpakaian, atau menggosok gigi. Aktivitas sederhana ini bisa dilakukan di rumah dengan pendekatan bermain. Misalnya, ajak anak merapikan mainan atau membantu menyiapkan camilan untuk melatih koordinasi motorik halusnya.

Selain itu, orang tua dapat menggunakan alat bantu seperti sendok pegangan tebal atau pakaian dengan perekat untuk memudahkan proses latihan. Terapi ini bertujuan agar anak merasa percaya diri dan mandiri dalam kehidupan sehari-hari.

**4. Terapi Sensorik untuk Menyeimbangkan Respon Anak**

Banyak anak autis mengalami gangguan pada sistem sensorik, seperti terlalu sensitif terhadap suara atau sentuhan. Terapi sensorik di rumah dapat membantu menyeimbangkan respon tersebut melalui aktivitas bermain seperti bermain pasir, mencubit adonan mainan, atau menggambar dengan jari.

Kegiatan ini membantu anak belajar mengatur reaksi terhadap berbagai rangsangan. Dengan latihan teratur, anak menjadi lebih tenang dan mampu menyesuaikan diri dengan lingkungan yang berubah-ubah tanpa merasa kewalahan.

**5. Terapi Sosial untuk Meningkatkan Interaksi**

Anak autis sering kali mengalami kesulitan dalam memahami bahasa tubuh dan emosi orang lain. Terapi sosial dapat dilakukan di rumah dengan cara mengajak anak bermain bersama anggota keluarga. Misalnya, bermain giliran atau permainan papan sederhana yang melatih kemampuan mengikuti aturan dan menunggu.

Melalui interaksi ringan ini, anak belajar mengenali ekspresi, memahami emosi, dan mengembangkan rasa empati. Perlahan-lahan, kemampuan anak untuk berinteraksi dengan orang lain akan meningkat, dan mereka menjadi lebih nyaman berada di lingkungan sosial.

**6. Terapi Musik untuk Relaksasi dan Komunikasi Emosional**

Musik memiliki kekuatan luar biasa dalam menstimulasi emosi dan membantu anak autis mengekspresikan diri. Orang tua dapat memperdengarkan lagu-lagu dengan tempo lembut atau mengajak anak bermain alat musik sederhana seperti drum atau pianika.

Selain menenangkan, terapi musik juga melatih kemampuan mendengarkan dan fokus. Anak belajar mengenali ritme, nada, dan pola suara, yang semuanya membantu perkembangan bahasa dan koordinasi motorik halus. Aktivitas ini bisa menjadi momen menyenangkan antara anak dan orang tua.

**7. Terapi Nutrisi untuk Mendukung Kesehatan Otak dan Perilaku**

Selain stimulasi perilaku, asupan nutrisi yang tepat juga berpengaruh besar terhadap perkembangan anak autis. Makanan kaya omega-3, vitamin B kompleks, dan magnesium diketahui membantu meningkatkan fokus dan kestabilan emosi.

Beberapa orang tua juga mulai menggunakan suplemen kesehatan yang diformulasikan untuk mendukung fungsi otak dan keseimbangan sistem saraf. Dengan pengawasan dokter, kombinasi terapi nutrisi dan aktivitas terarah bisa memberikan hasil yang optimal bagi anak.

**Manfaat Jangka Panjang dari Terapi di Rumah**

Terapi anak autis di rumah memberikan manfaat jangka panjang yang tidak hanya terlihat pada kemampuan berbicara atau perilaku, tetapi juga pada perkembangan emosi dan sosial. Anak menjadi lebih mandiri, tenang, dan mampu mengontrol reaksi mereka terhadap lingkungan.

Kegiatan sehari-hari yang dilakukan secara konsisten membuat anak lebih siap menghadapi dunia luar. Dengan dukungan keluarga yang penuh kasih dan terapi yang tepat, anak dapat mencapai potensi terbaiknya dan beradaptasi dengan kehidupan sosial secara lebih positif.
"""
    },
  ];

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "Semua": return Icons.dashboard_outlined;
      case "Autisme": return Icons.favorite_border;
      case "Perilaku": return Icons.sentiment_satisfied_alt;
      case "Sensori": return Icons.toys_outlined;
      case "Terapi": return Icons.spa_outlined;
      default: return Icons.category;
    }
  }

  List<Map<String, dynamic>> _getFilteredContent() {
    List<Map<String, dynamic>> mixedContent = [];
    mixedContent.addAll(_articles);

    if (_selectedCategory == "Semua") {
      mixedContent.addAll(_videos.sublist(1)); 
    } else {
      mixedContent.addAll(_videos);
    }

    if (_selectedCategory == "Semua") {
      return mixedContent;
    } else {
      return mixedContent.where((item) => item['category'] == _selectedCategory).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayContent = _getFilteredContent();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Explore Contents"),
        centerTitle: true,
        backgroundColor: Colors.white,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 28),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MusicScreen())),
            icon: const Icon(Icons.music_note_rounded, color: kMainTeal),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            SizedBox(
              height: 90,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 20),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  bool isSelected = _selectedCategory == cat;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 55, height: 55,
                          decoration: BoxDecoration(
                            color: isSelected ? kMainTeal : Colors.grey.shade100,
                            shape: BoxShape.circle,
                            boxShadow: isSelected ? [
                              BoxShadow(color: kMainTeal.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))
                            ] : [],
                          ),
                          child: Icon(
                            _getCategoryIcon(cat), 
                            color: isSelected ? Colors.white : Colors.grey
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat, 
                          style: TextStyle(
                            fontSize: 12, 
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, 
                            color: isSelected ? kMainTeal : Colors.grey
                          )
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Featured Video Banner 
            if (_selectedCategory == "Semua")
              Padding(
                padding: const EdgeInsets.all(24),
                child: InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPlayerScreen(videoId: _videos[0]['videoId'], title: _videos[0]['title']))),
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: kAccentCoral.withOpacity(0.2), 
                      borderRadius: BorderRadius.circular(24),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/pattern_bg.png'),
                        fit: BoxFit.cover,
                        opacity: 0.1
                      )
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_videos[0]['title'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kDarkGrey)),
                              const SizedBox(height: 4),
                              Text(_videos[0]['desc'], style: const TextStyle(fontSize: 12, color: kDarkGrey)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(color: kAccentCoral, shape: BoxShape.circle),
                          child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
                        )
                      ],
                    ),
                  ),
                ),
              ),

            // Grid Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: displayContent.isEmpty 
              ? const Center(child: Text("Belum ada konten di kategori ini.", style: TextStyle(color: Colors.grey)))
              : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85, 
                ),
                itemCount: displayContent.length,
                itemBuilder: (context, index) {
                  final item = displayContent[index];
                  return _buildUnifiedGridCard(context, item);
                },
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Widget Card
  Widget _buildUnifiedGridCard(BuildContext context, Map<String, dynamic> item) {
    bool isVideo = item['type'] == 'video';
    Color cardColor = item['color']; 
    Color accentColor = item['accent'];

    return GestureDetector(
      onTap: () {
        if (isVideo) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPlayerScreen(videoId: item['videoId'], title: item['title'])));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleDetailScreen(article: item)));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cardColor,
              cardColor.withOpacity(0.8), 
            ]
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10, top: -10,
              child: Icon(item['icon'], size: 100, color: Colors.white.withOpacity(0.4)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                    child: Icon(item['icon'], color: accentColor, size: 20),
                  ),
                  const Spacer(),
                  Text(
                    item['title'],
                    style: TextStyle(
                      fontFamily: 'NerkoOne',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: kDarkGrey.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['source'] ?? "-", 
                    style: TextStyle(fontSize: 10, color: kDarkGrey.withOpacity(0.5), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Artikel Detail
class ArticleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: kDarkGrey),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Artikel disimpan ke favorit!")),
              );
            },
            icon: const Icon(Icons.bookmark_border_rounded, color: kDarkGrey),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              decoration: BoxDecoration(
                color: article['color'],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(article['icon'], size: 50, color: article['accent']),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    article['title'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kDarkGrey, fontFamily: 'NerkoOne'),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Sumber: ${article['source']}",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: article['accent']),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
              child: MarkdownBody(
                data: article['content'],
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(fontSize: 16, height: 1.8, color: kDarkGrey),
                  strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  em: const TextStyle(fontStyle: FontStyle.italic, color: kDarkGrey),
                  listBullet: const TextStyle(color: kMainTeal, fontSize: 16),
                ),
              ),
            ),
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}