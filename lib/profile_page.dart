import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:islami_kit/login_page.dart';
import 'package:islami_kit/password_change_page.dart';
import 'package:islami_kit/change_profile_page.dart';
import 'package:islami_kit/home_page.dart'; 
import 'package:islami_kit/mini_apps_page.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String firstName = '';
  String lastName = '';
  String email = '';
  String? profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
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
        firstName = responseData['firstName'];
        lastName = responseData.containsKey('lastName')
            ? responseData['lastName'] : "";
        email = responseData['email'];
        profilePictureUrl = responseData.containsKey('profilePicture')
            ? 'http://10.0.2.2:3000/profile_pictures/' + responseData['profilePicture']
            : null;
      });
    } else {
      
      print('Failed to load user data: ${response.statusCode}');
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 53, 88, 231),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 24),
              CircleAvatar(
                radius: 120,
                backgroundImage: profilePictureUrl != null
                    ? NetworkImage(profilePictureUrl!)
                    : AssetImage('assets/avatar.png') as ImageProvider,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.transparent,
                child: ClipOval(
                  child: Image(
                    fit: BoxFit.fill,
                    image: profilePictureUrl != null
                        ? NetworkImage(profilePictureUrl!)
                        : AssetImage('assets/avatar.png') as ImageProvider,
                  ),
                ),
              ),
              SizedBox(height: 18),
              Text(
                firstName != ''
                    ? '$firstName $lastName'
                    : "Anonymous User",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'poppins'),
                textAlign: TextAlign.center,
              ),
              Text(
                email != ''
                    ? '$email'
                    : "anonymous@gmail.com",
                style: TextStyle(fontSize: 18, fontFamily: 'poppins'),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              _buildProfileButton(
                context,
                title: 'Change Profile',
                icon: Icons.person,
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ChangeProfilePage()),
                  );
                },
              ),
              _buildProfileButton(
                context,
                title: 'Change Password',
                icon: Icons.lock,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                  );
                },
              ),
              _buildProfileButton(
                context,
                title: 'Logout',
                icon: Icons.logout,
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.remove('token');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                color: Color.fromARGB(255, 190, 54, 32)
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 53, 88, 231),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        currentIndex: 2, 
        onTap: (index) async {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MiniAppsPage()),
            );
          } 
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bento),
            label: 'Mini Apps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context,
      {required String title, required IconData icon, required VoidCallback onTap, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: SizedBox(
        width: double.infinity,
        height: 45,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, color: Colors.white),
          label: Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 16.0, fontFamily: 'Poppins'),
            textAlign: TextAlign.center,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Color.fromARGB(255, 53, 88, 231),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
    );
  }
}
