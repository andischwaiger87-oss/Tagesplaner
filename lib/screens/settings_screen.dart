import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../services/update_check.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../services/image_util.dart';
import 'help_wizard.dart';
import 'notif_setup.dart';

const String appVersion = '0.1 (Beta)';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _toast(BuildContext c, String m) {
    ScaffoldMessenger.of(c)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(m), duration: const Duration(milliseconds: 1000),
          behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    final s = st.settings;
    final ink = cs.onSurface;

    return SafeArea(
      child: ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 28), children: [
        Text('Einstellungen', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: ink)),
        Text('Alles individuell anpassbar', style: TextStyle(fontSize: 16, color: ink.withOpacity(.6))),
        const SizedBox(height: 16),

        const _UpdateCard(),
        _header('Persönlich', ink),
        _card(cs, [
          // Profilbild + Name
          Row(children: [
            _avatarPick(context, st, s.avatarUser, 56, (b) => st.updateSettings((x) => x.avatarUser = b)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Profilbild', style: TextStyle(fontWeight: FontWeight.w600, color: ink)),
              Text('Wird oben neben deinem Namen angezeigt',
                  style: TextStyle(fontSize: 12.5, color: ink.withOpacity(.55))),
            ])),
          ]),
          const Divider(height: 26),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Name', style: TextStyle(fontWeight: FontWeight.w600, color: ink)),
            const _NameField(),
          ]),
        ]),

        _header('Stimme', ink),
        _card(cs, [
          Text('Mit welcher Stimme soll vorgelesen werden?',
              style: TextStyle(color: ink.withOpacity(.7), fontSize: 14)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _voiceCard(context, st, 'f', 'Frau', s.avatarF,
                (b) => st.updateSettings((x) => x.avatarF = b))),
            const SizedBox(width: 12),
            Expanded(child: _voiceCard(context, st, 'm', 'Mann', s.avatarM,
                (b) => st.updateSettings((x) => x.avatarM = b))),
          ]),
        ]),

        _header('Erinnerungen', ink),
        _card(cs, [
          ListTile(contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.notifications_active_rounded, color: cs.primary),
            title: Text('Erinnerungen einrichten', style: TextStyle(fontWeight: FontWeight.w600, color: ink)),
            subtitle: Text('In 3 einfachen Schritten – damit die App sich pünktlich meldet.',
                style: TextStyle(fontSize: 12.5, color: ink.withOpacity(.55))),
            trailing: Icon(Icons.chevron_right_rounded, color: ink.withOpacity(.5)),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotifSetupScreen())),
          ),
        ]),

        _header('Darstellung', ink),
        _card(cs, [
          _row('Farbthema', ink, Row(mainAxisSize: MainAxisSize.min, children: [
            for (int i = 0; i < kSeeds.length; i++) GestureDetector(
              onTap: () { st.updateSettings((x) => x.themeIndex = i); _toast(context, 'Farbe übernommen'); },
              child: Container(width: 30, height: 30, margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(color: kSeeds[i], shape: BoxShape.circle,
                  border: Border.all(color: s.themeIndex == i ? ink : Colors.transparent, width: 3))),
            ),
          ])),
          _switch(context, 'Hoher Kontrast', ink, s.highContrast,
              (v) => st.updateSettings((x) => x.highContrast = v)),
          _row('Schriftgröße', ink, SizedBox(width: 170, child: Slider(
            value: s.fontScale, min: 1, max: 1.4, divisions: 4,
            onChanged: (v) => st.updateSettings((x) => x.fontScale = v),
            onChangeEnd: (v) => _toast(context, 'Schriftgröße gespeichert')))),
          _switch(context, 'Animationen reduzieren', ink, s.reduceMotion,
              (v) => st.updateSettings((x) => x.reduceMotion = v)),
        ]),

        _header('Verhalten', ink),
        _card(cs, [
          _switch(context, '„Als Nächstes" zeigen', ink, s.showNext, (v) => st.updateSettings((x) => x.showNext = v)),
          _switch(context, 'Uhrzeiten zeigen', ink, s.showClock, (v) => st.updateSettings((x) => x.showClock = v)),
          _switch(context, 'Vibration', ink, s.vibrate, (v) => st.updateSettings((x) => x.vibrate = v)),
          _row('Lautstärke', ink, SizedBox(width: 170, child: Slider(
            value: s.volume, min: 0, max: 1, divisions: 10,
            onChanged: (v) => st.updateSettings((x) => x.volume = v),
            onChangeEnd: (v) => _toast(context, 'Lautstärke gespeichert')))),
        ]),

        _header('Hilfe', ink),
        _card(cs, [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.help_outline_rounded, color: cs.primary),
            title: Text('Einführung & Hilfe', style: TextStyle(fontWeight: FontWeight.w600, color: ink)),
            subtitle: Text('Schritt für Schritt erklärt – auch zum Vorlesen',
                style: TextStyle(fontSize: 12.5, color: ink.withOpacity(.55))),
            trailing: Icon(Icons.chevron_right_rounded, color: ink.withOpacity(.5)),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HelpWizard())),
          ),
        ]),

        _header('Über die App', ink),
        _card(cs, [
          ListTile(contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.info_outline_rounded, color: cs.primary),
            title: Text('Version & Projekt', style: TextStyle(fontWeight: FontWeight.w600, color: ink)),
            subtitle: Text('Tagesbegleiter $appVersion · gemeinnütziges Open-Source-Projekt',
                style: TextStyle(fontSize: 12.5, color: ink.withOpacity(.55)))),
          const Divider(height: 8),
          ListTile(contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.shield_outlined, color: cs.primary),
            title: Text('Datenschutz', style: TextStyle(fontWeight: FontWeight.w600, color: ink)),
            trailing: Icon(Icons.chevron_right_rounded, color: ink.withOpacity(.5)),
            onTap: () => showDialog(context: context, builder: (_) => AlertDialog(
              title: const Text('Datenschutz'),
              content: const Text('Tagesbegleiter speichert alle Pläne und Einstellungen ausschließlich lokal auf deinem Gerät. '
                  'Es gibt keine Konten, keine Werbung und kein Tracking. Standortdaten werden nicht erhoben.'),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]))),
          ListTile(contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.business_outlined, color: cs.primary),
            title: Text('Impressum', style: TextStyle(fontWeight: FontWeight.w600, color: ink)),
            trailing: Icon(Icons.chevron_right_rounded, color: ink.withOpacity(.5)),
            onTap: () => showDialog(context: context, builder: (_) => AlertDialog(
              title: const Text('Impressum'),
              content: const Text('Tagesbegleiter ist ein ehrenamtliches, gemeinnütziges Open-Source-Projekt.\n\n'
                  'Umsetzung: mosaik-design.at\nAndreas Schwaiger\nhallo@mosaik-design.at'),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]))),
          const Divider(height: 8),
          ListTile(contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.restart_alt_rounded, color: cs.primary),
            title: Text('Standardplan wiederherstellen', style: TextStyle(fontWeight: FontWeight.w600, color: ink)),
            subtitle: Text('Setzt alle Wochentage auf den Standard zurück.',
                style: TextStyle(fontSize: 12.5, color: ink.withOpacity(.55))),
            onTap: () => showDialog(context: context, builder: (_) => AlertDialog(
              title: const Text('Wirklich zurücksetzen?'),
              content: const Text('Alle Wochentage werden auf den Standardplan gesetzt. Deine bisherigen Pläne gehen verloren.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
                FilledButton(onPressed: () { st.resetWeek(); Navigator.pop(context); _toast(context, 'Standardplan wiederhergestellt'); },
                    child: const Text('Zurücksetzen')),
              ]))),
        ]),
      ]),
    );
  }

  // ---- Bausteine ----
  Widget _header(String t, Color ink) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 8, 0, 8),
    child: Text(t, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: ink)));

  Widget _card(ColorScheme cs, List<Widget> children) => Container(
    decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(22),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 14)]),
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
    margin: const EdgeInsets.only(bottom: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children));

  Widget _row(String k, Color ink, Widget control) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Flexible(child: Text(k, style: TextStyle(fontWeight: FontWeight.w600, color: ink))), control,
    ]));

  Widget _switch(BuildContext c, String k, Color ink, bool v, ValueChanged<bool> on) =>
    _row(k, ink, Switch(value: v, onChanged: (nv) { on(nv); _toast(c, nv ? 'Aktiviert' : 'Deaktiviert'); }));

  Widget _avatarPick(BuildContext c, AppState st, String? b64, double size, ValueChanged<String?> save) =>
    GestureDetector(
      onTap: () => _avatarMenu(c, b64, save),
      child: Stack(children: [
        CircleAvatar(radius: size / 2, backgroundColor: AppTheme.tile(c),
          backgroundImage: avatarProvider(b64),
          child: b64 == null ? Icon(Icons.person_rounded, color: Colors.white, size: size * .55) : null),
        Positioned(right: 0, bottom: 0, child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(color: kAccent, shape: BoxShape.circle,
            border: Border.all(color: Theme.of(c).colorScheme.surface, width: 2)),
          child: const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 13))),
      ]),
    );

  Future<void> _avatarMenu(BuildContext c, String? b64, ValueChanged<String?> save) async {
    final r = await showModalBottomSheet<String>(context: c, builder: (_) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: const Icon(Icons.photo_library_outlined), title: const Text('Bild wählen'),
            onTap: () => Navigator.pop(c, 'pick')),
        if (b64 != null) ListTile(leading: const Icon(Icons.delete_outline_rounded), title: const Text('Bild entfernen'),
            onTap: () => Navigator.pop(c, 'remove')),
        ListTile(leading: const Icon(Icons.close_rounded), title: const Text('Abbrechen'),
            onTap: () => Navigator.pop(c)),
      ])));
    if (r == 'pick') { final img = await pickImageBase64(); if (img != null) { save(img); _toast(c, 'Bild gespeichert'); } }
    else if (r == 'remove') { save(null); _toast(c, 'Bild entfernt'); }
  }

  Widget _voiceCard(BuildContext c, AppState st, String voice, String label, String? b64, ValueChanged<String?> save) {
    final cs = Theme.of(c).colorScheme;
    final on = st.settings.voice == voice;
    return GestureDetector(
      onTap: () { st.updateSettings((x) => x.voice = voice); _toast(c, 'Stimme: $label'); },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: on ? AppTheme.tile(c).withOpacity(.12) : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: on ? kAccent : Colors.transparent, width: 2),
        ),
        child: Column(children: [
          _avatarPick(c, st, b64, 56, save),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface)),
          Text(on ? 'ausgewählt' : 'auswählen',
              style: TextStyle(fontSize: 12, color: on ? kAccent : cs.onSurface.withOpacity(.5))),
        ]),
      ),
    );
  }
}


// Eigenes Namensfeld: behält den Controller, damit die Eingabe beim
// sekündlichen Neuaufbau nicht überschrieben wird.
class _NameField extends StatefulWidget {
  const _NameField();
  @override
  State<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<_NameField> {
  late final TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: context.read<AppState>().settings.name);
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final st = context.read<AppState>();
    return SizedBox(
      width: 170,
      child: TextField(
        controller: _c,
        maxLength: 20,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
            isDense: true, border: OutlineInputBorder(), counterText: ''),
        onChanged: (v) {
          final n = v.trim();
          if (n.isNotEmpty) st.updateSettings((x) => x.name = n);
        },
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
      ),
    );
  }
}

/// Zeigt eine Karte, sobald eine neuere Version veröffentlicht wurde.
/// Nur in der installierten App – die Web-Version aktualisiert sich selbst.
class _UpdateCard extends StatefulWidget {
  const _UpdateCard();
  @override
  State<_UpdateCard> createState() => _UpdateCardState();
}

class _UpdateCardState extends State<_UpdateCard> {
  int? _latest;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final b = await fetchLatestBuild();
    if (mounted) setState(() => _latest = b);
  }

  @override
  Widget build(BuildContext context) {
    final l = _latest;
    if (kIsWeb || l == null || l <= kBuildNumber) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Eine neue Version der App ist verfügbar',
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kAccent.withOpacity(.12),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: kAccent.withOpacity(.35), width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.system_update_rounded, color: kAccent, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Neue Version verfügbar',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: cs.onSurface)),
                  const SizedBox(height: 2),
                  Text('Deine Pläne und Einstellungen bleiben erhalten.',
                      style: TextStyle(fontSize: 13, color: cs.onSurface.withOpacity(.65))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: kAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => openExternal(kApkDownloadUrl),
              child: const Text('Holen', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
