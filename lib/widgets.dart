import 'package:flutter/material.dart';

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
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
