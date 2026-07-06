import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../data/default_data.dart';
import '../theme/app_theme.dart';
import '../widgets/activity_icon.dart';
import '../util/format.dart';

// Kompakte Meldung – wird per eigenem Timer zuverlässig geschlossen
// (unabhängig von Browser-/Plattform-Eigenheiten).
void _snack(BuildContext c, String m, {bool undo = false, VoidCallback? onUndo}) {
  final messenger = ScaffoldMessenger.of(c);
  messenger.clearSnackBars();
  final ctrl = messenger.showSnackBar(SnackBar(
    content: Text(m, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5)),
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    duration: const Duration(days: 1),
    action: undo ? SnackBarAction(label: 'Rückgängig', onPressed: onUndo ?? () {}) : null,
  ));
  Future.delayed(Duration(milliseconds: undo ? 2600 : 1400), () { try { ctrl.close(); } catch (_) {} });
}

String _hhmm(int min) => '${min ~/ 60}:${(min % 60).toString().padLeft(2, '0')}';
String _wdShort(int d) => const ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'][d - 1];
String _wdLong(int d) => const ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag'][d - 1];

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  Future<void> _setTime(BuildContext c, AppState st, int i) async {
    final a = st.plan[i];
    final t = await showTimePicker(context: c,
        initialTime: TimeOfDay(hour: a.startMinutes ~/ 60, minute: a.startMinutes % 60),
        helpText: 'Startzeit wählen',
        builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true), child: child!));
    if (t == null) return;
    final ok = st.setStart(i, t.hour * 60 + t.minute);
    _snack(c, ok ? 'Zeit gespeichert' : 'Belegt oder zu spät für die Dauer');
  }

  Future<void> _setDuration(BuildContext c, AppState st, int i) async {
    final mins = await showDialog<int>(context: c, builder: (dc) {
      final ctrl = TextEditingController();
      return AlertDialog(
        title: const Text('Wie lange dauert es?'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(spacing: 10, runSpacing: 10, children: [
            for (final v in [5, 10, 15, 20, 30, 45, 60, 90, 120])
              ActionChip(label: Text(fmtDuration(v)), onPressed: () => Navigator.pop(dc, v)),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: TextField(controller: ctrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Eigene Minuten', isDense: true, border: OutlineInputBorder()))),
            const SizedBox(width: 8),
            FilledButton(onPressed: () {
              final v = int.tryParse(ctrl.text.trim());
              if (v != null && v >= 2 && v <= 600) Navigator.pop(dc, v);
            }, child: const Text('OK')),
          ]),
        ]),
      );
    });
    if (mins == null) return;
    final ok = st.setDuration(i, mins);
    _snack(c, ok ? 'Dauer gespeichert' : 'Zu lang – überschneidet sich oder reicht über den Tag hinaus');
  }

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    final ink = cs.onSurface;
    // Kopfbereich (scrollt mit); darunter die per Drag & Drop sortierbaren Einträge.
    final header = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Tag zusammenstellen',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: ink)),
      const SizedBox(height: 12),
      SizedBox(height: 40, child: ListView(scrollDirection: Axis.horizontal, children: [
        for (int d = 1; d <= 7; d++) Padding(padding: const EdgeInsets.only(right: 6),
          child: ChoiceChip(label: Text(_wdShort(d)), selected: st.editingDay == d,
            onSelected: (_) => st.setEditingDay(d))),
      ])),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(child: Text('Plan für ${_wdLong(st.editingDay)} · ${st.plan.length} Schritte',
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w600, color: ink))),
        TextButton.icon(onPressed: () => _copyMenu(context, st),
          icon: const Icon(Icons.copy_all_rounded, size: 18), label: const Text('Kopieren')),
      ]),
      const SizedBox(height: 8),
      SizedBox(width: double.infinity, child: FilledButton.icon(
        style: FilledButton.styleFrom(backgroundColor: kAccent, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        onPressed: () => _showAddSheet(context, st),
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text('Baustein hinzufügen', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      )),
      const SizedBox(height: 14),
      Text('Dein Ablauf', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ink)),
      Text('Am ⠿ halten & ziehen zum Sortieren · Uhrzeit/Dauer antippen',
          style: TextStyle(fontSize: 12.5, color: ink.withOpacity(.55))),
      const SizedBox(height: 10),
    ]);

    if (st.plan.isEmpty) {
      return SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 24), children: [
        header,
        Padding(padding: const EdgeInsets.all(24),
          child: Center(child: Text('Noch keine Schritte.\nTippe „Baustein hinzufügen".',
              textAlign: TextAlign.center, style: TextStyle(color: ink.withOpacity(.5))))),
      ]));
    }
    return SafeArea(
      child: ReorderableListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        buildDefaultDragHandles: false,
        header: header,
        onReorder: (o, n) { if (st.reorderChain(o, n)) { _snack(context, 'Reihenfolge geändert'); } else { _snack(context, 'Passt zeitlich nicht in den Tag'); } },
        children: [for (int i = 0; i < st.plan.length; i++) _row(context, st, i, cs)],
      ),
    );
  }

  Future<void> _pickFile(BuildContext c, AppState st, int i, bool icon) async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: icon ? ['svg'] : ['mp3', 'wav', 'm4a']);
    final p = res?.files.single.path;
    if (p == null) return;
    icon ? st.setIcon(i, p) : st.setAudio(i, p);
    _snack(c, icon ? 'Icon zugewiesen' : 'Sprachdatei zugewiesen');
  }

  Widget _row(BuildContext c, AppState st, int i, ColorScheme cs) {
    final ink = cs.onSurface;
    final a = st.plan[i];
    final isCustom = a.key == null;
    return Container(
      key: ValueKey(a.id),
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 12)]),
      child: Column(children: [
        Row(children: [
          ReorderableDragStartListener(index: i,
            child: Padding(padding: const EdgeInsets.only(right: 6),
              child: Icon(Icons.drag_indicator_rounded, size: 22, color: ink.withOpacity(.35)))),
          IconTile(activity: a, tileSize: 50, iconSize: 34, radius: 14),
          const SizedBox(width: 12),
          Expanded(child: Text(a.label, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: ink))),
          InkWell(onTap: () { final r = a.copy(); st.removeAt(i);
              _snack(c, '„${a.label}" entfernt', undo: true, onUndo: () => st.insertActivity(r)); },
            borderRadius: BorderRadius.circular(12),
            child: Container(width: 40, height: 40,
              decoration: BoxDecoration(color: const Color(0x22EC6A53), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.delete_outline_rounded, size: 22, color: kAccent))),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _chip(c, Icons.schedule_rounded, '${_hhmm(a.startMinutes)} Uhr', () => _setTime(c, st, i), cs),
          const SizedBox(width: 10),
          _chip(c, Icons.timelapse_rounded, fmtDuration(a.durationMin), () => _setDuration(c, st, i), cs),
        ]),
        if (isCustom) Padding(padding: const EdgeInsets.only(top: 8),
          child: Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () => _pickFile(c, st, i, true),
              icon: const Icon(Icons.image_outlined, size: 18),
              label: Text(a.iconPath != null ? 'Icon ✓' : 'Eigenes Icon'))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(onPressed: () => _pickFile(c, st, i, false),
              icon: const Icon(Icons.graphic_eq_rounded, size: 18),
              label: Text(a.audioPath != null ? 'Audio ✓' : 'Eigene Stimme'))),
          ])),
      ]),
    );
  }

  Widget _chip(BuildContext c, IconData ic, String label, VoidCallback on, ColorScheme cs) => InkWell(
    onTap: on, borderRadius: BorderRadius.circular(14),
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(14)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(ic, size: 18, color: cs.onSurface.withOpacity(.7)),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: cs.onSurface)),
        const SizedBox(width: 4),
        Icon(Icons.expand_more_rounded, size: 18, color: cs.onSurface.withOpacity(.5)),
      ])),
  );

  void _copyMenu(BuildContext c, AppState st) {
    showModalBottomSheet(context: c, builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Padding(padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Align(alignment: Alignment.centerLeft, child: Text('Diesen Plan kopieren auf …',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)))),
      ListTile(leading: const Icon(Icons.work_outline_rounded), title: const Text('Alle Werktage (Mo–Fr)'),
        onTap: () { st.copyEditTo([1, 2, 3, 4, 5]); Navigator.pop(c); _snack(c, 'Auf Werktage kopiert'); }),
      ListTile(leading: const Icon(Icons.weekend_outlined), title: const Text('Wochenende (Sa–So)'),
        onTap: () { st.copyEditTo([6, 7]); Navigator.pop(c); _snack(c, 'Auf Wochenende kopiert'); }),
      ListTile(leading: const Icon(Icons.calendar_view_week_rounded), title: const Text('Alle Tage'),
        onTap: () { st.copyEditTo([1, 2, 3, 4, 5, 6, 7]); Navigator.pop(c); _snack(c, 'Auf alle Tage kopiert'); }),
    ])));
  }

  void _showAddSheet(BuildContext context, AppState st) {
    showModalBottomSheet(context: context, isScrollControlled: true, useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _AddSheet(st: st));
  }
}

class _AddSheet extends StatefulWidget {
  final AppState st;
  const _AddSheet({required this.st});
  @override
  State<_AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<_AddSheet> {
  String _query = '';
  String? _cat;
  String? _confirm;
  String? _flashId;
  Timer? _ct;
  Timer? _ft;

  @override
  void dispose() { _ct?.cancel(); _ft?.cancel(); super.dispose(); }

  List<Activity> get _items {
    final all = moduleLibrary();
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      return all.where((m) => m.label.toLowerCase().contains(q)).toList();
    }
    if (_cat == null) return all;
    return moduleCategories().firstWhere((c) => c.name == _cat).items;
  }

  void _add(Activity m) {
    if (!widget.st.addFromTemplate(m)) {
      _snack(context, 'Kein Platz mehr am Tag – bitte eine Aufgabe kürzen oder entfernen.');
      return;
    }
    setState(() { _confirm = m.label; _flashId = m.id; });
    _ct?.cancel(); _ct = Timer(const Duration(milliseconds: 1500), () { if (mounted) setState(() => _confirm = null); });
    _ft?.cancel(); _ft = Timer(const Duration(milliseconds: 550), () { if (mounted) setState(() => _flashId = null); });
  }

  Future<void> _custom() async {
    final nameC = TextEditingController();
    final textC = TextEditingController();
    final added = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Eigener Eintrag'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameC, autofocus: true,
          decoration: const InputDecoration(labelText: 'Name', hintText: 'z. B. Hund füttern')),
        const SizedBox(height: 12),
        TextField(controller: textC, decoration: const InputDecoration(labelText: 'Gesprochener Text (optional)')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Abbrechen')),
        FilledButton(onPressed: () {
          if (nameC.text.trim().isEmpty) { Navigator.pop(c); return; }
          Navigator.pop(c, widget.st.addCustom(nameC.text, spoken: textC.text));
        }, child: const Text('Hinzufügen')),
      ],
    ));
    if (!mounted) return;
    if (added == true) { setState(() { _confirm = nameC.text.trim(); }); }
    else if (added == false) { _snack(context, 'Kein Platz mehr am Tag – bitte kürzen.'); }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cats = moduleCategories();
    final items = _items;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(children: [
          const SizedBox(height: 10),
          Container(width: 44, height: 5, decoration: BoxDecoration(
              color: cs.onSurface.withOpacity(.2), borderRadius: BorderRadius.circular(3))),
          Padding(padding: const EdgeInsets.fromLTRB(16, 10, 8, 6),
            child: Row(children: [
              Expanded(child: Text('Baustein wählen',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: cs.onSurface))),
              TextButton.icon(onPressed: _custom, icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text('Eigener')),
              IconButton(onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded), tooltip: 'Schließen'),
            ])),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(hintText: 'Suchen … (z. B. Frühstück)',
                prefixIcon: const Icon(Icons.search_rounded), filled: true, fillColor: cs.surfaceContainerHighest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 4)))),
          if (_query.trim().isEmpty) SizedBox(height: 46,
            child: ListView(scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), children: [
                Padding(padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(label: const Text('Alle'), selected: _cat == null, onSelected: (_) => setState(() => _cat = null))),
                for (final cc in cats) Padding(padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(label: Text(cc.name), selected: _cat == cc.name, onSelected: (_) => setState(() => _cat = cc.name))),
              ])),
          const SizedBox(height: 4),
          Expanded(child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.86),
            itemCount: items.length,
            itemBuilder: (c, i) {
              final m = items[i];
              final flash = _flashId == m.id;
              return InkWell(onTap: () => _add(m), borderRadius: BorderRadius.circular(18),
                child: Stack(children: [
                  Container(
                    decoration: BoxDecoration(color: AppTheme.tile(context), borderRadius: BorderRadius.circular(18)),
                    padding: const EdgeInsets.all(8),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Expanded(child: Center(child: ActivityIcon(activity: m, size: 46))),
                      const SizedBox(height: 4),
                      Text(m.label, maxLines: 2, textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, height: 1.05)),
                    ])),
                  AnimatedOpacity(opacity: flash ? 1 : 0, duration: const Duration(milliseconds: 150),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.black.withOpacity(.35), borderRadius: BorderRadius.circular(18)),
                      child: const Center(child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 44)))),
                ]));
            },
          )),
          // sichtbare Bestätigung (über dem Raster, schließt sich selbst)
          AnimatedContainer(duration: const Duration(milliseconds: 200),
            height: _confirm == null ? 0 : 46,
            color: cs.primary,
            child: _confirm == null ? null : Center(child: Text('✓  „$_confirm" hinzugefügt',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)))),
        ]),
      ),
    );
  }
}
