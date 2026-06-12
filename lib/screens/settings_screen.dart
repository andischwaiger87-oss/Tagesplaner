import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    final s = st.settings;
    return SafeArea(
      child: ListView(padding: const EdgeInsets.fromLTRB(18, 16, 18, 24), children: [
        Text('Einstellungen', style: TextStyle(color: cs.onPrimary, fontSize: 24, fontWeight: FontWeight.w700)),
        Text('Alles individuell anpassbar', style: TextStyle(color: cs.onPrimary.withOpacity(.85), fontSize: 15)),
        const SizedBox(height: 14),

        _section(cs, 'Persönlich', [
          _rowWidget('Name', SizedBox(width: 170, child: TextField(
            controller: TextEditingController(text: s.name)
              ..selection = TextSelection.collapsed(offset: s.name.length),
            onSubmitted: (v) => st.updateSettings((x) => x.name = v.isEmpty ? 'Andi' : v),
            decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
          )), cs),
          _rowWidget('Stimme', DropdownButton<String>(
            value: s.voice, underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'f', child: Text('Frau (Deutsch)')),
              DropdownMenuItem(value: 'm', child: Text('Mann (Deutsch)')),
            ],
            onChanged: (v) => st.updateSettings((x) => x.voice = v ?? 'f'),
          ), cs),
        ]),

        _section(cs, 'Darstellung', [
          _rowWidget('Farbthema', Row(mainAxisSize: MainAxisSize.min, children: [
            for (int i = 0; i < kSeeds.length; i++)
              GestureDetector(
                onTap: () => st.updateSettings((x) => x.themeIndex = i),
                child: Container(width: 30, height: 30, margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(color: kSeeds[i], shape: BoxShape.circle,
                    border: Border.all(color: s.themeIndex == i ? cs.onSurface : Colors.transparent, width: 3))),
              ),
          ]), cs),
          _switch('Hoher Kontrast', s.highContrast, (v) => st.updateSettings((x) => x.highContrast = v), cs),
          _rowWidget('Schriftgröße', SizedBox(width: 160, child: Slider(
            value: s.fontScale, min: 1, max: 1.4, divisions: 4,
            onChanged: (v) => st.updateSettings((x) => x.fontScale = v))), cs),
          _switch('Animationen reduzieren', s.reduceMotion, (v) => st.updateSettings((x) => x.reduceMotion = v), cs),
        ]),

        _section(cs, 'Verhalten', [
          _switch('„Als Nächstes“ zeigen', s.showNext, (v) => st.updateSettings((x) => x.showNext = v), cs),
          _switch('Uhrzeiten zeigen', s.showClock, (v) => st.updateSettings((x) => x.showClock = v), cs),
          _switch('Vibration', s.vibrate, (v) => st.updateSettings((x) => x.vibrate = v), cs),
          _rowWidget('Lautstärke', SizedBox(width: 160, child: Slider(
            value: s.volume, min: 0, max: 1, divisions: 10,
            onChanged: (v) => st.updateSettings((x) => x.volume = v))), cs),
        ]),
      ]),
    );
  }

  Widget _section(ColorScheme cs, String title, List<Widget> rows) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.fromLTRB(4, 6, 0, 8),
        child: Text(title, style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w700, fontSize: 16))),
      Container(
        decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(22)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: rows),
      ),
      const SizedBox(height: 14),
    ]);

  Widget _rowWidget(String k, Widget control, ColorScheme cs) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Flexible(child: Text(k, style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface))),
      control,
    ]));

  Widget _switch(String k, bool v, ValueChanged<bool> on, ColorScheme cs) => _rowWidget(
    k, Switch(value: v, onChanged: on), cs);
}
