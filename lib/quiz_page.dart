import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class SurahQuestion {
  final String question;
  final Map<String, String> options;
  final String correctAnswer;

  SurahQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory SurahQuestion.fromJson(Map<String, dynamic> json) {
    List<dynamic> optionsJson = json['options'];
    Map<String, String> options = {
      'A': optionsJson[0]['text'],
      'B': optionsJson[1]['text'],
      'C': optionsJson[2]['text'],
      'D': optionsJson[3]['text'],
    };

    String correctAnswer = options.entries.firstWhere(
      (entry) => entry.value == optionsJson.firstWhere(
        (option) => option['value'] == 1,
        orElse: () => {'text': ''}, 
      )['text'],
      orElse: () => MapEntry('', ''),
    ).key;

    String decodedQuestion = utf8.decode(json['question'].runes.toList());

    return SurahQuestion(
      question: decodedQuestion,
      options: options,
      correctAnswer: correctAnswer,
    );
  }
}

Future<List<SurahQuestion>> fetchSurahQuestions() async {
  List<int> surahNumbers = List.generate(114, (index) => index + 1)..shuffle();
  surahNumbers = surahNumbers.take(4).toList(); 

  final response = await http.get(Uri.parse('https://quran.zakiego.com/api/guessSurah?select=${surahNumbers.join(",")}&amount=5'));

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    final List<dynamic> questionsJson = json['data'];

    return questionsJson.map((questionJson) => SurahQuestion.fromJson(questionJson)).toList();
  } else {
    throw Exception('Failed to load Surah questions');
  }
}

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late Future<List<SurahQuestion>> _futureQuestions;
  List<SurahQuestion>? _questions;
  int _currentQuestionIndex = 0;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _futureQuestions = fetchSurahQuestions();
  }

  void _answerQuestion(String answer) {
    if (_questions![_currentQuestionIndex].correctAnswer == answer) {
      _score++;
    }

    setState(() {
      if (_currentQuestionIndex < _questions!.length - 1) {
        _currentQuestionIndex++;
      } else {
        _showResult();
      }
    });
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Game Over',
          style: GoogleFonts.poppins(),
        ),
        content: Text(
          'You have completed the game! Your score: $_score',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _score = 0;
                _currentQuestionIndex = 0;
                _futureQuestions = fetchSurahQuestions();
                Navigator.of(context).pop();
              });
            },
            child: Text(
              'Restart',
              style: GoogleFonts.poppins(color: Color.fromARGB(255, 53, 88, 231)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Exit',
              style: GoogleFonts.poppins(color: Color.fromARGB(255, 53, 88, 231)),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Surah Quiz',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 53, 88, 231),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<SurahQuestion>>(
        future: _futureQuestions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            _questions = snapshot.data;

            return _questions != null ? _buildQuiz() : Center(child: Text('No questions found'));
          }
        },
      ),
    );
  }

  Widget _buildQuiz() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1} of ${_questions!.length}',
              style: GoogleFonts.poppins(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Answer with the correct surah name:',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              _questions![_currentQuestionIndex].question,
              style: GoogleFonts.scheherazadeNew(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 20),
            ..._questions![_currentQuestionIndex].options.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () => _answerQuestion(entry.key),
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: GoogleFonts.poppins(fontSize: 16,color: Colors.white),
                      
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 53, 88, 231),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
            SizedBox(height: 20),
            Text(
              'Score: $_score',
              style: GoogleFonts.poppins(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: QuizPage(),
  ));
}
