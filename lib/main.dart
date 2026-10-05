import 'dart:async';

import 'package:flutter/material.dart';

import 'pet_model.dart';

void main() {
  runApp(const DigitalPetApp());
}

class DigitalPetApp extends StatelessWidget {
  const DigitalPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Pet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff6750a4)),
        useMaterial3: true,
      ),
      home: const PetScreen(),
    );
  }
}

class PetScreen extends StatefulWidget {
  const PetScreen({super.key});

  @override
  State<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends State<PetScreen> {
  final _nameController = TextEditingController(text: 'Jay');
  late final PetGameModel _pet;
  Timer? _hungerTimer;
  late final HighMoodWinTracker _winTracker;
  Timer? _reactionTimer;
  String _selectedActivity = 'Play';
  String _reaction = '';
  bool _isPaused = false;
  double _bounce = 1;

  bool get _finished => _pet.isFinished;
  bool get _gameOver => _pet.outcome == PetOutcome.lost;
  bool get _hasWon => _pet.outcome == PetOutcome.won;
  int get _happiness => _pet.happiness;
  int get _hunger => _pet.hunger;
  int get _energy => _pet.energy;
  String get _petName => _pet.name;

  String get _moodLabel {
    if (_gameOver) return 'Needs care';
    if (_hasWon) return 'Thriving';
    if (_happiness > 70) return 'Happy';
    if (_happiness >= 30) return 'Neutral';
    return 'Unhappy';
  }

  Color get _moodColor {
    if (_happiness > 70) return Colors.green;
    if (_happiness >= 30) return Colors.amber;
    return Colors.red;
  }

  String get _petMessage {
    if (_gameOver) return 'I need a rest. Please restart me.';
    if (_hasWon) return 'Best day ever!';
    if (_isPaused) return 'I am taking a little break.';
    if (_hunger > 80) return "I'm starving!";
    if (_energy < 20) return 'So sleepy...';
    if (_happiness <= 30) return 'Play with me?';
    return "Hi, I'm $_petName!";
  }

  double get _petScale => _bounce * (_happiness > 70
      ? 1.06
      : _happiness < 30
          ? 0.94
          : 1);

  @override
  void initState() {
    super.initState();
    _pet = PetGameModel();
    _winTracker = HighMoodWinTracker(onWin: () {
      if (!mounted || _finished) return;
      setState(_pet.markWon);
      _hungerTimer?.cancel();
    });
    _startHungerTimer();
  }

  void _startHungerTimer() {
    _hungerTimer?.cancel();
    _hungerTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted || _isPaused || _finished) return;
      _applyHungerTick();
    });
  }

  void _applyHungerTick() {
    setState(_pet.hungerTick);
    _updateOutcome();
  }

  void _feedPet() {
    if (_finished || _isPaused) return;
    setState(_pet.feed);
    _showReaction('🍖');
    _updateOutcome();
  }

  void _playWithPet() {
    if (_finished || _isPaused) return;
    if (_energy < 10) {
      _showReaction('💤');
      _announce('Jay needs more energy before playing.');
      return;
    }
    setState(_pet.play);
    _showReaction('🎾');
    _updateOutcome();
  }

  void _doActivity() {
    if (_selectedActivity == 'Run') {
      _playWithPet();
      return;
    }
    if (_selectedActivity == 'Sleep') {
      _restPet();
      return;
    }
    _playWithPet();
  }

  void _restPet() {
    if (_finished || _isPaused) return;
    setState(_pet.sleep);
    _showReaction('💤');
    _updateOutcome();
  }

  void _updateOutcome() {
    if (!mounted || _finished) return;
    if (_gameOver) {
      _winTracker.cancel();
      _hungerTimer?.cancel();
      return;
    }
    _winTracker.update(_pet);
  }

  void _showReaction(String reaction) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    _reactionTimer?.cancel();
    setState(() {
      _reaction = reaction;
      _bounce = reduceMotion ? 1 : 1.12;
    });
    _reactionTimer = Timer(reduceMotion ? Duration.zero : const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _reaction = '';
        _bounce = 1;
      });
    });
  }

  void _announce(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _saveName() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _announce('Please enter a pet name.');
      return;
    }
    setState(() => _pet.name = name);
    _announce('Your pet is now called $name.');
  }

  void _togglePause() {
    if (_finished) return;
    setState(() => _isPaused = !_isPaused);
  }

  void _resetPet() {
    _reactionTimer?.cancel();
    setState(() {
      _pet.reset(name: _nameController.text.trim().isEmpty ? 'Jay' : _nameController.text.trim());
      _isPaused = false;
      _reaction = '';
      _bounce = 1;
    });
    _winTracker.cancel();
    _startHungerTimer();
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _winTracker.dispose();
    _reactionTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final animationDuration =
        reduceMotion ? Duration.zero : const Duration(milliseconds: 350);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Pet'),
        actions: [
          IconButton(
            tooltip: _isPaused ? 'Resume care' : 'Pause care',
            onPressed: _finished ? null : _togglePause,
            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
          ),
          IconButton(
            tooltip: 'Reset pet',
            onPressed: _resetPet,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Meet $_petName', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: animationDuration,
              child: Text(_petMessage, key: ValueKey(_petMessage), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 12),
            Center(
              child: AnimatedScale(
                scale: _petScale,
                duration: animationDuration,
                curve: Curves.easeOutBack,
                child: Semantics(
                  label: '$_petName, $_moodLabel pet',
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(_moodColor, BlendMode.modulate),
                    child: const Text('🐶', style: TextStyle(fontSize: 120)),
                  ),
                ),
              ),
            ),
            Center(
              child: Chip(
                avatar: Icon(Icons.circle, size: 14, color: _moodColor),
                label: Text('Mood: $_moodLabel'),
              ),
            ),
            if (_reaction.isNotEmpty)
              Center(child: Text(_reaction, style: const TextStyle(fontSize: 34))),
            if (_finished)
              Card(
                color: _hasWon ? Colors.green.shade50 : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _hasWon ? 'You won! Jay stayed happy for three minutes.' : 'Game over. Restart to try again.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            _Meter(label: 'Happiness', value: _happiness, color: Colors.pink),
            _Meter(label: 'Hunger', value: _hunger, color: Colors.orange),
            _Meter(label: 'Energy', value: _energy, color: Colors.blue),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Pet name',
                suffixIcon: IconButton(onPressed: _saveName, icon: const Icon(Icons.check)),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _saveName(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedActivity,
              decoration: const InputDecoration(labelText: 'Activity', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'Play', child: Text('Play')),
                DropdownMenuItem(value: 'Run', child: Text('Run')),
                DropdownMenuItem(value: 'Sleep', child: Text('Sleep')),
              ],
              onChanged: _finished ? null : (value) => setState(() => _selectedActivity = value!),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _finished || _isPaused ? null : _feedPet,
                    icon: const Icon(Icons.restaurant),
                    label: const Text('Feed'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _finished || _isPaused ? null : _doActivity,
                    icon: const Icon(Icons.pets),
                    label: Text(_selectedActivity),
                  ),
                ),
              ],
            ),
            if (_isPaused) const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('Care is paused. Resume when you are ready.', textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}

class _Meter extends StatelessWidget {
  const _Meter({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return Semantics(
      label: '$label: $value out of 100',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(label), Text('$value / 100')],
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value / 100),
              duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 400),
              builder: (context, progress, _) => LinearProgressIndicator(
                value: progress,
                color: color,
                minHeight: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
