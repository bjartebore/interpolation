# Interpolation

This library is a port of react-natives Animated interpolation.

```dart
import 'package:interpolation/interpolation.dart'

final interpolate = createInterpolation(
    inputRange: [0, 1],
    outputRange: [0, 100]
);

final result = interpolate(0.5);

```