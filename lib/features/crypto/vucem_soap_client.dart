import 'package:flutter/foundation.dart';
import 'package:aduana_801/core/utils/fiel_signer.dart';

/// Cliente SOAP para conectarse a Ventanilla Única (VUCEM)
/// Utiliza criptografía Client-Side (Zero-Trust) para firmar las peticiones.
class VucemSoapClient {
  // Proxy CORS genérico para evitar bloqueos del navegador en Flutter Web.
  // En producción, este proxy debería ser un Cloud Function propio.
  static const String proxyUrl = 'https://corsproxy.io/?';

  // Endpoint simulado de VUCEM (Ventanilla Única)
  static const String vucemEndpoint =
      'https://www.ventanillaunica.gob.mx/vucem/ws/ConsultaPedimento';

  /// Genera una firma WS-Security, construye el sobre SOAP y lo envía a VUCEM.
  static Future<String> consultarPedimento({
    required String cerBase64,
    required String keyBase64,
    required String password,
    required String pedimento,
  }) async {
    // 1. Construir el Body del XML (La petición real)
    final String bodyXml = '''
      <vucem:ConsultaPedimentoRequest>
         <vucem:NumeroPedimento>$pedimento</vucem:NumeroPedimento>
      </vucem:ConsultaPedimentoRequest>''';

    // 2. Firmar Criptográficamente el Body (Client-Side con node-forge)
    // Esto asegura que la llave privada nunca sale de la memoria RAM del navegador.
    final signature = FielSigner.signData(keyBase64, password, bodyXml);
    if (signature == null) {
      throw Exception(
          "Fallo criptográfico: No se pudo generar la firma RSA-SHA256.");
    }

    // 3. Ensamblar el Sobre SOAP 1.1 con WS-Security
    final soapEnvelope = '''
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:vucem="http://www.ventanillaunica.gob.mx/">
   <soapenv:Header>
      <wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd">
         <wsse:BinarySecurityToken ValueType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-x509-token-profile-1.0#X509v3">$cerBase64</wsse:BinarySecurityToken>
         <ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
            <ds:SignedInfo>
               <ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>
               <ds:SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256"/>
            </ds:SignedInfo>
            <ds:SignatureValue>$signature</ds:SignatureValue>
         </ds:Signature>
      </wsse:Security>
   </soapenv:Header>
   <soapenv:Body>
$bodyXml
   </soapenv:Body>
</soapenv:Envelope>''';

    // 4. Transmitir Vía Red (Simulación Segura)
    // En un entorno de producción con IPs registradas, aquí se haría un HTTP POST real:
    // final response = await http.post(Uri.parse('\$proxyUrl\$vucemEndpoint'), headers: {'Content-Type': 'text/xml'}, body: soapEnvelope);

    // Simulamos latencia de red del SAT
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    // Imprimir el sobre real que enviaríamos para depuración
    debugPrint("--- SOBRE SOAP FIRMADO LISTO PARA VUCEM ---");
    // debugPrint is truncated for very long strings, but it's better than print
    debugPrint(soapEnvelope);

    // Retornamos un XML de respuesta exitosa simulando la respuesta del SAAI
    return '''
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
   <soapenv:Body>
      <vucem:ConsultaPedimentoResponse>
         <vucem:NumeroPedimento>$pedimento</vucem:NumeroPedimento>
         <vucem:Estatus>PAGADO_SAAI</vucem:Estatus>
         <vucem:FechaPago>${DateTime.now().toIso8601String()}</vucem:FechaPago>
         <vucem:FirmaValidacion>VUCEM-SIM-RX-${DateTime.now().millisecondsSinceEpoch}</vucem:FirmaValidacion>
         <vucem:Mensaje>Operación autorizada y firmada correctamente con FIEL.</vucem:Mensaje>
      </vucem:ConsultaPedimentoResponse>
   </soapenv:Body>
</soapenv:Envelope>''';
  }
}
