import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trivia_app/core/error/failures.dart';
import 'package:trivia_app/core/usecases/usecase.dart';
import 'package:trivia_app/core/util/input_converter.dart';
import 'package:trivia_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:trivia_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:trivia_app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:trivia_app/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  NumberTriviaBloc bloc;
  MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      concrete: mockGetConcreteNumberTrivia,
      random: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  test('InitialState should be empty', () async {
    // Assert
    expect(bloc.initialState, Empty());
  });

  group('GetTriviaForConcreteNumber', () {
    final tNumberString = '1';
    final tNumberParsed = 1;
    final tNumberTrivia = NumberTrivia(text: 'Test', number: 1);

    void setUpMockInputConverterSuccess() =>
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(Right(tNumberParsed));
    test(
        'Should call the InputConverter to validate and convert the string to an unsigned integer',
        () async {
      // Arrange
      setUpMockInputConverterSuccess();
      // Act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockInputConverter.stringToUnsignedInteger(any));
      // Assert
      verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
    });
    test('Should emit [Error] when the input is invalid', () async {
      // Arrange
      when(mockInputConverter.stringToUnsignedInteger(any))
          .thenReturn(Left(InvalidInputFailure()));
      // Assert later
      final expected = [
        Empty(),
        Error(message: INVALID_INPUT_FAILURE_MESSAGE),
      ];
      expectLater(bloc, emitsInOrder(expected));
      // Act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });
    test('Should get data for the concrete use case', () async {
      // Arrange
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));
      // Act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockGetConcreteNumberTrivia(any));
      // Assert
      verify(mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
    });
    test('Should emit [Loading, Loaded] when data is gotten successfully',
        () async {
      // Arrange
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));
      // Assert later
      final expected = [
        Empty(),
        Loading(),
        Loaded(numberTrivia: tNumberTrivia)
      ];
      expectLater(bloc, emitsInOrder(expected));
      // Act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });
    test('Should emit [Loading, Error] when getting data fails', () async {
      // Arrange
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Left(ServerFailure()));
      // Assert later
      final expected = [
        Empty(),
        Loading(),
        Error(message: SERVER_FAILURE_MESSAGE)
      ];
      expectLater(bloc, emitsInOrder(expected));
      // Act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });
    test(
        'Should emit [Loading, Error] with a proper message for the error when getting data fails',
        () async {
      // Arrange
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Left(CacheFailure()));
      // Assert later
      final expected = [
        Empty(),
        Loading(),
        Error(message: CACHE_FAILURE_MESSAGE)
      ];
      expectLater(bloc, emitsInOrder(expected));
      // Act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });
  });

  group('GetTriviaForRandomNumber', () {
    final tNumberTrivia = NumberTrivia(text: 'Test', number: 1);

    test('Should get data for the random use case', () async {
      // Arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));
      // Act
      bloc.add(GetTriviaForRandomNumber());
      await untilCalled(mockGetRandomNumberTrivia(any));
      // Assert
      verify(mockGetRandomNumberTrivia(NoParams()));
    });
    test('Should emit [Loading, Loaded] when data is gotten successfully',
        () async {
      // Arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));
      // Assert later
      final expected = [
        Empty(),
        Loading(),
        Loaded(numberTrivia: tNumberTrivia)
      ];
      expectLater(bloc, emitsInOrder(expected));
      // Act
      bloc.add(GetTriviaForRandomNumber());
    });
    test('Should emit [Loading, Error] when getting data fails', () async {
      // Arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Left(ServerFailure()));
      // Assert later
      final expected = [
        Empty(),
        Loading(),
        Error(message: SERVER_FAILURE_MESSAGE)
      ];
      expectLater(bloc, emitsInOrder(expected));
      // Act
      bloc.add(GetTriviaForRandomNumber());
    });
    test(
        'Should emit [Loading, Error] with a proper message for the error when getting data fails',
        () async {
      // Arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Left(CacheFailure()));
      // Assert later
      final expected = [
        Empty(),
        Loading(),
        Error(message: CACHE_FAILURE_MESSAGE)
      ];
      expectLater(bloc, emitsInOrder(expected));
      // Act
      bloc.add(GetTriviaForRandomNumber());
    });
  });
}
