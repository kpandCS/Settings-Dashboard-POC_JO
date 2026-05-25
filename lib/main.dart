import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'view/screens/dashboard_screen.dart';
import 'view/screens/settings_screen.dart';
import 'viewmodel/dashboard_viewmodel.dart';
import 'viewmodel/settings_viewmodel.dart';

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
      ],
      child: MaterialApp(
        title: 'PocketLink POC',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
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

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _screens = <Widget>[
    DashboardScreen(),
    SettingsScreen(),
  ];

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
