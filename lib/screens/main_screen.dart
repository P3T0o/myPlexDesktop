import 'dart:async';
import 'package:flutter/material.dart';
import '../app_colors.dart';
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight), // Définit la hauteur de l'AppBar
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary, // Couleur de fond de l'AppBar
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.secondary, // Couleur de la bordure inférieure
                width: 2.0, // Épaisseur de la bordure
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent, // Transparent pour voir la couleur du Container
            elevation: 0, // Supprime l'ombre
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.accent,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 23),
                        child: Text(
                          "Bonjour, Quentin",
                          style: TextStyle(
                            fontSize: 16,
                          ),
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
        ),
      ),

      body: Row(
        children: [
          // Navigation Rail (Sidebar) avec une bordure à droite
          Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(
                  color: AppColors.secondary, // Couleur de la bordure
                  width: 2, // Épaisseur de la bordure
                ),
              ),
            ),
            child: NavigationRail(
              backgroundColor: AppColors.primary,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              groupAlignment: -0.8,

              // 🔹 Couleurs des icônes
              selectedIconTheme: IconThemeData(
                color: AppColors.accent,
                size: 26,
              ),
              unselectedIconTheme: IconThemeData(
                color: AppColors.textSideBar,
                size: 24,
              ),

              // 🔹 Couleurs du texte
              selectedLabelTextStyle: const TextStyle(
                color: AppColors.accent,
              ),
              unselectedLabelTextStyle: TextStyle(
                color: AppColors.textSideBar,
              ),

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
          ),

          // Contenu principal avec une bordure à gauche
          Expanded(
            child: Container(
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }
}