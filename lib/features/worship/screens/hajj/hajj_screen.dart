import 'package:flutter/material.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/widgets/language_selector_button.dart';

class HajjScreen extends StatefulWidget {
  const HajjScreen({super.key});

  @override
  State<HajjScreen> createState() => _HajjScreenState();
}

class _HajjScreenState extends State<HajjScreen> {
  final Map<String, bool> _checklist = {
    "Passport & Visa": false,
    "Ihram Towels (x2)": false,
    "Comfortable Slippers": false,
    "Basic First Aid & Medicines": false,
    "Prayer Mat": false,
    "Umbrella / Sun Glasses": false,
    "Power Bank": false,
    "Fragrance-Free Soap/Lotion": false,
    "Small Backpack for Mina": false,
    "Nail Clipper & Scissors": false,
  };

  final List<Map<String, String>> _guideSteps = [
    {
      "title": "1. Preparation & Ihram",
      "desc": "Perform Ghusl, wear the Ihram, and make the intention for Hajj before crossing the Miqat. Start reciting the Talbiyah."
    },
    {
      "title": "2. Tawaf al-Qudum",
      "desc": "Upon reaching Masjid al-Haram, perform 7 circuits of the Kaaba starting from the Black Stone."
    },
    {
      "title": "3. Sa'i",
      "desc": "Walk 7 times between the hills of Safa and Marwa. Afterwards, remain in the state of Ihram if performing Hajj al-Ifrad or Qiran."
    },
    {
      "title": "4. 8th Dhul Hijjah - Mina",
      "desc": "Proceed to Mina before Dhuhr. Stay there until the next morning, praying all 5 prayers (Dhuhr, Asr, Maghrib, Isha, Fajr)."
    },
    {
      "title": "5. 9th Dhul Hijjah - Arafat",
      "desc": "The pinnacle of Hajj. Proceed to Arafat and spend the day in intense Dua and repentance until sunset."
    },
    {
      "title": "6. Night of 9th - Muzdalifah",
      "desc": "Leave Arafat after sunset without praying Maghrib. Pray Maghrib and Isha combined at Muzdalifah, sleep, and collect pebbles."
    },
    {
      "title": "7. 10th Dhul Hijjah - Rami & Sacrifice",
      "desc": "Return to Mina to throw 7 pebbles at Jamarat al-Aqabah. Then perform the sacrifice, followed by shaving/cutting hair to begin leaving Ihram."
    },
    {
      "title": "8. Tawaf al-Ifadah",
      "desc": "Return to Makkah to perform Tawaf al-Ifadah and Sa'i (if required). You are now completely out of Ihram restrictions."
    },
    {
      "title": "9. 11th-13th - Days of Tashreeq",
      "desc": "Stay in Mina and pelt all three Jamarat each afternoon. Perform the Farewell Tawaf (Wada) before leaving Makkah."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const TranslatedText('Hajj Companion', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: const [LanguageSelectorButton()],
          bottom: const TabBar(
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.teal,
            tabs: [
              Tab(icon: Icon(Icons.map), text: "Guide"),
              Tab(icon: Icon(Icons.menu_book), text: "Duas"),
              Tab(icon: Icon(Icons.checklist), text: "Checklist"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGuideTab(),
            _buildDuasTab(),
            _buildChecklistTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _guideSteps.length,
      itemBuilder: (context, index) {
        final step = _guideSteps[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              child: Text("${index + 1}", style: TextStyle(color: Colors.teal.shade900, fontWeight: FontWeight.bold)),
            ),
            title: TranslatedText(step["title"]!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TranslatedText(step["desc"]!),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDuasTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDuaCard(
          "The Talbiyah",
          "لَبَّيْكَ اللّٰهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ",
          "Labbayk, Allahumma Labbayk, Labbayka la sharika laka Labbayk, Innal hamda wanni'mata laka walmulk, La sharika lak",
          "Here I am, O Allah, here I am. Here I am, You have no partner, here I am. Verily all praise and blessings are Yours, and all sovereignty, You have no partner."
        ),
        const SizedBox(height: 16),
        _buildDuaCard(
          "At Safa & Marwa",
          "إِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَآئِرِ اللّٰهِ",
          "Innas-Safa wal-Marwata min sha'aa'irillaah",
          "Indeed, Safa and Marwa are from the signs of Allah."
        ),
        const SizedBox(height: 16),
        _buildDuaCard(
          "Dua on the Day of Arafat",
          "لَا إِلٰهَ إِلَّا اللّٰهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ",
          "La ilaha illallahu wahdahu la sharika lahu, lahul mulk wa lahul hamdu, wa huwa 'ala kulli shay'in qadeer",
          "There is no deity but Allah alone, without partner. To Him belongs the dominion, and to Him belongs all praise, and He has power over all things."
        ),
      ],
    );
  }

  Widget _buildDuaCard(String title, String arabic, String transliteration, String translation) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TranslatedText(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 12),
            Text(
              arabic,
              textAlign: TextAlign.right,
              style: const TextStyle(fontFamily: 'UthmanicHafs', fontSize: 24, height: 1.5),
              textDirection: TextDirection.rtl,
            ),
            const Divider(height: 16),
            Text(
              transliteration,
              style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            TranslatedText(
              translation,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _checklist.keys.length,
      itemBuilder: (context, index) {
        String key = _checklist.keys.elementAt(index);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: CheckboxListTile(
            title: TranslatedText(key, 
              style: TextStyle(
                decoration: _checklist[key]! ? TextDecoration.lineThrough : null,
                color: _checklist[key]! ? Colors.grey : Colors.black87
              )
            ),
            value: _checklist[key],
            activeColor: Colors.teal,
            onChanged: (bool? value) {
              setState(() {
                _checklist[key] = value ?? false;
              });
            },
          ),
        );
      },
    );
  }
}
