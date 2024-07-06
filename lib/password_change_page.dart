import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  String _currentPassword = "";
  String _newPassword = "";
  String _confirmPassword = "";
  final _formKey = GlobalKey<FormState>();
  bool _showCurrentPasswordError = false;
  bool _showNewPasswordError = false;
  bool _showConfirmPasswordError = false;
  bool _showConfirmPasswordErrorEmpty = false;
  bool _showNewPasswordInvalidError = false;
  bool _showCurrentPasswordInvalidError = false;

  String? _token;

  @override
  void initState() {
    super.initState();
    _getTokenFromSharedPreferences();
  }

  Future<void> _getTokenFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
    });
  }

  void _changePassword() async {
    if (_formKey.currentState!.validate()) {
      if (_newPassword != _confirmPassword) {
        setState(() {
          _showConfirmPasswordError = true;
        });
        return;
      }

      if (!_showCurrentPasswordError &&
          !_showNewPasswordError &&
          !_showConfirmPasswordErrorEmpty &&
          !_showConfirmPasswordError) {
        var url = Uri.parse('http://10.0.2.2:3000/api/users/current/password');
        var body = jsonEncode({
          'currentPassword': _currentPassword,
          'newPassword': _newPassword,
          'confirmPassword': _confirmPassword,
        });

        var response = await http.patch(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': '$_token',
          },
          body: body,
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Password changed successfully'),
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        } else if (response.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Current password is incorrect'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to change password'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
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
      appBar: AppBar(
        title: Text('Change Password', style: TextStyle(color: Colors.white, fontFamily: "poppins")),
        backgroundColor: Color.fromARGB(255, 53, 88, 231),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Enter your current password',
                    labelText: 'Current Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    errorText: _showCurrentPasswordError
                        ? 'Current Password cannot be empty'
                        : (_showCurrentPasswordInvalidError
                            ? 'Password must be at least 8 characters long, contain uppercase,\nlowercase, number, and symbol, and have no spaces'
                            : null),
                  ),
                  obscureText: true,
                  onChanged: (value) {
                    setState(() {
                      _currentPassword = value;
                      _showCurrentPasswordError = false;
                      _showCurrentPasswordInvalidError = false;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      setState(() {
                        _showCurrentPasswordError = true;
                      });
                      return null;
                    } else if (!_isValidPassword(value)) {
                      setState(() {
                        _showCurrentPasswordInvalidError = true;
                      });
                      return null;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Enter your new password',
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    errorText: _showNewPasswordError
                        ? 'New Password cannot be empty'
                        : (_showNewPasswordInvalidError
                            ? 'Password must be at least 8 characters long, contain uppercase,\nlowercase, number, and symbol, and have no spaces'
                            : null),
                  ),
                  obscureText: true,
                  onChanged: (value) {
                    setState(() {
                      _newPassword = value;
                      _showNewPasswordError = false;
                      _showNewPasswordInvalidError = false;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      setState(() {
                        _showNewPasswordError = true;
                      });
                      return null;
                    } else if (!_isValidPassword(value)) {
                      setState(() {
                        _showNewPasswordInvalidError = true;
                      });
                      return null;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'Confirm your new password',
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    errorText: _showConfirmPasswordErrorEmpty
                        ? 'Confirm Password cannot be empty'
                        : (_showConfirmPasswordError
                            ? 'Passwords do not match'
                            : null),
                  ),
                  obscureText: true,
                  onChanged: (value) {
                    setState(() {
                      _confirmPassword = value;
                      _showConfirmPasswordError = false;
                      _showConfirmPasswordErrorEmpty = false;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      setState(() {
                        _showConfirmPasswordErrorEmpty = true;
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
                    onPressed: _changePassword,
                    child: const Text(
                      'Change Password',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
