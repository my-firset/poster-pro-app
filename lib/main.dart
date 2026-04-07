import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/account_manager_screen.dart';
import 'screens/campaign_screen.dart';
import 'screens/posting_dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/account_provider.dart';
import 'providers/campaign_provider.dart';
import 'providers/posting_provider.dart';

void main() {
  runApp(const PosterProApp());
}

class PosterProApp extends StatelessWidget {
  const PosterProApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => CampaignProvider()),
        ChangeNotifierProvider(create: (_) => PostingProvider()),
      ],
      child: MaterialApp(
        title: 'Poster Pro - ناشر برو',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF1877F2), // Facebook Blue
          scaffoldBackgroundColor: const Color(0xFF0a0a0a),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1a1a1a),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF1a1a1a),
            selectedItemColor: Color(0xFF1877F2),
            unselectedItemColor: Colors.grey,
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white70),
            labelLarge: TextStyle(color: Colors.white),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF1a1a1a),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF333333)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF333333)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1877F2)),
            ),
            hintStyle: const TextStyle(color: Colors.grey),
            labelStyle: const TextStyle(color: Colors.white70),
          ),
        ),
        home: const MainApp(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AccountManagerScreen(),
    const CampaignScreen(),
    const PostingDashboardScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'الحسابات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'حملة جديدة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'النشر المباشر',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}
