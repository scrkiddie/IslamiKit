import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class WaktuSholatPage extends StatefulWidget {
  const WaktuSholatPage({Key? key}) : super(key: key);

  @override
  _WaktuSholatPageState createState() => _WaktuSholatPageState();
}

class _WaktuSholatPageState extends State<WaktuSholatPage> {
  late Future<List<Map<String, String>>> _prayerTimes;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID');
    _prayerTimes = _fetchPrayerTimes();
  }

  Future<List<Map<String, String>>> _fetchPrayerTimes() async {
    final response = await http.get(Uri.parse('https://muslimsalat.com/magelang/weekly.json'));

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      List<dynamic> items = jsonBody['items'];
      return items.map((item) {
        final Map<String, dynamic> prayerTime = item;
        return {
          'date_for': prayerTime['date_for'].toString(),
          'fajr': prayerTime['fajr'].toString(),
          'dhuhr': prayerTime['dhuhr'].toString(),
          'asr': prayerTime['asr'].toString(),
          'maghrib': prayerTime['maghrib'].toString(),
          'isha': prayerTime['isha'].toString(),
        };
      }).toList();
    } else {
      throw Exception('Failed to load prayer times');
    }
  }

  String _formatDate(String date) {
    List<String> dateParts = date.split('-');
    String year = dateParts[0];
    String month = dateParts[1].padLeft(2, '0');
    String day = dateParts[2].padLeft(2, '0');

    String formattedDateString = '$year-$month-$day';
    DateTime dateTime = DateTime.parse(formattedDateString);
    String dayName = DateFormat('EEEE', 'id_ID').format(dateTime);
    String formattedDate = DateFormat('d MMMM yyyy', 'id_ID').format(dateTime);

    return '$dayName, $formattedDate';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waktu Sholat', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        backgroundColor: Color(0xFF3559E7),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _prayerTimes,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Map<String, String>> prayerTimes = snapshot.data!;
            return ListView.builder(
              itemCount: prayerTimes.length,
              itemBuilder: (context, index) {
                final prayerTime = prayerTimes[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    color: Color.fromARGB(255, 247, 242, 250),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDate(prayerTime['date_for']!),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3559E7),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(height: 8),
                          Divider(color: Color(0xFF3559E7)),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Shubuh :', style: _getTimeTextStyle()),
                              Text(prayerTime['fajr']!, style: _getTimeTextStyle()),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Dzuhur :', style: _getTimeTextStyle()),
                              Text(prayerTime['dhuhr']!, style: _getTimeTextStyle()),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Ashar :', style: _getTimeTextStyle()),
                              Text(prayerTime['asr']!, style: _getTimeTextStyle()),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Maghrib :', style: _getTimeTextStyle()),
                              Text(prayerTime['maghrib']!, style: _getTimeTextStyle()),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Isya :', style: _getTimeTextStyle()),
                              Text(prayerTime['isha']!, style: _getTimeTextStyle()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  TextStyle _getTimeTextStyle() {
    return TextStyle(
      fontSize: 16,
      color: Colors.black87,
      fontFamily: 'Poppins',
    );
  }
}
