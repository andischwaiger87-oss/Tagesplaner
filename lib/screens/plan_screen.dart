import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/activity_icon.dart';
import '../util/format.dart';

const _wdShort = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
const _wdLong = ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag', 'Sonntag'];
const _monNames = ['Jänner', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'];
String _hhmm(int m) => '${m ~/ 60}:${(m % 60).toString().padLeft(2, '0')}';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});
  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  int _view = 0; // 0 Tag, 1 Woche, 2 Monat
  int _day = DateTime.now().weekday;
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    final ink = cs.onSurface;
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Mein Plan', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: ink)),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Tag'), icon: Icon(Icons.today_rounded)),
                ButtonSegment(value: 1, label: Text('Woche'), icon: Icon(Icons.view_week_rounded)),
                ButtonSegment(value: 2, label: Text('Monat'), icon: Icon(Icons.calendar_month_rounded)),
              ],
              selected: {_view},
              onSelectionChanged: (s) => setState(() => _view = s.first),
            ),
          ])),
        Expanded(child: _view == 0 ? _tag(st, cs) : _view == 1 ? _woche(st, cs) : _monat(st, cs)),
      ]),
    );
  }

  // -------- TAG --------
  Widget _tag(AppState st, ColorScheme cs) {
    final list = st.dayPlan(_day);
    final isToday = _day == DateTime.now().weekday;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 6, 20, 20), children: [
      SizedBox(height: 40, child: ListView(scrollDirection: Axis.horizontal, children: [
        for (int d = 1; d <= 7; d++) Padding(padding: const EdgeInsets.only(right: 6),
          child: ChoiceChip(label: Text(_wdShort[d - 1]), selected: _day == d,
            onSelected: (_) => setState(() => _day = d))),
      ])),
      const SizedBox(height: 8),
      if (list.isEmpty) Padding(padding: const EdgeInsets.all(24),
        child: Center(child: Text('Für ${_wdLong[_day - 1]} ist noch nichts geplant.',
            style: TextStyle(color: cs.onSurface.withOpacity(.5))))),
      for (int i = 0; i < list.length; i++)
        _planRow(cs, list[i], highlight: isToday && i == st.currentIndex),
      const SizedBox(height: 8),
      Center(child: TextButton.icon(
        onPressed: () { st.setEditingDay(_day); st.goTab(2); },
        icon: const Icon(Icons.edit_rounded, size: 18), label: Text('${_wdLong[_day - 1]} bearbeiten'))),
    ]);
  }

  Widget _planRow(ColorScheme cs, Activity a, {bool highlight = false}) => Container(
    margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(20),
      border: highlight ? Border.all(color: kAccent, width: 3) : null,
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 12)]),
    child: Row(children: [
      IconTile(activity: a, tileSize: 52, iconSize: 34, radius: 14),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(a.label, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface)),
        Text('${a.timeLabel} Uhr · ${fmtDuration(a.durationMin)}',
            style: TextStyle(fontSize: 12.5, color: cs.onSurface.withOpacity(.55))),
      ])),
      if (highlight) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(999)),
        child: const Text('JETZT', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800))),
    ]),
  );

  // -------- WOCHE --------
  Widget _woche(AppState st, ColorScheme cs) {
    final todayWd = DateTime.now().weekday;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 6, 20, 20), children: [
      for (int d = 1; d <= 7; d++) _dayCard(st, cs, d, d == todayWd),
    ]);
  }

  Widget _dayCard(AppState st, ColorScheme cs, int d, bool today) {
    final list = st.dayPlan(d);
    final range = list.isEmpty ? 'leer'
        : '${_hhmm(list.first.startMinutes)}–${_hhmm(list.last.startMinutes + list.last.durationMin)} Uhr';
    return InkWell(
      onTap: () { st.setEditingDay(d); st.goTab(2); },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(20),
          border: today ? Border.all(color: cs.primary, width: 2) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 12)]),
        child: Row(children: [
          Container(width: 48, height: 48, alignment: Alignment.center,
            decoration: BoxDecoration(color: AppTheme.tile(context), borderRadius: BorderRadius.circular(14)),
            child: Text(_wdShort[d - 1], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(_wdLong[d - 1], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface)),
              if (today) Padding(padding: const EdgeInsets.only(left: 8),
                child: Text('heute', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cs.primary))),
            ]),
            Text('${list.length} Schritte · $range', style: TextStyle(fontSize: 13, color: cs.onSurface.withOpacity(.55))),
          ])),
          Icon(Icons.chevron_right_rounded, color: cs.onSurface.withOpacity(.4)),
        ]),
      ),
    );
  }

  // -------- MONAT --------
  Widget _monat(AppState st, ColorScheme cs) {
    final first = DateTime(_month.year, _month.month, 1);
    final lead = first.weekday - 1; // Leerzellen vor dem 1.
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final now = DateTime.now();
    return ListView(padding: const EdgeInsets.fromLTRB(16, 6, 16, 20), children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        IconButton(onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1, 1)),
            icon: const Icon(Icons.chevron_left_rounded)),
        Text('${_monNames[_month.month - 1]} ${_month.year}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface)),
        IconButton(onPressed: () => setState(() => _month = DateTime(_month.year, _month.month + 1, 1)),
            icon: const Icon(Icons.chevron_right_rounded)),
      ]),
      const SizedBox(height: 6),
      Row(children: [for (final w in _wdShort) Expanded(child: Center(
        child: Text(w, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cs.onSurface.withOpacity(.5)))))]),
      const SizedBox(height: 6),
      GridView.count(crossAxisCount: 7, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 6, crossAxisSpacing: 6, children: [
          for (int i = 0; i < lead; i++) const SizedBox(),
          for (int day = 1; day <= days; day++) _monthCell(st, cs, day, now),
        ]),
      const SizedBox(height: 12),
      Text('Tippe einen Tag an, um seinen Plan zu sehen.',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: cs.onSurface.withOpacity(.5))),
    ]);
  }

  Widget _monthCell(AppState st, ColorScheme cs, int day, DateTime now) {
    final date = DateTime(_month.year, _month.month, day);
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final count = st.dayPlan(date.weekday).length;
    return InkWell(
      onTap: () => _showDay(st, cs, date),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isToday ? cs.primary : cs.surface, borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 6)]),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('$day', style: TextStyle(fontWeight: FontWeight.w700,
              color: isToday ? Colors.white : cs.onSurface)),
          if (count > 0) Container(margin: const EdgeInsets.only(top: 3), width: 6, height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: isToday ? Colors.white : kAccent)),
        ]),
      ),
    );
  }

  void _showDay(AppState st, ColorScheme cs, DateTime date) {
    final list = st.dayPlan(date.weekday);
    showModalBottomSheet(context: context, backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${_wdLong[date.weekday - 1]}, ${date.day}.${date.month}.${date.year}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface)),
          const SizedBox(height: 10),
          if (list.isEmpty) Text('Noch nichts geplant.', style: TextStyle(color: cs.onSurface.withOpacity(.6)))
          else ConstrainedBox(constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .5),
            child: ListView(shrinkWrap: true, children: [
              for (final a in list) Padding(padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(children: [
                  IconTile(activity: a, tileSize: 40, iconSize: 26, radius: 11),
                  const SizedBox(width: 12),
                  Expanded(child: Text(a.label, style: TextStyle(fontWeight: FontWeight.w600, color: cs.onSurface))),
                  Text('${a.timeLabel} · ${fmtDuration(a.durationMin)}',
                      style: TextStyle(fontSize: 12, color: cs.onSurface.withOpacity(.55))),
                ])),
            ])),
          const SizedBox(height: 14),
          SizedBox(width: double.infinity, child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: kAccent, foregroundColor: Colors.white),
            onPressed: () { Navigator.pop(context); st.setEditingDay(date.weekday); st.goTab(2); },
            icon: const Icon(Icons.edit_rounded), label: Text('${_wdLong[date.weekday - 1]} bearbeiten'))),
        ]))));
  }
}
