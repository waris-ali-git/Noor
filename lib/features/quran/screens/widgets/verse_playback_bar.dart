import 'package:flutter/material.dart';
import '../../services/verse_by_verse_controller.dart';

/// Floating bottom bar shown during active verse-by-verse playback.
/// Shows the current ayah, active step, and playback controls.
class VersePlaybackBar extends StatelessWidget {
  final VerseByVerseController controller;
  final VoidCallback onSettingsTap;
  final VoidCallback onClose;
  final VoidCallback? onBarTap;

  const VersePlaybackBar({
    super.key,
    required this.controller,
    required this.onSettingsTap,
    required this.onClose,
    this.onBarTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        if (!state.isActive) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
            ),
          ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ─── Step indicator bar ─────────────────────
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onBarTap,
                    child: _StepIndicator(step: state.step),
                  ),
                  const SizedBox(height: 8),

                  // ─── Main controls row ──────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: onBarTap,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ayah ${state.currentAyahInSurah} of ${state.totalAyahs}',
                                    style: const TextStyle(
                                      color: Color(0xFFB8960C),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _stepLabel(state.step, controller.config),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Controls
                      _ControlButton(
                        icon: Icons.skip_previous_rounded,
                        onTap: () => controller.skipToPrev(),
                      ),
                      const SizedBox(width: 4),
                      _PlayPauseButton(
                        isPlaying: state.isPlaying,
                        onTap: () => controller.togglePlayPause(),
                      ),
                      const SizedBox(width: 4),
                      _ControlButton(
                        icon: Icons.skip_next_rounded,
                        onTap: () => controller.skipToNext(),
                      ),
                      const SizedBox(width: 4),
                      _ControlButton(
                        icon: Icons.fast_forward_rounded,
                        tooltip: 'Skip step',
                        onTap: () => controller.skipStep(),
                      ),
                      const SizedBox(width: 4),
                      _ControlButton(
                        icon: Icons.settings_rounded,
                        onTap: onSettingsTap,
                      ),
                      const SizedBox(width: 4),
                      _ControlButton(
                        icon: Icons.close_rounded,
                        onTap: () {
                          controller.stop();
                          onClose();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _stepLabel(VersePlaybackStep step, VerseByVerseConfig config) {
    switch (step) {
      case VersePlaybackStep.recitation:
        return '🎙️ Recitation — ${config.reciter.name}';
      case VersePlaybackStep.translation:
        return '📖 Translation — ${config.translationEdition.translatorName}';
      case VersePlaybackStep.tafseer:
        return '📚 Tafseer';
      case VersePlaybackStep.idle:
        return 'Starting...';
    }
  }
}

// ─────────────────────────────────────────────
// Step Indicator
// ─────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final VersePlaybackStep step;

  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepDot(
          label: 'Recitation',
          isActive: step == VersePlaybackStep.recitation,
          isPast: _isPast(VersePlaybackStep.recitation),
        ),
        _StepLine(active: _isPast(VersePlaybackStep.recitation) || step == VersePlaybackStep.translation || step == VersePlaybackStep.tafseer),
        _StepDot(
          label: 'Translation',
          isActive: step == VersePlaybackStep.translation,
          isPast: _isPast(VersePlaybackStep.translation),
        ),
        _StepLine(active: _isPast(VersePlaybackStep.translation) || step == VersePlaybackStep.tafseer),
        _StepDot(
          label: 'Tafseer',
          isActive: step == VersePlaybackStep.tafseer,
          isPast: false,
        ),
      ],
    );
  }

  bool _isPast(VersePlaybackStep s) {
    final order = [VersePlaybackStep.recitation, VersePlaybackStep.translation, VersePlaybackStep.tafseer];
    return order.indexOf(step) > order.indexOf(s);
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isPast;

  const _StepDot({required this.label, required this.isActive, required this.isPast});

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? const Color(0xFFD4AF37)
        : isPast
            ? const Color(0xFFD4AF37).withValues(alpha: 0.6)
            : Colors.grey[300]!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isActive ? 10 : 7,
          height: isActive ? 10 : 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [BoxShadow(color: const Color(0xFFD4AF37).withValues(alpha: 0.5), blurRadius: 6)]
                : null,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFFB8960C) : Colors.grey[400],
            fontSize: 9,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool active;
  const _StepLine({required this.active});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 14),
        color: active ? const Color(0xFFD4AF37) : Colors.grey[200],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Control Button
// ─────────────────────────────────────────────
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const _ControlButton({required this.icon, required this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Tooltip(
        message: tooltip ?? '',
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: const Color(0xFFB8960C), size: 22),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Play/Pause Button (larger, golden)
// ─────────────────────────────────────────────
class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;

  const _PlayPauseButton({required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFD4AF37), Color(0xFFB8960C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
