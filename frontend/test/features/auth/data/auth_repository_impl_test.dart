import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_todo_app/core/error/failures.dart';
import 'package:smart_todo_app/core/storage/token_storage.dart';
import 'package:smart_todo_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:smart_todo_app/features/auth/data/models/auth_response_model.dart';
import 'package:smart_todo_app/features/auth/data/models/user_model.dart';
import 'package:smart_todo_app/features/auth/data/repositories/auth_repository_impl.dart';

class _MockDataSource extends Mock implements AuthRemoteDataSource {}

class _MockTokenStorage extends Mock implements TokenStorage {}

const _response = AuthResponseModel(
  accessToken: 'acc',
  refreshToken: 'ref',
  expiresIn: 900,
  user: UserModel(id: 'u1', email: 'mario@example.com', displayName: 'Mario'),
);

DioException _dio401() {
  final options = RequestOptions(path: '/api/v1/auth/login');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: options,
      statusCode: 401,
      data: {'message': 'Invalid email or password'},
    ),
  );
}

void main() {
  late _MockDataSource dataSource;
  late _MockTokenStorage tokenStorage;
  late AuthRepositoryImpl repository;

  setUp(() {
    dataSource = _MockDataSource();
    tokenStorage = _MockTokenStorage();
    repository = AuthRepositoryImpl(dataSource, tokenStorage);
    when(() => tokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        )).thenAnswer((_) async {});
    when(() => tokenStorage.clear()).thenAnswer((_) async {});
  });

  test('login stores the token pair and returns the domain user', () async {
    when(() => dataSource.login(email: 'mario@example.com', password: 'pw'))
        .thenAnswer((_) async => _response);

    final user = await repository.login(email: 'mario@example.com', password: 'pw');

    expect(user.email, 'mario@example.com');
    verify(() => tokenStorage.saveTokens(accessToken: 'acc', refreshToken: 'ref'))
        .called(1);
  });

  test('login maps DioException to a Failure with the backend message', () async {
    when(() => dataSource.login(email: any(named: 'email'), password: any(named: 'password')))
        .thenThrow(_dio401());

    await expectLater(
      repository.login(email: 'mario@example.com', password: 'wrong'),
      throwsA(isA<UnauthorizedFailure>()
          .having((f) => f.message, 'message', 'Invalid email or password')),
    );
    verifyNever(() => tokenStorage.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ));
  });

  test('register stores the token pair and returns the domain user', () async {
    when(() => dataSource.register(
          email: 'mario@example.com',
          password: 'pw',
          displayName: 'Mario',
        )).thenAnswer((_) async => _response);

    final user = await repository.register(
        email: 'mario@example.com', password: 'pw', displayName: 'Mario');

    expect(user.displayName, 'Mario');
    verify(() => tokenStorage.saveTokens(accessToken: 'acc', refreshToken: 'ref'))
        .called(1);
  });

  test('hasSession reflects the presence of a stored access token', () async {
    when(() => tokenStorage.readAccessToken()).thenAnswer((_) async => 'acc');
    expect(await repository.hasSession(), isTrue);

    when(() => tokenStorage.readAccessToken()).thenAnswer((_) async => null);
    expect(await repository.hasSession(), isFalse);
  });

  test('logout clears the stored tokens', () async {
    await repository.logout();

    verify(() => tokenStorage.clear()).called(1);
  });
}
