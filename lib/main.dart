// ============================================================
//  main.dart — Entry point | Dark Vault Theme
// ============================================================

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'core/providers.dart';
import 'screens/home/home_screen.dart';
import 'screens/stats/stats_screen.dart';
import 'screens/budget/budget_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/add_edit/add_edit_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(kExpenseBox);
  await Hive.openBox(kCategoryBox);
  await Hive.openBox(kBudgetBox);
  await Hive.openBox(kSettingsBox);

  final settings   = SettingsProvider();
  final categories = CategoryProvider();
  final expenses   = ExpenseProvider();
  final budgets    = BudgetProvider();

  await settings.init();
  await categories.init();
  await expenses.init();
  await budgets.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: categories),
        ChangeNotifierProvider.value(value: expenses),
        ChangeNotifierProvider.value(value: budgets),
      ],
      child: const EzzeExpenseApp(),
    ),
  );
}

class EzzeExpenseApp extends StatelessWidget {
  const EzzeExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final t = EzzeTheme.of(context);
    final settings = context.watch<SettingsProvider>();
    // Always dark — theme handles light/dark variants
    return MaterialApp(
      title:                  kAppName,
      debugShowCheckedModeBanner: false,
      theme:     buildTheme(false),
      darkTheme: buildTheme(true),
      themeMode: settings.isDark ? ThemeMode.dark : ThemeMode.light,
      home:      const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    StatsScreen(),
    BudgetScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final t = EzzeTheme.of(context);
    return Scaffold(
      backgroundColor: t.bgBase,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color:  t.bgBase,
          border: Border(top: BorderSide(color: t.border, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex:         _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor:       Colors.transparent,
          surfaceTintColor:      Colors.transparent,
          shadowColor:           Colors.transparent,
          destinations: const [
            NavigationDestination(
              icon:         Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label:        'Home',
            ),
            NavigationDestination(
              icon:         Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded),
              label:        'Stats',
            ),
            NavigationDestination(
              icon:         Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet_rounded),
              label:        'Budget',
            ),
            NavigationDestination(
              icon:         Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label:        'Settings',
            ),
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AddEditExpenseScreen()),
              ),
              backgroundColor: kAccent,
              foregroundColor: t.bgDeep,
              elevation:       12,
              tooltip: 'Add Expense',
              child: const Icon(Icons.add_rounded, size: 26),
            )
          : null,
    );
  }
}
