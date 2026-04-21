import '../models/prophet_model.dart';

const ProphetModel dawud = ProphetModel(
  id: 17,
  arabicName: 'داود',
  englishName: 'Dawud',
  title: 'The Prophet-King',
  period: '~1000 BCE',
  mentionedIn: 'Quran 2:251, 4:163, 17:55, 21:78–79, 38:17–26',
  keyLesson: 'Power and prophethood together — true leadership serves Allah, not the self.',
  emoji: '🎵',
  shortBio:
      'A young shepherd who killed Goliath with a sling, becoming King of Israel. He was given the Zabur (Psalms), the ability to make iron malleable, and a voice so beautiful that mountains and birds sang with him.',
  tableOfContents: [
    'The Young Shepherd and Goliath',
    'King and Prophet',
    'Gifts of Dawud',
    'The Zabur',
    'A Moment of Trial',
  ],
  sections: [
    ProphetSection(
      heading: 'The Young Shepherd and Goliath',
      content:
          'The Children of Israel faced the mighty Goliath (Jalut) and his army. When Talut (Saul) led a small army of believers against them, it was a young shepherd named Dawud who stepped forward to face the giant. With a sling and stones, and absolute trust in Allah, Dawud killed Goliath.\n\n"So they defeated them by permission of Allah, and Dawud killed Goliath, and Allah gave him the kingship and prophethood and taught him from that which He willed." (2:251). From shepherd to king in a single day — but the real transformation was inward.',
    ),
    ProphetSection(
      heading: 'King and Prophet',
      content:
          'Dawud ruled with extraordinary justice. The Quran records Allah telling him: "O Dawud, indeed We have made you a successor upon the earth, so judge between the people in truth and do not follow desire, as it will lead you astray from the way of Allah." (38:26).\n\nHe was a warrior, a judge, a poet, and a prophet — all combined in one person. His kingdom became a model of justice and divine guidance.',
    ),
    ProphetSection(
      heading: 'Gifts of Dawud',
      content:
          'Allah blessed Dawud with extraordinary gifts: mountains and birds responded to his glorification of Allah, joining his hymns of praise. He was taught to craft armor from iron — a skill Allah gave him miraculously. His voice was the most beautiful ever created, such that when he sang the Zabur, all of creation listened.',
    ),
    ProphetSection(
      heading: 'The Zabur',
      content:
          'Allah gave Dawud the Zabur (Psalms) — a book of divine praise, wisdom, and guidance. "And to Dawud We gave the Zabur." (17:55). The Psalms of the Bible are believed to trace back to this revelation, though the original form has not been preserved in its entirety.',
    ),
    ProphetSection(
      heading: 'A Moment of Trial',
      content:
          'The Quran relates a trial of Dawud regarding a judgment — described through a parable of two men arguing over sheep — in which Dawud recognized he had been tested and immediately fell in prostration: "And Dawud became certain that We had tried him, so he asked forgiveness of his Lord, fell bowing, and turned in repentance." (38:24).\n\nThis teaches that even the greatest prophets remain human, and the test of a great person is how swiftly they return to Allah.',
    ),
  ],
);
