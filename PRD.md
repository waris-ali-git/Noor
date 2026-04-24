# PRD: Quran App Enhancements & Typography Standardization

## Overview
This document outlines the tasks for completing the Quran App's UI refinement, specifically focusing on typography standardization and feature completion.

## Task 1: Typography Standardization (Arabic)
Ensure that all Arabic text components across the app use the `DigitalKhatt` font family.
- Check `reader_screen.dart`
- Check `word_by_word_ayah.dart`
- Check `tajweed_ayah.dart`
- Verify that `DigitalKhattIndoPak.otf` is correctly applied.

## Task 2: Typography Standardization (Urdu)
Ensure that all Urdu translations and UI elements use the `Jameel Noori` font family.
- Update `translation_selection_screen.dart`
- Update settings sheets where Urdu is displayed.
- Verify that `Jameel Noori Nastaleeq Kasheeda.ttf` is correctly applied.

## Task 3: Translation Selection Cleanup
Refine the translation selection UI by removing unnecessary flag emojis and cleaning up the edition names.
- Remove "buck" translation references.
- Ensure the UI looks professional and uniform.

## Task 4: Prophet Narratives Validation
Verify that all prophet narratives (Prophets 2-8) are 100% literal and matches the source data.
- Check `lib/features/prophets/data/` files.
- Ensure no content is skipped or summarized.

## Task 5: Asma Ul Husna UI Polish
Finalize the Asma Ul Husna screen UI.
- Ensure smooth audio playback integration.
- Verify font rendering for calligraphy.
