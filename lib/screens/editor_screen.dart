import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../data/default_data.dart';
import '../theme/app_theme.dart';
import '../widgets/activity_icon.dart';

void _snack(BuildContext c, String m, {SnackBarAction? action}) {
  ScaffoldMessenger.of(c)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1600), action: action));
}

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    final ink = cs.onSurface;
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Tag zusammenstellen', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: ink)),
            const SizedBox(height: 12),
            Row(children: [
              Icon(Icons.schedule_rounded, size: 20, color: ink.withOpacity(.7)),
              const SizedBox(width: 8),
              Text('Start:', style: TextStyle(color: ink.withOpacity(.7), fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              ActionChip(
                label: Text(st.plan.isEmpty ? '–' : '${st.plan.first.timeLabel} Uhr'),
                onPressed: () async {
                  final t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 7, minute: 0));
                  if (t != null) { st.setDayStart(t.hour * 60 + t.minute); _snack(context, 'Startzeit gespeichert'); }
                },
              ),
              const Spacer(),
              Text('${st.plan.length} Schritte', style: TextStyle(color: ink.withOpacity(.5), fontSize: 13)),
            ]),
            const SizedBox(height: 12),
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
            Text('Am  ⠿  ziehen zum Sortieren · mit − / + die Dauer ändern',
                style: TextStyle(fontSize: 12.5, color: ink.withOpacity(.55))),
            const SizedBox(height: 8),
          ]),
        ),
        Expanded(
          child: st.plan.isEmpty
              ? Center(child: Text('Noch keine Schritte.\nTippe „Baustein hinzufügen".',
                  textAlign: TextAlign.center, style: TextStyle(color: ink.withOpacity(.5))))
              : ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  buildDefaultDragHandles: false,
                  itemCount: st.plan.length,
                  onReorder: (o, n) { st.reorder(o, n); _snack(context, 'Reihenfolge geändert'); },
                  itemBuilder: (c, i) => _EditRow(key: ValueKey(st.plan[i].id), st: st, index: i),
                ),
        ),
      ]),
    );
  }

  void _showAddSheet(BuildContext context, AppState st) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _AddSheet(st: st),
    );
  }
}

class _EditRow extends StatelessWidget {
  final AppState st; final int index;
  const _EditRow({super.key, required this.st, required this.index});

  Future<void> _pick(BuildContext c, bool icon) async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: icon ? ['svg'] : ['mp3', 'wav', 'm4a']);
    final p = res?.files.single.path;
    if (p == null) return;
    icon ? st.setIcon(index, p) : st.setAudio(index, p);
    _snack(c, icon ? 'Icon zugewiesen' : 'Sprachdatei zugewiesen');
  }

  void _delete(BuildContext c) {
    final removed = st.plan[index].copy();
    final at = index;
    st.removeAt(index);
    _snack(c, '„${removed.label}" entfernt',
      action: SnackBarAction(label: 'Rückgängig', onPressed: () => st.insertActivity(at, removed)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ink = cs.onSurface;
    final a = st.plan[index];
    final isCustom = a.key == null;
    return Container(
      key: ValueKey('row_${a.id}'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10)]),
      child: Column(children: [
        Row(children: [
          ReorderableDragStartListener(index: index,
            child: Padding(padding: const EdgeInsets.only(right: 2),
              child: Icon(Icons.drag_indicator_rounded, size: 22, color: ink.withOpacity(.35)))),
          IconTile(activity: a, tileSize: 46, iconSize: 30, radius: 13),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a.label, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: ink)),
            Text('${a.timeLabel} Uhr', style: TextStyle(color: ink.withOpacity(.55), fontSize: 12)),
          ])),
          // Dauer-Regler mit klarer Beschriftung
          Container(
            decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(14)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _mini(context, Icons.remove_rounded, () => st.changeDuration(index, -5)),
              SizedBox(width: 50, child: Text('${a.durationMin} Min', textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: ink))),
              _mini(context, Icons.add_rounded, () => st.changeDuration(index, 5)),
            ]),
          ),
          const SizedBox(width: 6),
          InkWell(onTap: () => _delete(context), borderRadius: BorderRadius.circular(12),
            child: Container(width: 38, height: 38,
              decoration: BoxDecoration(color: const Color(0x22EC6A53), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.delete_outline_rounded, size: 20, color: kAccent))),
        ]),
        if (isCustom) Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () => _pick(context, true),
              icon: const Icon(Icons.image_outlined, size: 18),
              label: Text(a.iconPath != null ? 'Icon ✓' : 'Eigenes Icon'))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(onPressed: () => _pick(context, false),
              icon: const Icon(Icons.graphic_eq_rounded, size: 18),
              label: Text(a.audioPath != null ? 'Audio ✓' : 'Eigene Stimme'))),
          ]),
        ),
      ]),
    );
  }

  Widget _mini(BuildContext c, IconData ic, VoidCallback on) => InkWell(
    onTap: on, borderRadius: BorderRadius.circular(12),
    child: SizedBox(width: 34, height: 38, child: Icon(ic, size: 20, color: Theme.of(c).colorScheme.onSurface)));
}

// ---------------- Hinzufügen-Sheet mit Suche ----------------
class _AddSheet extends StatefulWidget {
  final AppState st;
  const _AddSheet({required this.st});
  @override
  State<_AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<_AddSheet> {
  String _query = '';
  String? _cat;

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
    widget.st.addFromTemplate(m);
    _snack(context, '„${m.label}" hinzugefügt');
  }

  Future<void> _custom() async {
    final nameC = TextEditingController();
    final textC = TextEditingController();
    await showDialog(context: context, builder: (c) => AlertDialog(
      title: const Text('Eigener Eintrag'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameC, autofocus: true,
          decoration: const InputDecoration(labelText: 'Name', hintText: 'z. B. Hund füttern')),
        const SizedBox(height: 12),
        TextField(controller: textC, decoration: const InputDecoration(labelText: 'Gesprochener Text (optional)')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Abbrechen')),
        FilledButton(onPressed: () {
          final ok = nameC.text.trim().isNotEmpty;
          if (ok) widget.st.addCustom(nameC.text, spoken: textC.text);
          Navigator.pop(c);
          if (ok) _snack(context, 'Eintrag hinzugefügt');
        }, child: const Text('Hinzufügen')),
      ],
    ));
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
          Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(children: [
              Expanded(child: Text('Baustein wählen',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: cs.onSurface))),
              TextButton.icon(onPressed: _custom, icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text('Eigener')),
            ])),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Suchen … (z. B. Frühstück)', prefixIcon: const Icon(Icons.search_rounded),
                filled: true, fillColor: cs.surfaceContainerHighest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 4)),
            )),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.86),
            itemCount: items.length,
            itemBuilder: (c, i) {
              final m = items[i];
              return InkWell(onTap: () => _add(m), borderRadius: BorderRadius.circular(18),
                child: Container(
                  decoration: BoxDecoration(color: AppTheme.tile(context), borderRadius: BorderRadius.circular(18)),
                  padding: const EdgeInsets.all(8),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Expanded(child: Center(child: ActivityIcon(activity: m, size: 46))),
                    const SizedBox(height: 4),
                    Text(m.label, maxLines: 2, textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, height: 1.05)),
                  ]),
                ));
            },
          )),
        ]),
      ),
    );
  }
}
