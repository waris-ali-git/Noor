import '../models/prophet_model.dart';

const ProphetModel alyasa = ProphetModel(
  id: 20,
  arabicName: 'اليسع',
  englishName: 'Alyasa',
  title: 'Successor to Ilyas',
  period: '~850 BCE',
  mentionedIn: 'Quran 6:86, 38:48',
  keyLesson: 'Righteousness in quiet service is no less honored than dramatic prophethood.',
  emoji: '🌿',
  shortBio:
      'Alyasa (Elisha) was the companion and successor of Ilyas. He continued the prophetic mission with devotion and is praised alongside the greatest prophets in the Quran.',
  tableOfContents: ['Companion of Ilyas', 'Praise in the Quran'],
  sections: [
    ProphetSection(
      heading: 'Companion of Ilyas',
      content:
          'In biblical tradition, Elisha was the devoted disciple and successor of Elijah. He witnessed miracles, learned from his teacher, and eventually carried on the prophetic mission after Ilyas. His dedication is captured in the narrations of his following Ilyas and refusing to leave his side even when given the opportunity.',
    ),
    ProphetSection(
      heading: 'Praise in the Quran',
      content:
          'Allah mentions Alyasa among His chosen ones: "And Ismail and Alyasa and Yunus and Lut — all of them We preferred over the worlds." (6:86). And in another verse: "And remember Our servants Ismail, Alyasa, and Dhul-Kifl — and all of them were from the best." (38:48).\n\nThe fact that Alyasa is mentioned in such esteemed company, despite minimal detail in the Quran, is itself a lesson — in Allah\'s sight, quiet devotion and faithful service are worthy of eternal honor.',
    ),
  ],
);
