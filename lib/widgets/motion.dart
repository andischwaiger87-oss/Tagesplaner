import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

/// Sind Micro-Interactions erlaubt? (Standard: ja; abschaltbar über
/// Einstellungen → „Animationen reduzieren".)
bool motionOn(BuildContext context) =>
    !context.watch<AppState>().settings.reduceMotion;

const Duration kFast = Duration(milliseconds: 140);
const Duration kSmooth = Duration(milliseconds: 320);
const Curve kEase = Curves.easeOutCubic;

/// Drückt sich beim Antippen sanft zusammen – gibt spürbares Feedback,
/// ohne abzulenken. Respektiert „Animationen reduzieren".
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap, this.scale = .96});
  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final on = motionOn(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) { if (on) setState(() => _down = true); },
      onTapUp: (_) { if (on) setState(() => _down = false); },
      onTapCancel: () { if (on) setState(() => _down = false); },
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1.0,
        duration: on ? kFast : Duration.zero,
        curve: kEase,
        child: widget.child,
      ),
    );
  }
}

/// Sanftes Einblenden + leichtes Aufsteigen beim Wechsel des Inhalts.
class SoftSwitch extends StatelessWidget {
  const SoftSwitch({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final on = motionOn(context);
    return AnimatedSwitcher(
      duration: on ? kSmooth : Duration.zero,
      switchInCurve: kEase,
      switchOutCurve: kEase,
      transitionBuilder: (c, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, .04), end: Offset.zero).animate(anim),
          child: c,
        ),
      ),
      child: child,
    );
  }
}

/// Fortschrittsbalken, der weich auf den neuen Wert läuft.
class SmoothBar extends StatelessWidget {
  const SmoothBar({super.key, required this.value, required this.color});
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final on = motionOn(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: value, end: value.clamp(0.0, 1.0)),
        duration: on ? const Duration(milliseconds: 520) : Duration.zero,
        curve: kEase,
        builder: (_, v, __) => LinearProgressIndicator(
          value: v,
          minHeight: 10,
          backgroundColor: Colors.white,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    );
  }
}
