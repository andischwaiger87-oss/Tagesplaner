// Zeit-Formatierung: nie mehr als 60 Minuten am Stück anzeigen.
String fmtDuration(int m) {
  if (m < 60) return '$m Min';
  final h = m ~/ 60, r = m % 60;
  return r == 0 ? '$h Std' : '$h Std $r Min';
}

String fmtUntil(int m) {
  if (m <= 0) return 'jetzt';
  return 'In ${fmtDuration(m)}';
}
