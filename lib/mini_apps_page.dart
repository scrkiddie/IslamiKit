import 'package:flutter/material.dart';
import 'package:islami_kit/notes_page.dart';
import 'package:islami_kit/quiz_page.dart';
import 'package:islami_kit/profile_page.dart';
import 'package:islami_kit/home_page.dart';
import 'package:islami_kit/dzikir_page.dart';
import 'package:islami_kit/asmaul_husna_page.dart';

class MiniAppsPage extends StatelessWidget {
  const MiniAppsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> pages = [
      {
        'title': 'Mini Apps',
        'widgets': [
          _buildFeatureCard(
            context,
            title: 'Dzikir Counter',
            icon: Icons.my_library_add,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DzikirPage()),
              );
            },
          ),
          _buildFeatureCard(
            context,
            title: 'Notes',
            icon: Icons.note,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotesPage()),
              );
            },
          ),
          _buildFeatureCard(
            context,
            title: 'Surah Quiz\n(zakiego.com)',
            icon: Icons.quiz,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuizPage()),
              );
            },
          ),
          _buildFeatureCard(
            context,
            title: 'Asmaul Husna\n(aladhan.com)',
            icon: Icons.tag,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AsmaulHusnaPage()),
              );
            },
          ),
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(pages[0]['title'], style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 53, 88, 231),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20.0,
                crossAxisSpacing: 20.0,
                children: List<Widget>.from(pages[0]['widgets']),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(255, 53, 88, 231),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white.withOpacity(0.6),
        currentIndex: 1,
        onTap: (index) async {
          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          } else if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
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

  static Widget _buildFeatureCard(BuildContext context,
      {required String title, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: Color.fromARGB(255, 53, 88, 231),
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
