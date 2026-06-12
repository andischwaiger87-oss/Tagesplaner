import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget? fileSvg(String path, double size) {
  final f = File(path);
  if (!f.existsSync()) return null;
  return SvgPicture.file(f, width: size, height: size);
}
