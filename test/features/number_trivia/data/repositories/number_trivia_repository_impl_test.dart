import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trivia_app/core/error/exceptions.dart';
import 'package:trivia_app/core/error/failures.dart';
import 'package:trivia_app/core/network/network_info.dart';
import 'package:trivia_app/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:trivia_app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:trivia_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:trivia_app/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:trivia_app/features/number_trivia/domain/entities/number_trivia.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  NumberTriviaRepositoryImpl repository;
  MockRemoteDataSource mockRemoteDataSource;
  MockLocalDataSource mockLocalDataSource;
  MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('Device is online', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  void runTestsOffline(Function body) {
    group('Device is offline', () {
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel(text: 'Test', number: tNumber);
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test('Should check if the device is online', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      // Act
      repository.getConcreteNumberTrivia(tNumber);
      // Assert
      verify(mockNetworkInfo.isConnected);
    });
    runTestsOnline(() {
      test(
          'Should return data when the call to remote data source is successful',
          () async {
        // Arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenAnswer((_) async => tNumberTriviaModel);
        // Act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // Assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        expect(result, Right(tNumberTrivia));
      });
      test(
          'Should cache the data locally when the call to remote data source is successful',
          () async {
        // Arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenAnswer((_) async => tNumberTriviaModel);
        // Act
        await repository.getConcreteNumberTrivia(tNumber);
        // Assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
      });
      test(
          'Should return ServerFailure when the call to remote data source is unsuccessful',
          () async {
        // Arrange
        when(mockRemoteDataSource.getConcreteNumberTrivia(any))
            .thenThrow(ServerException());
        // Act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // Assert
        verify(mockRemoteDataSource.getConcreteNumberTrivia(tNumber));
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, Left(ServerFailure()));
      });
    });
    runTestsOffline(() {
      test(
          'Should return last locally cache data when the cache data is present',
          () async {
        // Arrange
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        // Act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // Assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, Right(tNumberTrivia));
      });
      test('Should return CacheFailure when there is not cached data present',
          () async {
        // Arrange
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());
        // Act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        // Assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, Left(CacheFailure()));
      });
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(text: 'Test', number: 123);
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test('Should check if the device is online', () async {
      // Arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      // Act
      repository.getRandomNumberTrivia();
      // Assert
      verify(mockNetworkInfo.isConnected);
    });
    runTestsOnline(() {
      test(
          'Should return data when the call to remote data source is successful',
          () async {
        // Arrange
        when(mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        // Act
        final result = await repository.getRandomNumberTrivia();
        // Assert
        verify(mockRemoteDataSource.getRandomNumberTrivia());
        expect(result, Right(tNumberTrivia));
      });
      test(
          'Should cache the data locally when the call to remote data source is successful',
          () async {
        // Arrange
        when(mockRemoteDataSource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        // Act
        await repository.getRandomNumberTrivia();
        // Assert
        verify(mockRemoteDataSource.getRandomNumberTrivia());
        verify(mockLocalDataSource.cacheNumberTrivia(tNumberTriviaModel));
      });
      test(
          'Should return ServerFailure when the call to remote data source is unsuccessful',
          () async {
        // Arrange
        when(mockRemoteDataSource.getRandomNumberTrivia())
            .thenThrow(ServerException());
        // Act
        final result = await repository.getRandomNumberTrivia();
        // Assert
        verify(mockRemoteDataSource.getRandomNumberTrivia());
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, Left(ServerFailure()));
      });
    });
    runTestsOffline(() {
      test(
          'Should return last locally cache data when the cache data is present',
          () async {
        // Arrange
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        // Act
        final result = await repository.getRandomNumberTrivia();
        // Assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, Right(tNumberTrivia));
      });
      test('Should return CacheFailure when there is not cached data present',
          () async {
        // Arrange
        when(mockLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());
        // Act
        final result = await repository.getRandomNumberTrivia();
        // Assert
        verifyZeroInteractions(mockRemoteDataSource);
        verify(mockLocalDataSource.getLastNumberTrivia());
        expect(result, Left(CacheFailure()));
      });
    });
  });
}
