import 'dart:async';
import 'package:flutter/material.dart';
import '../home_page.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/auth_service.dart';

class MainScreen extends StatefulWidget {
  final VoidCallback onLogout; // Callback pour la déconnexion

  const MainScreen({super.key, required this.onLogout});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Liste des pages associées aux boutons de la sidebar
  final List<Widget> _pages = [
    const HomePage(),
    const Center(child: Text('Rappels en cours de développement...')),
    const Center(child: Text('Actus en cours de développement...')),
    const Center(child: Text('Paramètres en cours de développement...')),
  ];

  String _currentTime = '';
  String _currentDate = '';

  @override
  void initState() {
    super.initState();
    _initializeDate();
  }

  void _initializeDate() async {
    await initializeDateFormatting('fr_FR', null);
    _updateTime();
  }

  void _updateTime() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return; // Vérifie si le widget est toujours monté

      setState(() {
        _currentTime = DateFormat('HH:mm').format(DateTime.now());
        _currentDate = DateFormat('EEEE dd MMMM yyyy', 'fr_FR').format(DateTime.now());
      });
    });
  }

  void _logout() {
    AuthService.logout();
    widget.onLogout(); // Retourne à l'écran de connexion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.5), // Marge à gauche et à droite
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 23),
                    child: Text(
                      "Bonjour, Quentin",
                      style: TextStyle(fontSize: 16, color: const Color(0xFFE0E0E0)),
                    ),
                  ),
                ],
              ),
              const Text('MyPlex'),
              Column(
                children: [
                  Text(_currentTime, style: const TextStyle(fontSize: 16)),
                  Text(_currentDate, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout, // Déconnexion
          ),
        ],
      ),

      body: Row(
        children: [
          // Navigation Rail (Sidebar)
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            groupAlignment: -0.8,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Accueil'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.schedule_outlined),
                selectedIcon: Icon(Icons.schedule),
                label: Text('Rappels'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.newspaper_outlined),
                selectedIcon: Icon(Icons.newspaper),
                label: Text('Actus'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Paramètres'),
              ),
            ],
          ),

          // Contenu principal
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}