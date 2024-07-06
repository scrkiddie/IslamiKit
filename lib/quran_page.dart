import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'surah_detail_page.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({Key? key}) : super(key: key);

  @override
  _QuranPageState createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  late Future<List<Surah>> futureSurahs;
  List<Surah> _surahs = [];
  List<Surah> _filteredSurahs = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureSurahs = fetchSurahs();
    futureSurahs.then((surahs) {
      setState(() {
        _surahs = surahs;
        _filteredSurahs = surahs;
      });
    });
    _searchController.addListener(_filterSurahs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Surah>> fetchSurahs() async {
    final response =
        await http.get(Uri.parse('http://api.alquran.cloud/v1/surah'));

    if (response.statusCode == 200) {
      List<Surah> surahs = [];
      var data = json.decode(response.body);
      for (var surah in data['data']) {
        surahs.add(Surah.fromJson(surah));
      }
      return surahs;
    } else {
      throw Exception('Failed to load surahs');
    }
  }

  void _filterSurahs() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSurahs = _surahs.where((surah) {
        return surah.englishName.toLowerCase().contains(query) ||
            surah.name.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Al-Quran', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 53, 88, 231),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Surah...',
                labelText: 'Search Surah',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Surah>>(
              future: futureSurahs,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}'));
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: _filteredSurahs.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SurahDetailPage(surah: _filteredSurahs[index]),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          margin: EdgeInsets.all(10.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _filteredSurahs[index].englishName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(_filteredSurahs[index].name),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: Text('No surahs found.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Surah {
  final int number;
  final String name;
  final String englishName;

  Surah({required this.number, required this.name, required this.englishName});

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      name: json['name'],
      englishName: json['englishName'],
    );
  }
}
