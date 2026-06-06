import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/detection_screen.dart';
import 'screens/history_screen.dart';
import 'screens/statistics_screen.dart';
import 'services/api_service.dart';
import 'services/history_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF08101B),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
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
        title: 'Banknote AI Pro',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          fontFamily: 'Inter',
          scaffoldBackgroundColor: const Color(0xFF07101F),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4F46E5),
            brightness: Brightness.dark,
            primary: const Color(0xFF4F46E5),
            secondary: const Color(0xFF22C55E),
            surface: const Color(0xFF0F172A),
            background: const Color(0xFF07101F),
            onSurface: Colors.white,
            onBackground: Colors.white,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

  void _navigateToDetection() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeScreen(onStartPressed: _navigateToDetection),
      const DetectionScreen(),
      const HistoryScreen(),
      const StatisticsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0B192E),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: NavigationBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              indicatorColor: const Color(0xFF4F46E5).withOpacity(0.24),
              labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
              selectedIndex: _selectedIndex,
              height: 65,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, size: 24),
                  selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF4F46E5)),
                  label: 'Accueil',
                ),
                NavigationDestination(
                  icon: Icon(Icons.camera_outlined, size: 24),
                  selectedIcon: Icon(Icons.camera_rounded, color: Color(0xFF4F46E5)),
                  label: 'Scanner',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history_outlined, size: 24),
                  selectedIcon: Icon(Icons.history_rounded, color: Color(0xFF4F46E5)),
                  label: 'Historique',
                ),
                NavigationDestination(
                  icon: Icon(Icons.analytics_outlined, size: 24),
                  selectedIcon: Icon(Icons.analytics_rounded, color: Color(0xFF4F46E5)),
                  label: 'Stats',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
