import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Future<List<User>> getAll() async {
    final r = await _api.get('/users');
    final body = _api.decode(r);
    return _parse('users', () {
      return (body as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<User> getById(int id) async {
    final r = await _api.get('/users/$id');
    final body = _api.decode(r);
    return _parse(
      'users/$id',
      () => User.fromJson(body as Map<String, dynamic>),
    );
  }

  Future<User> create(User draft) async {
    final payload = draft.toJson()..remove('id');
    final http.Response r = await _api.post('/users', payload);
    if (r.statusCode != 201) {
      throw BadResponseException(
        'POST users: expected 201, got ${r.statusCode}',
      );
    }
    final body = _api.decode(r);
    return _parse(
      'POST users',
      () => User.fromJson(body as Map<String, dynamic>),
    );
  }

  T _parse<T>(String what, T Function() build) {
    try {
      return build();
    } on TypeError catch (e) {
      throw BadResponseException('$what: $e');
    } on FormatException catch (e) {
      throw BadResponseException('$what: $e');
    }
  }
}
