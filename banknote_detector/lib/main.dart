import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/detection_screen.dart';
import 'screens/history_screen.dart';
import 'screens/statistics_screen.dart';
import 'services/api_service.dart';
import 'services/history_service.dart';

void main() {
  runApp(const BanknoteDetectorApp());
}

class BanknoteDetectorApp extends StatelessWidget {
  const BanknoteDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiService()),
        ChangeNotifierProvider(create: (_) => HistoryService()),
      ],
      child: MaterialApp(
        title: 'Banknote AI',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue.shade900,
            primary: Colors.blue.shade700,
            surface: Colors.grey.shade50,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey.shade50,
            foregroundColor: Colors.blue.shade900,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20,
              color: Colors.blue.shade900,
              letterSpacing: 1,
            ),
          ),
        ),
        home: const MainNavigationContainer(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainNavigationContainer extends StatefulWidget {
  const MainNavigationContainer({super.key});

  @override
  State<MainNavigationContainer> createState() => _MainNavigationContainerState();
}

class _MainNavigationContainerState extends State<MainNavigationContainer> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    DetectionScreen(),
    HistoryScreen(),
    StatisticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          elevation: 0,
          backgroundColor: Colors.white,
          indicatorColor: Colors.blue.shade50,
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: Colors.blue),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.camera_outlined),
              selectedIcon: Icon(Icons.camera_rounded, color: Colors.blue),
              label: 'Détecter',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history_rounded, color: Colors.blue),
              label: 'Historique',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded, color: Colors.blue),
              label: 'Stats',
            ),
          ],
        ),
      ),
    );
  }
}
