import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static String? _token; // Stocke uniquement le token JWT

  static const String _baseUrl = 'http://127.0.0.1:3333/api';

  static bool isAuthenticated() => _token != null;

  // Connexion utilisateur
  static Future<bool> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['token'] != null && data['token']['token'] != null) {
          _token = data['token']['token'];
          await _saveToken(_token!);

          // 🔥 Appeler `/api/auth/me` immédiatement après connexion
          Map<String, dynamic>? userData = await fetchUserData(_token!);
          if (userData != null) {
            await saveUserData(userData); // Stocke les infos utilisateur
            return true;
          }
        } else {
          print('Réponse inattendue: ${response.body}');
        }
      } else {
        print('Erreur lors de la connexion: ${response.body}');
      }
    } catch (e) {
      print('Erreur réseau: $e');
    }
    return false;
  }


  // Inscription utilisateur
  static Future<bool> register(String name, String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        // Vérifie si le token est présent et extrait la valeur correcte
        if (data['token'] != null && data['token']['token'] != null) {
          _token = data['token']['token']; // Extraire et stocker uniquement le token
          await _saveToken(_token!); // Sauvegarde le token localement
          return true;
        } else {
          print('Réponse inattendue: ${response.body}');
          return false;
        }
      } else {
        print('Erreur lors de l\'inscription: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erreur réseau: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> fetchUserData(String token) async {
    final response = await http.get(
      Uri.parse("$_baseUrl/auth/me"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveUserData(data); // Stocke l'utilisateur en cache
      return data;
    } else {
      return null;
    }
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user_data');
    if (userData != null) {
      return jsonDecode(userData);
    }
    return null;
  }

  // Sauvegarde du token
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Récupération du token
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');

    if (_token != null) {
      // 🔥 Récupérer les infos utilisateur si elles ne sont pas en cache
      Map<String, dynamic>? userData = await getUserData();
      if (userData == null) {
        await fetchUserData(_token!);
      }
    }
  }


  // Déconnexion utilisateur
  static Future<void> logout() async {
    final url = Uri.parse('$_baseUrl/auth/logout');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        _token = null;
        await _removeToken(); // Supprime le token localement
        print('Déconnexion réussie');
      } else {
        print('Erreur lors de la déconnexion: ${response.body}');
      }
    } catch (e) {
      print('Erreur réseau: $e');
    }
  }

  // Suppression du token
  static Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token'); // Supprime le token
    await prefs.remove('user_data'); // Supprime les infos utilisateur
  }
}