import 'package:flutter/material.dart';
import 'package:islami_kit/quran_page.dart';
import 'package:islami_kit/hadis_page.dart';
import 'package:islami_kit/waktu_sholat_page.dart';
import 'package:islami_kit/daknet_visitor_page.dart';
import 'package:islami_kit/daknet_admin_page.dart';
import 'package:islami_kit/daknet_penyelenggara_page.dart';
import 'package:islami_kit/profile_page.dart';
import 'package:islami_kit/mini_apps_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> pages = [
      {
        'title': 'Home Page',
        'widgets': [
          _buildFeatureCard(
            context,
            title: 'Al-Quran\n(alquran.cloud)',
            icon: Icons.book,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuranPage()),
              );
            },
          ),
          _buildFeatureCard(
            context,
            title: 'Hadiths\n(hadithapi.com)',
            icon: Icons.bookmarks,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HadisPage()),
              );
            },
          ),
          _buildFeatureCard(
            context,
            title: 'Waktu Sholat\n(muslimsalat.com)',
            icon: Icons.access_time_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WaktuSholatPage()),
              );
            },
          ),
          _buildFeatureCard(
            context,
            title: 'Informasi Kajian\n(DakNet Webview)',
            icon: Icons.find_in_page,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DakNetVisitorPage()),
              );
            },
          ),
          _buildFeatureCard(
            context,
            title: 'Administrator\n(DakNet Webview)',
            icon: Icons.admin_panel_settings,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DakNetAdminPage()),
              );
            },
          ),
          _buildFeatureCard(
            context,
            title: 'Penyelenggara\n(DakNet Webview)',
            icon: Icons.how_to_reg,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DakNetPenyelenggaraPage()),
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
        currentIndex: 0,
        onTap: (index) async {
          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
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
