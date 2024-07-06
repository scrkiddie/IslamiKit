import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islami_kit/register.dart';
import 'package:islami_kit/home_page.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _username = "";
  String _password = "";
  final _formKey = GlobalKey<FormState>();
  bool _showUsernameEmptyError = false;
  bool _showPasswordEmptyError = false;
  bool _showUsernameWrongError = false;
  bool _showPasswordWrongError = false;

  void _authenticateUser() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/users/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': _username,
          'password': _password,
        }),
      );

      if (response.statusCode == 200) {

        final jsonResponse = jsonDecode(response.body);
        String token = jsonResponse['token'];
        await _saveToken(token);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        setState(() {
          _showUsernameWrongError = true;
          _showPasswordWrongError = true;
        });
      }
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                'assets/banner.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 60,
                left: 20,
                child: Text(
                  'Welcome\nBack',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Enter your username',
                            labelText: 'Username',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            ),
                            errorText: _showUsernameEmptyError
                                ? 'Username cannot be empty'
                                : _showUsernameWrongError
                                    ? 'Username or password is wrong'
                                    : null,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(height: 1.5),
                          onChanged: (value) {
                            setState(() {
                              _username = value;
                              _showUsernameWrongError = false;
                              if (value.isNotEmpty) {
                                _showUsernameEmptyError = false;
                              }
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              setState(() {
                                _showUsernameEmptyError = true;
                              });
                              return null;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.0),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            ),
                            errorText: _showPasswordEmptyError
                                ? 'Password cannot be empty'
                                : _showPasswordWrongError
                                    ? 'Password or username is wrong'
                                    : null,
                          ),
                          obscureText: true,
                          style: TextStyle(height: 1.5),
                          onChanged: (value) {
                            setState(() {
                              _password = value;
                              _showPasswordWrongError = false;
                              if (value.isNotEmpty) {
                                _showPasswordEmptyError = false;
                              }
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              setState(() {
                                _showPasswordEmptyError = true;
                              });
                              return null;
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () {
                              _authenticateUser();
                            },
                            child: const Text(
                              'Log In',
                              style: TextStyle(color: Colors.white, fontSize: 16.0),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 53, 88, 231),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't have an account?"),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => RegisterPage()),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.all(3),
                              ),
                              child: const Text(
                                'Register',
                                style: TextStyle(color: Color.fromARGB(255, 53, 88, 231)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
