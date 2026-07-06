import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'state/app_state.dart';
import 'screens/now_screen.dart';
import 'screens/plan_screen.dart';
import 'screens/editor_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/help_wizard.dart';
import 'screens/notif_setup.dart';

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
    final seed = kSeeds[s.themeIndex.clamp(0, kSeeds.length - 1)];
    return MaterialApp(
      title: 'Tagesbegleiter',
      debugShowCheckedModeBanner: false,
      locale: const Locale('de'),
      supportedLocales: const [Locale('de')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.build(themeIndex: s.themeIndex, highContrast: s.highContrast, reduceMotion: s.reduceMotion),
      themeAnimationDuration: s.reduceMotion ? Duration.zero : kThemeAnimationDuration,
      builder: (context, child) {
        final deco = s.highContrast
            ? const BoxDecoration(color: Color(0xFF0F1413))
            : BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [seed.withOpacity(.22), const Color(0xFFEFF3F1), const Color(0xFFF4F7F5)],
                  stops: const [0.0, 0.40, 1.0],
                ),
              );
        return Container(
          decoration: deco,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(s.fontScale), disableAnimations: s.reduceMotion),
            child: child!,
          ),
        );
      },
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
  bool _onbHandled = false;
  @override
  Widget build(BuildContext context) {
    final st = context.watch<AppState>();
    if (st.loading) {
      return const Scaffold(backgroundColor: Colors.transparent, body: Center(child: CircularProgressIndicator()));
    }
    if (!_onbHandled && !st.settings.onboardingDone) {
      _onbHandled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        st.updateSettings((x) => x.onboardingDone = true);
        final nav = Navigator.of(context);
        // 1) kurze Einführung, danach 2) Erinnerungen einrichten
        await nav.push(MaterialPageRoute(builder: (_) => const HelpWizard()));
        await nav.push(MaterialPageRoute(builder: (_) => const NotifSetupScreen()));
      });
    }
    const screens = [NowScreen(), PlanScreen(), EditorScreen(), SettingsScreen()];
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: IndexedStack(index: st.navTab, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: st.navTab,
        onDestinationSelected: (i) { ScaffoldMessenger.of(context).clearSnackBars(); st.goTab(i); },
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
