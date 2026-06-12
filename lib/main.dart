import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'state/app_state.dart';
import 'screens/now_screen.dart';
import 'screens/plan_screen.dart';
import 'screens/editor_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
    create: (_) => AppState()..init(),
    child: const TagesbegleiterApp(),
  ));
}

class TagesbegleiterApp extends StatelessWidget {
  const TagesbegleiterApp({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>().settings;
    return MaterialApp(
      title: 'Tagesbegleiter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(themeIndex: s.themeIndex, highContrast: s.highContrast),
      // Schriftgröße sicher über den TextScaler (verursacht keinen Theme-Crash).
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(s.fontScale)),
        child: child!,
      ),
      home: const RootScaffold(),
    );
  }
}

class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key});
  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    if (st.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    const screens = [NowScreen(), PlanScreen(), EditorScreen(), SettingsScreen()];
    return Scaffold(
      body: IndexedStack(index: _tab, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.schedule_rounded), label: 'Jetzt'),
          NavigationDestination(icon: Icon(Icons.view_agenda_outlined), label: 'Tagesplan'),
          NavigationDestination(icon: Icon(Icons.edit_calendar_outlined), label: 'Bearbeiten'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Einstellungen'),
        ],
      ),
    );
  }
}
