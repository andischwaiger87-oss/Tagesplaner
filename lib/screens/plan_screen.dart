import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/activity_icon.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 20), children: [
        Text('Dein Tag', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: cs.onSurface)),
        Text('ganzer Überblick', style: TextStyle(fontSize: 16, color: cs.onSurface.withOpacity(.6))),
        const SizedBox(height: 16),
        for (int i = 0; i < st.plan.length; i++) _row(context, st, i, cs),
      ]),
    );
  }

  Widget _row(BuildContext c, AppState st, int i, ColorScheme cs) {
    final a = st.plan[i];
    final isCurrent = i == st.currentIndex;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface, borderRadius: BorderRadius.circular(22),
        border: isCurrent ? Border.all(color: kAccent, width: 3) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 14)],
      ),
      child: Row(children: [
        IconTile(activity: a, tileSize: 58, iconSize: 38, radius: 16),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(a.label, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: cs.onSurface)),
          if (st.settings.showClock)
            Text('${a.timeLabel} Uhr · ${a.durationMin} Min.',
                style: TextStyle(fontSize: 13, color: cs.onSurface.withOpacity(.6))),
        ])),
        if (isCurrent) Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(999)),
          child: const Text('JETZT', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
        ),
      ]),
    );
  }
}
