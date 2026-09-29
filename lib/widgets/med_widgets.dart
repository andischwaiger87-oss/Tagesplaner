import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Abhakliste der Medikamente eines Schritts – ein Tipp pro Tablette.
/// Sind alle abgehakt, gilt der Schritt automatisch als erledigt.
class MedChecklist extends StatelessWidget {
  final Activity activity;
  final bool large;
  const MedChecklist({super.key, required this.activity, this.large = false});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    final a = activity;
    final left = st.pillsLeft(a);
    final total = a.meds.length;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(left == 0 ? 'Alle genommen ✓' : '${total - left} von $total genommen',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: large ? 17 : 15, fontWeight: FontWeight.w700,
                color: left == 0 ? cs.primary : cs.onSurface.withOpacity(.7))),
      ),
      for (final m in a.meds) Builder(builder: (_) {
        final taken = st.pillTaken(a, m);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Semantics(
            button: true, checked: taken,
            label: '$m, ${taken ? 'genommen' : 'noch nicht genommen'}',
            child: ExcludeSemantics(child: Material(
              color: taken ? cs.primary.withOpacity(.12) : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => st.togglePill(a, m),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: large ? 16 : 13),
                  child: Row(children: [
                    Icon(taken ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        size: large ? 32 : 28, color: taken ? cs.primary : cs.onSurface.withOpacity(.45)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(m, style: TextStyle(
                        fontSize: large ? 20 : 17, fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                        decoration: taken ? TextDecoration.lineThrough : null))),
                  ]),
                ),
              ),
            )),
          ),
        );
      }),
    ]);
  }
}

/// Hinweis auf „Jetzt": Medikamente, deren Zeit schon da war, sind noch offen.
/// Bleibt sichtbar, bis alles abgehakt ist – auch wenn längst der nächste Schritt läuft.
class OpenMedsCard extends StatelessWidget {
  final List<Activity> open;
  final bool large;
  const OpenMedsCard({super.key, required this.open, this.large = false});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    return Column(children: [
      for (final a in open) Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Semantics(
          button: true,
          label: 'Noch offen: ${a.label} von ${a.timeLabel} Uhr',
          child: ExcludeSemantics(child: Material(
            color: kAccent.withOpacity(.12),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => showMedSheet(context, a),
              child: Container(
                padding: EdgeInsets.all(large ? 16 : 14),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kAccent.withOpacity(.5), width: 1.5)),
                child: Row(children: [
                  Icon(Icons.medication_rounded, color: kAccent, size: large ? 34 : 30),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Noch offen: ${a.label}', maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: large ? 19 : 17, fontWeight: FontWeight.w800, color: cs.onSurface)),
                    Text(a.meds.isEmpty
                        ? 'seit ${a.timeLabel} Uhr · antippen zum Abhaken'
                        : 'seit ${a.timeLabel} Uhr · ${st.pillsLeft(a)} von ${a.meds.length} fehlen',
                        style: TextStyle(fontSize: 13.5, color: cs.onSurface.withOpacity(.65))),
                  ])),
                  Icon(Icons.chevron_right_rounded, color: cs.onSurface.withOpacity(.5)),
                ]),
              ),
            ),
          )),
        ),
      ),
    ]);
  }
}

/// Fenster zum Abhaken eines Medikamenten-Schritts.
Future<void> showMedSheet(BuildContext context, Activity a) {
  return showModalBottomSheet(
    context: context, isScrollControlled: true, useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (c) {
      final st = c.watch<AppState>();
      final cs = Theme.of(c).colorScheme;
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(child: Container(width: 44, height: 5, decoration: BoxDecoration(
              color: cs.onSurface.withOpacity(.2), borderRadius: BorderRadius.circular(3)))),
          const SizedBox(height: 14),
          Text(a.label, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: cs.onSurface)),
          Text('um ${a.timeLabel} Uhr', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: cs.onSurface.withOpacity(.55))),
          const SizedBox(height: 16),
          if (a.meds.isNotEmpty)
            MedChecklist(activity: a, large: true)
          else
            FilledButton.icon(
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
              onPressed: () { st.toggleDone(a.id); Navigator.pop(c); },
              icon: const Icon(Icons.check_rounded, size: 26),
              label: const Text('Genommen', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700)),
            ),
          const SizedBox(height: 6),
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Schließen')),
        ])),
      );
    },
  );
}
