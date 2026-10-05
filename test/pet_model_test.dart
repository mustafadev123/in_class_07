import 'package:digital_pet/pet_model.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('feed applies bounded state transitions', () {
    final pet = PetGameModel(hunger: 5, happiness: 95, energy: 100);

    pet.feed();

    expect(pet.hunger, 0);
    expect(pet.happiness, 75);
    expect(pet.energy, 100);
  });

  test('all meters remain within bounds', () {
    final pet = PetGameModel(hunger: 100, happiness: 0, energy: 0);

    pet.hungerTick();
    pet.sleep();

    expect(pet.hunger, inInclusiveRange(0, 100));
    expect(pet.happiness, inInclusiveRange(0, 100));
    expect(pet.energy, inInclusiveRange(0, 100));
  });

  test('hunger overflow reduces happiness only after reaching 100', () {
    final pet = PetGameModel(hunger: 95, happiness: 50);

    pet.hungerTick();
    expect(pet.hunger, 100);
    expect(pet.happiness, 50);

    pet.hungerTick();
    expect(pet.hunger, 100);
    expect(pet.happiness, 30);
  });

  test('loss occurs at hunger 100 and happiness 10 or lower', () {
    final pet = PetGameModel(hunger: 100, happiness: 15);

    pet.hungerTick();

    expect(pet.outcome, PetOutcome.lost);
    expect(pet.isFinished, isTrue);
  });

  test('win requires three continuous minutes above 80', () {
    fakeAsync((async) {
      final pet = PetGameModel(happiness: 81);
      var wins = 0;
      final tracker = HighMoodWinTracker(
        duration: const Duration(minutes: 3),
        onWin: () {
          wins++;
          pet.markWon();
        },
      );

      tracker.update(pet);
      async.elapse(const Duration(minutes: 2, seconds: 59));
      expect(wins, 0);

      pet.happiness = 80;
      tracker.update(pet);
      async.elapse(const Duration(seconds: 1));
      expect(wins, 0);

      pet.happiness = 81;
      tracker.update(pet);
      async.elapse(const Duration(minutes: 3));
      expect(wins, 1);
      expect(pet.outcome, PetOutcome.won);
      tracker.dispose();
    });
  });

  test('reset restores meters and clears terminal outcome', () {
    final pet = PetGameModel(hunger: 100, happiness: 5, energy: 0);
    pet.hungerTick();
    expect(pet.outcome, PetOutcome.lost);

    pet.reset(name: 'Jay');

    expect(pet.name, 'Jay');
    expect(pet.happiness, 50);
    expect(pet.hunger, 50);
    expect(pet.energy, 70);
    expect(pet.outcome, PetOutcome.playing);
  });
}
//all my testcases are passing, but I want to add a test case for the sleep function. Can you help me write a test case for that?