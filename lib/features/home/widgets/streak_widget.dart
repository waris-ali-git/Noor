import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class StreakWidget extends StatefulWidget {
  const StreakWidget({Key? key}) : super(key: key);

  @override
  State<StreakWidget> createState() => _StreakWidgetState();
}

class _StreakWidgetState extends State<StreakWidget> with SingleTickerProviderStateMixin {
  int _streakCount = 1;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _initStreak();
  }

  Future<void> _initStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastOpenDate = prefs.getString('last_open_date');
    final today = _formatDate(DateTime.now());
    
    int streak = prefs.getInt('streak_count') ?? 1;

    if (lastOpenDate != null) {
      if (lastOpenDate == today) {
        // Already opened today, do nothing
      } else {
        final yesterday = _formatDate(DateTime.now().subtract(const Duration(days: 1)));
        if (lastOpenDate == yesterday) {
          // Continuous streak
          streak++;
        } else {
          // Missed a day, reset streak
          streak = 1;
        }
      }
    }
    
    await prefs.setString('last_open_date', today);
    await prefs.setInt('streak_count', streak);
    
    if (mounted) {
      setState(() {
        _streakCount = streak;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Hidden feature to manually increase streak for testing/demo
  Future<void> _forceIncrementStreak() async {
    final prefs = await SharedPreferences.getInstance();
    int streak = (prefs.getInt('streak_count') ?? 1) + 1;
    await prefs.setInt('streak_count', streak);
    setState(() {
      _streakCount = streak;
    });
  }

  Color _getFlameColor() {
    if (_streakCount <= 2) return const Color(0xFFF39C12); // Orange Starter
    if (_streakCount <= 6) return const Color(0xFFF1C40F); // Gold Consistent
    return const Color(0xFF90BDE7); // Pastel Blue Mastery
  }

  Color _getGlowColor() {
    if (_streakCount <= 2) return const Color(0xFFF39C12).withOpacity(0.3);
    if (_streakCount <= 6) return const Color(0xFFF1C40F).withOpacity(0.5);
    return const Color(0xFF90BDE7).withOpacity(0.7);
  }

  double _getFlameSize() {
    if (_streakCount <= 2) return 18.0;
    if (_streakCount <= 6) return 22.0;
    return 26.0;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flameColor = _getFlameColor();
    final glowColor = _getGlowColor();
    final flameSize = _getFlameSize();
    final isMastery = _streakCount > 6;

    Widget flameIcon = Icon(
      Icons.local_fire_department_rounded,
      color: flameColor,
      size: flameSize,
    );

    if (isMastery) {
      flameIcon = AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: glowColor,
                    blurRadius: 10 * _pulseAnimation.value,
                    spreadRadius: 2 * _pulseAnimation.value,
                  ),
                ],
              ),
              child: Icon(
                Icons.whatshot_rounded,
                color: flameColor,
                size: flameSize,
              ),
            ),
          );
        },
      );
    } else {
       // Static glow for lower streaks
       flameIcon = Container(
         decoration: BoxDecoration(
           shape: BoxShape.circle,
           boxShadow: [
             BoxShadow(
               color: glowColor,
               blurRadius: 6,
               spreadRadius: 0,
             ),
           ],
         ),
         child: flameIcon,
       );
    }

    return GestureDetector(
      onTap: _forceIncrementStreak,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            flameIcon,
            const SizedBox(width: 4),
            Text(
              '$_streakCount',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A2E44),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
