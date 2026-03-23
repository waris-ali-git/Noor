import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../state/language_cubit.dart';
import '../services/supported_languages.dart';

class LanguageSelectorButton extends StatelessWidget {
  const LanguageSelectorButton({super.key});

  void _showLanguageSheet(BuildContext context, String currentLangCode) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _LanguageSearchSheet(currentLangCode: currentLangCode);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, String>(
      builder: (context, currentLang) {
        return IconButton(
          icon: const Icon(Icons.language),
          tooltip: 'Select Language',
          onPressed: () => _showLanguageSheet(context, currentLang),
        );
      },
    );
  }
}

class _LanguageSearchSheet extends StatefulWidget {
  final String currentLangCode;

  const _LanguageSearchSheet({required this.currentLangCode});

  @override
  State<_LanguageSearchSheet> createState() => _LanguageSearchSheetState();
}

class _LanguageSearchSheetState extends State<_LanguageSearchSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Filter the languages based on the search query
    final filteredLanguages = supportedLanguages.entries.where((entry) {
      return entry.key.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Padding(
      // Padding handles the keyboard pushing the sheet up
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: FractionallySizedBox(
        heightFactor: 0.8, // Take up 80% of screen height
        child: Column(
          children: [
            // Handle for bottom sheet
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Select Language',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search language...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            const Divider(),
            // Language List
            Expanded(
              child: filteredLanguages.isEmpty
                  ? const Center(child: Text('No languages found.'))
                  : ListView.builder(
                      itemCount: filteredLanguages.length,
                      itemBuilder: (context, index) {
                        final entry = filteredLanguages[index];
                        final isSelected = entry.value == widget.currentLangCode;

                        return ListTile(
                          title: Text(
                            entry.key,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Theme.of(context).colorScheme.primary : null,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                              : null,
                          onTap: () {
                            context.read<LanguageCubit>().setLanguage(entry.value);
                            Navigator.pop(context); // Close the sheet
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
