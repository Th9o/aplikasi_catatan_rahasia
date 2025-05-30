import 'package:encrypt/encrypt.dart';

class EncryptionService {
  // ✅ Kunci AES 32 karakter (256-bit)
  static final _key = Key.fromUtf8('my32lengthsupersecretnooneknows!');
  static final _iv = IV.fromLength(16); // IV tetap

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
