import '../models/prophet_model.dart';

const ProphetModel ayyub = ProphetModel(
  id: 12,
  arabicName: 'أيوب',
  englishName: 'Ayyub',
  title: 'The Epitome of Patience',
  period: '~1700 BCE',
  mentionedIn: 'Quran 21:83–84, 38:41–44',
  keyLesson: 'Patience in affliction is the highest form of trust in Allah.',
  emoji: '🙏',
  shortBio:
      'Ayyub (Job) was a wealthy and righteous prophet stripped of everything — health, wealth, and children. His patient endurance for years became the standard of sabr for all believers.',
  tableOfContents: [
    'Ayyub Before the Trial',
    'The Years of Affliction',
    'The Prayer that Ended the Trial',
  ],
  sections: [
    ProphetSection(
      heading: 'Ayyub Before the Trial',
      content:
          'Ayyub (عَلَيْهِ ٱلسَّلَامُ) was blessed with tremendous wealth, a large family, and perfect health. More importantly, he was blessed with righteousness — he was a grateful, devoted servant of Allah who distributed his wealth generously among the poor.',
    ),
    ProphetSection(
      heading: 'The Years of Affliction',
      content:
          'Allah tested Ayyub by removing all his blessings. His wealth was lost, his children died, and a painful illness afflicted his body for years — some narrations say 18 years. Yet throughout it all, Ayyub did not complain to others, did not question Allah, and did not abandon his prayers.\n\nHis wife, who had been with him through everything, worked as a servant to earn their food. When even she was driven away, Ayyub\'s trial was complete.',
    ),
    ProphetSection(
      heading: 'The Prayer that Ended the Trial',
      content:
          'The prayer of Ayyub is among the most beautiful in the Quran: "Indeed, adversity has touched me, and You are the Most Merciful of the merciful." (21:83). It is not a complaint — it is a statement of fact combined with an acknowledgment of Allah\'s mercy. Allah responded: "So We responded to him and removed what afflicted him of adversity. And We restored his family and the like thereof with them." (21:84).\n\nAyyub\'s name became synonymous with patience. Whenever Muslims speak of someone with extraordinary sabr, they say: "He has the patience of Ayyub."',
    ),
  ],
);
