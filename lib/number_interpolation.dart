/// Copyright (c) Bjarte Bore <bjarte.bore@gmail.com>
/// Copyright (c) Facebook, Inc. and its affiliates.
///
/// This source code is licensed under the MIT license found in the
/// LICENSE file in the root directory of this source tree.
///
///

enum ExtrapolateType {
  Identity,
  Clamp,
  Extend,
}

typedef Easing = num Function(num number);

final Easing linear = (t) => t;

int _findRange(num input, List<num> inputRange) {
  int i;
  for (i = 1; i < inputRange.length - 1; ++i) {
    if (inputRange[i] >= input) {
      break;
    }
  }
  return i - 1;
}

num Function(num) createInterpolation ({
  required List<num> inputRange,
  required List<num> outputRange ,
  Easing? easing,
  ExtrapolateType extrapolate = ExtrapolateType.Clamp,
  ExtrapolateType? extrapolateLeft,
  ExtrapolateType? extrapolateRight,
}) {
  assert(inputRange.length == outputRange.length, 'inputRange (${inputRange.length}) and outputRange (${outputRange.length}) must have the same length');

  checkInfiniteRange('outputRange', outputRange);
  checkInfiniteRange('inputRange', inputRange);
  checkValidInputRange(inputRange);

  return (num input) {
    final range = _findRange(input, inputRange);
    return _interpolate(
      input,
      inputRange[range],
      inputRange[range + 1],
      outputRange[range],
      outputRange[range + 1],
      easing ?? linear,
      extrapolateLeft ?? extrapolate,
      extrapolateRight ?? extrapolate,
    );
  };
}


num _interpolate(
  num input,
  num inputMin,
  num inputMax,
  num outputMin,
  num outputMax,
  easing,
  ExtrapolateType extrapolateLeft,
  ExtrapolateType extrapolateRight,
) {
  var result = input;

  // Extrapolate
  if (result < inputMin) {
    if (extrapolateLeft == ExtrapolateType.Identity) {
      return result;
    } else if (extrapolateLeft == ExtrapolateType.Clamp) {
      result = inputMin;
    } else if (extrapolateLeft == ExtrapolateType.Extend) {
      // noop
    }
  }

  if (result > inputMax) {
    if (extrapolateRight == ExtrapolateType.Identity) {
      return result;
    } else if (extrapolateRight == ExtrapolateType.Clamp) {
      result = inputMax;
    } else if (extrapolateRight == ExtrapolateType.Extend) {
      // noop
    }
  }

  if (outputMin == outputMax) {
    return outputMin;
  }

  if (inputMin == inputMax) {
    if (input <= inputMin) {
      return outputMin;
    }
    return outputMax;
  }

  // Input Range
  if (inputMin == -double.infinity) {
    result = -result;
  } else if (inputMax == double.infinity) {
    result = result - inputMin;
  } else {
    result = (result - inputMin) / (inputMax - inputMin);
  }

  // Easing
  result = easing(result);

  // Output Range
  if (outputMin == -double.infinity) {
    result = -result;
  } else if (outputMax == double.infinity) {
    result = result + outputMin;
  } else {
    result = result * (outputMax - outputMin) + outputMin;
  }

  return result;
}

void checkValidInputRange(List<num> arr) {
  assert(arr.length >= 2, 'inputRange must have at least 2 elements');
  for (var i = 1; i < arr.length; ++i) {
    assert(
      arr[i] >= arr[i - 1],
      'inputRange must be monotonically non-decreasing $arr',
    );
  }
}

void checkInfiniteRange(String name, List<num> arr) {
  assert(arr.length >= 2, name + ' must have at least 2 elements');
  assert(
    arr.length != 2 || arr[0] != -double.infinity || arr[1] != double.infinity,
    name + 'cannot be ]-infinity;+infinity[ $arr',
  );
}