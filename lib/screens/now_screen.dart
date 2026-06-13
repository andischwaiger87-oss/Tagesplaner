import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/activity_icon.dart';
import '../services/image_util.dart';
import '../models/models.dart';
import '../util/format.dart';

String _todayLabel() {
  final n = DateTime.now();
  const wd = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
  return '${wd[n.weekday - 1]}, ${n.day}.${n.month}.';
}

class NowScreen extends StatelessWidget {
  const NowScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    final s = st.settings;
    final done = st.dayState == DayState.done;
    final a = st.current;

    final up = st.upcoming;
    final nextList = st.isActive ? up : (up.length > 1 ? up.sublist(1) : const <Activity>[]);

    return SafeArea(
      child: ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 20), children: [
        Row(children: [
          CircleAvatar(radius: 24, backgroundColor: AppTheme.tile(context),
            backgroundImage: avatarProvider(s.avatarUser),
            child: s.avatarUser == null ? const Icon(Icons.person_rounded, color: Colors.white, size: 26) : null),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Hallo ${s.name}', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: cs.onSurface)),
            Text(done ? 'Für heute' : (st.isActive ? 'Das ist jetzt dran' : 'Gleich dran'),
                style: TextStyle(fontSize: 16, color: cs.onSurface.withOpacity(.6))),
          ])),
          InkWell(
            onTap: () => st.goTab(1),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10)]),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.calendar_month_rounded, size: 18, color: cs.primary),
                const SizedBox(width: 6),
                Text(_todayLabel(), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: cs.onSurface)),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 20),

        if (done)
          _doneCard(cs)
        else
          _bigCard(context, st, a, cs, s),

        if (!done && s.showNext && nextList.isNotEmpty) ...[
          const SizedBox(height: 22),
          Text('Als Nächstes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.onSurface)),
          const SizedBox(height: 10),
          for (final n in nextList.take(6)) _nextRow(context, st, n, cs),
        ],
      ]),
    );
  }

  Widget _bigCard(BuildContext context, AppState st, Activity a, ColorScheme cs, AppSettings s) {
    final hc = s.highContrast;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(hc ? .35 : .10), blurRadius: 36, offset: const Offset(0, 16))]),
      child: Column(children: [
        IconTile(activity: a, tileSize: 168, iconSize: 106, radius: 38),
        const SizedBox(height: 18),
        Text(a.label, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, height: 1.1, color: cs.onSurface)),
        if (s.showClock) Padding(padding: const EdgeInsets.only(top: 6),
          child: Text('um ${a.timeLabel} Uhr', style: TextStyle(fontSize: 16, color: cs.onSurface.withOpacity(.55)))),
        const SizedBox(height: 18),
        if (st.isActive) ...[
          _Bar(progress: st.progress, track: cs.surfaceContainerHighest, fill: hc ? cs.primary : kAccent),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerRight, child: Text('noch ${fmtDuration(st.remainingMin)}',
              style: TextStyle(fontSize: 14, color: cs.onSurface.withOpacity(.55)))),
          const SizedBox(height: 14),
        ] else ...[
          Text(fmtUntil(st.minutesUntil(a)),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: hc ? cs.primary : kAccent)),
          const SizedBox(height: 14),
        ],
        SizedBox(width: double.infinity, child: FilledButton(
          style: FilledButton.styleFrom(backgroundColor: hc ? cs.primary : kAccent,
            foregroundColor: hc ? Colors.black : Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
          onPressed: () => st.speakCurrent(),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.volume_up_rounded, size: 28), SizedBox(width: 10),
            Text('Vorlesen', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          ]),
        )),
      ]),
    );
  }

  Widget _doneCard(ColorScheme cs) => Container(
    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
    decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(32),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 30)]),
    child: Column(children: [
      Icon(Icons.check_circle_rounded, size: 80, color: cs.primary),
      const SizedBox(height: 14),
      Text('Für heute geschafft!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: cs.onSurface)),
      const SizedBox(height: 4),
      Text('Es ist gerade keine Aufgabe geplant.', style: TextStyle(color: cs.onSurface.withOpacity(.6))),
    ]),
  );

  Widget _nextRow(BuildContext c, AppState st, Activity n, ColorScheme cs) {
    final mins = st.minutesUntil(n);
    final ring = (1 - (mins / 60).clamp(0, 1)).toDouble();
    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 12)]),
      child: Row(children: [
        IconTile(activity: n, tileSize: 52, iconSize: 34, radius: 14),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(n.label, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface)),
          if (st.settings.showClock)
            Text('${n.timeLabel} Uhr · ${fmtDuration(n.durationMin)}',
                style: TextStyle(fontSize: 12.5, color: cs.onSurface.withOpacity(.55))),
        ])),
        SizedBox(width: 30, height: 30, child: CircularProgressIndicator(
          value: ring, strokeWidth: 3, backgroundColor: cs.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation(cs.primary))),
        const SizedBox(width: 8),
        SizedBox(width: 64, child: Text(fmtUntil(mins), textAlign: TextAlign.right,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: cs.onSurface.withOpacity(.7)))),
      ]),
    );
  }
}

class _Bar extends StatelessWidget {
  final double progress; final Color track; final Color fill;
  const _Bar({required this.progress, required this.track, required this.fill});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (c, cons) => Container(
    height: 24, decoration: BoxDecoration(color: track, borderRadius: BorderRadius.circular(14)),
    child: Align(alignment: Alignment.centerLeft, child: AnimatedContainer(
      duration: const Duration(milliseconds: 500), width: cons.maxWidth * progress.clamp(0, 1),
      decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(14)))),
  ));
}
