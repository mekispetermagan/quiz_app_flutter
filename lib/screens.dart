import 'package:flutter/material.dart';
import 'package:quiz_app/quiz.dart';
import 'package:quiz_app/widgets.dart';

typedef ResultData = ({int correct, int selected});

class TitleScreen extends StatelessWidget {
  final VoidCallback? onStart;
  const TitleScreen({
    required this.onStart,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Quiz App",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                ),
              ),
              PrimaryActionButton(
                text: onStart != null ? "Start" : "Wait...",
                onPressed: onStart,
              ),
            ],
          ),
        ),
        ),
    );
  }
}

class TopicScreen extends StatelessWidget {
  final Set<String> topics;
  final void Function(String) onTopicSelect;
  const TopicScreen({
    required this.topics,
    required this.onTopicSelect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              for (final topic in topics)
              PrimaryActionButton(
                text: topic,
                onPressed: () => onTopicSelect(topic),
              )
            ],
          ),
        ),
        ),
    );
  }
}

class GameScreen extends StatelessWidget {
  final String title;
  final ShuffledQuestion question;
  final ResultData? resultData;
  final void Function(int)? onButtonPress;
  final int score;
  const GameScreen({
    required this.title,
    required this.question,
    required this.resultData,
    required this.onButtonPress,
    required this.score,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final rd = resultData;
    final obp = onButtonPress;

    ButtonStyle optionStyle (int i) {
      Color bg = cs.secondaryContainer;
      Color fg = cs.onSecondaryContainer;

      if (rd != null) {
        if (i == rd.correct) { bg = cs.tertiaryContainer; fg = cs.onTertiaryContainer; }
        else if (i == rd.selected) { bg = cs.errorContainer; fg = cs.onErrorContainer; }
      }
      return ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(bg),
        foregroundColor: WidgetStatePropertyAll(fg),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(title),
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(.0),
          child: SizedBox.expand(
            child: Column(
              children: <Widget>[
                // inner column: buttons
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  <Widget>[
                      QuestionText(questionText: question.question),
                      for (final entry in question.options.asMap().entries)
                        OptionButton(
                          optionText: entry.value,
                          onPressed: obp != null
                              ? () => obp(entry.key)
                              : null,
                          style: optionStyle(entry.key),
                        ),
                    ],
                  ),
                ),
                ScoreText(score: score),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EndScreen extends StatelessWidget {
  final int score;
  final VoidCallback onReset;
  const EndScreen({
    required this.score,
    required this.onReset,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              EndText(text: "The quiz has ended.\nThank you for playing!"),
              ScoreText(score: score),
              PrimaryActionButton(text: "Restart", onPressed: onReset)
            ],
          ),
        ),
        ),
    );
  }
}

