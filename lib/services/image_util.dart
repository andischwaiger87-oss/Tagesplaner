import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:file_picker/file_picker.dart';

// Wählt ein Bild und gibt es als Base64-String zurück (plattformübergreifend).
Future<String?> pickImageBase64() async {
  final r = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
  if (r == null || r.files.isEmpty) return null;
  final bytes = r.files.first.bytes;
  if (bytes == null) return null;
  return base64Encode(bytes);
}

ImageProvider? avatarProvider(String? b64) =>
    (b64 == null || b64.isEmpty) ? null : MemoryImage(base64Decode(b64));
