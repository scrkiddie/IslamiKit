import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DzikirPage extends StatefulWidget {
  const DzikirPage({Key? key}) : super(key: key);

  @override
  _DzikirPageState createState() => _DzikirPageState();
}

class _DzikirPageState extends State<DzikirPage> {
  late SharedPreferences _prefs;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _loadCounter();
  }

  Future<void> _loadCounter() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _counter = _prefs.getInt('counter') ?? 0;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
      _saveCounter();
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      _saveCounter();
    });
  }

  void _decrementCounter() {
    setState(() {
      if (_counter > 0) {
        _counter--;
        _saveCounter();
      }
    });
  }

  Future<void> _saveCounter() async {
    await _prefs.setInt('counter', _counter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dzikir Counter', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 53, 88, 231),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: _incrementCounter,
        child: Container(
          color: Colors.transparent, 
          child: Column(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Tap to count:',
                      style: TextStyle(fontFamily: "poppins", fontSize: 25),
                    ),
                    Text(
                      '$_counter',
                      style: const TextStyle(fontFamily: "poppins", fontSize: 50),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FloatingActionButton(
                      onPressed: _decrementCounter,
                      backgroundColor: const Color.fromARGB(255, 53, 88, 231),
                      tooltip: 'Decrement',
                      child: const Icon(Icons.remove, color: Colors.white),
                    ),
                    const SizedBox(width: 20),
                    FloatingActionButton(
                      onPressed: _resetCounter,
                      backgroundColor: const Color.fromARGB(255, 53, 88, 231),
                      tooltip: 'Reset',
                      child: const Icon(Icons.refresh, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
