// Puente Criptográfico para VUCEM FIEL usando node-forge
// Se comunica con Dart a través de JS Interop.

window.FielBridge = {
  // 1. Extraer Número de Serie del Certificado
  getSerialNumber: function(cerBase64) {
    try {
      const der = forge.util.decode64(cerBase64);
      const asn1 = forge.asn1.fromDer(der);
      const cert = forge.pki.certificateFromAsn1(asn1);
      // El número de serie del SAT viene en hexadecimal, algunas veces hay que parsearlo.
      let hex = cert.serialNumber;
      
      // Convertir Hex a String ASCII (El SAT usa el string ASCII como número de serie real)
      let str = '';
      for (let i = 0; i < hex.length; i += 2) {
        str += String.fromCharCode(parseInt(hex.substr(i, 2), 16));
      }
      return str;
    } catch (e) {
      console.error("Error leyendo .cer", e);
      return null;
    }
  },

  // 2. Extraer RFC del Certificado
  getRfc: function(cerBase64) {
    try {
      const der = forge.util.decode64(cerBase64);
      const asn1 = forge.asn1.fromDer(der);
      const cert = forge.pki.certificateFromAsn1(asn1);
      
      // En los certificados del SAT, el OID 2.5.4.45 (x500UniqueIdentifier) contiene el RFC
      let rfc = null;
      cert.subject.attributes.forEach(attr => {
        if (attr.type === '2.5.4.45' || attr.name === 'x500UniqueIdentifier') {
          rfc = attr.value;
        }
      });
      return rfc;
    } catch (e) {
      console.error("Error extrayendo RFC", e);
      return null;
    }
  },

  // 3. Validar y Desencriptar la Llave Privada
  validateKey: function(keyBase64, password) {
    try {
      const der = forge.util.decode64(keyBase64);
      const asn1 = forge.asn1.fromDer(der);
      // Intentar desencriptar con PBKDF2 (estándar del SAT)
      const privateKey = forge.pki.decryptRsaPrivateKey(asn1, password);
      return privateKey !== null;
    } catch (e) {
      console.error("Contraseña incorrecta o archivo inválido", e);
      return false;
    }
  },

  // 4. Firmar cadena original o XML
  signData: function(keyBase64, password, dataToSign) {
    try {
      const der = forge.util.decode64(keyBase64);
      const asn1 = forge.asn1.fromDer(der);
      const privateKey = forge.pki.decryptRsaPrivateKey(asn1, password);
      
      if (!privateKey) throw new Error("Llave incorrecta");

      // El SAT normalmente requiere SHA-256 para VUCEM y web services modernos
      const md = forge.md.sha256.create();
      md.update(dataToSign, 'utf8');
      
      const signature = privateKey.sign(md);
      return forge.util.encode64(signature);
    } catch (e) {
      console.error("Error al firmar", e);
      return null;
    }
  }
};
