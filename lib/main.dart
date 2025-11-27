import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:quiz_app/quiz.dart';
import "package:quiz_app/screens.dart";

void main() {
  runApp(const MyApp());
}

// used in HomePageState,
// which handles the UI-size quiz logic
enum QuizStatus { loading, title, idle, checking, showingResult, ended }


class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  late QuizManager quizManager;
  ShuffledQuestion? currentQuestion;
  int? correctIndex;
  int? selectedIndex;
  int? wrongIndex;
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
    quizManager = QuizManager(rawQuizData: data);
    currentQuestion = quizManager.getQuestion();
    if (!mounted) return;
    setState(() {
      status = QuizStatus.title;
    });
  }

  void _onStart() {
    setState(() => status = QuizStatus.idle);
  }

  Future<void> onButtonPress(int i) async {
    if (!mounted) return;
    if (status != QuizStatus.idle) return;
    setState(() {
      status = QuizStatus.checking;
      selectedIndex = i;
    });
    final GuessResult result = quizManager.checkGuess(i);
    await _feedback(result);
  }

  Future<void> _feedback(GuessResult result) async {
    if (!mounted) return;
    final sel = selectedIndex;
    setState(() => status = QuizStatus.showingResult);

    switch (result) {
      case Correct():
        setState(() => correctIndex = sel);
        await _correct.stop();
        await _correct.play(AssetSource('audio/correct.mp3'));
      case Incorrect(correctIndex: final i):
        setState(() {
          correctIndex = i;
          wrongIndex = sel;
        });
        await _wrong.stop();
        await _wrong.play(AssetSource('audio/wrong.mp3'));
    }

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      correctIndex = null;
      selectedIndex = null;
      wrongIndex = null;
      currentQuestion = quizManager.getQuestion();
      if (currentQuestion != null) {status = QuizStatus.idle;} else {status = QuizStatus.ended;
      _fanfare.play(AssetSource('audio/fanfare.mp3'));}
    });
  }

  List<Widget> _loadingSignal() {
    return <Widget>[SizedBox(height: 32), CircularProgressIndicator()];
  }

  @override
  Widget build(BuildContext context) {
    final q = currentQuestion;
    return switch (status) {
      QuizStatus.loading => TitleScreen(onStart: null),
      QuizStatus.title => TitleScreen(onStart: _onStart),
      QuizStatus.idle => GameScreen(
        title: "Quiz",
        question: currentQuestion!,
        resultData: null,
        onButtonPress: onButtonPress,
        score: quizManager.score,
      ),
      QuizStatus.checking => GameScreen(
        title: "Quiz",
        question: currentQuestion!,
        resultData: null,
        onButtonPress: null,
        score: quizManager.score,
      ),
      QuizStatus.showingResult => GameScreen(
        title: "Quiz",
        question: currentQuestion!,
        resultData: (correct: correctIndex!, selected: selectedIndex!),
        onButtonPress: null,
        score: quizManager.score,
      ),
      QuizStatus.ended => EndScreen(
        score: quizManager.score,
      )
    };
  }
}
