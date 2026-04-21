import 'package:flutter/material.dart';
import '../models/dua_model.dart';

/// All available duas with their PDF download links.
/// To add a new dua, simply add a new DuaModel entry to this list.
final List<DuaModel> allDuas = [
  const DuaModel(
    id: 'dua_from_quran',
    title: 'Dua from the Quran',
    subtitle: 'Collection of Quranic Supplications',
    pdfUrl:
        'https://markazalsalam.com/wp-content/uploads/2022/12/Dua-from-the-Quran_Book.pdf',
    icon: Icons.menu_book_rounded,
    color: Color(0xFF1B5E20),
  ),
];
