# Quiz App (working title)

A small Flutter quiz app powered by pure Dart quiz logic and JSON-based quiz data.  
Current content: a Europe-themed multiple-choice quiz for my Ugandan friends.

---

## Idea

- Separate, **UI-agnostic Dart quiz engine** that can work with different UIs.
- **Flutter UI** on top of that engine for a simple, touch-friendly experience.
- Quiz data stored in **JSON** so topics and questions are easy to extend or replace.

The goal is a reusable quiz core that can be dropped into different apps and frontends.

---

## Current Features

- Single-topic **Europe quiz** (countries, capitals, geography, culture).
- Multiple-choice questions loaded from `quizdata.json`.
- Clear separation between:
  - **Quiz logic** (pure Dart, no Flutter imports).
  - **Presentation layer** (Flutter widgets).

---

## Project Structure (high level)

- `quiz.dart` – pure Dart quiz logic, designed to:
  - Work with various quiz data sets.
  - Be reusable with other UIs (CLI, Flutter, web, etc.).
- `main.dart` – Flutter UI that:
  - Presents questions and options.
  - Connects user interactions to the quiz logic.
- `quizdata.json` – quiz data:
  - Each entry has:
    - `q`: question text
    - `a`: correct answer
    - `o`: list of other options

---

## Roadmap / To Do

Planned features:

- **Topic choice**
  - Multiple quiz sets (e.g. Europe, Africa, World, History, etc.).
- **Difficulty levels**
  - Easier vs more demanding question sets.
- **User-side customization**
  - Basic UI customization (colors, maybe fonts or layouts).
- **Scoring and progress**
  - Persistent score and streak tracking.
  - Simple progress view for the learner.

---

## Status

- **Work in progress.**
- Core quiz logic and a first Europe quiz are implemented.
- Next steps focus on configurability (topics, difficulty) and persistent scoring.
# quiz_app
