import '../models/prophet_model.dart';

const ProphetModel harun = ProphetModel(
  id: 15,
  arabicName: 'هارون',
  englishName: 'Harun',
  title: 'The Eloquent Brother',
  period: '~1300 BCE',
  mentionedIn: 'Quran 20:29–36, 28:34',
  keyLesson: 'A true helper in the cause of Allah is one of the greatest gifts.',
  emoji: '🗣️',
  shortBio:
      'Brother and companion of Musa, Harun (Aaron) was given as a prophet alongside him at his own request. Known for his eloquence, he supported Musa throughout his mission.',
  tableOfContents: ['Harun as Musa\'s Support', 'The Trial of the Golden Calf'],
  sections: [
    ProphetSection(
      heading: 'Harun as Musa\'s Support',
      content:
          'When Allah appointed Musa for the mission to Pharaoh, Musa made a heartfelt dua: "And appoint for me a minister from my family — Harun, my brother. Increase through him my strength and let him share my task." (20:29–32). Allah granted this request — Harun was made a prophet and sent alongside Musa.\n\nHarun\'s eloquence complemented Musa\'s strength and directness. Together they were a complete team — one bold and direct, the other smooth and persuasive. This shows the value of recognizing one\'s weaknesses and seeking complementary support.',
    ),
    ProphetSection(
      heading: 'The Trial of the Golden Calf',
      content:
          'When Musa went to Mount Sinai for forty days, he left Harun in charge of the Children of Israel. During his absence, the Samiri crafted a golden calf and the people began to worship it. Harun tried to stop them but was threatened and outvoted. When Musa returned, he was furious and grabbed Harun\'s beard in anger. Harun explained: "O son of my mother! Do not seize me by my beard or my head. I was afraid you would say: You have caused division among the Children of Israel." (20:94).\n\nHarun had prioritized unity over confrontation, hoping Musa\'s return would settle things. This incident teaches leaders the difficult balance between firmness and unity.',
    ),
  ],
);
