import 'dart:js_interop';

@JS('FielBridge')
external _FielBridge get _fielBridge;

@JS()
@staticInterop
class _FielBridge {}

extension _FielBridgeExtension on _FielBridge {
  @JS('getSerialNumber')
  external String? _getSerialNumber(String cerBase64);

  @JS('getRfc')
  external String? _getRfc(String cerBase64);

  @JS('validateKey')
  external bool _validateKey(String keyBase64, String password);

  @JS('signData')
  external String? _signData(
      String keyBase64, String password, String dataToSign);
}

/// Helper class to interact with the JS Cryptography Bridge for VUCEM.
class FielSigner {
  /// Extrae el Número de Serie del Certificado
  static String? getSerialNumber(String cerBase64) {
    return _fielBridge._getSerialNumber(cerBase64);
  }

  /// Extrae el RFC del Certificado
  static String? getRfc(String cerBase64) {
    return _fielBridge._getRfc(cerBase64);
  }

  /// Valida si la contraseña puede desencriptar la llave privada
  static bool validateKey(String keyBase64, String password) {
    return _fielBridge._validateKey(keyBase64, password);
  }

  /// Firma una cadena o XML con la llave privada usando RSA-SHA256
  /// Retorna la firma en Base64
  static String? signData(
      String keyBase64, String password, String dataToSign) {
    return _fielBridge._signData(keyBase64, password, dataToSign);
  }
}
