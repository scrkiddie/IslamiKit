import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'quran_page.dart'; 

class SurahDetailPage extends StatefulWidget {
  final Surah surah;

  const SurahDetailPage({Key? key, required this.surah}) : super(key: key);

  @override
  _SurahDetailPageState createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {
  late Future<List<Ayah>> futureAyahs;

  @override
  void initState() {
    super.initState();
    futureAyahs = fetchAyahs();
  }

  Future<List<Ayah>> fetchAyahs() async {
    final response = await http
        .get(Uri.parse('http://api.alquran.cloud/v1/surah/${widget.surah.number}/editions/quran-uthmani,en.asad'));

    if (response.statusCode == 200) {
      List<Ayah> ayahs = [];
      var data = json.decode(response.body);
      var quranData = data['data'][0]['ayahs'];
      var translationData = data['data'][1]['ayahs'];
      for (int i = 0; i < quranData.length; i++) {
        ayahs.add(Ayah.fromJson(quranData[i], translationData[i]));
      }
      return ayahs;
    } else {
      throw Exception('Failed to load ayahs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Al-Quran (${widget.surah.englishName})", style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 53, 88, 231),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: FutureBuilder<List<Ayah>>(
          future: futureAyahs,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.all(10.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data![index].text,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(snapshot.data![index].translation),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class Ayah {
  final String text;
  final String translation;

  Ayah({required this.text, required this.translation});

  factory Ayah.fromJson(Map<String, dynamic> json, Map<String, dynamic> translationJson) {
    return Ayah(
      text: json['text'],
      translation: translationJson['text'],
    );
  }
}
