import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_response_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(authRemoteDataSourceProvider),
    ref.read(tokenStorageProvider),
  );
});

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource, this._tokenStorage);

  final AuthRemoteDataSource _dataSource;
  final TokenStorage _tokenStorage;

  @override
  Future<User> register({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _authenticate(() => _dataSource.register(
        email: email, password: password, displayName: displayName));
  }

  @override
  Future<User> login({required String email, required String password}) {
    return _authenticate(() => _dataSource.login(email: email, password: password));
  }

  @override
  Future<bool> hasSession() async {
    return await _tokenStorage.readAccessToken() != null;
  }

  @override
  Future<void> logout() => _tokenStorage.clear();

  Future<User> _authenticate(Future<AuthResponseModel> Function() call) async {
    try {
      final response = await call();
      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      return response.user.toEntity();
    } on DioException catch (e) {
      throw Failure.fromDio(e);
    }
  }
}
