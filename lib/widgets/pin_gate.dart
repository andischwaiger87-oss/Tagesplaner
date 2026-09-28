import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../state/app_state.dart';

/// Fragt die PIN ab, wenn Bearbeiten/Einstellungen gesperrt sind.
/// Gibt true zurück, wenn der Zugang frei ist.
Future<bool> ensureUnlocked(BuildContext context, AppState st) async {
  if (!st.locked) return true;
  final ok = await showDialog<bool>(context: context, builder: (_) => _PinDialog(st: st));
  return ok == true;
}

class _PinDialog extends StatefulWidget {
  final AppState st;
  const _PinDialog({required this.st});
  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final _c = TextEditingController();
  String? _err;

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  void _check() {
    if (widget.st.unlock(_c.text)) {
      Navigator.pop(context, true);
    } else {
      setState(() { _err = 'Falsche PIN'; _c.clear(); });
    }
  }

  Future<void> _forgot() async {
    final c = TextEditingController();
    final reset = await showDialog<bool>(context: context, builder: (dc) => AlertDialog(
      title: const Text('PIN vergessen?'),
      content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Die Sperre schützt nur vor versehentlichen Änderungen. '
            'Zum Aufheben bitte ZURÜCKSETZEN eintippen. Pläne und Einstellungen bleiben erhalten.'),
        const SizedBox(height: 12),
        TextField(controller: c, autofocus: true, textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true)),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dc, false), child: const Text('Abbrechen')),
        FilledButton(onPressed: () => Navigator.pop(dc, c.text.trim().toUpperCase() == 'ZURÜCKSETZEN'),
            child: const Text('Sperre aufheben')),
      ],
    ));
    c.dispose();
    if (!mounted) return;
    if (reset == true) {
      widget.st.setPin('');
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Für Betreuende'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Bitte PIN eingeben.'),
        const SizedBox(height: 12),
        TextField(
          controller: _c, autofocus: true, obscureText: true, maxLength: 6,
          keyboardType: TextInputType.number, textAlign: TextAlign.center,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 24, letterSpacing: 8),
          decoration: InputDecoration(border: const OutlineInputBorder(), counterText: '', errorText: _err),
          onSubmitted: (_) => _check(),
        ),
        Align(alignment: Alignment.centerLeft,
            child: TextButton(onPressed: _forgot, child: const Text('PIN vergessen?'))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Abbrechen')),
        FilledButton(onPressed: _check, child: const Text('Öffnen')),
      ],
    );
  }
}
