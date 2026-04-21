import 'package:flutter/material.dart';

class DuaModel {
  final String id;
  final String title;
  final String subtitle;
  final String pdfUrl;
  final IconData icon;
  final Color color;

  const DuaModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.pdfUrl,
    required this.icon,
    required this.color,
  });
}
