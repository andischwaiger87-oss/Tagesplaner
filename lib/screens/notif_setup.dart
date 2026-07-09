import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

// Maximal einfache Einrichtung: EIN Knopf erledigt alles.
class NotifSetupScreen extends StatefulWidget {
  const NotifSetupScreen({super.key});
  @override
  State<NotifSetupScreen> createState() => _NotifSetupScreenState();
}

class _NotifSetupScreenState extends State<NotifSetupScreen> {
  bool _busy = false;
  bool? _ok;

  Future<void> _setup() async {
    final st = context.read<AppState>();
    setState(() => _busy = true);
    final allowed = await st.requestReminderPermissions();
    final tested = allowed ? await st.sendTestReminder() : false;
    if (!mounted) return;
    setState(() { _busy = false; _ok = allowed && tested; });
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(_ok == true
            ? 'Es hat geklappt! Du hast gerade eine Test-Meldung bekommen.'
            : 'Bitte erlaube die Benachrichtigungen.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    final ink = cs.onSurface;
    final ok = _ok ?? st.remindersGranted;

    return Scaffold(
      appBar: AppBar(title: const Text('Erinnerungen einrichten'),
          backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Text('Tippe einmal auf den großen Knopf.\nDen Rest macht die App für dich.',
              style: TextStyle(fontSize: 18, height: 1.35, color: ink)),
          const SizedBox(height: 22),

          // Ein Knopf für alles
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: kAccent, foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(64),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: _busy ? null : _setup,
              icon: _busy
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Icon(Icons.notifications_active_rounded, size: 28),
              label: Text(_busy ? 'Einen Moment …' : 'Erinnerungen aktivieren',
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 18),

          // Status, sehr klar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ok ? cs.primary : Colors.transparent, width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 12)],
            ),
            child: Row(children: [
              Icon(ok ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                  size: 32, color: ok ? cs.primary : kAccent),
              const SizedBox(width: 12),
              Expanded(child: Text(
                ok
                    ? 'Erinnerungen sind aktiv. Die App meldet sich, wenn ein Schritt beginnt.'
                    : 'Erinnerungen sind noch nicht erlaubt. Tippe oben auf den Knopf und wähle „Zulassen".',
                style: TextStyle(fontSize: 15, height: 1.3, color: ink))),
            ]),
          ),

          if (kIsWeb) ...[
            const SizedBox(height: 22),
            Text('Noch besser: App installieren',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: ink)),
            const SizedBox(height: 6),
            Text('So meldet sich die App auch dann, wenn du den Browser schließt.',
                style: TextStyle(fontSize: 14, color: ink.withOpacity(.7))),
            const SizedBox(height: 12),
            if (st.canInstallApp)
              SizedBox(width: double.infinity, child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: cs.primary, foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                onPressed: () => st.installApp(),
                icon: const Icon(Icons.install_mobile_rounded, size: 26),
                label: const Text('App installieren', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ))
            else
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  Icon(Icons.more_vert_rounded, color: cs.primary),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Tippe oben rechts im Browser auf die 3 Punkte und wähle „App installieren".',
                      style: TextStyle(fontSize: 14, height: 1.3, color: ink))),
                ]),
              ),
          ],

          const SizedBox(height: 24),
          Text('Tipp: Damit die Erinnerung immer pünktlich kommt, nimm die App in den Handy-Einstellungen '
              'von der Akku-Sparfunktion aus (Einstellungen → Apps → Tagesbegleiter → Akku → „Uneingeschränkt").',
              style: TextStyle(fontSize: 13, height: 1.35, color: ink.withOpacity(.6))),
        ]),
      ),
    );
  }
}
