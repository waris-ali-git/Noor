import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants.dart';
import '../models/counter.dart';

class TasbeehService {
  static const String _countersKey = 'tasbeeh_counters';
  static const String _sessionsKey = 'tasbeeh_sessions';
  static const String _settingsKey = 'tasbeeh_settings';

  // ─── Load all counters from storage ───────────────────────────────────────
  Future<List<TasbeehCounter>> loadCounters() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_countersKey);

    if (jsonString == null) {
      // First launch: load presets
      return _buildPresetCounters();
    }

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => TasbeehCounter.fromJson(e)).toList();
  }

  // ─── Save all counters ─────────────────────────────────────────────────────
  Future<void> saveCounters(List<TasbeehCounter> counters) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = counters.map((c) => c.toJson()).toList();
    await prefs.setString(_countersKey, json.encode(jsonList));
  }

  // ─── Save a session ────────────────────────────────────────────────────────
  Future<void> saveSession(TasbeehSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_sessionsKey);
    final List<dynamic> sessions =
    existing != null ? json.decode(existing) : [];

    sessions.add({
      'id': session.id,
      'tasbeehId': session.tasbeehId,
      'tasbeehName': session.tasbeehName,
      'count': session.count,
      'startTime': session.startTime.toIso8601String(),
      'endTime': session.endTime.toIso8601String(),
    });

    // Keep only last 100 sessions
    if (sessions.length > 100) sessions.removeAt(0);

    await prefs.setString(_sessionsKey, json.encode(sessions));
  }

  // ─── Load sessions ─────────────────────────────────────────────────────────
  Future<List<TasbeehSession>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_sessionsKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((e) => TasbeehSession(
      id: e['id'],
      tasbeehId: e['tasbeehId'],
      tasbeehName: e['tasbeehName'],
      count: e['count'],
      startTime: DateTime.parse(e['startTime']),
      endTime: DateTime.parse(e['endTime']),
    )).toList();
  }

  // ─── Settings ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_settingsKey);
    if (jsonString == null) {
      return {
        'vibrationEnabled': true,
        'soundEnabled': false,
        'keepScreenOn': true,
        'nightMode': false,
        'autoReset': false,
        'showTransliteration': true,
        'showTranslation': true,
        'fontSize': 'medium',
      };
    }
    return json.decode(jsonString);
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, json.encode(settings));
  }

  // ─── Reset all data ────────────────────────────────────────────────────────
  Future<void> resetAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_countersKey);
    await prefs.remove(_sessionsKey);
  }

  // ─── Build preset counters from constants ──────────────────────────────────
  List<TasbeehCounter> _buildPresetCounters() {
    return kPresetDhikr.map((data) => TasbeehCounter(
      id: data['id'],
      name: data['name'],
      arabicText: data['arabicText'],
      transliteration: data['transliteration'],
      translation: data['translation'],
      targetCount: data['targetCount'],
      category: data['category'],
    )).toList();
  }

  // ─── Statistics ────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getStatistics(
      List<TasbeehCounter> counters) async {
    final sessions = await loadSessions();

    final totalCount = counters.fold<int>(0, (s, c) => s + c.totalCount);
    final totalSessions = counters.fold<int>(0, (s, c) => s + c.totalSessions);
    final mostUsed = counters.isEmpty
        ? null
        : counters.reduce((a, b) => a.totalCount > b.totalCount ? a : b);

    // Today's count
    final today = DateTime.now();
    final todaySessions = sessions.where((s) =>
    s.startTime.day == today.day &&
        s.startTime.month == today.month &&
        s.startTime.year == today.year);
    final todayCount = todaySessions.fold<int>(0, (s, sess) => s + sess.count);

    return {
      'totalCount': totalCount,
      'totalSessions': totalSessions,
      'mostUsed': mostUsed,
      'todayCount': todayCount,
      'uniqueDhikr': counters.length,
    };
  }
}