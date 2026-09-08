class XmlSanitizerService {
  static String sanitize(String rawXml) {
    if (rawXml.isEmpty) return "{}";
    
    var cleanXml = rawXml.replaceAll(RegExp('<ds:Signature.*?</ds:Signature>', dotAll: true), '');
    cleanXml = cleanXml.replaceAll(RegExp('xmlns:?[^=]*="[^"]*"'), '');

    final fracciones = _extractTags(cleanXml, 'FraccionArancelaria');
    final descripcion = _extractTags(cleanXml, 'Descripcion');
    final valorAduana = _extractTags(cleanXml, 'ValorAduana');
    final proveedor = _extractTags(cleanXml, 'RazonSocialProveedor');

    final payload = {
      "proveedores": proveedor,
      "mercancia": {
        "fracciones_declaradas": fracciones,
        "descripciones": descripcion,
        "valores_aduanales": valorAduana
      }
    };
    
    return payload.toString();
  }

  static List<String> _extractTags(String xml, String tag) {
    final regex = RegExp('<$tag.*?>([\\s\\S]*?)</$tag>', caseSensitive: false);
    final matches = regex.allMatches(xml);
    return matches.map((m) => m.group(1)?.trim() ?? '').toList();
  }
}
