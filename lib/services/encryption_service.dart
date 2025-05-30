import 'package:encrypt/encrypt.dart';

class EncryptionService {
  static final _key = Key.fromUtf8('my32lengthsupersecretnooneknows!');
  final _encrypter = Encrypter(AES(_key));

  Future<Map<String, String>> encrypt(String plainText) async {
    final iv = IV.fromSecureRandom(16);
    final encrypted = _encrypter.encrypt(plainText, iv: iv);
    return {'content': encrypted.base64, 'iv': iv.base64};
  }

  Future<String> decrypt(String encryptedText, String base64IV) async {
    final iv = IV.fromBase64(base64IV);
    return _encrypter.decrypt64(encryptedText, iv: iv);
  }
}
