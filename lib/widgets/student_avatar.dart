import 'dart:convert';
import 'package:flutter/material.dart';

ImageProvider? getStudentImageProvider(String? photoUrl) {
  if (photoUrl == null || photoUrl.trim().isEmpty) return null;
  final url = photoUrl.trim();
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return NetworkImage(url);
  }
  try {
    return MemoryImage(base64Decode(url));
  } catch (_) {
    return null;
  }
}
