import 'package:flutter/material.dart';
import 'package:islami_kit/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islami_kit/home_page.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  runApp(MyApp(initialRoute: token != null ? '/home' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Daknet App',
      theme: ThemeData(
        fontFamily: 'poppins',
      ),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => HomePage(), 
      },
    );
  }
}
