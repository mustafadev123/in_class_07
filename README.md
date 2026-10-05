# in_class_07

# githuburl
https://github.com/mustafadev123/in_class_07

A stateful Flutter digital pet app.

## Architecture and trade-off

I separated the pet rules from the widget tree in [`lib/pet_model.dart`](lib/pet_model.dart). `PetGameModel` owns the pet's mutable game data and rules for feeding, playing, sleeping, hunger ticks, meter bounds, reset, winning, and losing. `HighMoodWinTracker` owns the timed win condition. The presentation layer in [`lib/main.dart`](lib/main.dart) owns the widgets, buttons, animations, mood labels, `ColorFiltered` tint, and calls to `setState()`.

This boundary makes the game rules easier to test without rendering Flutter widgets, which is why the state-transition tests can verify bounds, reset behavior, and win/loss outcomes directly against the model. The trade-off is that the app has more classes and some state coordination between the screen and the model, so a very small prototype could be shorter with all logic in the widget. I chose the separation because it makes the timer and outcome rules clearer and gives the app a cleaner path for future features such as persistence or additional activities.

## Evidence and verification

The required implementation evidence passed for the submitted app:

- Core care loop: feed, play/run, sleep, reset, pause/resume, editable pet name, and derived mood feedback are implemented in [`lib/main.dart`](lib/main.dart).
- Bounded state: happiness, hunger, and energy are clamped to `0..100` in [`lib/pet_model.dart`](lib/pet_model.dart).
- Timed behavior: hunger changes every 30 seconds, the three-minute high-mood win condition is tracked separately, and timers are canceled on terminal outcomes and screen disposal.
- Win/loss behavior: the model prevents actions after a terminal outcome, marks a win only after the high-mood timer completes, and marks a loss when hunger is full and happiness is `10` or lower.
- Visual polish and accessibility: mood tint uses `ColorFiltered` together with a text mood label, animated scale/message feedback supports reduced motion, and semantic labels expose the pet mood and meter values.
- Automated tests: `flutter test` passed with 8 tests covering feed transitions, meter bounds, hunger overflow, loss, the three-minute win, reset, screen rendering, and feeding feedback.
- Release artifact: the release APK was built at `build/app/outputs/flutter-apk/app-release.apk`.
