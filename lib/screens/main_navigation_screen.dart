import 'package:flutter/material.dart';
import '../services/printer_service.dart';
import '../services/settings_service.dart';
import 'home_screen.dart';
import 'printer_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final PrinterService _printerService = PrinterService();
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _printerService.checkStatus();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        printerService: _printerService,
        settingsService: _settingsService,
        onOpenPrinterTab: () => setState(() => _currentIndex = 1),
      ),
      PrinterScreen(
        printerService: _printerService,
      ),
      SettingsScreen(
        settingsService: _settingsService,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Home / Printer',
          ),
          NavigationDestination(
            icon: Icon(Icons.print_outlined),
            selectedIcon: Icon(Icons.print_rounded),
            label: 'Printer',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
