import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import 'help_screen.dart';

/// Betreuung & Sicherheit: Personengruppe, Notfall, Sperre, Sicherung.
/// Bewusst als eigene Seite – die Einstellungen bleiben so übersichtlich wie bisher.
class CareSettingsScreen extends StatelessWidget {
  const CareSettingsScreen({super.key});

  static const _profileInfo = {
    'allgemein': 'Die gewohnte Ansicht – ohne Zusätze.',
    'kognitiv': 'Hilfe-Knopf und ruhige Nachtansicht.',
    'ads': 'Hilfe-Knopf und eine Erinnerung 5 Minuten vor jedem Wechsel („Noch 5 Minuten").',
    'autismus': 'Hilfe-Knopf, Nachtansicht und eine Vorwarnung 2 Minuten vor jedem Wechsel.',
    'demenz': 'Hilfe-Knopf und ruhige Nachtansicht („Es ist Nacht. Du kannst weiterschlafen.").',
  };

  void _toast(BuildContext c, String m) {
    ScaffoldMessenger.of(c)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(m), duration: const Duration(milliseconds: 1600),
          behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final s = st.settings;
    final cs = Theme.of(context).colorScheme;
    final ink = cs.onSurface;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Betreuung & Sicherheit'),
          backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 28), children: [
        _header('Für wen ist die App?', ink),
        _card(cs, [
          for (final e in kProfiles.entries)
            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              value: e.key, groupValue: s.profile,
              title: Text(e.value, style: TextStyle(fontWeight: FontWeight.w600, color: ink)),
              subtitle: Text(_profileInfo[e.key] ?? '', style: TextStyle(fontSize: 12.5, color: ink.withOpacity(.6))),
              onChanged: (v) {
                if (v == null) return;
                st.updateSettings((x) => x.profile = v);
                _toast(context, 'Personengruppe: ${e.value}');
              },
            ),
          Padding(padding: const EdgeInsets.fromLTRB(4, 6, 4, 2),
            child: Text('Für alle gilt: Bei Medikamenten, Tropfen und Insulin fragt die App '
                '15 Minuten später nach, ob es erledigt wurde.',
                style: TextStyle(fontSize: 12.5, height: 1.3, color: ink.withOpacity(.6)))),
        ]),

        _header('Notfall', ink),
        _card(cs, [
          _edit(context, Icons.person_outline_rounded, 'Kontaktperson', s.emergencyName,
              'z. B. Mama, Betreuerin Anna', (v) => st.updateSettings((x) => x.emergencyName = v)),
          _edit(context, Icons.call_outlined, 'Telefonnummer', s.emergencyPhone,
              'z. B. +43 664 1234567', (v) => st.updateSettings((x) => x.emergencyPhone = v),
              phone: true),
          _edit(context, Icons.badge_outlined, 'Notfallpass', s.emergencyInfo,
              'Adresse, Medikamente, Allergien, Hinweise …',
              (v) => st.updateSettings((x) => x.emergencyInfo = v), multiline: true),
          Padding(padding: const EdgeInsets.fromLTRB(4, 6, 4, 4),
            child: Text(s.showHelpButton
                ? 'Der Hilfe-Knopf ist auf „Jetzt" sichtbar.'
                : 'Der Hilfe-Knopf erscheint auf „Jetzt", sobald oben eine Personengruppe gewählt '
                  'und eine Telefonnummer eingetragen ist.',
                style: TextStyle(fontSize: 12.5, height: 1.3, color: ink.withOpacity(.6)))),
          if (s.hasEmergency) Align(alignment: Alignment.centerLeft, child: TextButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HelpScreen())),
            icon: const Icon(Icons.visibility_outlined, size: 18),
            label: const Text('Hilfe-Seite ansehen'))),
        ]),

        _header('Sperre für Betreuende', ink),
        _card(cs, [
          ListTile(contentPadding: EdgeInsets.zero,
            leading: Icon(s.pin.isEmpty ? Icons.lock_open_rounded : Icons.lock_rounded, color: cs.primary),
            title: Text(s.pin.isEmpty ? 'PIN festlegen' : 'PIN ändern',
                style: TextStyle(fontWeight: FontWeight.w600, color: ink)),
            subtitle: Text('Schützt „Bearbeiten" und „Einstellungen" vor versehentlichen Änderungen.',
                style: TextStyle(fontSize: 12.5, color: ink.withOpacity(.55))),
            onTap: () => _setPin(context, st),
          ),
          if (s.pin.isNotEmpty) ListTile(contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.no_encryption_outlined, color: cs.primary),
            title: Text('Sperre entfernen', style: TextStyle(fontWeight: FontWeight.w600, color: ink)),
            onTap: () { st.setPin(''); _toast(context, 'Sperre entfernt'); },
          ),
        ]),

        _header('Sicherung', ink),
        _card(cs, [
          ListTile(contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.save_alt_rounded, color: cs.primary),
            title: Text('Sicherung erstellen', style: TextStyle(fontWeight: FontWeight.w600, color: ink)),
            subtitle: Text('Alle Pläne und Einstellungen als Text kopieren – z. B. per Mail an dich selbst.',
                style: TextStyle(fontSize: 12.5, color: ink.withOpacity(.55))),
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: st.exportBackup()));
              if (context.mounted) _toast(context, 'Sicherung kopiert – jetzt z. B. in eine Mail einfügen');
            },
          ),
          ListTile(contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.settings_backup_restore_rounded, color: cs.primary),
            title: Text('Sicherung einspielen', style: TextStyle(fontWeight: FontWeight.w600, color: ink)),
            subtitle: Text('Ersetzt die aktuellen Pläne. Profilbilder bleiben erhalten.',
                style: TextStyle(fontSize: 12.5, color: ink.withOpacity(.55))),
            onTap: () => _import(context, st),
          ),
        ]),
      ])),
    );
  }

  Widget _header(String t, Color ink) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 12, 0, 8),
    child: Text(t, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: ink)));

  Widget _card(ColorScheme cs, List<Widget> children) => Container(
    decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(22),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 14)]),
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children));

  Widget _edit(BuildContext c, IconData ic, String label, String value, String hint,
      ValueChanged<String> save, {bool phone = false, bool multiline = false}) {
    final ink = Theme.of(c).colorScheme.onSurface;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(ic, color: Theme.of(c).colorScheme.primary),
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: ink)),
      subtitle: Text(value.trim().isEmpty ? 'nicht eingetragen' : value.trim(),
          maxLines: 2, overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13, color: ink.withOpacity(.6))),
      trailing: Icon(Icons.edit_outlined, size: 20, color: ink.withOpacity(.45)),
      onTap: () async {
        final ctrl = TextEditingController(text: value);
        final r = await showDialog<String>(context: c, builder: (dc) => AlertDialog(
          title: Text(label),
          content: TextField(controller: ctrl, autofocus: true,
            keyboardType: phone ? TextInputType.phone : (multiline ? TextInputType.multiline : TextInputType.text),
            minLines: multiline ? 4 : 1, maxLines: multiline ? 8 : 1,
            decoration: InputDecoration(hintText: hint, border: const OutlineInputBorder())),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dc), child: const Text('Abbrechen')),
            FilledButton(onPressed: () => Navigator.pop(dc, ctrl.text.trim()), child: const Text('Speichern')),
          ],
        ));
        ctrl.dispose();
        if (r != null) { save(r); if (c.mounted) _toast(c, '$label gespeichert'); }
      },
    );
  }

  Future<void> _setPin(BuildContext c, AppState st) async {
    final a = TextEditingController();
    final b = TextEditingController();
    final pin = await showDialog<String>(context: c, builder: (dc) => StatefulBuilder(builder: (dc, set) {
      return AlertDialog(
        title: const Text('PIN festlegen'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('4 bis 6 Ziffern. Gilt für „Bearbeiten" und „Einstellungen".'),
          const SizedBox(height: 12),
          TextField(controller: a, autofocus: true, obscureText: true, maxLength: 6,
            keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(labelText: 'PIN', border: OutlineInputBorder(), counterText: '')),
          const SizedBox(height: 10),
          TextField(controller: b, obscureText: true, maxLength: 6,
            keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: 'PIN wiederholen', border: const OutlineInputBorder(),
                counterText: '')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dc), child: const Text('Abbrechen')),
          FilledButton(onPressed: () {
            if (a.text.length >= 4 && a.text == b.text) Navigator.pop(dc, a.text);
          }, child: const Text('Speichern')),
        ],
      );
    }));
    a.dispose(); b.dispose();
    if (pin == null) return;
    st.setPin(pin);
    if (c.mounted) _toast(c, 'PIN gespeichert');
  }

  Future<void> _import(BuildContext c, AppState st) async {
    final ctrl = TextEditingController();
    final text = await showDialog<String>(context: c, builder: (dc) => AlertDialog(
      title: const Text('Sicherung einspielen'),
      content: TextField(controller: ctrl, autofocus: true, minLines: 4, maxLines: 8,
        decoration: const InputDecoration(hintText: 'Sicherungstext hier einfügen',
            border: OutlineInputBorder())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dc), child: const Text('Abbrechen')),
        FilledButton(onPressed: () => Navigator.pop(dc, ctrl.text), child: const Text('Weiter')),
      ],
    ));
    ctrl.dispose();
    if (text == null || text.trim().isEmpty || !c.mounted) return;
    final sure = await showDialog<bool>(context: c, builder: (dc) => AlertDialog(
      title: const Text('Wirklich ersetzen?'),
      content: const Text('Die aktuellen Pläne und Einstellungen werden durch die Sicherung ersetzt.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dc, false), child: const Text('Abbrechen')),
        FilledButton(onPressed: () => Navigator.pop(dc, true), child: const Text('Ersetzen')),
      ],
    ));
    if (sure != true || !c.mounted) return;
    final err = st.importBackup(text);
    _toast(c, err ?? 'Sicherung eingespielt');
  }
}
