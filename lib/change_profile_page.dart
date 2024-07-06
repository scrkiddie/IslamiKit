import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:islami_kit/login_page.dart';
import 'package:islami_kit/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

class ChangeProfilePage extends StatefulWidget {
  @override
  _ChangeProfilePageState createState() => _ChangeProfilePageState();
}

class _ChangeProfilePageState extends State<ChangeProfilePage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  String _profilePictureUrl = '';
  File? _imageFile;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  bool _showFirstNameEmptyError = false;
  bool _showEmailEmptyError = false;
  bool _showEmailInvalidError = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _getCurrentUser();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      return;
    }

    var url = Uri.parse('http://10.0.2.2:3000/api/users/current');
    var response = await http.get(
      url,
      headers: {
        'Authorization': '$token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body)['data'];
      setState(() {
        _firstNameController.text = responseData['firstName'];
        _lastNameController.text = responseData.containsKey('lastName')
            ? responseData['lastName']
            : "";
        _emailController.text = responseData['email'];
        _profilePictureUrl = responseData.containsKey('profilePicture')
            ? 'http://10.0.2.2:3000/profile_pictures/' + responseData['profilePicture']
            : '';
      });
    } else {
      print('Failed to load user data: ${response.statusCode}');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if(!_showFirstNameEmptyError && !_showEmailEmptyError && !_showEmailInvalidError){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('token');
        if (token == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
          return;
        }

        var url = Uri.parse('http://10.0.2.2:3000/api/users/current');
        var request = http.MultipartRequest('PATCH', url);
        request.headers.addAll({
          'Authorization': '$token',
        });

        if (_imageFile != null) {
          File resizedFile = await _resizeImage(_imageFile!);
          request.files.add(await http.MultipartFile.fromPath(
            'profilePicture',
            resizedFile.path,
          ));
        }

        request.fields['firstname'] = _firstNameController.text;
        request.fields['lastname'] = _lastNameController.text;
        request.fields['email'] = _emailController.text;

        var response = await request.send();

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully'),
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          
        } else {
          print('Failed to update profile: ${response.reasonPhrase}');
          
        }
      }
    }

  }

  Future<File> _resizeImage(File originalImageFile) async {
    final bytes = await originalImageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image != null) {
      img.Image resizedImage = img.copyResize(image, width: 500, height: 500);
      var resizedFile = File(originalImageFile.path)
        ..writeAsBytesSync(img.encodePng(resizedImage));
      return resizedFile;
    }
    return originalImageFile;
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File resizedFile = await _resizeImage(File(pickedFile.path));
      setState(() {
        _imageFile = resizedFile;
      });
    }
  }

  bool _isValidEmail(String email) {
    String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regExp = RegExp(emailPattern);
    return regExp.hasMatch(email);
  }

  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          title: Text('Change Profile', style: TextStyle(color: Colors.white)),
          backgroundColor: Color.fromARGB(255, 53, 88, 231),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 120,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (_profilePictureUrl.isNotEmpty
                            ? NetworkImage(_profilePictureUrl)
                            : AssetImage('assets/avatar.png') as ImageProvider),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.transparent,
                    child: ClipOval(
                      child: Image(
                        fit: BoxFit.fill,
                        image: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (_profilePictureUrl.isNotEmpty
                                ? NetworkImage(_profilePictureUrl)
                                : AssetImage('assets/avatar.png')
                                    as ImageProvider),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                    errorText: _showFirstNameEmptyError
                        ? 'First Name cannot be empty'
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value.isNotEmpty) {
                        _showFirstNameEmptyError = false;
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      setState(() {
                        _showFirstNameEmptyError = true;
                      });
                      return null;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: 'Last Name (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                    errorText: _showEmailEmptyError
                        ? 'Email cannot be empty'
                        : (_showEmailInvalidError
                            ? 'Invalid email format'
                            : null),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _showEmailInvalidError = false;
                      _showEmailEmptyError = false;
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
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text(
                      'Change Profile',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
