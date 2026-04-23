import 'package:flutter/material.dart';

class AsmaUlHusnaScreen extends StatefulWidget {
  const AsmaUlHusnaScreen({super.key});

  @override
  State<AsmaUlHusnaScreen> createState() => _AsmaUlHusnaScreenState();
}

class _AsmaUlHusnaScreenState extends State<AsmaUlHusnaScreen>
    with TickerProviderStateMixin {
  int? _activeIndex;
  late AnimationController _headerController;
  late Animation<double> _headerFade;

  final List<Map<String, String>> _names = [
    {"arabic": "اللَّٰه", "transliteration": "Allah", "meaning": "The Greatest Name — The One worthy of all worship"},
    {"arabic": "الرَّحْمَٰن", "transliteration": "Ar-Rahman", "meaning": "The Most Gracious — Whose mercy encompasses all creation"},
    {"arabic": "الرَّحِيم", "transliteration": "Ar-Raheem", "meaning": "The Most Merciful — Whose mercy is specific to the believers"},
    {"arabic": "الْمَلِك", "transliteration": "Al-Malik", "meaning": "The King — Absolute Sovereign of all existence"},
    {"arabic": "الْقُدُّوس", "transliteration": "Al-Quddus", "meaning": "The Most Pure — Free from all imperfection"},
    {"arabic": "السَّلَام", "transliteration": "As-Salam", "meaning": "The Source of Peace — Granter of safety and perfection"},
    {"arabic": "الْمُؤْمِن", "transliteration": "Al-Mu'min", "meaning": "The Granter of Security — Who gives faith and safety"},
    {"arabic": "الْمُهَيْمِن", "transliteration": "Al-Muhaymin", "meaning": "The Guardian — The Watchful Protector over all"},
    {"arabic": "الْعَزِيز", "transliteration": "Al-Aziz", "meaning": "The Almighty — The Invincible and Overpowering"},
    {"arabic": "الْجَبَّار", "transliteration": "Al-Jabbar", "meaning": "The Compeller — Who mends the broken and compels"},
    {"arabic": "الْمُتَكَبِّر", "transliteration": "Al-Mutakabbir", "meaning": "The Supreme — Who possesses all greatness"},
    {"arabic": "الْخَالِق", "transliteration": "Al-Khaliq", "meaning": "The Creator — Who brings all things into existence"},
    {"arabic": "الْبَارِئ", "transliteration": "Al-Bari'", "meaning": "The Originator — Who creates with distinction"},
    {"arabic": "الْمُصَوِّر", "transliteration": "Al-Musawwir", "meaning": "The Fashioner — Who gives unique form to all creation"},
    {"arabic": "الْغَفَّار", "transliteration": "Al-Ghaffar", "meaning": "The Ever-Forgiving — Who forgives again and again"},
    {"arabic": "الْقَهَّار", "transliteration": "Al-Qahhar", "meaning": "The Subduer — Who has complete dominion over all"},
    {"arabic": "الْوَهَّاب", "transliteration": "Al-Wahhab", "meaning": "The Bestower — Who gives freely without measure"},
    {"arabic": "الرَّزَّاق", "transliteration": "Ar-Razzaq", "meaning": "The Provider — The Sustainer of all creation"},
    {"arabic": "الْفَتَّاح", "transliteration": "Al-Fattah", "meaning": "The Opener — Who opens hearts and grants victories"},
    {"arabic": "الْعَلِيم", "transliteration": "Al-'Alim", "meaning": "The All-Knowing — Whose knowledge is infinite"},
    {"arabic": "الْقَابِض", "transliteration": "Al-Qabid", "meaning": "The Withholder — Who restrains with wisdom"},
    {"arabic": "الْبَاسِط", "transliteration": "Al-Basit", "meaning": "The Extender — Who expands with generosity"},
    {"arabic": "الْخَافِض", "transliteration": "Al-Khafid", "meaning": "The Reducer — Who lowers the arrogant"},
    {"arabic": "الرَّافِع", "transliteration": "Ar-Rafi'", "meaning": "The Exalter — Who raises the righteous in rank"},
    {"arabic": "الْمُعِز", "transliteration": "Al-Mu'izz", "meaning": "The Honourer — Who grants honour to whom He wills"},
    {"arabic": "الْمُذِل", "transliteration": "Al-Mudhill", "meaning": "The Humiliator — Who humbles the disobedient"},
    {"arabic": "السَّمِيع", "transliteration": "As-Sami'", "meaning": "The All-Hearing — Who hears every sound and whisper"},
    {"arabic": "الْبَصِير", "transliteration": "Al-Basir", "meaning": "The All-Seeing — Whose sight encompasses everything"},
    {"arabic": "الْحَكَم", "transliteration": "Al-Hakam", "meaning": "The Judge — The Ultimate Arbiter of all matters"},
    {"arabic": "الْعَدْل", "transliteration": "Al-'Adl", "meaning": "The Just — Perfectly equitable in all things"},
    {"arabic": "اللَّطِيف", "transliteration": "Al-Latif", "meaning": "The Subtle — Gentle and aware of the finest details"},
    {"arabic": "الْخَبِير", "transliteration": "Al-Khabir", "meaning": "The All-Aware — Who has full knowledge of all things"},
    {"arabic": "الْحَلِيم", "transliteration": "Al-Halim", "meaning": "The Forbearing — Who is slow to anger, full of patience"},
    {"arabic": "الْعَظِيم", "transliteration": "Al-'Azim", "meaning": "The Magnificent — Of incomparable greatness"},
    {"arabic": "الْغَفُور", "transliteration": "Al-Ghafur", "meaning": "The Forgiving — Who covers and pardons sins"},
    {"arabic": "الشَّكُور", "transliteration": "Ash-Shakur", "meaning": "The Appreciative — Who rewards gratitude abundantly"},
    {"arabic": "الْعَلِىّ", "transliteration": "Al-'Ali", "meaning": "The Most High — Exalted above all creation"},
    {"arabic": "الْكَبِير", "transliteration": "Al-Kabir", "meaning": "The Most Great — The Greatest in every way"},
    {"arabic": "الْحَفِيظ", "transliteration": "Al-Hafiz", "meaning": "The Preserver — Who guards all things from loss"},
    {"arabic": "الْمُقِيت", "transliteration": "Al-Muqit", "meaning": "The Sustainer — Who provides nourishment to all"},
    {"arabic": "الْحَسِيب", "transliteration": "Al-Hasib", "meaning": "The Reckoner — Who takes account of everything"},
    {"arabic": "الْجَلِيل", "transliteration": "Al-Jalil", "meaning": "The Majestic — Possessing all attributes of glory"},
    {"arabic": "الْكَرِيم", "transliteration": "Al-Karim", "meaning": "The Generous — Overflowing with generosity"},
    {"arabic": "الرَّقِيب", "transliteration": "Ar-Raqib", "meaning": "The Watchful — Who observes all things constantly"},
    {"arabic": "الْمُجِيب", "transliteration": "Al-Mujib", "meaning": "The Responsive — Who answers every call and prayer"},
    {"arabic": "الْوَاسِع", "transliteration": "Al-Wasi'", "meaning": "The All-Encompassing — Whose capacity is boundless"},
    {"arabic": "الْحَكِيم", "transliteration": "Al-Hakim", "meaning": "The Wise — Who acts with perfect wisdom always"},
    {"arabic": "الْوَدُود", "transliteration": "Al-Wadud", "meaning": "The Loving — Who loves and is worthy of all love"},
    {"arabic": "الْمَاجِد", "transliteration": "Al-Majid", "meaning": "The Glorious — Whose glory is beyond all bounds"},
    {"arabic": "الْبَاعِث", "transliteration": "Al-Ba'ith", "meaning": "The Resurrector — Who raises all from the dead"},
    {"arabic": "الشَّهِيد", "transliteration": "Ash-Shahid", "meaning": "The Witness — Present and aware of all things"},
    {"arabic": "الْحَق", "transliteration": "Al-Haqq", "meaning": "The Truth — The Absolute Reality and True Being"},
    {"arabic": "الْوَكِيل", "transliteration": "Al-Wakil", "meaning": "The Trustee — The Perfect Guardian and Disposer"},
    {"arabic": "الْقَوِىّ", "transliteration": "Al-Qawiyy", "meaning": "The All-Strong — Whose strength is immeasurable"},
    {"arabic": "الْمَتِين", "transliteration": "Al-Matin", "meaning": "The Firm — Possessing absolute power and firmness"},
    {"arabic": "الْوَلِىّ", "transliteration": "Al-Waliyy", "meaning": "The Protecting Friend — Ally and Guardian of believers"},
    {"arabic": "الْحَمِيد", "transliteration": "Al-Hamid", "meaning": "The Praiseworthy — All praise belongs to Him alone"},
    {"arabic": "الْمُحْصِى", "transliteration": "Al-Muhsi", "meaning": "The Reckoner — Who counts and records everything"},
    {"arabic": "الْمُبْدِئ", "transliteration": "Al-Mubdi'", "meaning": "The Originator — Who begins creation from nothing"},
    {"arabic": "الْمُعِيد", "transliteration": "Al-Mu'id", "meaning": "The Restorer — Who brings back what has ended"},
    {"arabic": "الْمُحْيِى", "transliteration": "Al-Muhyi", "meaning": "The Giver of Life — Who grants life to all"},
    {"arabic": "الْمُمِيت", "transliteration": "Al-Mumit", "meaning": "The Taker of Life — Who brings death by His will"},
    {"arabic": "الْحَىّ", "transliteration": "Al-Hayy", "meaning": "The Ever-Living — Who was never born and never dies"},
    {"arabic": "الْقَيُّوم", "transliteration": "Al-Qayyum", "meaning": "The Self-Sustaining — On Whom all existence depends"},
    {"arabic": "الْوَاجِد", "transliteration": "Al-Wajid", "meaning": "The Finder — Who finds what He wills instantly"},
    {"arabic": "الْمَاجِد", "transliteration": "Al-Majid", "meaning": "The Noble — Full of honour and generosity"},
    {"arabic": "الْوَاحِد", "transliteration": "Al-Wahid", "meaning": "The One — Uniquely singular, without partner"},
    {"arabic": "الْأَحَد", "transliteration": "Al-Ahad", "meaning": "The Unique — Absolutely indivisible and alone"},
    {"arabic": "الصَّمَد", "transliteration": "As-Samad", "meaning": "The Eternal — On Whom all depend, Who depends on none"},
    {"arabic": "الْقَادِر", "transliteration": "Al-Qadir", "meaning": "The Capable — Who has power over everything"},
    {"arabic": "الْمُقْتَدِر", "transliteration": "Al-Muqtadir", "meaning": "The Powerful — All-prevailing over all affairs"},
    {"arabic": "الْمُقَدِّم", "transliteration": "Al-Muqaddim", "meaning": "The Expediter — Who brings forward whom He wills"},
    {"arabic": "الْمُؤَخِّر", "transliteration": "Al-Mu'akhkhir", "meaning": "The Delayer — Who puts back whom He wills"},
    {"arabic": "الْأَوَّل", "transliteration": "Al-Awwal", "meaning": "The First — Before Whom there was nothing"},
    {"arabic": "الْآخِر", "transliteration": "Al-Akhir", "meaning": "The Last — After Whom nothing shall remain"},
    {"arabic": "الظَّاهِر", "transliteration": "Az-Zahir", "meaning": "The Manifest — Evident through His signs in creation"},
    {"arabic": "الْبَاطِن", "transliteration": "Al-Batin", "meaning": "The Hidden — Whose essence is beyond all perception"},
    {"arabic": "الْوَالِى", "transliteration": "Al-Wali", "meaning": "The Governor — Who manages and governs all affairs"},
    {"arabic": "الْمُتَعَالِى", "transliteration": "Al-Muta'ali", "meaning": "The Self-Exalted — Supremely high beyond all things"},
    {"arabic": "الْبَرّ", "transliteration": "Al-Barr", "meaning": "The Source of Goodness — Kind and gracious to all"},
    {"arabic": "التَّوَّاب", "transliteration": "At-Tawwab", "meaning": "The Accepter of Repentance — Who turns to forgive"},
    {"arabic": "الْمُنْتَقِم", "transliteration": "Al-Muntaqim", "meaning": "The Avenger — Who justly punishes the wrongdoers"},
    {"arabic": "الْعَفُوّ", "transliteration": "Al-'Afuww", "meaning": "The Pardoner — Who erases sins completely"},
    {"arabic": "الرَّءُوف", "transliteration": "Ar-Ra'uf", "meaning": "The Most Kind — Who is full of compassion and tenderness"},
    {"arabic": "مَالِكُ الْمُلْك", "transliteration": "Malik-ul-Mulk", "meaning": "The Owner of All Sovereignty — Dominion is His alone"},
    {"arabic": "ذُو الْجَلَالِ وَالْإِكْرَام", "transliteration": "Dhul-Jalali wal-Ikram", "meaning": "Lord of Majesty and Generosity — Possessor of all glory"},
    {"arabic": "الْمُقْسِط", "transliteration": "Al-Muqsit", "meaning": "The Equitable — Who acts with perfect justice"},
    {"arabic": "الْجَامِع", "transliteration": "Al-Jami'", "meaning": "The Gatherer — Who gathers all on the Day of Judgment"},
    {"arabic": "الْغَنِىّ", "transliteration": "Al-Ghani", "meaning": "The Self-Sufficient — Free of all needs"},
    {"arabic": "الْمُغْنِى", "transliteration": "Al-Mughni", "meaning": "The Enricher — Who grants richness to whom He wills"},
    {"arabic": "الْمَانِع", "transliteration": "Al-Mani'", "meaning": "The Preventer — Who withholds to protect His servants"},
    {"arabic": "الضَّار", "transliteration": "Ad-Darr", "meaning": "The Distresser — Who creates harm as a trial and test"},
    {"arabic": "النَّافِع", "transliteration": "An-Nafi'", "meaning": "The Propitious — Who creates all benefit and good"},
    {"arabic": "النُّور", "transliteration": "An-Nur", "meaning": "The Light — Who illuminates the heavens and the earth"},
    {"arabic": "الْهَادِى", "transliteration": "Al-Hadi", "meaning": "The Guide — Who leads to the straight path"},
    {"arabic": "الْبَدِيع", "transliteration": "Al-Badi'", "meaning": "The Incomparable — Who creates without any model"},
    {"arabic": "الْبَاقِى", "transliteration": "Al-Baqi", "meaning": "The Everlasting — Who remains when all things perish"},
    {"arabic": "الْوَارِث", "transliteration": "Al-Warith", "meaning": "The Inheritor — Who remains after all creation ends"},
    {"arabic": "الرَّشِيد", "transliteration": "Ar-Rashid", "meaning": "The Guide to the Right Path — Whose guidance is perfect"},
    {"arabic": "الصَّبُور", "transliteration": "As-Sabur", "meaning": "The Patient — Who is never hasty in punishment"},
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
      backgroundColor: const Color(0xFFFAF8F2),
      appBar: AppBar(
        title: const Text('Asma ul Husna', style: TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: const Color(0xFF1A1208),
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
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
                childAspectRatio: 1.15, // Made smaller and wider
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
            colors: [Color(0xFF1A1208), Color(0xFFFAF8F2)],
          ),
        ),
        child: Column(
          children: [
            const Text(
              'بِسْمِ اللَّٰهِ',
              style: TextStyle(
                fontFamily: 'Jameel Noori',
                fontSize: 52,
                color: Color(0xFFD4AF37),
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 12),
            Text(
              'ASMĀ UL ḤUSNĀ',
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
              'The 99 Beautiful Names of Allah',
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFFD4AF37).withOpacity(0.7),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 48),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  const Color(0xFFD4AF37).withOpacity(0.6),
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
    final isEven = index % 2 == 0;
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
                  colors: [Color(0xFF1A1208), Color(0xFF2E1F0A)],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFF5F0E8)],
                ),
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? const Color(0xFFD4AF37).withOpacity(0.35)
                  : Colors.black.withOpacity(0.06),
              blurRadius: isActive ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isActive
                ? const Color(0xFFD4AF37).withOpacity(0.8)
                : const Color(0xFFD4AF37).withOpacity(0.18),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Number badge
            Positioned(
              top: 8,
              left: 10,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? const Color(0xFFD4AF37).withOpacity(0.2)
                      : const Color(0xFFD4AF37).withOpacity(0.12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.4),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? const Color(0xFFD4AF37)
                          : const Color(0xFF8B6914),
                    ),
                  ),
                ),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 22, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Arabic name
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
                          color: isActive
                              ? const Color(0xFFD4AF37)
                              : const Color(0xFF1A1208),
                        ),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Divider
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: const Color(0xFFD4AF37).withOpacity(0.25),
                  ),
                  const SizedBox(height: 4),
                  // Transliteration
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
                            color: isActive
                                ? Colors.white
                                : const Color(0xFF8B6914),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 1),
                        // Meaning
                        Text(
                          data['meaning']!,
                          style: TextStyle(
                            fontSize: 9,
                            height: 1.2,
                            color: isActive
                                ? Colors.white.withOpacity(0.7)
                                : const Color(0xFF6B5B3E).withOpacity(0.85),
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

