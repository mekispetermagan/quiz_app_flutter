import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:quiz_app/quiz.dart';
import "package:quiz_app/screens.dart";

// used in HomePageState,
// which handles the UI-size quiz logic
enum QuizStatus { loading, title, topic, idle, checking, showingResult, ended }

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(title: 'Quiz'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late QuizManager _quizManager;
  ShuffledQuestion? _currentQuestion;
  int? _correctIndex;
  int? _selectedIndex;
  int? _wrongIndex;
  QuizStatus status = QuizStatus.loading;
  late final AudioPlayer _correct = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  late final AudioPlayer _wrong = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);
  late final AudioPlayer _fanfare = AudioPlayer()
    ..setReleaseMode(ReleaseMode.stop);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _correct.dispose();
    _wrong.dispose();
    _fanfare.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    List<StoredQuestion> data = await loadQuizDataAsset('assets/data/quizdata.json');
    _quizManager = QuizManager(
      quizData: data,
    );
    if (!mounted) return;
    setState(() {
      status = QuizStatus.title;
    });
  }

  void _onStart() {
    setState(() => status = QuizStatus.topic);
  }

  void _onTopicSelect(String topic) {
    setState((){
      _quizManager.resetWith(
        topic: topic,
        length: 20,
      );
      _quizManager.generateQuestion();
      _currentQuestion = _quizManager.currentQuestion;
      status = QuizStatus.idle;
    });
  }

  Future<void> _onSubmit(int i) async {
    if (!mounted) return;
    if (status != QuizStatus.idle) return;
    setState(() {
      status = QuizStatus.checking;
      _selectedIndex = i;
    });
    final GuessResult result = _quizManager.checkGuess(i);
    await _feedback(result);
  }

  Future<void> _feedback(GuessResult result) async {
    if (!mounted) return;
    final sel = _selectedIndex;
    setState(() => status = QuizStatus.showingResult);

    switch (result) {
      case Correct():
        setState(() => _correctIndex = sel);
        await _correct.stop();
        await _correct.play(AssetSource('audio/correct.mp3'));
      case Incorrect(correctIndex: final i):
        setState(() {
          _correctIndex = i;
          _wrongIndex = sel;
        });
        await _wrong.stop();
        await _wrong.play(AssetSource('audio/wrong.mp3'));
    }

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _correctIndex = null;
      _selectedIndex = null;
      _wrongIndex = null;
      _quizManager.generateQuestion();
      _currentQuestion = _quizManager.currentQuestion;
      if (_currentQuestion != null) {status = QuizStatus.idle;} else {status = QuizStatus.ended;
      _fanfare.play(AssetSource('audio/fanfare.mp3'));}
    });
  }

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      QuizStatus.loading => TitleScreen(onStart: null),
      QuizStatus.title => TitleScreen(onStart: _onStart),
      QuizStatus.topic => TopicScreen(
        topics: _quizManager.allTopics,
        onTopicSelect: _onTopicSelect,
      ),
      QuizStatus.idle => GameScreen(
        title: "${_quizManager.topic ??""} Quiz",
        question: _currentQuestion!,
        resultData: null,
        onButtonPress: _onSubmit,
        score: _quizManager.score,
      ),
      QuizStatus.checking => GameScreen(
        title: "${_quizManager.topic ??""} Quiz",
        question: _currentQuestion!,
        resultData: null,
        onButtonPress: null,
        score: _quizManager.score,
      ),
      QuizStatus.showingResult => GameScreen(
        title: "${_quizManager.topic ??""} Quiz",
        question: _currentQuestion!,
        resultData: (correct: _correctIndex!, selected: _selectedIndex!),
        onButtonPress: null,
        score: _quizManager.score,
      ),
      QuizStatus.ended => EndScreen(
        score: _quizManager.score,
        onReset: _onStart,
      )
    };
  }
}

void main() {
  runApp(const QuizApp());
}
