class RakatInfo {
  final String prayerName;
  final int sunnahMuakkadahBefore;
  final int sunnahGhairMuakkadahBefore;
  final int fard;
  final int sunnahAfter;
  final int nafl;
  final int witr;
  final int naflAfterWitr;
  final int total;

  const RakatInfo({
    required this.prayerName,
    this.sunnahMuakkadahBefore = 0,
    this.sunnahGhairMuakkadahBefore = 0,
    this.fard = 0,
    this.sunnahAfter = 0,
    this.nafl = 0,
    this.witr = 0,
    this.naflAfterWitr = 0,
    required this.total,
  });
}

const List<RakatInfo> rakatData = [
  RakatInfo(prayerName: 'Fajr', sunnahMuakkadahBefore: 2, fard: 2, total: 4),
  RakatInfo(prayerName: 'Dhuhr', sunnahMuakkadahBefore: 4, fard: 4, sunnahAfter: 2, nafl: 2, total: 12),
  RakatInfo(prayerName: 'Asr', sunnahGhairMuakkadahBefore: 4, fard: 4, total: 8),
  RakatInfo(prayerName: 'Maghrib', fard: 3, sunnahAfter: 2, nafl: 2, total: 7),
  RakatInfo(prayerName: 'Isha', sunnahGhairMuakkadahBefore: 4, fard: 4, sunnahAfter: 2, nafl: 2, witr: 3, naflAfterWitr: 2, total: 17),
  RakatInfo(prayerName: 'Jumu\'ah', sunnahMuakkadahBefore: 4, fard: 2, sunnahAfter: 4, nafl: 2, total: 14),
];
