import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/language_selector_button.dart';
import '../../../core/widgets/translated_text.dart';
import '../models/dua_category_model.dart';
import '../services/dua_service.dart';
import '../state/dua_bloc.dart';
import '../state/dua_event.dart';
import '../state/dua_state.dart';
import 'dua_detail_screen.dart';

class DuasHomeScreen extends StatefulWidget {
  const DuasHomeScreen({super.key});

  @override
  State<DuasHomeScreen> createState() => _DuasHomeScreenState();
}

class _DuasHomeScreenState extends State<DuasHomeScreen> {
  final _searchController = TextEditingController();
  late final DuaBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = DuaBloc(DuaService.instance)..add(LoadDuaCategoriesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F7),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF1C1C1E)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Duas & Supplications',
              style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF1C1C1E)),
            ),
          ),
          const LanguageSelectorButton(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => _bloc.add(v.isEmpty ? ClearSearchEvent() : SearchDuasEvent(v)),
          style: GoogleFonts.plusJakartaSans(fontSize: 15, color: const Color(0xFF1C1C1E)),
          decoration: InputDecoration(
            hintText: 'Search duas...',
            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 15, color: Colors.grey),
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<DuaBloc, DuaState>(
      builder: (context, state) {
        if (state is DuaLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF1B8A5A)));
        }
        if (state is DuaError) {
          return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
        }
        if (state is DuaCategoriesLoaded) {
          final cats = state.filtered;
          if (cats.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
                const SizedBox(height: 12),
                Text('No duas found', style: GoogleFonts.plusJakartaSans(color: Colors.grey, fontSize: 16)),
              ]),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Supplications', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1C1C1E))),
                    Text('${cats.length} CATEGORIES', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: cats.length,
                  itemBuilder: (ctx, i) => _DuaCategoryCard(category: cats[i], index: i + 1),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _DuaCategoryCard extends StatelessWidget {
  final DuaCategory category;
  final int index;

  const _DuaCategoryCard({required this.category, required this.index});

  static const _iconMap = <String, IconData>{
    'wb_sunny': Icons.wb_sunny_rounded,
    'bedtime': Icons.bedtime_rounded,
    'wc': Icons.wc_rounded,
    'exit_to_app': Icons.exit_to_app_rounded,
    'restaurant': Icons.restaurant_rounded,
    'lunch_dining': Icons.lunch_dining_rounded,
    'home': Icons.home_rounded,
    'logout': Icons.logout_rounded,
    'mosque': Icons.mosque_rounded,
    'directions_walk': Icons.directions_walk_rounded,
    'travel_explore': Icons.travel_explore_rounded,
    'directions_car': Icons.directions_car_rounded,
    'healing': Icons.healing_rounded,
    'favorite': Icons.favorite_rounded,
    'psychology': Icons.psychology_rounded,
    'self_improvement': Icons.self_improvement_rounded,
    'elderly': Icons.elderly_rounded,
    'child_care': Icons.child_care_rounded,
    'water_drop': Icons.water_drop_rounded,
    'cloud': Icons.cloud_rounded,
    'nightlight': Icons.nightlight_rounded,
    'brightness_5': Icons.brightness_5_rounded,
    'shopping_bag': Icons.shopping_bag_rounded,
    'checkroom': Icons.checkroom_rounded,
    'sentiment_very_satisfied': Icons.sentiment_very_satisfied_rounded,
    'warning': Icons.warning_rounded,
    'shield': Icons.shield_rounded,
    'face': Icons.face_rounded,
    'church': Icons.church_rounded,
    'book': Icons.book_rounded,
    'auto_awesome': Icons.auto_awesome_rounded,
  };

  static const _colors = [
    Color(0xFF1B8A5A),
    Color(0xFF1565C0),
    Color(0xFF6A1B9A),
    Color(0xFFE65100),
    Color(0xFF880E4F),
    Color(0xFF004D40),
    Color(0xFF1A237E),
    Color(0xFFBF360C),
    Color(0xFF37474F),
    Color(0xFF4A148C),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[(index - 1) % _colors.length];
    final icon = _iconMap[category.icon] ?? Icons.auto_awesome_rounded;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DuaDetailScreen(category: category))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Circular icon (like the image)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.12),
                ),
                child: Center(child: Icon(icon, color: color, size: 26)),
              ),
              const SizedBox(width: 14),
              // Text column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TranslatedText(
                      category.category,
                      style: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.w300, color: const Color(0xFF1C1C1E)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.format_list_bulleted_rounded, size: 11, color: Colors.grey.shade400),
                      const SizedBox(width: 4),
                      Text('${category.duaCount} dua${category.duaCount > 1 ? "s" : ""}',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10, color: Colors.grey.shade500)),
                    ]),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
