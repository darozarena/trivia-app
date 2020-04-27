import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:trivia_app/core/network/network_info.dart';

class MockDataConnectionChecker extends Mock implements DataConnectionChecker {}

void main() {
  NetworkInfoImpl networkInfoImpl;
  MockDataConnectionChecker mockDataConnectionChecker;

  setUp(() {
    mockDataConnectionChecker = MockDataConnectionChecker();
    networkInfoImpl = NetworkInfoImpl(mockDataConnectionChecker);
  });

  group('isConnected', () {
    test('Should forward the call to DataConnectionChecker.hasConnection',
        () async {
      final tHasConnectionFuture = Future.value(true);
      // Arrange
      when(mockDataConnectionChecker.hasConnection)
          .thenAnswer((_) => tHasConnectionFuture);
      // Act
      final result = networkInfoImpl.isConnected;
      // Assert
      verify(mockDataConnectionChecker.hasConnection);
      expect(result, tHasConnectionFuture);
    });
  });
}
