import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:quiz_app/quiz.dart';

void main() {
  runApp(const MyApp());
}

// used in HomePageState,
// which handles the UI-size quiz logic
enum QuizStatus { loading, idle, checking, showingResult, ended }

class QuestionText extends StatelessWidget {
  final String questionText;
  const QuestionText({required this.questionText, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          questionText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

class OptionButton extends StatelessWidget {
  final String optionText;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  const OptionButton({
    required this.optionText,
    required this.onPressed,
    this.style,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: TextButton(
        onPressed: onPressed,
        style: style ?? ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.secondaryContainer,
          ),
          foregroundColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(optionText, style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}

class EndText extends StatelessWidget {
  final String text;
  const EndText({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 36, 12, 36),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

class ScoreText extends StatelessWidget {
  final int score;
  const ScoreText({required this.score, super.key});

  @override
  Widget build(BuildContext context) {
    final String text = "Score: $score";
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 36, 12, 36),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

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
      status = QuizStatus.idle;
    });
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

  List<Widget> _endMessage() {
    return <Widget>[
      EndText(text: "The quiz has ended.\nThank you for playing!"),
      ScoreText(score: quizManager.score),
    ];
  }

  List<Widget> _questionContent(q) {
    return <Widget>[
      QuestionText(questionText: q.question),
      for (final entry in q.options.asMap().entries)
        OptionButton(
          optionText: entry.value,
          onPressed: status == QuizStatus.idle
              ? () => onButtonPress(entry.key)
              : null,
          style: _optionStyle(context, entry.key),
        ),
        ScoreText(score: quizManager.score),
    ];
  }

  List<Widget> _loadingSignal() {
    return <Widget>[SizedBox(height: 32), CircularProgressIndicator()];
  }

ButtonStyle _optionStyle(BuildContext c, int i) {
  final cs = Theme.of(c).colorScheme;
  var bg = cs.secondaryContainer;
  var fg = cs.onSecondaryContainer;

  if (status == QuizStatus.showingResult) {
    if (i == correctIndex) { bg = cs.tertiaryContainer; fg = cs.onTertiaryContainer; }
    else if (i == wrongIndex) { bg = cs.errorContainer; fg = cs.onErrorContainer; }
  }
  return ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(bg),
    foregroundColor: WidgetStatePropertyAll(fg),
  );
}

  @override
  Widget build(BuildContext context) {
    final q = currentQuestion;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(widget.title),
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: LayoutBuilder(
        builder: (context, vp) {
          final w = (vp.maxWidth * 0.8).clamp(0.0, 360.0);
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: vp.maxHeight),
              child: Center(
                child: SizedBox(
                  width: w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: status == QuizStatus.ended
                        ? _endMessage()
                        : (q != null ? _questionContent(q) : _loadingSignal()),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
