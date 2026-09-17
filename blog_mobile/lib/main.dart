import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Auth/theme.dart';
import 'Auth/session.dart';
import 'pages/home_page.dart';
import 'pages/login.dart';
import 'pages/register.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Session.loadFromStorage();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blog App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.poppins().fontFamily,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      initialRoute: Session.isLoggedIn ? '/home' : '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
