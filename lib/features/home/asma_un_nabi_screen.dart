import 'package:flutter/material.dart';

class AsmaUnNabiScreen extends StatefulWidget {
  const AsmaUnNabiScreen({super.key});

  @override
  State<AsmaUnNabiScreen> createState() => _AsmaUnNabiScreenState();
}

class _AsmaUnNabiScreenState extends State<AsmaUnNabiScreen>
    with TickerProviderStateMixin {
  int? _activeIndex;
  late AnimationController _headerController;
  late Animation<double> _headerFade;

  final List<Map<String, String>> _names = [
    {"arabic": "مُحَمَّدٌ", "transliteration": "Muhammad", "meaning": "Oft-Praised"},
    {"arabic": "أَحْمَدٌ", "transliteration": "Ahmad", "meaning": "Greatest of Praisers"},
    {"arabic": "حَامِدٌ", "transliteration": "Hamid", "meaning": "Praiser"},
    {"arabic": "مَحْمُودٌ", "transliteration": "Mahmud", "meaning": "Praised One"},
    {"arabic": "أَحِيدُ", "transliteration": "Ahid", "meaning": "Repeller"},
    {"arabic": "وَحِيدٌ", "transliteration": "Wahid", "meaning": "Unique"},
    {"arabic": "مَاحٍ", "transliteration": "Mahi", "meaning": "Effacer"},
    {"arabic": "حَاشِرٌ", "transliteration": "Hashir", "meaning": "Gatherer"},
    {"arabic": "عَاقِبٌ", "transliteration": "Aqib", "meaning": "Last in Succession"},
    {"arabic": "طه", "transliteration": "Taha", "meaning": "Taha"},
    {"arabic": "يس", "transliteration": "Yasin", "meaning": "Yasin"},
    {"arabic": "طَاهِرٌ", "transliteration": "Tahir", "meaning": "Pure One"},
    {"arabic": "مُطَهَّرٌ", "transliteration": "Mutahhar", "meaning": "Purified"},
    {"arabic": "طَيِّبٌ", "transliteration": "Tayyib", "meaning": "Fragrant"},
    {"arabic": "سَيِّدٌ", "transliteration": "Sayyid", "meaning": "Liegelord"},
    {"arabic": "رَسُولٌ", "transliteration": "Rasul", "meaning": "Emissary, or Messenger"},
    {"arabic": "نَبِيٌّ", "transliteration": "Nabiyy", "meaning": "Prophet"},
    {"arabic": "رَسُولُ الرَّحْمَةِ", "transliteration": "Rasulu r-Rahmah", "meaning": "Emissary of Mercy"},
    {"arabic": "قَيِّمٌ", "transliteration": "Qayyim", "meaning": "Upright"},
    {"arabic": "جَامِعٌ", "transliteration": "Jami'", "meaning": "Embodier of all Virtues"},
    {"arabic": "مُقْتَفٍ", "transliteration": "Muqtafi", "meaning": "Successor to the Past Prophets"},
    {"arabic": "مُقَفِّى", "transliteration": "Muqaffi", "meaning": "Surpasser"},
    {"arabic": "رَسُولُ الْمَلَاحِمِ", "transliteration": "Rasulu l-Malahim", "meaning": "Emissary who fought Battles"},
    {"arabic": "رَسُولُ الرَّاحَةِ", "transliteration": "Rasulu r-Rahah", "meaning": "Emissary of Comfort"},
    {"arabic": "كَامِلٌ", "transliteration": "Kamil", "meaning": "Complete"},
    {"arabic": "إِكْلِيلٌ", "transliteration": "Iklil", "meaning": "Crown"},
    {"arabic": "مُدَّثِّرٌ", "transliteration": "Muddaththir", "meaning": "Enwrapped in His Robe"},
    {"arabic": "مُزَّمِّلٌ", "transliteration": "Muzzammil", "meaning": "Enwrapped in His Cloak"},
    {"arabic": "عَبْدُ اللهِ", "transliteration": "Abdullah", "meaning": "Slave of Allah"},
    {"arabic": "حَبِيبُ اللهِ", "transliteration": "Habibullah", "meaning": "Beloved of Allah"},
    {"arabic": "صَفِيُّ اللهِ", "transliteration": "Safiyyullah", "meaning": "One Solely Chosen by Allah"},
    {"arabic": "نَجِيُّ اللهِ", "transliteration": "Najiyyullah", "meaning": "One who had Intimate Discourse with Allah"},
    {"arabic": "كَلِيمُ اللهِ", "transliteration": "Kalimullah", "meaning": "One Addressed by Allah"},
    {"arabic": "خَاتِمُ الْأَنْبِيَاءِ", "transliteration": "Khatimu l-Anbiya", "meaning": "Seal of the Prophets"},
    {"arabic": "خَاتِمُ الرُّسُلِ", "transliteration": "Khatimu r-Rusul", "meaning": "Seal of the Emissaries"},
    {"arabic": "مُحْيٍ", "transliteration": "Muhyi", "meaning": "Reviver"},
    {"arabic": "مُنْجٍ", "transliteration": "Munji", "meaning": "Deliverer"},
    {"arabic": "مُذَكِّرٌ", "transliteration": "Mudhakkir", "meaning": "One Who Reminds"},
    {"arabic": "نَاصِرٌ", "transliteration": "Nasir", "meaning": "Bringer of Victory"},
    {"arabic": "مَنْصُورٌ", "transliteration": "Mansur", "meaning": "One Granted Victory"},
    {"arabic": "نَبِيُّ الرَّحْمَةِ", "transliteration": "Nabiyyu r-Rahmah", "meaning": "Prophet of Mercy"},
    {"arabic": "نَبِيُّ التَّوْبَةِ", "transliteration": "Nabiyyu t-Tawbah", "meaning": "Prophet of Repentance"},
    {"arabic": "حَرِيصٌ عَلَيْكُمْ", "transliteration": "Harisun Alaykum", "meaning": "Most Concerned for You"},
    {"arabic": "مَعْلُومٌ", "transliteration": "Ma'lum", "meaning": "Known One"},
    {"arabic": "شَهِيرٌ", "transliteration": "Shahir", "meaning": "Renowned"},
    {"arabic": "شَاهِدٌ", "transliteration": "Shahid", "meaning": "Testifier"},
    {"arabic": "شَهِيدٌ", "transliteration": "Shahid", "meaning": "Witness"},
    {"arabic": "مَشْهُودٌ", "transliteration": "Mashhud", "meaning": "One Witnessed to"},
    {"arabic": "بَشِيرٌ", "transliteration": "Bashir", "meaning": "Bearer of Good Tidings"},
    {"arabic": "مُبَشِّرٌ", "transliteration": "Mubashshir", "meaning": "Bringer of Good News"},
    {"arabic": "نَذِيرٌ", "transliteration": "Nadhir", "meaning": "Warner"},
    {"arabic": "مُنْذِرٌ", "transliteration": "Mundhir", "meaning": "Admonisher"},
    {"arabic": "نُورٌ", "transliteration": "Nur", "meaning": "Light"},
    {"arabic": "سِرَاجٌ", "transliteration": "Siraj", "meaning": "Lamp"},
    {"arabic": "مِصْبَاحٌ", "transliteration": "Misbah", "meaning": "Lantern"},
    {"arabic": "هُدَىً", "transliteration": "Huda", "meaning": "Guidance"},
    {"arabic": "مَهْدِيٌ", "transliteration": "Mahdiyy", "meaning": "Guided"},
    {"arabic": "مُنِيرٌ", "transliteration": "Munir", "meaning": "Giver of Light"},
    {"arabic": "دَاعٍ", "transliteration": "Da'i", "meaning": "Caller"},
    {"arabic": "مَدْعُوٌّ", "transliteration": "Mad'uww", "meaning": "Called Upon"},
    {"arabic": "مُجِيبٌ", "transliteration": "Mujib", "meaning": "Answerer to the Call"},
    {"arabic": "مُجَابٌ", "transliteration": "Mujab", "meaning": "Answered"},
    {"arabic": "حَفِيٌّ", "transliteration": "Hafiyy", "meaning": "Welcoming"},
    {"arabic": "عَفُوٌّ", "transliteration": "Afuww", "meaning": "Much-Pardoning"},
    {"arabic": "وَلِيٌّ", "transliteration": "Waliyy", "meaning": "One Close to Allah"},
    {"arabic": "حَقٌ", "transliteration": "Haqq", "meaning": "Truth"},
    {"arabic": "قَوِيٌّ", "transliteration": "Qawiyy", "meaning": "Mighty"},
    {"arabic": "أَمِينٌ", "transliteration": "Amin", "meaning": "Trustworthy"},
    {"arabic": "مَأْمُونٌ", "transliteration": "Ma'mun", "meaning": "Trusted"},
    {"arabic": "كَرِيمٌ", "transliteration": "Karim", "meaning": "Noble"},
    {"arabic": "مُكَرَّمٌ", "transliteration": "Mukarram", "meaning": "Ennobled"},
    {"arabic": "مَكِينٌ", "transliteration": "Makin", "meaning": "Unshakeable"},
    {"arabic": "مَتِينٌ", "transliteration": "Matin", "meaning": "Firm"},
    {"arabic": "مُبِينٌ", "transliteration": "Mubin", "meaning": "Evident, Clarifier"},
    {"arabic": "مُؤَمِّلٌ", "transliteration": "Mu'ammil", "meaning": "Hopeful"},
    {"arabic": "وَصُولٌ", "transliteration": "Wasul", "meaning": "Maintainer of Ties"},
    {"arabic": "ذُو قُوَّةٍ", "transliteration": "Dhu Quwwah", "meaning": "Possessor of Might"},
    {"arabic": "ذُو حُرْمَةٍ", "transliteration": "Dhu Hurmah", "meaning": "Possessor of Sanctity"},
    {"arabic": "ذُو مَكَانَةٍ", "transliteration": "Dhu Makanah", "meaning": "Possessor of a Mighty Station"},
    {"arabic": "ذُو عِزٍّ", "transliteration": "Dhu Izz", "meaning": "Possessor of Glory"},
    {"arabic": "ذُو فَضْلٍ", "transliteration": "Dhu Fadl", "meaning": "Possessor of Virtue"},
    {"arabic": "مُطَاعٌ", "transliteration": "Muta'", "meaning": "Obeyed"},
    {"arabic": "مُطِيعٌ", "transliteration": "Muti'", "meaning": "Obedient"},
    {"arabic": "قَدَمُ صِدْقٍ", "transliteration": "Qadamu Sidq", "meaning": "Sure Forerunner"},
    {"arabic": "رَحْمَةٌ", "transliteration": "Rahmah", "meaning": "Mercy"},
    {"arabic": "بُشْرَى", "transliteration": "Bushra", "meaning": "Glad Tidings"},
    {"arabic": "غُوثٌ", "transliteration": "Ghawth", "meaning": "Aid"},
    {"arabic": "غَيْثٌ", "transliteration": "Ghayth", "meaning": "Relief"},
    {"arabic": "غِيَاثٌ", "transliteration": "Ghiyath", "meaning": "Succour"},
    {"arabic": "نِعْمَةُ اللهِ", "transliteration": "Ni'matullah", "meaning": "Allah’s Blessing"},
    {"arabic": "هَدِيَّةُ اللهِ", "transliteration": "Hadiyyatullah", "meaning": "Allah’s Gift"},
    {"arabic": "عُرْوَةٌ وُثْقَى", "transliteration": "Urwatun Wuthqa", "meaning": "Most Trusty Hold"},
    {"arabic": "صِرَاطُ اللهِ", "transliteration": "Siratullah", "meaning": "Path to Allah"},
    {"arabic": "صِرَاطٌ مُسْتَقِيمٌ", "transliteration": "Siratun Mustaqim", "meaning": "Straight Path"},
    {"arabic": "ذِكْرُ اللهِ", "transliteration": "Dhikrullah", "meaning": "Remembrance of Allah"},
    {"arabic": "سَيْفُ اللهِ", "transliteration": "Sayfullah", "meaning": "Sword of Allah"},
    {"arabic": "حِزْبُ اللهِ", "transliteration": "Hizbullah", "meaning": "Party of Allah"},
    {"arabic": "النَّجْمُ الثَّاقِبُ", "transliteration": "An-Najmu th-thaqib", "meaning": "Shining Star"},
    {"arabic": "مُصْطَفَى", "transliteration": "Mustafa", "meaning": "Chosen"},
    {"arabic": "مُجْتَبَى", "transliteration": "Mujtaba", "meaning": "Selected"},
  ];

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _headerFade = CurvedAnimation(parent: _headerController, curve: Curves.easeOut);
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        title: const Text('Asma un Nabi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B5E20),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.15,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => _NameCard(
                  index: index,
                  data: _names[index],
                  isActive: _activeIndex == index,
                  onTap: () {
                    setState(() => _activeIndex = index);
                  },
                ),
                childCount: _names.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _headerFade,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1B5E20), Color(0xFFF1F8E9)],
          ),
        ),
        child: Column(
          children: [
            const Text(
              'مُحَمَّدٌ رَسُولُ اللهِ',
              style: TextStyle(
                fontFamily: 'Jameel Noori',
                fontSize: 48,
                color: Colors.white,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 12),
            Text(
              'ASMĀ UN NABĪ',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 13,
                letterSpacing: 6,
                color: Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'The 100 Beautiful Names of Prophet Muhammad (PBUH)',
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF1B5E20).withOpacity(0.7),
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 48),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  const Color(0xFF2E7D32).withOpacity(0.6),
                  Colors.transparent,
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NameCard extends StatelessWidget {
  final int index;
  final Map<String, String> data;
  final bool isActive;
  final VoidCallback onTap;

  const _NameCard({
    required this.index,
    required this.data,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isActive
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFE8F5E9)],
                ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? const Color(0xFF1B5E20).withOpacity(0.35)
                  : Colors.black.withOpacity(0.06),
              blurRadius: isActive ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isActive
                ? const Color(0xFF1B5E20).withOpacity(0.8)
                : const Color(0xFF1B5E20).withOpacity(0.18),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 8,
              left: 10,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? Colors.white.withOpacity(0.2)
                      : const Color(0xFF1B5E20).withOpacity(0.12),
                  border: Border.all(
                    color: isActive ? Colors.white.withOpacity(0.4) : const Color(0xFF1B5E20).withOpacity(0.4),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : const Color(0xFF1B5E20),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 22, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 4,
                    child: Center(
                      child: Text(
                        data['arabic']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Jameel Noori',
                          fontSize: 34,
                          height: 1.2,
                          color: isActive ? Colors.white : const Color(0xFF1B5E20),
                        ),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: isActive ? Colors.white.withOpacity(0.3) : const Color(0xFF1B5E20).withOpacity(0.25),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data['transliteration']!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: isActive ? Colors.white : const Color(0xFF2E7D32),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          data['meaning']!,
                          style: TextStyle(
                            fontSize: 9,
                            height: 1.2,
                            color: isActive ? Colors.white.withOpacity(0.85) : Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
