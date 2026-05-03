import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants.dart';

// ═══════════════════════════════════════════
//   CIRCULAR PROGRESS PAINTER
// ═══════════════════════════════════════════

class GoldenArcPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final bool showGlow;

  GoldenArcPainter({
    required this.progress,
    this.strokeWidth = 6.0,
    this.showGlow = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2 - 4;

    // ── Track arc ──
    final trackPaint = Paint()
      ..color = TasbeehColors.goldenCream2.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi,
      false,
      trackPaint,
    );

    if (progress <= 0) return;

    // ── Glow layer ──
    if (showGlow && progress > 0.05) {
      final glowPaint = Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: -math.pi / 2 + 2 * math.pi * progress,
          colors: [
            TasbeehColors.goldLight.withOpacity(0.0),
            TasbeehColors.standardGold.withOpacity(0.3),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        glowPaint,
      );
    }

    // ── Progress arc ──
    final progressPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + 2 * math.pi * progress,
        colors: const [
          Color(0xFFFFD28A),  // goldLight
          Color(0xFFD4AF37),  // standardGold
          Color(0xFFB8960C),  // darkerGold
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );

    // ── Tip dot ──
    if (progress > 0.01) {
      final tipAngle = -math.pi / 2 + 2 * math.pi * progress.clamp(0.0, 1.0);
      final tipX = center.dx + radius * math.cos(tipAngle);
      final tipY = center.dy + radius * math.sin(tipAngle);

      final dotPaint = Paint()
        ..color = TasbeehColors.standardGold
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(tipX, tipY), strokeWidth / 2 + 1, dotPaint);
    }
  }

  @override
  bool shouldRepaint(GoldenArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ═══════════════════════════════════════════
//   TASBIH BEAD ROW WIDGET
// ═══════════════════════════════════════════

class TasbeehBeadsRow extends StatelessWidget {
  final int count;
  final int target;

  const TasbeehBeadsRow({
    super.key,
    required this.count,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final int beadsPerRow = 10;
    final int activeFull = count % target;
    final int rounds = count ~/ target;

    return Column(
      children: [
        if (rounds > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                gradient: TasbeehColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$rounds round${rounds > 1 ? 's' : ''} complete',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(beadsPerRow, (i) {
            final isActive = i < (activeFull % beadsPerRow == 0 && activeFull > 0
                ? beadsPerRow
                : activeFull % beadsPerRow);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 12 : 10,
              height: isActive ? 12 : 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? TasbeehColors.standardGold
                    : TasbeehColors.goldenCream2,
                boxShadow: isActive
                    ? [
                  BoxShadow(
                    color: TasbeehColors.standardGold.withOpacity(0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  )
                ]
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════
//   GOLD ICON BUTTON
// ═══════════════════════════════════════════

class GoldenIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final bool filled;

  const GoldenIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 44,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: filled ? TasbeehColors.primaryGradient : null,
          color: filled ? null : TasbeehColors.surface,
          border: Border.all(
            color: TasbeehColors.goldenCream2,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: TasbeehColors.standardGold.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: size * 0.42,
          color: filled ? Colors.white : TasbeehColors.bronzeGold,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
//   GOLDEN DIVIDER
// ═══════════════════════════════════════════

class GoldenDivider extends StatelessWidget {
  final double opacity;

  const GoldenDivider({super.key, this.opacity = 0.3});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            TasbeehColors.standardGold.withOpacity(opacity),
            TasbeehColors.standardGold.withOpacity(opacity),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
//   STAT CARD WIDGET
// ═══════════════════════════════════════════

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TasbeehColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TasbeehColors.goldenCream2, width: 1),
        boxShadow: [
          BoxShadow(
            color: TasbeehColors.standardGold.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: TasbeehColors.standardGold, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: TasbeehColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TasbeehTextStyles.caption),
        ],
      ),
    );
  }
}