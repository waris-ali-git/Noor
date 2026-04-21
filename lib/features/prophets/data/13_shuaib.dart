import '../models/prophet_model.dart';

const ProphetModel shuaib = ProphetModel(
  id: 13,
  arabicName: 'شعيب',
  englishName: 'Shuaib',
  title: 'The Eloquent Prophet',
  period: '~1700 BCE',
  mentionedIn: 'Quran 7:85–93, 11:84–95, 26:176–191',
  keyLesson: 'Honesty in trade and business is a divine obligation.',
  emoji: '⚖️',
  shortBio:
      'Sent to the people of Madyan and the Companions of the Wood, Shuaib\'s primary mission was to end economic corruption — cheating in weights and measures — and return his people to honest trade.',
  tableOfContents: [
    'The People of Madyan',
    'Shuaib\'s Message: Economic Justice',
    'The Punishment',
  ],
  sections: [
    ProphetSection(
      heading: 'The People of Madyan',
      content:
          'The people of Madyan were a trading community who had fallen into a unique form of corruption: they cheated in their business transactions, giving short measures and weights while taking full value. They also created corruption in the land through other injustices.',
    ),
    ProphetSection(
      heading: 'Shuaib\'s Message: Economic Justice',
      content:
          'Shuaib (عَلَيْهِ ٱلسَّلَامُ) called them clearly: "O my people, worship Allah; you have no deity other than Him. Do not decrease from the measure and the scale. Indeed, I see you in prosperity, but I fear for you the punishment of an all-encompassing Day." (11:84).\n\nHe was known for his exceptional eloquence — his people called him "the most eloquent of men." They told him: "We don\'t understand much of what you say" — not because he was unclear, but because they refused to engage with the truth.',
    ),
    ProphetSection(
      heading: 'The Punishment',
      content:
          'When the people of Madyan persisted in their corruption and threatened Shuaib, a punishment came in the form of an overwhelming blast — the Sayhah. The people of the Wood met a similar fate with a day of shadow (a dark cloud that turned into fire).\n\nShuaib walked away in sorrow: "O my people! I did convey to you the messages of my Lord, and I was sincere to you. How then can I sorrow for a disbelieving people?" (7:93)',
    ),
  ],
);
