import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AsmaulHusnaPage extends StatefulWidget {
  const AsmaulHusnaPage({Key? key}) : super(key: key);

  @override
  _AsmaulHusnaPageState createState() => _AsmaulHusnaPageState();
}

class _AsmaulHusnaPageState extends State<AsmaulHusnaPage> {
  late List<AsmaulHusna> _asmaulHusna;
  bool _isLoading = false;

  int _page = 1;
  int _pageSize = 15; 
  bool _isLastPage = false; 

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _asmaulHusna = [];
    _fetchAsmaulHusna();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (!_isLastPage) {
          _fetchAsmaulHusna();
        }
      }
    });
  }

  Future<void> _fetchAsmaulHusna() async {
    if (_isLoading || _isLastPage) return;

    setState(() {
      _isLoading = true;
    });

    final response = await http.get(Uri.parse('https://api.aladhan.com/v1/asmaAlHusna?page=$_page&per_page=$_pageSize'));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List asmaulHusnaJson = json['data'];
      final List<AsmaulHusna> loadedAsmaulHusna =
          asmaulHusnaJson.map((json) => AsmaulHusna.fromJson(json)).toList();

      setState(() {
        _asmaulHusna.addAll(loadedAsmaulHusna);
        _isLoading = false;
        _page++; 
        if (loadedAsmaulHusna.isEmpty) {
          _isLastPage = true; 
        }
      });
    } else {
      throw Exception('Failed to load Asmaul Husna');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asmaul Husna', style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 53, 88, 231),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading && _asmaulHusna.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              controller: _scrollController,
              itemCount: _asmaulHusna.length,
              itemBuilder: (context, index) {
                final asmaulHusna = _asmaulHusna[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      '${asmaulHusna.name} (${asmaulHusna.transliteration.replaceAll(' ', '')})',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        asmaulHusna.meaning,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class AsmaulHusna {
  final String name;
  final String transliteration;
  final String meaning;

  AsmaulHusna({
    required this.name,
    required this.transliteration,
    required this.meaning,
  });

  factory AsmaulHusna.fromJson(Map<String, dynamic> json) {
    return AsmaulHusna(
      name: json['name'],
      transliteration: json['transliteration'],
      meaning: json['en']['meaning'],
    );
  }
}
