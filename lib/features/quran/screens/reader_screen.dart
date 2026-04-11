import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/audio_service.dart';
import '../state/quran_bloc.dart';
import '../models/surah.dart';
import '../models/ayah.dart';
import '../models/reading_mode.dart';
import '../widgets/tafseer_bottom_sheet.dart';
import 'widgets/reading_settings_sheet.dart';
import 'widgets/tajweed_ayah.dart';
import 'widgets/word_by_word_ayah.dart';
import 'widgets/reciter_selection_sheet.dart';
import 'widgets/ayah_toolbar.dart';
import 'widgets/mushaf_page_preview.dart';
import 'widgets/surah_skeleton.dart';
import 'package:just_audio/just_audio.dart';

class ReaderScreen extends StatefulWidget {
  final Surah surah;
  final ReadingDisplayMode initialMode;
  final int? initialAyah;

  const ReaderScreen({
    super.key,
    required this.surah,
    required this.initialMode,
    this.initialAyah,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollProgress = ValueNotifier(0.0);
  Timer? _lastReadDebouncer;
  Timer? _scrollPauseTimer;
  bool _showMarkAsReadOverlay = false;
  int _overlayTriggerCount = 0; // limit to first 3 times per session

  @override
  void initState() {
    super.initState();
    _loadSurah();
    _scrollController.addListener(_onScroll);

    if (widget.initialAyah != null && widget.initialAyah! > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          // Approximate jump: Bismillah header (~100px) + (ayah index * ~150px avg height)
          // This is a naive scroll just to get them close to the spot without a complex item-scroll package
          final estimatedTargetListIndex = widget.initialAyah! - 1; 
          final estimatedOffset = 100.0 + (estimatedTargetListIndex * 150.0);
          
          final maxOffset = _scrollController.position.maxScrollExtent;
          _scrollController.jumpTo(estimatedOffset.clamp(0.0, maxOffset));
        }
      });
    }
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (maxScroll > 0) {
        _scrollProgress.value = (currentScroll / maxScroll).clamp(0.0, 1.0);
      } else {
        _scrollProgress.value = 0.0;
      }

      // Hide overlay as soon as user starts scrolling again
      if (_showMarkAsReadOverlay) {
        setState(() => _showMarkAsReadOverlay = false);
      }

      // Check for pause to show overlay
      _scrollPauseTimer?.cancel();
      if (_overlayTriggerCount < 3 && _scrollProgress.value > 0.5 && widget.initialMode == ReadingDisplayMode.arabicOnly) {
        _scrollPauseTimer = Timer(const Duration(milliseconds: 1500), () {
          if (mounted && _scrollProgress.value > 0.5) {
            setState(() {
              _showMarkAsReadOverlay = true;
              _overlayTriggerCount++;
            });
            // Auto hide after 3 seconds
            Timer(const Duration(seconds: 3), () {
              if (mounted && _showMarkAsReadOverlay) {
                setState(() => _showMarkAsReadOverlay = false);
              }
            });
          }
        });
      }
    }
  }

  void _loadSurah() {
    final bloc = context.read<QuranBloc>();
    if (widget.initialMode == ReadingDisplayMode.wordByWord) {
      bloc.add(LoadSurahWordByWordEvent(surahNumber: widget.surah.number));
    } else {
      bloc.add(LoadSurahEvent(surahNumber: widget.surah.number));
    }
  }

  @override
  void dispose() {
    _lastReadDebouncer?.cancel();
    _scrollPauseTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollProgress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      appBar: _buildAppBar(context),
      body: BlocConsumer<QuranBloc, QuranState>(
        listener: (context, state) {
          if (state is BookmarkUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.isBookmarked ? '✓ بک مارک ہو گیا' : 'بک مارک ہٹا دیا',
                ),
                duration: const Duration(seconds: 1),
                backgroundColor: const Color(0xFF1B5E20),
              ),
            );
          }
        },
        builder: (context, state) {
          // Progressive streaming state — show loaded ayahs + skeleton cards for the rest
          if (state is SurahStreaming) {
            return _buildStreamingContent(context, state);
          }


          if (state is QuranError) {
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadSurah,
                      child: const Text('دوبارہ کوشش کریں'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is SurahLoaded) {
            return Stack(
              children: [
                _buildSurahContent(
                  context,
                  state.surah,
                  state.preferences,
                  state.bookmarks,
                ),
                if (_showMarkAsReadOverlay)
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B5E20).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                          ]
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.touch_app, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Tap any Ayah circle to mark as read',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }

          if (state is SurahWordByWordLoaded) {
            return _buildWordByWordContent(
              context,
              state.surahMeta,
              state.ayahs,
              state.preferences,
              state.bookmarks,
            );
          }

          // Fallback: still loading (initial QuranLoading or state not yet emitted)
          return _buildLoadingSkeletons();


        },
      ),
      bottomNavigationBar: _buildPersistentAudioPlayer(),
    );
  }

  // ─────────────────────────────────────────────
  // PERSISTENT TAFSEER PLAYER
  // ─────────────────────────────────────────────
  Widget _buildPersistentAudioPlayer() {
    final audioService = QuranAudioService();
    return StreamBuilder<PlayerState>(
      stream: audioService.tafseerPlayerStateStream,
      builder: (context, snapshot) {
        if (!audioService.hasTafseerAudio) return const SizedBox.shrink();
        
        final playerState = snapshot.data;
        final playing = playerState?.playing ?? false;
        
        return Container(
          color: const Color(0xFF1B5E20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SafeArea(
            bottom: true,
            top: false,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(playing ? Icons.pause : Icons.play_arrow, color: Colors.white),
                  onPressed: () {
                    if (playing) {
                      audioService.pauseTafseer();
                    } else {
                      if (audioService.currentTafseerUrl != null) {
                        audioService.playTafseer(
                          url: audioService.currentTafseerUrl!, 
                          surahName: audioService.tafseerSurahName ?? '', 
                          scholarName: audioService.tafseerScholarName ?? ''
                        );
                      }
                    }
                  }
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tafseer: Surah ${audioService.tafseerSurahName ?? ''}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        audioService.tafseerScholarName ?? 'Playing',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () {
                    audioService.stopTafseer();
                  }
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────────
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1B5E20),
      title: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'surah${widget.surah.number.toString().padLeft(3, '0')}',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'surah-name-v2-icon',
                fontSize: 33,
                fontFeatures: [FontFeature.enable('liga')],
              ),
            ),
          ),
          Text(
            widget.surah.englishName,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 9),
        ],
      ),
      centerTitle: true,
      actions: [
        // Reciter selection button
        IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: () {
            showReciterSelectionSheet(context);
            setState(() {}); // Rebuild to show new reciter
          },
          tooltip: 'Select Reciter',
        ),
        // Settings button
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () => _showSettingsSheet(context),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(2.0),
        child: ValueListenableBuilder<double>(
          valueListenable: _scrollProgress,
          builder: (context, progress, child) {
            return LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF948160)),
              minHeight: 2.0,
            );
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SHOW TAFSEER
  // ─────────────────────────────────────────────
  void _showTafseer(BuildContext context, Ayah ayah) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TafseerBottomSheet(
        ayah: ayah,
        surahNumber: widget.surah.number,
        surahName: widget.surah.name,
      ),
    ).then((_) {
      // Refresh to ensure persistent player shows up if started
      setState((){});
    });
  }

  // ─────────────────────────────────────────────
  // ARABIC + TRANSLATION  /  TAJWEED mode
  // ─────────────────────────────────────────────
  Widget _buildSurahContent(
      BuildContext context,
      Surah surah,
      ReadingPreferences prefs,
      List<String> bookmarks,
      ) {
    
    // Preview for Arabic Only mode using the Mushaf Layout
    if (prefs.displayMode == ReadingDisplayMode.arabicOnly) {
      return CustomScrollView(
        controller: _scrollController,
        cacheExtent: 500, // Pre-render 500px above/below viewport
        slivers: [
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: MushafPagePreview(
              surah: surah,
              onAyahMarkerTap: (ayahNumber) {
                context.read<QuranBloc>().add(
                  SaveLastReadEvent(
                    surahNumber: surah.number,
                    ayahNumber: ayahNumber,
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Saved Surah ${surah.number}, Ayah $ayahNumber as last read'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: const Color(0xFF948160),
                  ),
                );
              },
            ),
          )),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      );
    }

    final ayahs = surah.ayahs ?? [];

    return CustomScrollView(
      controller: _scrollController,
      cacheExtent: 500, // Pre-render 500px above/below viewport
      slivers: [
        // Bismillah header
        SliverToBoxAdapter(child: _BismillahHeader()),

        // Ayahs
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final ayah = ayahs[index];
              final isBookmarked = bookmarks.contains(
                '${surah.number}:${ayah.numberInSurah}',
              );

              // Tajweed mode
              if (prefs.displayMode == ReadingDisplayMode.tajweed ||
                  prefs.showTajweed) {
                return RepaintBoundary(
                  child: TajweedAyahWidget(
                    ayah: ayah,
                    surahNumber: surah.number,
                    preferences: prefs,
                    isBookmarked: isBookmarked,
                    onBookmarkToggle: () => _toggleBookmark(
                      context,
                      surah.number,
                      ayah.numberInSurah,
                      isBookmarked,
                    ),
                    onVisible: () {
                      _lastReadDebouncer?.cancel();
                      _lastReadDebouncer = Timer(const Duration(seconds: 2), () {
                        context.read<QuranBloc>().add(
                          SaveLastReadEvent(
                            surahNumber: surah.number,
                            ayahNumber: ayah.numberInSurah,
                          ),
                        );
                      });
                    },
                    onTafseerTap: () => _showTafseer(context, ayah),
                  ),
                );
              }

              // Arabic Only / Arabic + Translation
              return RepaintBoundary(
                child: _StandardAyahCard(
                  ayah: ayah,
                  surahNumber: surah.number,
                  preferences: prefs,
                  isBookmarked: isBookmarked,
                  onBookmarkToggle: () => _toggleBookmark(
                    context,
                    surah.number,
                    ayah.numberInSurah,
                    isBookmarked,
                  ),
                  onTafseerTap: () => _showTafseer(context, ayah),
                ),
              );
            },
            childCount: ayahs.length,
            addAutomaticKeepAlives: true,
            addRepaintBoundaries: true,
          ),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // WORD-BY-WORD mode (exactly image jaisa)
  // ─────────────────────────────────────────────
  Widget _buildWordByWordContent(
      BuildContext context,
      Surah surahMeta,
      List<Ayah> ayahs,
      ReadingPreferences prefs,
      List<String> bookmarks,
      ) {
    return CustomScrollView(
      controller: _scrollController,
      cacheExtent: 500, // Pre-render 500px above/below viewport
      slivers: [
        SliverToBoxAdapter(child: _BismillahHeader()),

        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final ayah = ayahs[index];
              final isBookmarked = bookmarks.contains(
                '${surahMeta.number}:${ayah.numberInSurah}',
              );

              return RepaintBoundary(
                child: WordByWordAyahWidget(
                  ayah: ayah,
                  surahNumber: surahMeta.number,
                  preferences: prefs,
                  isBookmarked: isBookmarked,
                  onBookmarkToggle: () => _toggleBookmark(
                    context,
                    surahMeta.number,
                    ayah.numberInSurah,
                    isBookmarked,
                  ),
                  onTafseerTap: () => _showTafseer(context, ayah),
                ),
              );
            },
            childCount: ayahs.length,
            addAutomaticKeepAlives: true,
            addRepaintBoundaries: true,
          ),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // STREAMING STATE: Real ayahs + skeleton cards
  // ─────────────────────────────────────────────
  Widget _buildStreamingContent(BuildContext context, SurahStreaming state) {
    final loadedAyahs = state.loadedAyahs;
    final remainingCount = state.remainingAyahs;
    final surah = state.surahMeta;
    final prefs = state.preferences;
    final bookmarks = state.bookmarks;

    return CustomScrollView(
      controller: _scrollController,
      cacheExtent: 500,
      slivers: [
        // Bismillah is immediately available
        SliverToBoxAdapter(child: _BismillahHeader()),

        // Already loaded ayahs — render normally
        if (loadedAyahs.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final ayah = loadedAyahs[index];
                final isBookmarked = bookmarks.contains('${surah.number}:${ayah.numberInSurah}');
                return RepaintBoundary(
                  child: _StandardAyahCard(
                    ayah: ayah,
                    surahNumber: surah.number,
                    preferences: prefs,
                    isBookmarked: isBookmarked,
                    onBookmarkToggle: () => _toggleBookmark(
                      context, surah.number, ayah.numberInSurah, isBookmarked,
                    ),
                    onTafseerTap: () => _showTafseer(context, ayah),
                  ),
                );
              },
              childCount: loadedAyahs.length,
              addRepaintBoundaries: true,
            ),
          ),

        // Skeleton placeholders for remaining ayahs
        if (remainingCount > 0)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => const SurahSkeletonCard(),
              childCount: remainingCount,
            ),
          ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // FALLBACK LOADING SKELETONS (pure skeleton)
  // ─────────────────────────────────────────────
  Widget _buildLoadingSkeletons() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(child: _BismillahHeader()),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => const SurahSkeletonCard(),
            childCount: 8, // Show 8 placeholder cards
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
      ],
    );
  }

  void _toggleBookmark(
      BuildContext context,
      int surahNumber,
      int ayahNumber,
      bool isCurrentlyBookmarked,
      ) {
    if (isCurrentlyBookmarked) {
      context.read<QuranBloc>().add(
        RemoveBookmarkEvent(surahNumber: surahNumber, ayahNumber: ayahNumber),
      );
    } else {
      context.read<QuranBloc>().add(
        BookmarkAyahEvent(surahNumber: surahNumber, ayahNumber: ayahNumber),
      );
    }
  }

  void _showSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<QuranBloc>(),
        child: ReadingSettingsSheet(
          onModeChanged: (mode) {
            context.read<QuranBloc>().add(ChangeReadingModeEvent(mode: mode));
            // Reload if switching to/from word-by-word
            if (mode == ReadingDisplayMode.wordByWord) {
              context.read<QuranBloc>().add(
                LoadSurahWordByWordEvent(surahNumber: widget.surah.number),
              );
            } else {
              context.read<QuranBloc>().add(
                LoadSurahEvent(surahNumber: widget.surah.number),
              );
            }
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BISMILLAH HEADER
// ─────────────────────────────────────────────
class _BismillahHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Text(
            'بِسۡمِ اللّٰہِ الرَّحۡمٰنِ الرَّحِیۡمِ',
            style: TextStyle(
              fontFamily: 'UthmanicHafs',
              fontSize: 26,
              color: Colors.white,
              height: 2,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'In the Name of Allah — the Most Compassionate, Most Merciful',
            style: TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// STANDARD AYAH CARD  (Arabic Only / Arabic+Translation)
// ─────────────────────────────────────────────
class _StandardAyahCard extends StatelessWidget {
  final Ayah ayah;
  final int surahNumber;
  final ReadingPreferences preferences;
  final bool isBookmarked;
  final VoidCallback onBookmarkToggle;
  final VoidCallback onTafseerTap;

  const _StandardAyahCard({
    required this.ayah,
    required this.surahNumber,
    required this.preferences,
    required this.isBookmarked,
    required this.onBookmarkToggle,
    required this.onTafseerTap,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ayah Toolbar
          AyahToolbar(
            ayah: ayah,
            surahNumber: surahNumber,
            isBookmarked: isBookmarked,
            onBookmarkToggle: onBookmarkToggle,
            onTafseerTap: onTafseerTap,
          ),

          // Arabic text (RTL)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              ayah.text.cleanArabic,
              style: TextStyle(
                fontFamily: 'UthmanicHafs',
                fontSize: preferences.arabicFontSize,
                height: 2.0,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ),

          // Transliteration (optional)
          if (preferences.showTransliteration && ayah.transliteration != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                ayah.transliteration!,
                style: TextStyle(
                  fontSize: preferences.translationFontSize - 2,
                  color: Colors.blueGrey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          // Translation
          if (preferences.displayMode != ReadingDisplayMode.arabicOnly &&
              ayah.translation != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F8E9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                ayah.translation!,
                style: TextStyle(
                  fontSize: preferences.translationFontSize,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ),
        ],
      ),
    );
  }
}