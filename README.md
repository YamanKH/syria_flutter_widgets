# syria_flutter_widgets

Reusable Flutter widgets that draw the Syrian flag as a rectangular banner, badge, or animated banner.

## Usage

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  syria_flutter_widgets: ^1.0.0
```

Import the package and use the exported widgets:

```dart
import 'package:syria_flutter_widgets/syria_flutter_widgets.dart';

// ...
AnimatedSyrianFlag(width: 260, height: 150);
SyrianFlag(width: 240, height: 140);
SyrianFlagBadge(diameter: 140);
```

The widgets respect the `waveAmplitude`/`waveFrequency` parameters so you can tune the waving motion (or set them to `0` for a static flag).

## Example

Run the example app to see the widgets in action:

```
flutter run example/lib/main.dart
```

## Publishing

This project is already configured as a publishable package (`lib/syria_flutter_widgets.dart` exports the API and `lib/src/syrian_flag.dart` holds the implementations). Before publishing to pub.dev:

1. Update `CHANGELOG.md` with any changes.
2. Confirm `pubspec.yaml` metadata (version, description, homepage, etc.).
3. Run `flutter pub publish --dry-run`.
4. When ready, run `flutter pub publish` (you must be logged in via `dart pub login` or `flutter pub login`).
