import 'dart:convert';
import 'dart:math';

// For Flutter integration
import 'package:flutter/services.dart' show rootBundle;

// Storedquestions are read from json, eg:
// StoredQuestion(
//   question: "Which of these is a kingdom?",
//   answer: "The Netherlands",
//   otherOptions: ["Russia", "Hungary"],
// )
class StoredQuestion {
  final String topic;
  final String question;
  final String answer;
  final List<String> otherOptions;

  StoredQuestion({
    required this.topic,
    required this.question,
    required this.answer,
    required this.otherOptions,
  }) : assert(answer.isNotEmpty),
       assert(otherOptions.isNotEmpty),
       assert({answer, ...otherOptions}.length == 1 + otherOptions.length);

  factory StoredQuestion.fromJson(Map<String, dynamic> j) => StoredQuestion(
    topic: j['t'] as String,
    question: j['q'] as String,
    answer: j['a'] as String,
    otherOptions: List<String>.from(j['o'] as List),
  );

  bool get valid => {answer, ...otherOptions}.length == [answer, ...otherOptions].length;

  pretty() {
    return "Topic: $question\n"
           "Question: $question\n"
           "answer: $answer\n"
           "otherOptions: $otherOptions";
  }
}

// StoredQuestions are converted to ShuffledQuestions, eg:
//  ShuffledQuestion(
//    question: "Which of these is a kingdom?",
//    options: ["Hungary", "Russia", "The Netherlands"],
//    correctIndex: 2,
//  )
class ShuffledQuestion {
  final String topic;
  final String question;
  final List<String> options;
  final int correctIndex;

  ShuffledQuestion ({
    required this.topic,
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory ShuffledQuestion.fromStoredQuestion({required StoredQuestion storedQuestion}) {
    final options = [storedQuestion.answer, ...storedQuestion.otherOptions]..shuffle();
    return ShuffledQuestion(
      topic: storedQuestion.topic,
      question: storedQuestion.question,
      options: options,
      correctIndex: options.indexOf(storedQuestion.answer)
    );
  }

}

enum ProgressLogStatus {unSolved, correct, wrong}


// A quiz guess is an int, the index of the guessed option
// in a shuffled question.
// The result of evaluate guess can be:
// Correct() when the guess matches the correct option's index
// Incorrect(2) when the guess is wrong, and the correct option is 2
sealed class GuessResult {
  const GuessResult();
}

class Correct extends GuessResult {
  const Correct();
}

class Incorrect extends GuessResult {
  final int correctIndex;
  const Incorrect(this.correctIndex);
}

// This class contains the quiz logic.
// It is UI agnostic.
class QuizManager {
  final List<StoredQuestion> _quizData;
  late int _quizLength;
  late List<StoredQuestion> _sessionData;
  late int _i;
  late int _score;
  String? _topic;
  ShuffledQuestion? _currentQuestion;


  QuizManager({
    required List<StoredQuestion> quizData,
    topic,
    quizLength,
    }) : _quizData = [...quizData]
    {
      _validate(quizData);
      resetWith(topic: topic, length: quizLength);
    }

  int get score => _score;
  bool get isOn => _i < _quizLength;
  ShuffledQuestion? get currentQuestion => _currentQuestion;
  Set<String> get allTopics => {for (final q in _quizData) q.topic};
  String? get topic => _topic;
  int? get length => _quizLength;

  void resetWith({
    String? topic,
    int? length,
  }) {
    _topic = topic;
    _sessionData = topic != null
      ? (_quizData.where((q) => q.topic == _topic).toList()..shuffle())
      : [..._quizData]..shuffle();
    _quizLength = length != null
      ? min(length, _sessionData.length)
      : _sessionData.length;
    _i = 0;
    _score = 0;
  }

  void _validate(List<StoredQuestion> quizData) {
    for (var item in quizData) {
      if (!item.valid) { throw ArgumentError("Duplicates in question: ${item.pretty()}");}
    }
  }

  void _next() {
    _i++;
    _currentQuestion = null;
  }

  void generateQuestion() {
    if (!isOn) return;
    _currentQuestion ??= ShuffledQuestion.fromStoredQuestion(storedQuestion: _sessionData[_i]);
  }

  GuessResult checkGuess(int guess) {
    final cq = _currentQuestion;
    if (cq == null) throw StateError('No current question');
    assert(0 <= guess && guess < cq.options.length);
    final k = cq.correctIndex;
    _next();
    final bool ok = guess == k;
    if (ok) _score++;
    return ok ? const Correct() : Incorrect(k);
  }
}

// Reads quiz data from assets
Future<List<StoredQuestion>> loadQuizDataAsset(String assetPath) async {
  final text = await rootBundle.loadString(assetPath);
  final list = jsonDecode(text) as List;
  return list
      .map((e) => StoredQuestion.fromJson(e as Map<String, dynamic>))
      .toList();
}

