# Graph Report - quran_app  (2026-05-03)

## Corpus Check
- 165 files · ~310,436 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 1312 nodes · 1507 edges · 52 communities detected
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 12 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 33|Community 33]]
- [[_COMMUNITY_Community 34|Community 34]]
- [[_COMMUNITY_Community 35|Community 35]]
- [[_COMMUNITY_Community 36|Community 36]]
- [[_COMMUNITY_Community 37|Community 37]]
- [[_COMMUNITY_Community 38|Community 38]]
- [[_COMMUNITY_Community 39|Community 39]]
- [[_COMMUNITY_Community 40|Community 40]]
- [[_COMMUNITY_Community 41|Community 41]]
- [[_COMMUNITY_Community 42|Community 42]]
- [[_COMMUNITY_Community 43|Community 43]]
- [[_COMMUNITY_Community 44|Community 44]]
- [[_COMMUNITY_Community 45|Community 45]]
- [[_COMMUNITY_Community 46|Community 46]]
- [[_COMMUNITY_Community 47|Community 47]]
- [[_COMMUNITY_Community 48|Community 48]]
- [[_COMMUNITY_Community 49|Community 49]]
- [[_COMMUNITY_Community 50|Community 50]]
- [[_COMMUNITY_Community 51|Community 51]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 50 edges
2. `../models/prophet_model.dart` - 26 edges
3. `package:flutter_bloc/flutter_bloc.dart` - 25 edges
4. `../../core/widgets/translated_text.dart` - 20 edges
5. `../../../../shared/widgets/custom_button.dart` - 15 edges
6. `../../../../core/widgets/language_selector_button.dart` - 15 edges
7. `dart:convert` - 11 edges
8. `../models/ayah.dart` - 10 edges
9. `package:flutter/services.dart` - 9 edges
10. `package:flutter/foundation.dart` - 9 edges

## Surprising Connections (you probably didn't know these)
- `OnCreate()` --calls--> `RegisterPlugins()`  [INFERRED]
  windows\runner\flutter_window.cpp → windows\flutter\generated_plugin_registrant.cc
- `OnCreate()` --calls--> `Show()`  [INFERRED]
  windows\runner\flutter_window.cpp → windows\runner\win32_window.cpp
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  windows\runner\main.cpp → windows\runner\utils.cpp
- `wWinMain()` --calls--> `SetQuitOnClose()`  [INFERRED]
  windows\runner\main.cpp → windows\runner\win32_window.cpp
- `my_application_dispose()` --calls--> `dispose`  [INFERRED]
  linux\runner\my_application.cc → lib\shared\widgets\custom_button.dart

## Communities

### Community 0 - "Community 0"
Cohesion: 0.03
Nodes (86): build, Center, Column, compare, Divider, _LanguageGroup, ListTile, Scaffold (+78 more)

### Community 1 - "Community 1"
Cohesion: 0.03
Nodes (81): add_tasbeeh_screen.dart, AddTasbeehScreen, _AddTasbeehScreenState, BorderSide, build, _buildField, _buildSectionLabel, dispose (+73 more)

### Community 2 - "Community 2"
Cohesion: 0.03
Nodes (70): arabicLarge, TasbeehColors, TasbeehTextStyles, Align, build, dispose, Divider, FadeTransition (+62 more)

### Community 3 - "Community 3"
Cohesion: 0.03
Nodes (65): build, _buildContent, _buildInfoRow, _buildKeyLessonCard, _buildSections, _buildShortBio, _buildSliverHeader, _buildTableOfContents (+57 more)

### Community 4 - "Community 4"
Cohesion: 0.04
Nodes (55): TranslationService, DuaService, _bookIdFromEdition, _getHadithsFromEditionJsonFallback, _getSectionsFromEditionJsonFallback, HadithService, _parseEditions, _parseEditionsFromCache (+47 more)

### Community 5 - "Community 5"
Cohesion: 0.04
Nodes (56): _ActionBtn, BackdropFilter, build, _buildHeader, Container, _copy, _DuaCard, DuaDetailScreen (+48 more)

### Community 6 - "Community 6"
Cohesion: 0.04
Nodes (55): build, _buildApiBasmallah, _buildBody, _buildFatihaLayout, _buildMushafPage, _buildSurahHeader, Center, Column (+47 more)

### Community 7 - "Community 7"
Cohesion: 0.03
Nodes (58): ../asma_ul_husna_screen.dart, ../asma_un_nabi_screen.dart, _a2, _ac, _appBar, _asrAlt, _at, _BottomNav (+50 more)

### Community 8 - "Community 8"
Cohesion: 0.04
Nodes (26): data/01_adam.dart, data/02_idris.dart, data/03_nuh.dart, data/04_hud.dart, data/05_salih.dart, data/06_ibrahim.dart, data/07_ismail.dart, data/08_ishaq.dart (+18 more)

### Community 9 - "Community 9"
Cohesion: 0.04
Nodes (43): build, _buildGrid, _buildQuranVerse, _buildSearchBar, _buildSliverAppBar, dispose, FadeTransition, initState (+35 more)

### Community 10 - "Community 10"
Cohesion: 0.05
Nodes (43): AppBar, _BismillahHeader, build, _buildAppBar, _buildLoadingSkeletons, _buildModeSelector, _buildPersistentAudioPlayer, _buildRecitationFab (+35 more)

### Community 11 - "Community 11"
Cohesion: 0.05
Nodes (40): _applyPosition, build, _buildAlignedBadge, _buildBottomInfo, _buildCardinals, _buildCenterJewel, _buildCompassArea, _buildDial (+32 more)

### Community 12 - "Community 12"
Cohesion: 0.05
Nodes (37): PreferencesService, LanguageCubit, _loadLanguage, build, didChangeDependencies, didUpdateWidget, initState, Text (+29 more)

### Community 13 - "Community 13"
Cohesion: 0.05
Nodes (38): build, _buildSliverHeader, Container, dispose, Divider, _DuaCard, FeelingDuaDetailScreen, _FeelingDuaDetailScreenState (+30 more)

### Community 14 - "Community 14"
Cohesion: 0.05
Nodes (38): build, _buildRakatRow, _buildTimingRow, Card, Center, DefaultTabController, Divider, Icon (+30 more)

### Community 15 - "Community 15"
Cohesion: 0.05
Nodes (37): build, _buildAllTranslationsView, _buildLoadingSkeletons, _buildMultiTranslationCard, _buildSectionHeader, _buildSectionsList, _buildSingleTranslationView, _buildStreamingAllTranslationsView (+29 more)

### Community 16 - "Community 16"
Cohesion: 0.09
Nodes (25): FlutterWindow(), OnCreate(), RegisterPlugins(), wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16(), Create() (+17 more)

### Community 17 - "Community 17"
Cohesion: 0.06
Nodes (30): _applyFilter, build, _buildSearchResults, Center, Column, Container, dispose, _ErrorWidget (+22 more)

### Community 18 - "Community 18"
Cohesion: 0.07
Nodes (27): build, _buildBody, _buildHeader, _buildSearchBar, Center, Column, dispose, _DuaCategoryCard (+19 more)

### Community 19 - "Community 19"
Cohesion: 0.07
Nodes (24): ayah.dart, HadithBloc, HadithError, HadithsLoaded, HadithsStreaming, MapEntry, _onToggleLanguage, Ayah (+16 more)

### Community 20 - "Community 20"
Cohesion: 0.07
Nodes (19): build, ClipRRect, dispose, GestureDetector, initState, LayoutBuilder, LiquidGlassButton, _LiquidGlassButtonState (+11 more)

### Community 21 - "Community 21"
Cohesion: 0.09
Nodes (22): build, _buildAudioPlayer, Container, dispose, Divider, DraggableScrollableSheet, DropdownMenuItem, _formatDuration (+14 more)

### Community 22 - "Community 22"
Cohesion: 0.09
Nodes (21): _BookCard, build, Center, Column, dispose, GestureDetector, _getArabicName, HadithBooksScreen (+13 more)

### Community 23 - "Community 23"
Cohesion: 0.12
Nodes (16): build, _buildInputSection, _buildResultSection, _buildTextField, _calculateZakat, Container, dispose, Icon (+8 more)

### Community 24 - "Community 24"
Cohesion: 0.12
Nodes (15): AsmaUnNabiScreen, _AsmaUnNabiScreenState, build, _buildHeader, Color, dispose, FadeTransition, GestureDetector (+7 more)

### Community 25 - "Community 25"
Cohesion: 0.12
Nodes (15): BookmarkAyahEvent, ChangeFontSizeEvent, ChangeReadingModeEvent, ChangeTranslationEvent, ChangeWbwLanguageEvent, LoadLastReadEvent, LoadSurahEvent, LoadSurahsEvent (+7 more)

### Community 26 - "Community 26"
Cohesion: 0.13
Nodes (14): AnimatedContainer, build, Column, Container, GestureDetector, GoldenArcPainter, GoldenDivider, GoldenIconButton (+6 more)

### Community 27 - "Community 27"
Cohesion: 0.17
Nodes (11): BookmarkUpdated, copyWith, QuranError, QuranInitial, QuranLoading, QuranSearchResults, QuranState, SurahLoaded (+3 more)

### Community 28 - "Community 28"
Cohesion: 0.18
Nodes (10): HadithAllTranslationsLoaded, HadithAllTranslationsStreaming, HadithBooksLoaded, HadithError, HadithInitial, HadithLoading, HadithSectionsLoaded, HadithsLoaded (+2 more)

### Community 29 - "Community 29"
Cohesion: 0.25
Nodes (7): ChangeHadithTranslationEvent, HadithEvent, LoadAllTranslationsForSectionEvent, LoadHadithBooksEvent, SelectHadithBookEvent, SelectHadithSectionEvent, ToggleHadithLanguageEvent

### Community 30 - "Community 30"
Cohesion: 0.29
Nodes (2): AppDelegate, FlutterAppDelegate

### Community 31 - "Community 31"
Cohesion: 0.29
Nodes (6): HadithBook, HadithEdition, HadithGrade, HadithItem, HadithSection, MultiTranslationHadith

### Community 32 - "Community 32"
Cohesion: 0.33
Nodes (3): RegisterGeneratedPlugins(), MainFlutterWindow, NSWindow

### Community 33 - "Community 33"
Cohesion: 0.6
Nodes (4): clean(), is_arabic(), Dua Scraper - allahuakbarofficial.com Install: pip install requests beautifulsou, scrape()

### Community 34 - "Community 34"
Cohesion: 0.4
Nodes (2): GeneratedPluginRegistrant, -registerWithRegistry

### Community 35 - "Community 35"
Cohesion: 0.4
Nodes (2): RunnerTests, XCTestCase

### Community 36 - "Community 36"
Cohesion: 0.4
Nodes (4): ClearSearchEvent, DuaEvent, LoadDuaCategoriesEvent, SearchDuasEvent

### Community 37 - "Community 37"
Cohesion: 0.4
Nodes (3): CustomIconsV2, Icomoon, package:flutter/widgets.dart

### Community 38 - "Community 38"
Cohesion: 0.5
Nodes (2): handle_new_rx_page(), Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.

### Community 39 - "Community 39"
Cohesion: 0.5
Nodes (3): copyWith, TasbeehCounter, TasbeehSession

### Community 40 - "Community 40"
Cohesion: 0.67
Nodes (2): DuaCategory, SingleDua

### Community 41 - "Community 41"
Cohesion: 0.67
Nodes (2): ProphetModel, ProphetSection

### Community 42 - "Community 42"
Cohesion: 0.67
Nodes (2): LanguageInfo, TranslationEdition

### Community 43 - "Community 43"
Cohesion: 1.0
Nodes (1): MainActivity

### Community 44 - "Community 44"
Cohesion: 1.0
Nodes (1): DuaImageService

### Community 45 - "Community 45"
Cohesion: 1.0
Nodes (1): TafseerSource

### Community 46 - "Community 46"
Cohesion: 1.0
Nodes (1): Kalma

### Community 47 - "Community 47"
Cohesion: 1.0
Nodes (1): NamazStep

### Community 48 - "Community 48"
Cohesion: 1.0
Nodes (1): PrayerTiming

### Community 49 - "Community 49"
Cohesion: 1.0
Nodes (1): RakatInfo

### Community 50 - "Community 50"
Cohesion: 1.0
Nodes (1): WorshipTimes

### Community 51 - "Community 51"
Cohesion: 1.0
Nodes (1): WorshipService

## Knowledge Gaps
- **1023 isolated node(s):** `Dua Scraper - allahuakbarofficial.com Install: pip install requests beautifulsou`, `MainActivity`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `-registerWithRegistry`, `IslamicApp` (+1018 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Community 30`** (7 nodes): `AppDelegate`, `.application()`, `.applicationShouldTerminateAfterLastWindowClosed()`, `.applicationSupportsSecureRestorableState()`, `FlutterAppDelegate`, `AppDelegate.swift`, `AppDelegate.swift`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 34`** (5 nodes): `GeneratedPluginRegistrant.java`, `GeneratedPluginRegistrant`, `.registerWith()`, `-registerWithRegistry`, `GeneratedPluginRegistrant.m`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 35`** (5 nodes): `RunnerTests.swift`, `RunnerTests.swift`, `RunnerTests`, `.testExample()`, `XCTestCase`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 38`** (4 nodes): `handle_new_rx_page()`, `__lldb_init_module()`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `flutter_lldb_helper.py`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 40`** (3 nodes): `DuaCategory`, `SingleDua`, `dua_category_model.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 41`** (3 nodes): `ProphetModel`, `ProphetSection`, `prophet_model.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 42`** (3 nodes): `LanguageInfo`, `TranslationEdition`, `translation_edition.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 43`** (2 nodes): `MainActivity.kt`, `MainActivity`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 44`** (2 nodes): `DuaImageService`, `dua_image_service.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 45`** (2 nodes): `TafseerSource`, `tafseer_source.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 46`** (2 nodes): `Kalma`, `kalma.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 47`** (2 nodes): `NamazStep`, `namaz_step.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 48`** (2 nodes): `PrayerTiming`, `prayer_timing.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 49`** (2 nodes): `RakatInfo`, `rakat_info.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 50`** (2 nodes): `WorshipTimes`, `worship_times.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 51`** (2 nodes): `WorshipService`, `worship_service.dart`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter/material.dart` connect `Community 2` to `Community 0`, `Community 1`, `Community 3`, `Community 5`, `Community 6`, `Community 7`, `Community 9`, `Community 10`, `Community 11`, `Community 12`, `Community 13`, `Community 14`, `Community 15`, `Community 17`, `Community 18`, `Community 20`, `Community 21`, `Community 22`, `Community 23`, `Community 24`, `Community 26`?**
  _High betweenness centrality (0.380) - this node is a cross-community bridge._
- **Why does `package:flutter_bloc/flutter_bloc.dart` connect `Community 1` to `Community 0`, `Community 2`, `Community 4`, `Community 6`, `Community 7`, `Community 10`, `Community 12`, `Community 15`, `Community 17`, `Community 18`, `Community 19`, `Community 22`?**
  _High betweenness centrality (0.094) - this node is a cross-community bridge._
- **Why does `../../core/widgets/translated_text.dart` connect `Community 3` to `Community 0`, `Community 2`, `Community 5`, `Community 7`, `Community 9`, `Community 13`, `Community 14`, `Community 17`, `Community 18`, `Community 20`, `Community 22`, `Community 23`?**
  _High betweenness centrality (0.049) - this node is a cross-community bridge._
- **What connects `Dua Scraper - allahuakbarofficial.com Install: pip install requests beautifulsou`, `MainActivity`, `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.` to the rest of the system?**
  _1023 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.03 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.03 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.03 - nodes in this community are weakly interconnected._