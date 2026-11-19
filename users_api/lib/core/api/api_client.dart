import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'});

  final http.Client _client;
  final String host;

  Map<String, String> get _headers => const {'Accept': 'application/json'};

  Future<http.Response> get(String path, {Map<String, String>? query}) async {
    final r = await _send(
      () => _client.get(Uri.https(host, path, query), headers: _headers),
    );
    _check(r);
    return r;
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final r = await _send(
      () => _client.post(
        Uri.https(host, path),
        headers: {..._headers, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ),
    );
    _check(r);
    return r;
  }

  dynamic decode(http.Response r) {
    try {
      return jsonDecode(r.body);
    } on FormatException catch (e) {
      throw BadResponseException('not JSON: ${e.message}');
    }
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final r = await call().timeout(const Duration(seconds: 10));
      if (kDebugMode) {
        log(
          '${r.request?.method} ${r.request?.url} -> ${r.statusCode} '
          '(${r.bodyBytes.length} B)',
          name: 'api',
        );
      }
      return r;
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    }
  }

  void _check(http.Response r) {
    final s = r.statusCode;
    if (s == 401) throw const UnauthorizedException();
    if (s == 404) throw const NotFoundException();
    if (s >= 500) throw ServerException(s);
  }
}
