import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:just_audio/just_audio.dart';
import '../../models/surah.dart';
import '../../models/ayah.dart';

/// Renders Surah text in a mushaf-style page layout.
/// Performance optimised: pre-builds spans once, uses RepaintBoundary,
/// single shared AudioPlayer with proper stop-before-play.
class MushafPagePreview extends StatefulWidget {
  final Surah surah;
  final void Function(int ayahNumber)? onAyahMarkerTap;

  const MushafPagePreview({
    super.key, 
    required this.surah,
    this.onAyahMarkerTap,
  });

  @override
  State<MushafPagePreview> createState() => _MushafPagePreviewState();
}

class _MushafPagePreviewState extends State<MushafPagePreview> {
  static const List<String> _bismillahVariants = [
    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', // AlQuran.cloud general
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', // AlQuran.cloud variant for Baqarah, etc.
    'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ', // Fatiha specific
    'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَـٰنِ ٱلرَّحِيمِ',
    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
    'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
    'بِسمِ اللَّهِ الرَّحمٰنِ الرَّحيمِ', // IndoPak style
    'بسم الله الرحمن الرحيم',
    '﷽',
  ];

  // Single shared audio player (reused across all taps for performance)
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _highlightedWordKey;
  OverlayEntry? _tooltipEntry;

  @override
  void dispose() {
    _audioPlayer.dispose();
    _removeTooltip();
    super.dispose();
  }

  // ─── Tooltip ───────────────────────────────────

  void _removeTooltip() {
    _tooltipEntry?.remove();
    _tooltipEntry = null;
  }

  void _showTooltip(BuildContext context, AyahWord word, Offset globalPosition) {
    _removeTooltip();

    if ((word.translation == null || word.translation!.isEmpty) &&
        (word.transliteration == null || word.transliteration!.isEmpty)) {
      return;
    }

    final screenSize = MediaQuery.of(context).size;
    double left = globalPosition.dx - 60;
    if (left < 16) left = 16;
    if (left + 140 > screenSize.width) left = screenSize.width - 150;

    _tooltipEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: left,
          top: globalPosition.dy - 70,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.9 + (0.1 * value),
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                constraints: const BoxConstraints(maxWidth: 180),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E20),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (word.translation != null && word.translation!.isNotEmpty)
                      Text(
                        word.translation!,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    if (word.transliteration != null && word.transliteration!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        word.transliteration!,
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_tooltipEntry!);
  }

  // ─── Audio + Tap Handler ───────────────────────

  Future<void> _handleWordTap(BuildContext context, AyahWord word, String wordKey, TapUpDetails details) async {
    // Toggle off if tapping same word while playing
    if (_highlightedWordKey == wordKey && _audioPlayer.playing) {
      await _audioPlayer.stop();
      setState(() => _highlightedWordKey = null);
      _removeTooltip();
      return;
    }

    setState(() => _highlightedWordKey = wordKey);
    _showTooltip(context, word, details.globalPosition);

    if (word.audioUrl != null && word.audioUrl!.isNotEmpty) {
      try {
        // CRITICAL: stop + seek to reset player state before loading new URL
        await _audioPlayer.stop();
        await _audioPlayer.seek(Duration.zero);
        await _audioPlayer.setUrl(word.audioUrl!);
        _audioPlayer.play(); // fire-and-forget to keep UI responsive
        // Wait for completion
        await _audioPlayer.playerStateStream.firstWhere(
          (state) => state.processingState == ProcessingState.completed,
        );
      } catch (_) {
        // Playback could fail or be interrupted — swallow silently
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 800));
    }

    if (mounted && _highlightedWordKey == wordKey) {
      setState(() => _highlightedWordKey = null);
      _removeTooltip();
    }
  }

  // ─── Helpers ───────────────────────────────────

  String _toArabicDigits(int number) {
    const digits = ['\u0660', '\u0661', '\u0662', '\u0663', '\u0664', '\u0665', '\u0666', '\u0667', '\u0668', '\u0669'];
    return number.toString().split('').map((e) => digits[int.parse(e)]).join('');
  }

  String _extractApiBismillah(String ayah1Text) {
    final cleanText = ayah1Text.cleanArabic.trim();
    for (final variant in _bismillahVariants) {
      final cleanVariant = variant.cleanArabic;
      if (cleanText.startsWith(cleanVariant)) {
        return cleanVariant;
      }
    }
    return _bismillahVariants[1].cleanArabic;
  }

  String _stripApiBismillah(String text) {
    final cleanText = text.cleanArabic.trim();
    for (final variant in _bismillahVariants) {
      final cleanVariant = variant.cleanArabic;
      if (cleanText.startsWith(cleanVariant)) {
        return cleanText.substring(cleanVariant.length).trimLeft();
      }
    }
    return cleanText;
  }

  // ─── Build word spans (shared between Fatiha & Mushaf pages) ─────

  List<InlineSpan> _buildWordSpans(List<Ayah> ayahs, {bool stripBismillah = false}) {
    final List<InlineSpan> spans = [];
    for (final ayah in ayahs) {
      if (ayah.ayahWords != null && ayah.ayahWords!.isNotEmpty) {
        for (var j = 0; j < ayah.ayahWords!.length; j++) {
          final word = ayah.ayahWords![j];
          final wordKey = '${ayah.number}_${word.position}';
          final isHighlighted = _highlightedWordKey == wordKey;
          spans.add(
            TextSpan(
              text: word.arabic.cleanArabic,
              style: TextStyle(
                color: isHighlighted ? const Color(0xFF388E3C) : Colors.black87,
                backgroundColor: isHighlighted ? const Color(0xFFE8F5E9) : Colors.transparent,
              ),
              recognizer: TapGestureRecognizer()
                ..onTapUp = (details) => _handleWordTap(context, word, wordKey, details),
            ),
          );
          if (j < ayah.ayahWords!.length - 1) {
            spans.add(const TextSpan(text: ' '));
          }
        }
        spans.add(const TextSpan(text: ' '));
      } else {
        // Fallback for missing word data
        var text = ayah.text.cleanArabic.trim();
        if (stripBismillah && ayah.numberInSurah == 1 && widget.surah.number != 9) {
          text = _stripApiBismillah(text);
        }
        if (text.isNotEmpty) {
          spans.add(TextSpan(text: text));
          spans.add(const TextSpan(text: ' '));
        }
      }
      // Ayah number marker
      spans.add(TextSpan(
        text: '${_toArabicDigits(ayah.numberInSurah)} ',
        style: const TextStyle(color: Color(0xFF1B5E20)),
        recognizer: widget.onAyahMarkerTap != null 
          ? (TapGestureRecognizer()..onTap = () => widget.onAyahMarkerTap!(ayah.numberInSurah))
          : null,
      ));
    }
    return spans;
  }

  // ─── Main build ────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_tooltipEntry != null) {
          setState(() => _highlightedWordKey = null);
          _removeTooltip();
        }
      },
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (widget.surah.number == 1) {
      return _buildFatihaLayout();
    }

    final ayahs = widget.surah.ayahs;
    if (ayahs == null || ayahs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text('No ayah data found for this Surah.'),
        ),
      );
    }

    String apiBismillahToDisplay = '';
    if (widget.surah.number != 9 && widget.surah.number != 1) {
      final firstAyah = ayahs.firstWhere((a) => a.numberInSurah == 1, orElse: () => ayahs.first);
      apiBismillahToDisplay = _extractApiBismillah(firstAyah.text);
    }

    final Map<int, List<Ayah>> pageMap = {};
    for (final ayah in ayahs) {
      pageMap.putIfAbsent(ayah.page, () => []).add(ayah);
    }
    final sortedPages = pageMap.keys.toList()..sort();

    return Column(
      children: [
        _buildSurahHeader(),
        if (apiBismillahToDisplay.isNotEmpty) _buildApiBasmallah(apiBismillahToDisplay),
        ...sortedPages.map((pageNum) => _buildMushafPage(pageMap[pageNum]!, pageNum)),
      ],
    );
  }

  // ─── Surah header (icon font) ──────────────────

  Widget _buildSurahHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1B5E20), width: 1),
      ),
      child: Text(
        'surah${widget.surah.number.toString().padLeft(3, '0')}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'surah-name-v2-icon',
          fontSize: 40,
          color: Color(0xFF1B5E20),
          fontFeatures: [FontFeature.enable('liga')],
        ),
      ),
    );
  }

  Widget _buildApiBasmallah(String bismillahText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 16, right: 16),
      child: Text(
        bismillahText,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          fontFamily: 'UthmanicHafs',
          fontSize: 24,
          color: Color(0xFF1B5E20),
        ),
      ),
    );
  }

  // ─── Fatiha ────────────────────────────────────

  Widget _buildFatihaLayout() {
    final ayahs = widget.surah.ayahs;
    final hasWordData = ayahs != null &&
        ayahs.any((a) => a.ayahWords != null && a.ayahWords!.isNotEmpty);

    return Column(
      children: [
        _buildSurahHeader(),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: _pageDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _pageNumber(1),
              const SizedBox(height: 12),
              if (hasWordData)
                RichText(
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  text: TextSpan(style: _arabicStyle, children: _buildWordSpans(ayahs!)),
                )
              else
                // Static fallback when word data hasn't loaded yet
                const Text(
                  '\u0628\u0650\u0633\u06e1\u0645\u0650 \u0671\u0644\u0644\u0651\u064e\u0647\u0650 \u0671\u0644\u0631\u0651\u064e\u062d\u06e1\u0645\u064e\u0640\u0670\u0646\u0650 \u0671\u0644\u0631\u0651\u064e\u062d\u0650\u064a\u0645\u0650',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'UthmanicHafs',
                    fontSize: 26,
                    height: 2.0,
                    color: Colors.black87,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Mushaf page ───────────────────────────────

  Widget _buildMushafPage(List<Ayah> pageAyahs, int pageNumber) {
    final spans = _buildWordSpans(pageAyahs, stripBismillah: true);

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: _pageDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _pageNumber(pageNumber),
            const SizedBox(height: 12),
            RichText(
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
              text: TextSpan(style: _arabicStyle, children: spans),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Shared constants ──────────────────────────

  static const _arabicStyle = TextStyle(
    fontFamily: 'UthmanicHafs',
    fontSize: 26,
    height: 2.0,
    color: Colors.black87,
    wordSpacing: 2,
  );

  static final _pageDecoration = BoxDecoration(
    color: const Color(0xFFFEFDF6),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: const Color(0xFFE8E5D1), width: 2),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  Widget _pageNumber(int n) => Text(
        '\u2014 $n \u2014',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
      );
}
