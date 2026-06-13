import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class _Step {
  final String title, text; final IconData icon; final String key;
  const _Step(this.title, this.text, this.icon, this.key);
}

const List<_Step> _steps = [
  _Step('Willkommen', 'Diese App hilft dir, deinen Tag Schritt für Schritt zu schaffen.', Icons.waving_hand_rounded, 'intro1'),
  _Step('Was ist jetzt dran?', 'Oben siehst du immer, was gerade dran ist – mit Bild, Text und Sprache.', Icons.schedule_rounded, 'intro2'),
  _Step('Vorlesen', 'Tippe auf „Vorlesen", um die Aufgabe noch einmal zu hören.', Icons.volume_up_rounded, 'intro3'),
  _Step('Als Nächstes', 'Du siehst, was bald kommt – samt verbleibender Restzeit.', Icons.update_rounded, 'intro4'),
  _Step('Tag bearbeiten', 'Im Tab „Bearbeiten" stellst du deinen Tag zusammen: Uhrzeit und Dauer wählen.', Icons.edit_calendar_outlined, 'intro5'),
  _Step('Einstellungen', 'Passe Stimme, Farben, Schriftgröße und mehr an.', Icons.settings_outlined, 'intro6'),
];

class HelpWizard extends StatefulWidget {
  const HelpWizard({super.key});
  @override
  State<HelpWizard> createState() => _HelpWizardState();
}

class _HelpWizardState extends State<HelpWizard> {
  final _pc = PageController();
  int _i = 0;
  AppState? _st;

  void _speak(int i) {
    final st = _st ?? context.read<AppState>();
    final s = _steps[i];
    st.media.speakActivity(Activity(id: 'help', key: s.key, label: s.title, spoken: s.text), st.settings);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) { _st = context.read<AppState>(); _speak(0); });
  }

  @override
  void dispose() { _st?.media.stop(); _pc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final last = _i == _steps.length - 1;
    return Scaffold(
      appBar: AppBar(title: const Text('Einführung & Hilfe'),
        backgroundColor: Colors.transparent, elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context))]),
      body: SafeArea(child: Column(children: [
        Expanded(child: PageView.builder(
          controller: _pc, itemCount: _steps.length,
          onPageChanged: (i) { setState(() => _i = i); _speak(i); },
          itemBuilder: (c, i) {
            final s = _steps[i];
            return Padding(padding: const EdgeInsets.all(28),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(width: 150, height: 150, decoration: BoxDecoration(
                    color: AppTheme.tile(c), borderRadius: BorderRadius.circular(36)),
                  child: Icon(s.icon, size: 84, color: Colors.white)),
                const SizedBox(height: 26),
                Text(s.title, textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: cs.onSurface)),
                const SizedBox(height: 12),
                Text(s.text, textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17, height: 1.4, color: cs.onSurface.withOpacity(.7))),
                const SizedBox(height: 22),
                OutlinedButton.icon(onPressed: () => _speak(i),
                    icon: const Icon(Icons.volume_up_rounded), label: const Text('Vorlesen')),
              ]));
          },
        )),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (int d = 0; d < _steps.length; d++) AnimatedContainer(
            duration: const Duration(milliseconds: 200), margin: const EdgeInsets.all(4),
            width: d == _i ? 22 : 8, height: 8,
            decoration: BoxDecoration(color: d == _i ? cs.primary : cs.onSurface.withOpacity(.2),
                borderRadius: BorderRadius.circular(4))),
        ]),
        Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
          child: Row(children: [
            if (_i > 0) TextButton(onPressed: () => _pc.previousPage(
                duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
              child: const Text('Zurück')),
            const Spacer(),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: kAccent, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14)),
              onPressed: () => last ? Navigator.pop(context) : _pc.nextPage(
                  duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
              child: Text(last ? 'Fertig' : 'Weiter', style: const TextStyle(fontWeight: FontWeight.w700))),
          ])),
      ])),
    );
  }
}
