import 'package:flutter_test/flutter_test.dart';
import 'package:smart_todo_app/features/auth/data/models/auth_response_model.dart';

void main() {
  test('AuthResponseModel round-trips the backend JSON contract', () {
    final json = {
      'accessToken': 'acc',
      'refreshToken': 'ref',
      'expiresIn': 900,
      'user': {
        'id': 'b6c0f9a2-0000-0000-0000-000000000001',
        'email': 'mario@example.com',
        'displayName': 'Mario',
      },
    };

    final model = AuthResponseModel.fromJson(json);

    expect(model.accessToken, 'acc');
    expect(model.refreshToken, 'ref');
    expect(model.expiresIn, 900);
    expect(model.user.email, 'mario@example.com');
    expect(model.toJson(), json);
  });

  test('UserModel maps to the domain entity', () {
    final json = {
      'accessToken': 'acc',
      'refreshToken': 'ref',
      'expiresIn': 900,
      'user': {
        'id': 'b6c0f9a2-0000-0000-0000-000000000001',
        'email': 'mario@example.com',
        'displayName': 'Mario',
      },
    };

    final user = AuthResponseModel.fromJson(json).user.toEntity();

    expect(user.id, 'b6c0f9a2-0000-0000-0000-000000000001');
    expect(user.displayName, 'Mario');
  });
}
