import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'view/screens/dashboard_screen.dart';
import 'view/screens/settings_screen.dart';
import 'viewmodel/dashboard_viewmodel.dart';
import 'viewmodel/settings_viewmodel.dart';
import 'viewmodel/time_registration_viewmodel.dart';

/// Lets code below the MaterialApp (e.g. reacting to Siri-logged time
/// entries on resume) show a SnackBar without needing a nested Scaffold.
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PocketLinkSettingsPOC());
}

class PocketLinkSettingsPOC extends StatelessWidget {
  const PocketLinkSettingsPOC({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProxyProvider<DashboardViewModel, TimeRegistrationViewModel>(
          create: (context) => TimeRegistrationViewModel(context.read<DashboardViewModel>()),
          update: (context, dashboardViewModel, previous) =>
              previous ?? TimeRegistrationViewModel(dashboardViewModel),
        ),
      ],
      child: MaterialApp(
        title: 'PocketLink POC',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        home: const AppShell(),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  int _index = 0;

  static const _screens = <Widget>[
    DashboardScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Pick up anything Siri logged while the app wasn't running.
    WidgetsBinding.instance.addPostFrameCallback((_) => _consumePendingSiriEntries());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _consumePendingSiriEntries();
    }
  }

  Future<void> _consumePendingSiriEntries() async {
    final applied =
        await context.read<TimeRegistrationViewModel>().consumePendingSiriEntries();
    if (applied.isEmpty) return;
    final totalHours = applied.fold<double>(0, (sum, e) => sum + e.hours);
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          'Siri logged ${applied.length} ${applied.length == 1 ? 'entry' : 'entries'} '
          '(${totalHours.toStringAsFixed(1)}h) while you were away',
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: Icon(PhosphorIcons.house(PhosphorIconsStyle.regular)),
            selectedIcon: Icon(PhosphorIcons.house(PhosphorIconsStyle.fill)),
            label: 'My Day',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIcons.gear(PhosphorIconsStyle.regular)),
            selectedIcon: Icon(PhosphorIcons.gear(PhosphorIconsStyle.fill)),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
