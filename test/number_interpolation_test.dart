/// Copyright (c) Bjarte Bore <bjarte.bore@gmail.com>
/// Copyright (c) Facebook, Inc. and its affiliates.
///
/// This source code is licensed under the MIT license found in the
/// LICENSE file in the root directory of this source tree.
///

import 'package:number_interpolation/number_interpolation.dart';
import 'package:test/test.dart';

double _quad(double t) => t * t;

void main() {

  group('Interpolation', () {
    test('should work with defaults', () {
      final interpolation = createInterpolation(
        inputRange: [0, 1],
        outputRange: [0, 1],
      );

      expect(interpolation(0), 0);
      expect(interpolation(0.5), 0.5);
      expect(interpolation(0.8), 0.8);
      expect(interpolation(1), 1);
    });


    test('should work with output range', () {
      final interpolation = createInterpolation(
        inputRange: [0, 1],
        outputRange: [100, 200],
      );

      expect(interpolation(0), 100);
      expect(interpolation(0.5), 150);
      expect(interpolation(0.8), 180);
      expect(interpolation(1), 200);
    });

    test('should work with input range', () {
      final interpolation = createInterpolation(
        inputRange: [100, 200],
        outputRange: [0, 1],
      );

      expect(interpolation(100), 0);
      expect(interpolation(150), 0.5);
      expect(interpolation(180), 0.8);
      expect(interpolation(200), 1);
    });

    test('should throw for non monotonic input ranges', () {
      expect(() => createInterpolation(
          inputRange: [0, 2, 1],
          outputRange: [0, 1, 2],
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(() =>
        createInterpolation(
          inputRange: [0, 1, 2],
          outputRange: [0, 3, 1],
        ),
        returnsNormally,
      );
    });

    test('should work with empty input range', () {
      final interpolation = createInterpolation(
        inputRange: [0, 10, 10],
        outputRange: [1, 2, 3],
        extrapolate: ExtrapolateType.Extend,
      );

      expect(interpolation(0), 1);
      expect(interpolation(5), 1.5);
      expect(interpolation(10), 2);
      expect(interpolation(10.1), 3);
      expect(interpolation(15), 3);
    });

    test('should work with empty output range', () {
      final interpolation = createInterpolation(
        inputRange: [1, 2, 3],
        outputRange: [0, 10, 10],
        extrapolate: ExtrapolateType.Extend
      );

      expect(interpolation(0), -10);
      expect(interpolation(1.5), 5);
      expect(interpolation(2), 10);
      expect(interpolation(2.5), 10);
      expect(interpolation(3), 10);
      expect(interpolation(4), 10);
    });

    test('should work with easing', () {
      final interpolation = createInterpolation(
        inputRange: [0, 1],
        outputRange: [0, 1],
        easing: _quad,
      );

      expect(interpolation(0), 0);
      expect(interpolation(0.5), 0.25);
      expect(interpolation(0.9), 0.81);
      expect(interpolation(1), 1);
    });

    test('should work with extrapolate', () {
      var interpolation = createInterpolation(
        inputRange: [0, 1],
        outputRange: [0, 1],
        extrapolate: ExtrapolateType.Extend,
        easing: _quad,
      );

      expect(interpolation(-2), 4);
      expect(interpolation(2), 4);

      interpolation = createInterpolation(
        inputRange: [0, 1],
        outputRange: [0, 1],
        extrapolate: ExtrapolateType.Clamp,
        easing: _quad,
      );

      expect(interpolation(-2), 0);
      expect(interpolation(2), 1);

      interpolation = createInterpolation(
        inputRange: [0, 1],
        outputRange: [0, 1],
        extrapolate: ExtrapolateType.Identity,
        easing: _quad,
      );

      expect(interpolation(-2), -2);
      expect(interpolation(2), 2);
    });

    test('should work with keyframes with extrapolate', () {
      final interpolation = createInterpolation(
        inputRange: [0, 10, 100, 1000],
        outputRange: [0, 5, 50, 500],
        extrapolate: ExtrapolateType.Extend,
      );

      expect(interpolation(-5), -2.5);
      expect(interpolation(0), 0);
      expect(interpolation(5), 2.5);
      expect(interpolation(10), 5);
      expect(interpolation(50), 25);
      expect(interpolation(100), 50);
      expect(interpolation(500), 250);
      expect(interpolation(1000), 500);
      expect(interpolation(2000), 1000);
    });

    test('should work with keyframes without extrapolate', () {
      final interpolation = createInterpolation(
        inputRange: [0, 1, 2],
        outputRange: [0.2, 1, 0.2],
        extrapolate: ExtrapolateType.Clamp,
      );

      expect(interpolation(5), closeTo(0.2, 0.05));
    });

    test('should throw for an infinite input range', () {
      expect(() =>
        createInterpolation(
          inputRange: [-double.infinity, double.infinity],
          outputRange: [0, 1],
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(() =>
        createInterpolation(
          inputRange: [-double.infinity, 0, double.infinity],
          outputRange: [1, 2, 3],
        ),
        returnsNormally,
      );
    });

    test('should work with negative infinite', () {
      final interpolation = createInterpolation(
        inputRange: [-double.infinity, 0],
        outputRange: [-double.infinity, 0],
        easing: _quad,
        extrapolate: ExtrapolateType.Identity,
      );

      expect(interpolation(-double.infinity), -double.infinity);

      expect(interpolation(-100), -10000);
      expect(interpolation(-10), -100);
      expect(interpolation(0), 0);
      expect(interpolation(1), 1);
      expect(interpolation(100), 100);
    });

    test('should work with positive infinite', () {
      final interpolation = createInterpolation(
        inputRange: [5, double.infinity],
        outputRange: [5, double.infinity],
        easing: _quad,
        extrapolate: ExtrapolateType.Identity,
      );

      expect(interpolation(-100), -100);
      expect(interpolation(-10), -10);
      expect(interpolation(0), 0);
      expect(interpolation(5), 5);
      expect(interpolation(6), 5 + 1);
      expect(interpolation(10), 5 + 25);
      expect(interpolation(100), 5 + 95 * 95);
      expect(interpolation(double.infinity), double.infinity);
    });
  });

}