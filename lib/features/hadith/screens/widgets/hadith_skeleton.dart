import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Animated skeleton card shown while hadith data is streaming in.
class HadithSkeletonCard extends StatelessWidget {
  final bool isArabic;
  const HadithSkeletonCard({super.key, this.isArabic = false});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8E4DF),
      highlightColor: const Color(0xFFF8F5F0),
      period: const Duration(milliseconds: 1200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hadith Number Badge Skeleton
          Align(
            alignment: Alignment.centerLeft,
            child: _pill(width: 100, height: 32, radius: 8),
          ),
          const SizedBox(height: 12),

          // Text lines
          if (isArabic) ...[
            Align(alignment: Alignment.centerRight, child: _pill(width: double.infinity, height: 26, radius: 4)),
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerRight, child: _pill(width: double.infinity, height: 26, radius: 4)),
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerRight, child: _pill(width: 180, height: 26, radius: 4)),
          ] else ...[
            Align(alignment: Alignment.centerLeft, child: _pill(width: double.infinity, height: 18, radius: 4)),
            const SizedBox(height: 10),
            Align(alignment: Alignment.centerLeft, child: _pill(width: double.infinity, height: 18, radius: 4)),
            const SizedBox(height: 10),
            Align(alignment: Alignment.centerLeft, child: _pill(width: double.infinity, height: 18, radius: 4)),
            const SizedBox(height: 10),
            Align(alignment: Alignment.centerLeft, child: _pill(width: 140, height: 18, radius: 4)),
          ],

          const SizedBox(height: 16),
          
          // Grade chips skeleton
          Row(
            children: [
              _pill(width: 80, height: 28, radius: 14),
              const SizedBox(width: 8),
              _pill(width: 120, height: 28, radius: 14),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill({required double width, required double height, required double radius}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
