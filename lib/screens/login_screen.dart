import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  final VoidCallback onRegister;

  const LoginScreen({super.key, required this.onLoginSuccess, required this.onRegister});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  void _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    bool success = await AuthService.login(email, password);
    if (success) {
      widget.onLoginSuccess();
    } else {
      setState(() => _errorMessage = "Email ou mot de passe incorrect.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: Padding(
        padding: const EdgeInsets.all(200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Mot de passe"),
              obscureText: true,
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
            ),
            ElevatedButton(
              onPressed: _login,
              child: const Text("Se connecter"),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
            ),
            TextButton(
              onPressed: widget.onRegister,
              child: const Text("Pas encore de compte ? Inscrivez-vous"),
            ),
          ],
        ),
      ),
    );
  }
}