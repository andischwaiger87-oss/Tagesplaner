import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/activity_icon.dart';

class NowScreen extends StatelessWidget {
  const NowScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    final s = st.settings;
    final a = st.current;
    final hc = s.highContrast;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hallo ${s.name}',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: cs.onSurface)),
          const SizedBox(height: 2),
          Text(st.isActive ? 'Das ist jetzt dran' : 'Als Nächstes',
              style: TextStyle(fontSize: 16, color: cs.onSurface.withOpacity(.6))),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(hc ? .35 : .08),
                  blurRadius: 30, offset: const Offset(0, 14))],
            ),
            child: Column(children: [
              IconTile(activity: a, tileSize: 168, iconSize: 104, radius: 36),
              const SizedBox(height: 18),
              Text(a.label, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700,
                      height: 1.1, color: cs.onSurface)),
              if (s.showClock) Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('um ${a.timeLabel} Uhr',
                    style: TextStyle(fontSize: 16, color: cs.onSurface.withOpacity(.55))),
              ),
              const SizedBox(height: 20),
              if (st.isActive) ...[
                _Bar(progress: st.progress, track: cs.surfaceContainerHighest, fill: hc ? cs.primary : kAccent),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight,
                  child: Text('noch ${st.remainingMin} Min.',
                      style: TextStyle(fontSize: 14, color: cs.onSurface.withOpacity(.55)))),
                const SizedBox(height: 14),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: hc ? cs.primary : kAccent,
                    foregroundColor: hc ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => st.speakCurrent(),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.volume_up_rounded, size: 28), SizedBox(width: 10),
                    Text('Vorlesen', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ]),
          ),
          if (s.showNext && st.isActive && st.next != null) Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(22),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(hc ? .3 : .05), blurRadius: 16)]),
              child: Row(children: [
                IconTile(activity: st.next!, tileSize: 52, iconSize: 34, radius: 14),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Als Nächstes', style: TextStyle(fontSize: 13, color: cs.onSurface.withOpacity(.55))),
                  Text(st.next!.label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface)),
                ])),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double progress; final Color track; final Color fill;
  const _Bar({required this.progress, required this.track, required this.fill});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (c, cons) => Container(
    height: 24,
    decoration: BoxDecoration(color: track, borderRadius: BorderRadius.circular(14)),
    child: Align(alignment: Alignment.centerLeft, child: AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: cons.maxWidth * progress.clamp(0, 1),
      decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(14)),
    )),
  ));
}
