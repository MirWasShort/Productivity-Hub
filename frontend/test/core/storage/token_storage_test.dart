import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_todo_app/core/storage/token_storage.dart';

class _MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockSecureStorage secureStorage;
  late TokenStorage tokenStorage;

  setUp(() {
    secureStorage = _MockSecureStorage();
    tokenStorage = TokenStorage(secureStorage);
    when(() => secureStorage.write(key: any(named: 'key'), value: any(named: 'value')))
        .thenAnswer((_) async {});
    when(() => secureStorage.delete(key: any(named: 'key'))).thenAnswer((_) async {});
  });

  test('saveTokens writes both tokens', () async {
    await tokenStorage.saveTokens(accessToken: 'acc', refreshToken: 'ref');

    verify(() => secureStorage.write(key: 'access_token', value: 'acc')).called(1);
    verify(() => secureStorage.write(key: 'refresh_token', value: 'ref')).called(1);
  });

  test('readAccessToken returns the stored value', () async {
    when(() => secureStorage.read(key: 'access_token')).thenAnswer((_) async => 'acc');

    expect(await tokenStorage.readAccessToken(), 'acc');
  });

  test('readRefreshToken returns null when nothing stored', () async {
    when(() => secureStorage.read(key: 'refresh_token')).thenAnswer((_) async => null);

    expect(await tokenStorage.readRefreshToken(), isNull);
  });

  test('clear deletes both tokens', () async {
    await tokenStorage.clear();

    verify(() => secureStorage.delete(key: 'access_token')).called(1);
    verify(() => secureStorage.delete(key: 'refresh_token')).called(1);
  });
}
