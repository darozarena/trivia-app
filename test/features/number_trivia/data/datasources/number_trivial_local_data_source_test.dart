import 'dart:convert';

import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trivia_app/core/error/exceptions.dart';
import 'package:trivia_app/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:trivia_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:matcher/matcher.dart' as matcher;

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  NumberTriviaLocalDataSourceImpl dataSource;
  MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(
        sharedPreferences: mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(fixture('trivia_cached.json')));
    test(
        'Should return NumberTrivia from SharedPreferences when there is one in the cache',
        () async {
      // Arrange
      when(mockSharedPreferences.getString(any))
          .thenReturn(fixture('trivia_cached.json'));
      // Act
      final result = await dataSource.getLastNumberTrivia();
      // Assert
      verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
      expect(result, tNumberTriviaModel);
    });
    test('Should throw CacheException when there is not a cached value',
        () async {
      // Arrange
      when(mockSharedPreferences.getString(any)).thenReturn(null);
      // Act
      final call = dataSource.getLastNumberTrivia;
      // Assert
      expect(() => call(), throwsA(matcher.TypeMatcher<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(text: 'Test', number: 1);
    test('Should call SharedPreferences to cache the data', () async {
      // Act
      dataSource.cacheNumberTrivia(tNumberTriviaModel);
      // Assert
      final expectedJsonString = jsonEncode(tNumberTriviaModel.toJson());
      verify(mockSharedPreferences.setString(
          CACHED_NUMBER_TRIVIA, expectedJsonString));
    });
  });
}
