class PrayerTiming {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String sunset;
  final String maghrib;
  final String isha;
  final String hijriDate;
  final String hijriMonth;
  final String hijriYear;
  final String gregorianDate;

  const PrayerTiming({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.sunset,
    required this.maghrib,
    required this.isha,
    required this.hijriDate,
    required this.hijriMonth,
    required this.hijriYear,
    required this.gregorianDate,
  });

  factory PrayerTiming.fromJson(Map<String, dynamic> json) {
    final timings = json['timings'];
    final date = json['date'];
    final hijri = date['hijri'];
    final gregorian = date['gregorian'];

    return PrayerTiming(
      fajr: timings['Fajr'],
      sunrise: timings['Sunrise'],
      dhuhr: timings['Dhuhr'],
      asr: timings['Asr'],
      sunset: timings['Sunset'],
      maghrib: timings['Maghrib'],
      isha: timings['Isha'],
      hijriDate: hijri['day'],
      hijriMonth: hijri['month']['en'],
      hijriYear: hijri['year'],
      gregorianDate: gregorian['date'],
    );
  }
}
