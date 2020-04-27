import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trivia_app/core/util/input_converter.dart';

void main() {
  InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  group('StringToUnsignedInt', () {
    test(
        'Should return an integer when the string represents an unsigned integer',
        () async {
      // Arrange
      final str = '123';
      // Act
      final result = inputConverter.stringToUnsignedInteger(str);
      // Assert
      expect(result, Right(123));
    });
    test('Should return an InvalidInputFailure when the string is not integer',
        () async {
      // Arrange
      final str = 'abc';
      // Act
      final result = inputConverter.stringToUnsignedInteger(str);
      // Assert
      expect(result, Left(InvalidInputFailure()));
    });
    test(
        'Should return an InvalidInputFailure when the string is a negative integer',
        () async {
      // Arrange
      final str = '-123';
      // Act
      final result = inputConverter.stringToUnsignedInteger(str);
      // Assert
      expect(result, Left(InvalidInputFailure()));
    });
  });
}
