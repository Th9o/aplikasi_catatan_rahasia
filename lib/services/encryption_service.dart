import 'package:encrypt/encrypt.dart';
import 'dart:convert';

class EncryptionService {
  // Gunakan kunci AES 32 byte (256 bit)
  static final _key = Key.fromUtf8(
    'my32lengthsupersecretnooneknows!',
  ); // Panjang harus 32 karakter
  static final _iv = IV.fromLength(16); // IV statis: tidak aman untuk produksi

  final _encrypter = Encrypter(AES(_key));

  Future<String> encrypt(String plainText) async {
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  Future<String> decrypt(String encryptedText) async {
    final decrypted = _encrypter.decrypt64(encryptedText, iv: _iv);
    return decrypted;
  }
}
