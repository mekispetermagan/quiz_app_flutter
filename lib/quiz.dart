import 'dart:convert';

// For Flutter integration
import 'package:flutter/services.dart' show rootBundle;

// Storedquestions are read from json, eg:
// StoredQuestion(
//   question: "Which of these is a kingdom?",
//   answer: "The Netherlands",
//   otherOptions: ["Russia", "Hungary"],
// )
class StoredQuestion {
  final String question;
  final String answer;
  final List<String> otherOptions;

  StoredQuestion({
    required this.question,
    required this.answer,
    required this.otherOptions,
  }) : assert(answer.isNotEmpty),
       assert(otherOptions.isNotEmpty),
       assert({answer, ...otherOptions}.length == 1 + otherOptions.length);

  factory StoredQuestion.fromJson(Map<String, dynamic> j) => StoredQuestion(
    question: j['q'] as String,
    answer: j['a'] as String,
    otherOptions: List<String>.from(j['o'] as List),
  );
}

// StoredQuestions are converted to ShuffledQuestions, eg:
//  ShuffledQuestion(
//    question: "Which of these is a kingdom?",
//    options: ["Hungary", "Russia", "The Netherlands"],
//    correctIndex: 2,
//  )
typedef ShuffledQuestion = ({
  String question,
  List<String> options,
  int correctIndex,
});

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
  int _i = 0;
  int _score = 0;
  ShuffledQuestion? _currentQuestion;
  final List<StoredQuestion> quizData;
  QuizManager({required List<StoredQuestion> rawQuizData}) : quizData = [...rawQuizData]..shuffle();

  int get score => _score;
  bool get isOn => _i < quizData.length;

  void _next() {
    _i++;
    _currentQuestion = null;
  }

  ShuffledQuestion? getQuestion() {
    if (!isOn) return null;
    return _currentQuestion ??= _shuffle(quizData[_i]);
  }

  GuessResult checkGuess(int guess) {
    final cq = _currentQuestion; // for flow promotion
    if (cq == null) throw StateError('No current question');
    assert(0 <= guess && guess < cq.options.length);
    final k = cq.correctIndex; // to prevent repeated reading of field
    _next();
    final ok = guess == k;
    if (ok) _score++;
    return ok ? const Correct() : Incorrect(k);
  }

  ShuffledQuestion _shuffle(StoredQuestion question) {
    final options = [question.answer, ...question.otherOptions]..shuffle();
    final correctIndex = options.indexOf(question.answer);
    return (
      question: question.question,
      options: List.unmodifiable(options),
      correctIndex: correctIndex,
    );
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
