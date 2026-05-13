import 'package:flutter/material.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/widgets/language_selector_button.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../widgets/worship_sliver_header.dart';

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  // Input Controllers for Values
  final _goldValueCtrl = TextEditingController();
  final _silverValueCtrl = TextEditingController();
  final _cashCtrl = TextEditingController();
  final _assetsCtrl = TextEditingController();
  final _liabilitiesCtrl = TextEditingController();

  double _zakatAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _goldValueCtrl.addListener(_calculateZakat);
    _silverValueCtrl.addListener(_calculateZakat);
    _cashCtrl.addListener(_calculateZakat);
    _assetsCtrl.addListener(_calculateZakat);
    _liabilitiesCtrl.addListener(_calculateZakat);
  }

  @override
  void dispose() {
    _goldValueCtrl.dispose();
    _silverValueCtrl.dispose();
    _cashCtrl.dispose();
    _assetsCtrl.dispose();
    _liabilitiesCtrl.dispose();
    super.dispose();
  }

  void _calculateZakat() {
    double gold = double.tryParse(_goldValueCtrl.text) ?? 0.0;
    double silver = double.tryParse(_silverValueCtrl.text) ?? 0.0;
    double cash = double.tryParse(_cashCtrl.text) ?? 0.0;
    double assets = double.tryParse(_assetsCtrl.text) ?? 0.0;
    double liabilities = double.tryParse(_liabilitiesCtrl.text) ?? 0.0;

    double totalWealth = gold + silver + cash + assets;
    double netWealth = totalWealth - liabilities;
    
    if (netWealth < 0) netWealth = 0;

    setState(() {
      _zakatAmount = netWealth * 0.025; // 2.5% logic
    });
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    const deepColor = Color(0xFFE65100);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TranslatedText(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
              filled: true,
              fillColor: const Color(0xFFF9F9F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: deepColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Orange theme for Zakat
    final Color deepColor = const Color(0xFFE65100); // Orange 900
    final Color lightColor = const Color(0xFFFFB74D); // Orange 300

    // Determine screen size for responsive layout
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          WorshipSliverHeader(
            title: 'Zakat',
            subtitle: 'Obligatory Charity',
            arabicTitle: 'زَكَاة',
            icon: Icons.volunteer_activism,
            deepColor: deepColor,
            lightColor: lightColor,
            badgeText: 'Pillar #4',
          ),
          SliverToBoxAdapter(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: isDesktop 
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildInputSection(deepColor)),
                        const SizedBox(width: 32),
                        Expanded(child: _buildResultSection(deepColor, lightColor)),
                      ],
                    )
                  : Column(
                      children: [
                        _buildInputSection(deepColor),
                        const SizedBox(height: 32),
                        _buildResultSection(deepColor, lightColor),
                        const SizedBox(height: 40),
                      ],
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildInputSection(Color deepColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: deepColor.withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 8),
          )
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TranslatedText(
            "Wealth Assessment",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: deepColor,
            ),
          ),
          const SizedBox(height: 8),
          const TranslatedText(
            "Enter the current market value of your assets.",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 32),
          _buildTextField("GOLD VALUE", _goldValueCtrl),
          _buildTextField("SILVER VALUE", _silverValueCtrl),
          _buildTextField("CASH & SAVINGS", _cashCtrl),
          _buildTextField("BUSINESS ASSETS", _assetsCtrl),
          _buildTextField("DEBTS & LIABILITIES", _liabilitiesCtrl),
        ],
      ),
    );
  }

  Widget _buildResultSection(Color deepColor, Color lightColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [deepColor, deepColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: deepColor.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      ),
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          // Calculator Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.calculate, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 24),
          
          // Total Zakat Due
          TranslatedText(
            "TOTAL ZAKAT DUE",
            style: TextStyle(
              color: lightColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "\$",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _zakatAmount.toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Times New Roman', // Giving it a serif look like the reference
                  height: 1.1,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Quote Box
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: lightColor.withOpacity(0.5), width: 1.5),
              color: Colors.white.withOpacity(0.1),
            ),
            child: const Text(
              "\"The example of those who spend their wealth in the way of Allah is like a seed of grain which grows seven spikes; in each spike is a hundred grains.\"",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Nisab Threshold Warning
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const TranslatedText(
                "NISAB THRESHOLD APPLIES",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          
          // The Pay Zakat button has been removed as per user request.
        ],
      ),
    );
  }
}
