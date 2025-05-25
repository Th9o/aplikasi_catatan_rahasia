import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static const _keyStorageKey = 'encryption_key';
  final _secureStorage = const FlutterSecureStorage();

  Future<Encrypter> _getEncrypter() async {
    String? base64Key = await _secureStorage.read(key: _keyStorageKey);

    if (base64Key == null) {
      final key = Key.fromSecureRandom(32);
      base64Key = base64.encode(key.bytes);
      await _secureStorage.write(key: _keyStorageKey, value: base64Key);
    }

    final key = Key(base64.decode(base64Key));
    final iv = IV.fromLength(
      16,
    ); // gunakan IV default (bisa juga simpan per catatan)

    return Encrypter(AES(key));
  }

  Future<String> encrypt(String plainText) async {
    final encrypter = await _getEncrypter();
    final iv = IV.fromLength(16);
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return encrypted.base64;
  }

  Future<String> decrypt(String encryptedText) async {
    final encrypter = await _getEncrypter();
    final iv = IV.fromLength(16);
    final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
    return decrypted;
  }
}
