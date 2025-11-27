import 'package:flutter/material.dart';
import 'quiz.dart';

enum BarEdge {left, none, right}

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

class PrimaryActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const PrimaryActionButton({
    required this.text,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.onPrimaryContainer),
        backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.primaryContainer),
      ),
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 6, vertical: 12),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 24,
            // fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class ProgressBarSegment extends StatelessWidget {
  final ProgressStatus status;
  final bool isCurrent;
  final bool isFifth;
  final BarEdge whichEdge;
  const ProgressBarSegment({
    required this.status,
    required this.isCurrent,
    required this.isFifth,
    required this.whichEdge,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Padding(
        padding: isFifth
          ? EdgeInsets.fromLTRB(3, 1, 1, 1)
          : EdgeInsets.all(1.0),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          height: isCurrent ? 18 : 15,
          decoration: BoxDecoration(
            color: switch(status) {
              ProgressStatus.unSolved => cs.surface,
              ProgressStatus.correct => cs.primaryContainer,
              ProgressStatus.wrong => cs.errorContainer
            },
            border: Border.all(
              color: cs.outlineVariant,
              width: 1,
            ),
            borderRadius: switch (whichEdge) {
              BarEdge.left  => BorderRadius.horizontal(left: Radius.circular(9999)),
              BarEdge.right => BorderRadius.horizontal(right: Radius.circular(9999)),
              BarEdge.none  => BorderRadius.zero,
            },
          ),
        ),
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final List<ProgressStatus> progressLog;
  final int current;
  const ProgressBar({
    required this.progressLog,
    required this.current,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final maxIndex = progressLog.length - 1;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: <Widget>[
          for (int i=0; i<=maxIndex; i++)
          ProgressBarSegment(
            status: progressLog[i],
            isCurrent: i == current,
            isFifth: 0 < i && i % 5 == 0,
            whichEdge: i== 0
              ? BarEdge.left
              : i == maxIndex
                ? BarEdge.right
                : BarEdge.none,
          )
        ],
      ),
    );

  }
}