import 'dart:async';

enum PetOutcome { playing, won, lost }

class PetGameModel {
  PetGameModel({
    this.name = 'Jay',
    this.happiness = 50,
    this.hunger = 50,
    this.energy = 70,
    this.outcome = PetOutcome.playing,
  });

  String name;
  int happiness;
  int hunger;
  int energy;
  PetOutcome outcome;

  bool get isFinished => outcome != PetOutcome.playing;
  bool get canStartWinTimer => !isFinished && happiness > 80;

  static int clampMeter(int value) => value.clamp(0, 100).toInt();

  void feed() {
    if (isFinished) return;
    final nextHunger = clampMeter(hunger - 10);
    hunger = nextHunger;
    happiness = clampMeter(happiness + (nextHunger < 30 ? -20 : 10));
    energy = clampMeter(energy + 5);
    _evaluateLoss();
  }

  bool play() {
    if (isFinished || energy < 10) return false;
    happiness = clampMeter(happiness + 15);
    hunger = clampMeter(hunger + 5);
    energy = clampMeter(energy - 10);
    _evaluateLoss();
    return true;
  }

  void sleep() {
    if (isFinished) return;
    energy = clampMeter(energy + 25);
    hunger = clampMeter(hunger + 5);
    _evaluateLoss();
  }

  void hungerTick() {
    if (isFinished) return;
    if (hunger < 100) {
      hunger = clampMeter(hunger + 5);
    } else {
      happiness = clampMeter(happiness - 20);
    }
    _evaluateLoss();
  }

  void markWon() {
    if (!isFinished && happiness > 80) outcome = PetOutcome.won;
  }

  void reset({String? name}) {
    this.name = name ?? this.name;
    happiness = 50;
    hunger = 50;
    energy = 70;
    outcome = PetOutcome.playing;
  }

  void _evaluateLoss() {
    if (hunger == 100 && happiness <= 10) outcome = PetOutcome.lost;
  }
}

class HighMoodWinTracker {
  HighMoodWinTracker({
    this.duration = const Duration(minutes: 3),
    required this.onWin,
  });

  final Duration duration;
  final void Function() onWin;
  Timer? _timer;

  void update(PetGameModel model) {
    if (!model.canStartWinTimer) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    _timer ??= Timer(duration, () {
      _timer = null;
      if (model.canStartWinTimer) onWin();
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() => cancel();
}
