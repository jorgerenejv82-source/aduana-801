import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import '../models/audit_report.dart';

class AIAuditorService {
  late final GenerativeModel _primaryModel;
  late final GenerativeModel _fallbackModel;

  AIAuditorService() {
    final auditSchema = Schema.object(
      properties: {
        'riskLevel': Schema.string(description: 'El nivel de riesgo detectado. Puede ser low, medium o high.', nullable: false),
        'discrepancies': Schema.array(items: Schema.string(), description: 'Lista de discrepancias encontradas.'),
        'semanticAnomalies': Schema.array(items: Schema.string(), description: 'Lista de anomalias semanticas.'),
        'potentialFinesUSD': Schema.number(description: 'Monto estimado de multas en dolares (USD).'),
        'summary': Schema.string(description: 'Resumen gerencial de la auditoria.', nullable: false),
      },
    );

    final config = GenerationConfig(
      responseMimeType: 'application/json',
      responseSchema: auditSchema,
      temperature: 0.1, 
      topK: 1,
    );

    final systemInstruction = Content.system(
      'Eres el Auditor Jefe del SAT en Mexico. Se te entregara el payload JSON extraido de un XML de un pedimento aduanal. '
      'Tu tarea es buscar discrepancias logicas, semanticas y regulatorias. '
      'Evalua con severidad, piensa paso a paso (Chain of Thought), y finalmente '
      'retorna el resultado adherido estrictamente al schema JSON.'
    );

    _primaryModel = FirebaseAI.vertexAI().generativeModel(
      model: 'gemini-1.5-flash', 
      generationConfig: config,
      systemInstruction: systemInstruction,
    );

    _fallbackModel = FirebaseAI.vertexAI().generativeModel(
      model: 'gemini-1.5-flash-8b', 
      generationConfig: config,
      systemInstruction: systemInstruction,
    );
  }

  Stream<String> analyzePedimentoStream(String sanitizedXmlJson) async* {
    final String prompt = 'Analiza el siguiente pedimento aduanal. Encuentra discrepancias arancelarias, subvaluaciones, anomalias semanticas y calcula posibles multas. Datos del pedimento:\n\n$sanitizedXmlJson';
    
    try {
      final stream = _primaryModel.generateContentStream([Content.text(prompt)]);
      await for (final chunk in stream) {
        yield chunk.text ?? '';
      }
    } catch (e) {
      try {
        final streamFallback = _fallbackModel.generateContentStream([Content.text(prompt)]);
        await for (final chunk in streamFallback) {
          yield chunk.text ?? '';
        }
      } catch (fallbackError) {
        final errorJson = jsonEncode({
          "riskLevel": "high",
          "discrepancies": ["Fallo en los motores de IA primaria y secundaria."],
          "semanticAnomalies": [e.toString()],
          "potentialFinesUSD": 0,
          "summary": "Error fatal de conexion con los motores Gemini."
        });
        yield errorJson;
      }
    }
  }

  AuditReport parseResponse(String fullJsonString) {
    try {
      final cleaned = fullJsonString.replaceAll('```json', '').replaceAll('```', '').trim();
      final decoded = jsonDecode(cleaned) as Map<String, dynamic>;
      return AuditReport.fromJson(decoded);
    } catch (e) {
      return AuditReport(
        riskLevel: 'high',
        discrepancies: ['Error de parseo del Dictamen de IA'],
        semanticAnomalies: [e.toString()],
        potentialFinesUSD: 0.0,
        summary: 'La IA devolvio una estructura corrupta.',
      );
    }
  }
}
