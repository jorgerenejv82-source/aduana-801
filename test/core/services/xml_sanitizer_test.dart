import 'package:flutter_test/flutter_test.dart';
import 'package:aduana_801/core/services/xml_sanitizer_service.dart';

void main() {
  test('removes ds:Signature and xmlns perfectly', () {
    const rawXml = """
      <cfdi:Comprobante xmlns:cfdi="http://www.sat.gob.mx/cfd/4">
        <RazonSocialProveedor>SAMSUNG ELECTRONICS CO.</RazonSocialProveedor>
        <FraccionArancelaria>85171301</FraccionArancelaria>
        <Descripcion>SMARTPHONE GALAXY S24</Descripcion>
        <ValorAduana>15000.50</ValorAduana>
        <ds:Signature>
          MIIGaTCCBFGgAwIBAgIUMzAwMDEwMDAwMDA1MDAwMDM0MTYwDQYJKoZIhvcNAQELBQAwggGyMTgw
        </ds:Signature>
      </cfdi:Comprobante>
    """;

    final sanitized = XmlSanitizerService.sanitize(rawXml);

    expect(sanitized.contains('SAMSUNG'), isTrue);
    expect(sanitized.contains('85171301'), isTrue);
    expect(sanitized.contains('SMARTPHONE'), isTrue);
    expect(sanitized.contains('15000.50'), isTrue);
    expect(sanitized.contains('MIIGaTCCBFGgAwIBAgIUMzAw'), isFalse); // Firma removida
    expect(sanitized.contains('xmlns'), isFalse); // Namespace removido
  });
}
