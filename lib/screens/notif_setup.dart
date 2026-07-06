import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

// Geführte, sehr einfache Einrichtung der Erinnerungen (für Laien).
class NotifSetupScreen extends StatelessWidget {
  const NotifSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.read<AppState>();
    final cs = Theme.of(context).colorScheme;
    final ink = cs.onSurface;

    void toast(String m) => ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1600)));

    return Scaffold(
      appBar: AppBar(title: const Text('Erinnerungen einrichten'),
          backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Text('Damit die App dich pünktlich erinnert, brauchst du nur 3 kurze Schritte.',
              style: TextStyle(fontSize: 16, color: ink)),
          const SizedBox(height: 18),

          if (kIsWeb)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0x22EC6A53), borderRadius: BorderRadius.circular(18)),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded, color: kAccent),
                const SizedBox(width: 12),
                Expanded(child: Text(
                    'Du nutzt gerade die Web-Version im Browser. Zuverlässige Erinnerungen gibt es nur in der installierten App. '
                    'Bitte die App (Android) installieren.',
                    style: TextStyle(color: ink, fontSize: 13.5))),
              ]),
            ),

          _step(cs, ink, '1', 'Erinnerungen erlauben',
              'Tippe auf den Knopf und wähle „Erlauben".',
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: kAccent, foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48)),
                onPressed: () async { await st.requestReminderPermissions(); toast('Danke! Erlaubnis abgefragt.'); },
                icon: const Icon(Icons.check_rounded),
                label: const Text('Jetzt erlauben', style: TextStyle(fontWeight: FontWeight.w700)),
              )),

          _step(cs, ink, '2', 'Test machen',
              'Tippe hier – gleich sollte oben eine Meldung erscheinen. Dann funktioniert es!',
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: cs.primary, foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48)),
                onPressed: () async { await st.sendTestReminder(); },
                icon: const Icon(Icons.notifications_active_rounded),
                label: const Text('Test-Erinnerung senden', style: TextStyle(fontWeight: FontWeight.w700)),
              )),

          _step(cs, ink, '3', 'Akku nicht sparen',
              'Damit die App auch im Hintergrund pünktlich ist:\n'
              'Einstellungen → Apps → Tagesbegleiter → Akku → „Uneingeschränkt".',
              null),

          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10)]),
            child: Row(children: [
              Icon(Icons.check_circle_rounded, color: cs.primary),
              const SizedBox(width: 10),
              Expanded(child: Text('Fertig! Ab jetzt meldet sich die App automatisch, wenn ein neuer Schritt beginnt.',
                  style: TextStyle(color: ink, fontSize: 13.5))),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _step(ColorScheme cs, Color ink, String n, String title, String body, Widget? action) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 12)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(radius: 16, backgroundColor: cs.primary,
                child: Text(n, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ink)),
              const SizedBox(height: 4),
              Text(body, style: TextStyle(fontSize: 14, height: 1.35, color: ink.withOpacity(.7))),
            ])),
          ]),
          if (action != null) Padding(padding: const EdgeInsets.only(top: 14), child: action),
        ]),
      );
}
