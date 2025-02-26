import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(QuizApp());
}

class QuizApp extends StatefulWidget {
  @override
  _QuizAppState createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  List<dynamic> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;
  List<int> _shuffledIndexes = [];
  int _remainingTime = 60;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _startTimer();
    _pageController = PageController();
  }

  Future<void> _loadQuestions() async {
    String data = await rootBundle.loadString('assets/questions.json');
    List<dynamic> questions = json.decode(data);
    _shuffledIndexes = List.generate(questions.length, (index) => index)..shuffle();
    setState(() {
      _questions = questions;
    });
  }

  void _startTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted && !_quizCompleted) {
        setState(() {
          if (_remainingTime > 0) {
            _remainingTime--;
            _startTimer();
          } else {
            _quizCompleted = true;
          }
        });
      }
    });
  }

  void _answerQuestion(List<int> selectedAnswers) {
  var correctAnswers = (_questions[_shuffledIndexes[_currentIndex]]['correct_answers'] as List)
      .map<int>((e) => e as int)
      .toList();

  if (selectedAnswers.toSet().containsAll(correctAnswers) &&
      correctAnswers.toSet().containsAll(selectedAnswers)) {
    _score++;
  }

  if (_currentIndex < _questions.length - 1) {
    setState(() {
      _currentIndex++;
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    });
  } else {
    setState(() {
      _quizCompleted = true;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Quiz App'), actions: [Text('Time: $_remainingTime s')]),
        body: _quizCompleted || _remainingTime == 0
            ? Center(child: Text('Quiz Completed! Your Score: $_score'))
            : PageView.builder(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  var question = _questions[_shuffledIndexes[_currentIndex]];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(question['question'], style: TextStyle(fontSize: 18.0)),
                      ),
                      ...List.generate(question['answers'].length, (i) {
                        return ListTile(
                          title: Text(question['answers'][i]),
                          leading: Checkbox(
                            value: question['user_selected']?.contains(i) ?? false,
                            onChanged: (bool? value) {
                              setState(() {
                                question['user_selected'] = question['user_selected'] ?? [];
                                if (value == true) {
                                  question['user_selected'].add(i);
                                } else {
                                  question['user_selected'].remove(i);
                                }
                              });
                            },
                          ),
                        );
                      }),
                      ElevatedButton(
                        onPressed: () => _answerQuestion(question['user_selected'] ?? []),
                        child: Text('Next'),
                      )
                    ],
                  );
                },
              ),
      ),
    );
  }
}
