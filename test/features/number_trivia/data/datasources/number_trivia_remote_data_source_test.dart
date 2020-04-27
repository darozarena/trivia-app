import 'dart:convert';

import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trivia_app/core/error/exceptions.dart';
import 'package:trivia_app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:trivia_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:matcher/matcher.dart' as matcher;
import 'package:http/http.dart' as http;

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  NumberTriviaRemoteDataSourceImpl dataSource;
  MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  void setUpMockHttpClientSuccess() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFailure() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(fixture('trivia.json')));
    test('''Should perform a GET request on an URL with number
         being the endpoint and with application/json header''', () async {
      // Arrange
      setUpMockHttpClientSuccess();
      // Act
      dataSource.getConcreteNumberTrivia(tNumber);
      // Assert
      verify(mockHttpClient.get(
        'http://numbersapi.com/$tNumber',
        headers: {
          'Content-Type': 'application/json',
        },
      ));
    });
    test('Should return NumberTrivia when the response code is 200 (success)',
        () async {
      // Arrange
      setUpMockHttpClientSuccess();
      // Act
      final result = await dataSource.getConcreteNumberTrivia(tNumber);
      // Assert
      expect(result, tNumberTriviaModel);
    });
    test('Should throw ServerException when the response code is 404 or other',
        () async {
      // Arrange
      setUpMockHttpClientFailure();
      // Act
      final call = dataSource.getConcreteNumberTrivia;
      // Assert
      expect(
          () => call(tNumber), throwsA(matcher.TypeMatcher<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(fixture('trivia.json')));
    test('''Should perform a GET request on an URL with random
         being the endpoint and with application/json header''', () async {
      // Arrange
      setUpMockHttpClientSuccess();
      // Act
      dataSource.getRandomNumberTrivia();
      // Assert
      verify(mockHttpClient.get(
        'http://numbersapi.com/random',
        headers: {
          'Content-Type': 'application/json',
        },
      ));
    });
    test('Should return NumberTrivia when the response code is 200 (success)',
        () async {
      // Arrange
      setUpMockHttpClientSuccess();
      // Act
      final result = await dataSource.getRandomNumberTrivia();
      // Assert
      expect(result, tNumberTriviaModel);
    });
    test('Should throw ServerException when the response code is 404 or other',
        () async {
      // Arrange
      setUpMockHttpClientFailure();
      // Act
      final call = dataSource.getRandomNumberTrivia;
      // Assert
      expect(() => call(), throwsA(matcher.TypeMatcher<ServerException>()));
    });
  });
}
