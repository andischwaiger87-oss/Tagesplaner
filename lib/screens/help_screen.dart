import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/update_check.dart' show openExternal;
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Hilfe-Knopf auf „Jetzt" – nur sichtbar, wenn eine Personengruppe gewählt
/// und eine Notfallnummer eingetragen ist.
class HelpButton extends StatelessWidget {
  final bool large;
  const HelpButton({super.key, this.large = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Hilfe holen',
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFC62828),
            side: const BorderSide(color: Color(0xFFC62828), width: 2),
            backgroundColor: cs.surface,
            padding: EdgeInsets.symmetric(vertical: large ? 18 : 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HelpScreen())),
          icon: Icon(Icons.sos_rounded, size: large ? 30 : 26),
          label: Text('Hilfe', style: TextStyle(fontSize: large ? 22 : 19, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

/// Hilfe-Seite: ein großer Anruf-Knopf + Notfallpass.
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});
  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  AppState? _st;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _st = context.read<AppState>();
      if (!_st!.settings.discreet) {
        _st!.media.speakActivity(Activity(id: 'help_calm', key: 'beruhigen', label: 'Ruhig werden',
            spoken: 'Alles ist gut. Hilfe ist da.'), _st!.settings);
      }
    });
  }

  @override
  void dispose() { _st?.media.stop(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final s = st.settings;
    final cs = Theme.of(context).colorScheme;
    final ink = cs.onSurface;
    final who = s.emergencyName.trim().isEmpty ? 'Kontaktperson' : s.emergencyName.trim();
    final phone = s.emergencyPhone.replaceAll(RegExp(r'[^0-9+]'), '');

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(title: const Text('Hilfe'), backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 28), children: [
        Text('Keine Sorge.\nHilfe ist da.', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, height: 1.15, color: ink)),
        const SizedBox(height: 24),
        if (phone.isNotEmpty) Semantics(button: true, label: '$who anrufen',
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC62828), foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 26),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
            onPressed: () => openExternal('tel:$phone'),
            child: Column(children: [
              const Icon(Icons.call_rounded, size: 40),
              const SizedBox(height: 6),
              Text('$who anrufen', textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              Text(s.emergencyPhone, style: const TextStyle(fontSize: 16)),
            ]),
          )),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.tile(context), width: 2)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.badge_outlined, color: AppTheme.tile(context), size: 28),
              const SizedBox(width: 10),
              Text('Notfallpass', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ink)),
            ]),
            const SizedBox(height: 4),
            Text('Für Helferinnen und Helfer', style: TextStyle(fontSize: 13, color: ink.withOpacity(.55))),
            const Divider(height: 22),
            if (s.name.trim().isNotEmpty) _line('Name', s.name.trim(), ink),
            _line('Kontakt', phone.isEmpty ? who : '$who · ${s.emergencyPhone}', ink),
            if (s.emergencyInfo.trim().isNotEmpty) _line('Wichtig', s.emergencyInfo.trim(), ink),
          ]),
        ),
        const SizedBox(height: 18),
        Text('Im Notfall: 144 (Rettung) · 112 (Euronotruf)', textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: ink.withOpacity(.6))),
      ])),
    );
  }

  Widget _line(String k, String v, Color ink) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(k, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink.withOpacity(.55))),
      const SizedBox(height: 2),
      Text(v, style: TextStyle(fontSize: 18, height: 1.3, color: ink)),
    ]),
  );
}
