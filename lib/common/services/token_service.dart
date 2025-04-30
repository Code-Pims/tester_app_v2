// ignore_for_file: constant_identifier_names

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenService {
  TokenService(this.storage);
  final FlutterSecureStorage storage;

  static const KEY_TOKEN = "access_token";

  Future<void> persistToken(String accessToken) async {
    await storage.write(key: KEY_TOKEN, value: accessToken);
  }

  Future<String?> getToken() async {
    final token = await storage.read(key: KEY_TOKEN);
    return token;
  }

  Future<void> deleteToken() async {
    await storage.delete(key: KEY_TOKEN);
  }
}
