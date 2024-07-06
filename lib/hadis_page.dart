import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HadisPage extends StatefulWidget {
  @override
  _HadisPageState createState() => _HadisPageState();
}

class _HadisPageState extends State<HadisPage> {
  List<dynamic> hadiths = [];
  bool isLoading = false;
  bool isLoadingMore = false;
  int currentPage = 1;
  final int pageSize = 10;
  String apiKey = r'$2y$10$0T2OkW5NVhGI6dnNCOpGDcHD1WHS1ooG2qdTjHY0fDBF8y';
  TextEditingController _searchWordController = TextEditingController();
  TextEditingController _searchNumberController = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchHadiths();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchHadiths({String query = '', String number = '', bool isInitialLoad = false}) async {
    if (isInitialLoad) {
      setState(() {
        isLoading = true;
      });
    } else {
      setState(() {
        isLoadingMore = true;
      });
    }

    String url = 'https://www.hadithapi.com/public/api/hadiths?apiKey=$apiKey&page=$currentPage&size=$pageSize';
    if (query.isNotEmpty) {
      url += '&hadithEnglish=$query';
    } else if (number.isNotEmpty) {
      url += '&hadithNumber=$number';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body)['hadiths']['data'];
      setState(() {
        if (isInitialLoad) {
          hadiths = responseData;
        } else {
          hadiths.addAll(responseData);
        }
        isLoading = false;
        isLoadingMore = false;
      });
    } else {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
      throw Exception('Failed to load hadiths');
    }
  }

  void searchHadithsByWord(String query) {
    currentPage = 1;
    fetchHadiths(query: query, isInitialLoad: true);
  }

  void searchHadithsByNumber(String number) {
    currentPage = 1;
    fetchHadiths(number: number, isInitialLoad: true);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !isLoadingMore) {
      currentPage++;
      fetchHadiths(
        query: _searchWordController.text,
        number: _searchNumberController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hadiths',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
        backgroundColor: Color.fromARGB(255, 53, 88, 231),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchWordController,
                  decoration: InputDecoration(
                    hintText: 'Search Hadiths by word...',
                    labelText: 'Search by Word',
                    labelStyle: TextStyle(fontFamily: 'Poppins'),
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _searchWordController.clear();
                        searchHadithsByWord('');
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                  ),
                  style: TextStyle(fontFamily: 'Poppins'),
                  onChanged: (query) {
                    searchHadithsByWord(query);
                  },
                ),
                SizedBox(height: 16.0),
                TextField(
                  controller: _searchNumberController,
                  decoration: InputDecoration(
                    hintText: 'Search Hadiths by number...',
                    labelText: 'Search by Number',
                    labelStyle: TextStyle(fontFamily: 'Poppins'),
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        _searchNumberController.clear();
                        searchHadithsByNumber('');
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontFamily: 'Poppins'),
                  onChanged: (number) {
                    searchHadithsByNumber(number);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && !isLoadingMore) {
                        currentPage++;
                        fetchHadiths(
                          query: _searchWordController.text,
                          number: _searchNumberController.text,
                        );
                      }
                      return true;
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: hadiths.length + (isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == hadiths.length) {
                          return Center(child: CircularProgressIndicator());
                        }
                        final hadith = hadiths[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          margin: EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(
                              'Hadith Number: ${hadith['hadithNumber']}',
                              style: TextStyle(fontFamily: 'Poppins'),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              hadith['hadithEnglish'],
                              style: TextStyle(fontFamily: 'Poppins'),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            isThreeLine: true,
                            trailing: Text(
                              hadith['book']['bookName'],
                              style: TextStyle(fontFamily: 'Poppins'),
                            ),
                            onTap: () => showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text(
                                    'Hadith Details',
                                    style: TextStyle(fontFamily: 'Poppins'),
                                  ),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text(
                                          'English: ${hadith['hadithEnglish']}',
                                          style: TextStyle(fontFamily: 'Poppins'),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'Arabic: ${hadith['hadithArabic']}',
                                          style: TextStyle(fontFamily: 'Poppins'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(
                                        'Close',
                                        style: TextStyle(fontFamily: 'Poppins', color: Color.fromARGB(255, 53, 88, 231)),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
