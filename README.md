# In-Class Activity 07 - Digital Pet

GitHub Repository:
https://github.com/mustafadev123/in_class_07

A stateful Flutter digital pet app built for Mobile Application Development
In-Class Activity 07.

## Contributors

- mustafadev123 - Application development
- rpraneeths - Documentation, testing, and project verification

## Project Description

This project is a stateful Flutter digital pet application.

The application allows users to interact with a virtual pet through actions
such as feeding, playing, running, sleeping, pausing, and resetting. The pet's
happiness, hunger, and energy values change based on user actions and time.

## Architecture and Trade-off

The pet rules are separated from the widget tree in `lib/pet_model.dart`.

`PetGameModel` owns the pet's mutable game data and rules for:

- Feeding
- Playing
- Sleeping
- Hunger changes
- Meter bounds
- Reset
- Winning
- Losing

`HighMoodWinTracker` owns the timed win condition.

The presentation layer in `lib/main.dart` owns:

- Widgets
- Buttons
- Animations
- Mood labels
- `ColorFiltered` tint
- Calls to `setState()`

This separation makes the game rules easier to test without rendering Flutter
widgets. The state-transition tests can verify bounds, reset behavior, and
win/loss outcomes directly against the model.

The trade-off is that the application has more classes and requires some
coordination between the screen and the model. However, this separation makes
the timer and outcome rules clearer and provides a better structure for future
features such as persistence or additional activities.

## Core Features

- Editable pet name
- Happiness meter
- Hunger meter
- Energy meter
- Feed action
- Play/run action
- Sleep action
- Reset action
- Pause/resume
- Derived mood feedback
- Mood tint using `ColorFiltered`
- Accessible mood and meter labels
- Hunger timer
- Three-minute high-mood win condition
- Hunger/happiness loss condition
- Meter values bounded from 0 to 100

## Timed Behavior

The application increases hunger every 30 seconds.

The application also tracks the three-minute high-mood win condition.

Timers are canceled when:

- The game reaches a terminal outcome
- The pet screen is disposed

## Win and Loss Behavior

The application prevents care actions after a terminal outcome.

A win occurs after the required high-mood timer completes.

A loss occurs when hunger reaches 100 and happiness is 10 or lower.

## Visual Polish and Accessibility

The application uses `ColorFiltered` for mood tinting together with a text
mood label so that color is not the only way to communicate the pet's state.

Animated scale and message feedback are used for interaction feedback.

Reduced-motion behavior is supported.

Semantic labels expose the pet mood and meter values.

## Testing

Run the automated tests with:

```bash
flutter test
