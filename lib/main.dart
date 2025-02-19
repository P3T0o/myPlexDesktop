import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'services/auth_service.dart';

void main() async  {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.loadToken();  // Charge le token sauvegardé
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isAuthenticated = AuthService.isAuthenticated();
  bool _showRegisterScreen = false;

  void _loginSuccess() {
    setState(() => _isAuthenticated = true);
  }

  void _logout() {
    AuthService.logout();
    setState(() => _isAuthenticated = false);
  }

  void _toggleRegister() {
    setState(() => _showRegisterScreen = !_showRegisterScreen);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyPlex',
      theme: ThemeData.light().copyWith( // Theme Light
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red), // Titres
          bodyMedium: TextStyle(fontSize: 16, color: Color(0xFFE0E0E0)), // Texte normal
          labelLarge: TextStyle(fontSize: 14, color: Colors.green), // Boutons
        ),
      ),
      darkTheme: ThemeData.dark().copyWith( // Theme Dark
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFFE0E0E0)), // Texte blanc en mode sombre
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red), // Titres
          labelLarge: TextStyle(fontSize: 14, color: Colors.green), // Boutons
        ),
      ),
      themeMode: ThemeMode.system, // Change automatiquement selon le système
      home: _isAuthenticated
          ? MainScreen(onLogout: _logout)
          : _showRegisterScreen
          ? RegisterScreen(onRegisterSuccess: _toggleRegister)
          : LoginScreen(onLoginSuccess: _loginSuccess, onRegister: _toggleRegister),
    );
  }
}
