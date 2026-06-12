import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/models.dart';
import '../services/asset_catalog.dart';
import '../theme/app_theme.dart';
import 'svg_file_web.dart' if (dart.library.io) 'svg_file_io.dart' as svgfile;

// Reines (weißes) Icon – ohne Hintergrund.
class ActivityIcon extends StatelessWidget {
  final Activity activity;
  final double size;
  const ActivityIcon({super.key, required this.activity, this.size = 80});

  @override
  Widget build(BuildContext context) {
    final custom = activity.iconPath;
    if (custom != null && custom.isNotEmpty) {
      if (activity.iconIsAsset && AssetCatalog.has(custom)) {
        return SvgPicture.asset(custom, width: size, height: size);
      }
      if (!activity.iconIsAsset) {
        final w = svgfile.fileSvg(custom, size);
        if (w != null) return w;
      }
    }
    final byKey = AssetCatalog.iconForKey(activity.key);
    if (byKey != null) return SvgPicture.asset(byKey, width: size, height: size);
    return SvgPicture.asset('assets/icons/placeholder.svg', width: size, height: size);
  }
}

// Farbige Kachel mit weißem Icon (hoher Kontrast, Bring-Stil).
class IconTile extends StatelessWidget {
  final Activity activity;
  final double tileSize;
  final double iconSize;
  final double radius;
  const IconTile({super.key, required this.activity,
    this.tileSize = 64, required this.iconSize, this.radius = 18});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tileSize,
      height: tileSize,
      decoration: BoxDecoration(
        color: AppTheme.tile(context),
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: ActivityIcon(activity: activity, size: iconSize),
    );
  }
}
