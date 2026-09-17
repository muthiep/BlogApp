import 'package:shared_preferences/shared_preferences.dart';

class Session {
  static String? token;
  static int? idUser;
  static String? nameUser;
  static String? email;
  static bool rememberMe = false;

  static bool get isLoggedIn => token != null;

  static Future<void> save({
    required String token,
    required int idUser,
    required String nameUser,
    required String email,
    required bool rememberMe,
  }) async {
    Session.token = token;
    Session.idUser = idUser;
    Session.nameUser = nameUser;
    Session.email = email;
    Session.rememberMe = rememberMe;

    final prefs = await SharedPreferences.getInstance();

    if (rememberMe) {
      await prefs.setString('token', token);
      await prefs.setInt('idUser', idUser);
      await prefs.setString('nameUser', nameUser);
      await prefs.setString('email', email);
      await prefs.setBool('rememberMe', true);
      return;
    }

    await prefs.setBool('rememberMe', false);
    await prefs.remove('token');
    await prefs.remove('idUser');
    await prefs.remove('nameUser');
    await prefs.remove('email');
  }

  static Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('rememberMe') ?? false;

    if (!remember) {
      clear();
      return;
    }

    final savedToken = prefs.getString('token');
    final savedId = prefs.getInt('idUser');
    final savedName = prefs.getString('nameUser');
    final savedEmail = prefs.getString('email');

    if (savedToken != null &&
        savedId != null &&
        savedName != null &&
        savedEmail != null) {
      token = savedToken;
      idUser = savedId;
      nameUser = savedName;
      email = savedEmail;
      rememberMe = true;
    } else {
      clear();
    }
  }

  static Future<void> clear() async {
    token = null;
    idUser = null;
    nameUser = null;
    email = null;
    rememberMe = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('idUser');
    await prefs.remove('nameUser');
    await prefs.remove('email');
    await prefs.setBool('rememberMe', false);
  }
}
