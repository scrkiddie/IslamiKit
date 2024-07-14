import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:islami_kit/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String _firstname = "";
  String _lastname = "";
  String _username = "";
  String _email = "";
  String _password = "";
  final _formKey = GlobalKey<FormState>();
  bool _showFirstnameEmptyError = false;
  bool _showUsernameEmptyError = false;
  bool _showUsernameInvalidError = false;
  bool _showEmailEmptyError = false;
  bool _showPasswordEmptyError = false;
  bool _showEmailInvalidError = false;
  bool _showPasswordInvalidError = false;

  void _registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (_firstname.isNotEmpty &&
          _username.isNotEmpty &&
          _email.isNotEmpty &&
          _password.isNotEmpty &&
          !_showEmailInvalidError &&
          !_showUsernameInvalidError &&
          !_showPasswordInvalidError) {
        var url = Uri.parse('http://10.0.2.2:3000/api/users/register');
        var body = jsonEncode({
          'firstname': _firstname,
          'lastname': _lastname,
          'username': _username,
          'email': _email,
          'password': _password,
        });

        var response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration successful'),
              duration: Duration(seconds: 1),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else if (response.statusCode == 409) {
          Map<String, dynamic> errorBody = jsonDecode(response.body);
          String errorMessage = errorBody['error'];

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print("Registration failed");
      }
    }
  }

  bool _isValidEmail(String email) {
    String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regExp = RegExp(emailPattern);
    return regExp.hasMatch(email);
  }

  bool _isValidUsername(String username) {
    return username.length >= 6 && !username.contains(' ');
  }

  bool _isValidPassword(String password) {
    String passwordPattern =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$';
    RegExp regExp = RegExp(passwordPattern);
    return regExp.hasMatch(password) && !password.contains(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
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
                    'Create\nAccount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Enter your first name',
                        labelText: 'First Name',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        errorText: _showFirstnameEmptyError
                            ? 'First Name cannot be empty'
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _firstname = value;
                          if (value.isNotEmpty) {
                            _showFirstnameEmptyError = false;
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() {
                            _showFirstnameEmptyError = true;
                          });
                          return null;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Enter your last name (Optional) ',
                        labelText: 'Last Name (Optional)',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _lastname = value;
                        });
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Enter your username',
                        labelText: 'Username',
                        prefixIcon: const Icon(Icons.person_sharp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        errorText: _showUsernameEmptyError
                            ? 'Username cannot be empty'
                            : (_showUsernameInvalidError
                                ? 'Username must be at least 6 characters and contain no spaces'
                                : null),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _username = value;
                          _showUsernameEmptyError = false;
                          _showUsernameInvalidError = false;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() {
                            _showUsernameEmptyError = true;
                          });
                          return null;
                        } else if (!_isValidUsername(value)) {
                          setState(() {
                            _showUsernameInvalidError = true;
                          });
                          return null;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        errorText: _showEmailEmptyError
                            ? 'Email cannot be empty'
                            : (_showEmailInvalidError
                                ? 'Invalid email format'
                                : null),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        setState(() {
                          _showEmailInvalidError = false;
                          _showEmailEmptyError = false;
                          _email = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() {
                            _showEmailEmptyError = true;
                          });
                          return null;
                        } else if (!_isValidEmail(value)) {
                          setState(() {
                            _showEmailInvalidError = true;
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
                            : (_showPasswordInvalidError
                                ? 'Password must be at least 8 characters long, contain uppercase,\nlowercase, number, and symbol, and have no spaces'
                                : null),
                      ),
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          _password = value;
                          _showPasswordEmptyError = false;
                          _showPasswordInvalidError = false;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() {
                            _showPasswordEmptyError = true;
                          });
                          return null;
                        } else if (!_isValidPassword(value)) {
                          setState(() {
                            _showPasswordInvalidError = true;
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
                          _registerUser();
                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 53, 88, 231),
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
                        Text("Already have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.all(3),
                          ),
                          child: const Text(
                            'Login      ',
                            style: TextStyle(color: Color.fromARGB(255, 53, 88, 231)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
