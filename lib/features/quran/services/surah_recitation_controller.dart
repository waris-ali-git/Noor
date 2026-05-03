import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'word_timing_service.dart';

/// Holds the current highlight state for the mushaf.
/// [activeAyah] = currently playing ayah number in surah (1-based)
/// [activeWordIndex] = currently highlighted word (1-based position from API)
/// [fadingWords] = set of "${ayahNumber}_${wordPosition}" keys fading out
class RecitationHighlightState {
  final int? activeAyah;
  final int? activeWordIndex;
  final Set<String> fadingWords;
  final bool isPlaying;

  const RecitationHighlightState({
    this.activeAyah,
    this.activeWordIndex,
    this.fadingWords = const {},
    this.isPlaying = false,
  });

  RecitationHighlightState copyWith({
    int? activeAyah,
    int? activeWordIndex,
    Set<String>? fadingWords,
    bool? isPlaying,
  }) {
    return RecitationHighlightState(
      activeAyah: activeAyah ?? this.activeAyah,
      activeWordIndex: activeWordIndex ?? this.activeWordIndex,
      fadingWords: fadingWords ?? this.fadingWords,
      isPlaying: isPlaying ?? this.isPlaying,
    );
  }

  /// Check if a specific word should be highlighted golden
  bool isWordActive(int ayahNumberInSurah, int wordPosition) {
    return activeAyah == ayahNumberInSurah && activeWordIndex == wordPosition;
  }

  /// Check if a word is in the fading-out phase
  bool isWordFading(int ayahNumberInSurah, int wordPosition) {
    return fadingWords.contains('${ayahNumberInSurah}_$wordPosition');
  }
}

/// Controls surah-level recitation with word-level golden highlighting.
/// 
/// Flow:
/// 1. Load chapter audio + timing segments via WordTimingService
/// 2. Play full-chapter audio via just_audio
/// 3. Monitor audio position via periodic timer
/// 4. Map position → current verse + word → emit highlight state
/// 5. When a word finishes, add to fading set (stays golden ~2s then removed)
class SurahRecitationController extends ChangeNotifier {
  final WordTimingService _timingService;
  final AudioPlayer _player = AudioPlayer();

  ChapterAudioData? _audioData;
  RecitationHighlightState _state = const RecitationHighlightState();
  Timer? _positionTimer;

  // Track previous word to detect transitions
  String? _prevWordKey;

  // Completion listener
  StreamSubscription<PlayerState>? _completionSub;

  RecitationHighlightState get state => _state;
  bool get isLoading => _isLoading;
  bool _isLoading = false;
  bool get isReady => _audioData != null && !_isLoading;

  SurahRecitationController(this._timingService);

  /// Initialize audio data for a chapter. Call before play.
  Future<bool> loadChapter(int chapterNumber, {String reciterId = 'alafasy'}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _audioData = await _timingService.getChapterAudioWithSegments(
        chapterNumber,
        reciterId: reciterId,
      );

      if (_audioData == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _player.setUrl(_audioData!.audioUrl);
      
      // Listen for completion (only once)
      _completionSub?.cancel();
      _completionSub = _player.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          stop();
        }
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ SurahRecitationController.loadChapter: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Start or resume playback — instant UI update
  Future<void> play() async {
    if (_audioData == null) return;

    // Update state FIRST so UI responds instantly
    _state = _state.copyWith(isPlaying: true);
    notifyListeners();

    // Start position tracking immediately
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _updateHighlightFromPosition();
    });

    // Then start audio (might take a few ms)
    _player.play();
  }

  /// Pause — instantly freezes everything
  Future<void> pause() async {
    // Stop tracking immediately
    _positionTimer?.cancel();

    // Freeze current highlight: keep active word golden, clear fading
    _state = RecitationHighlightState(
      activeAyah: _state.activeAyah,
      activeWordIndex: _state.activeWordIndex,
      fadingWords: const {}, // clear fading trail on pause
      isPlaying: false,
    );
    notifyListeners();

    // Then pause audio
    _player.pause();
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_state.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// Stop and reset everything
  Future<void> stop() async {
    _positionTimer?.cancel();
    _player.stop();
    _prevWordKey = null;
    _state = const RecitationHighlightState();
    notifyListeners();
  }

  /// Core logic: map current audio position to the active word
  void _updateHighlightFromPosition() {
    if (_audioData == null) return;

    final posMs = _player.position.inMilliseconds;
    
    // Find which verse we're in
    VerseTiming? currentVerse;
    for (final vt in _audioData!.verseTimings) {
      if (posMs >= vt.timestampFrom && posMs < vt.timestampTo) {
        currentVerse = vt;
        break;
      }
    }

    if (currentVerse == null) return;

    // Find which word we're on
    int? activeWord;
    for (final wt in currentVerse.wordTimings) {
      if (posMs >= wt.startMs && posMs < wt.endMs) {
        activeWord = wt.wordIndex;
        break;
      }
    }

    // If between word gaps, keep the last word active
    if (activeWord == null && currentVerse.wordTimings.isNotEmpty) {
      for (int i = currentVerse.wordTimings.length - 1; i >= 0; i--) {
        if (posMs >= currentVerse.wordTimings[i].startMs) {
          activeWord = currentVerse.wordTimings[i].wordIndex;
          break;
        }
      }
    }

    final ayahNum = currentVerse.ayahNumber;
    final newWordKey = activeWord != null ? '${ayahNum}_$activeWord' : null;

    // Only update if word changed
    if (newWordKey != _prevWordKey) {
      // Add previous word to fading set
      final newFading = Set<String>.from(_state.fadingWords);
      if (_prevWordKey != null) {
        newFading.add(_prevWordKey!);
        // Schedule removal after 2 seconds
        final keyToRemove = _prevWordKey!;
        Future.delayed(const Duration(seconds: 2), () {
          if (_state.fadingWords.contains(keyToRemove)) {
            final updated = Set<String>.from(_state.fadingWords)..remove(keyToRemove);
            _state = _state.copyWith(fadingWords: updated);
            notifyListeners();
          }
        });
      }

      _prevWordKey = newWordKey;
      _state = RecitationHighlightState(
        activeAyah: ayahNum,
        activeWordIndex: activeWord,
        fadingWords: newFading,
        isPlaying: true,
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _completionSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}

