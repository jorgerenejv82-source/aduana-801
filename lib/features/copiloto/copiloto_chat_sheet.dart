import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/firestore_collections.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/query_limit_service.dart';
import '../../core/services/subscription_service.dart';

class CopiloticChatSheet extends StatefulWidget {
  final String userPersona;
  final String userName;
  final String activeClientName;
  const CopiloticChatSheet({
    super.key,
    required this.userPersona,
    required this.userName,
    this.activeClientName = '',
  });

  @override
  State<CopiloticChatSheet> createState() => _CopiloticChatSheetState();
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  _ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
}

class _CopiloticChatSheetState extends State<CopiloticChatSheet> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;
  late final GenerativeModel _model; // Gemini model
  late final ChatSession _chat; // Gemini chat session
  bool _modelInitialized = false;
  int _remainingQueries = 10;
  bool _isPro = false;

  @override
  void initState() {
    super.initState();
    _initModel();
    _loadQueryCount();
    _messages.add(_ChatMessage(
      text:
          '¡Hola, ${widget.userName}! Soy tu Copiloto de Comercio Exterior 🤖\n\n'
          'Puedo ayudarte con:\n'
          '• Clasificación arancelaria de productos\n'
          '• Cálculo de impuestos y costos aduanales\n'
          '• Dudas sobre reglas de origen TMEC/USMCA\n'
          '• Permisos previos (COFEPRIS, SENASICA, SE)\n'
          '• Cualquier trámite de comercio exterior en México\n\n'
          '¿En qué te puedo ayudar hoy?',
      isUser: false,
    ));
  }

  Future<void> _loadQueryCount() async {
    final remaining = await QueryLimitService.instance.getRemainingQueries();
    final isPro = SubscriptionService.instance.isPro;
    if (mounted) {
      setState(() {
        _remainingQueries = remaining;
        _isPro = isPro;
      });
    }
  }

  void _initModel() {
    try {
      _model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.0-flash',
        systemInstruction: Content.system(_buildSystemPrompt()),
      );
      _chat = _model.startChat();
      _modelInitialized = true;
    } catch (e) {
      _modelInitialized = false;
    }
  }

  String _buildSystemPrompt() {
    final date = DateFormat('dd/MM/yyyy').format(DateTime.now());
    final personaDesc = switch (widget.userPersona) {
      'novato' =>
        'un importador nuevo que no tiene experiencia en comercio exterior. Usa lenguaje muy simple, evita jerga técnica, y siempre explica los términos que uses. Si menciona fracciones arancelarias, explícale qué son.',
      'agente' =>
        'un Agente Aduanal certificado con amplia experiencia en despacho. Puedes usar terminología técnica: pedimentos, fracciones TIGIE, DTA, PRV, reconocimientos aduanales, M3, SAAI, VUCEM, FIEL.',
      _ =>
        'un importador o exportador con experiencia moderada en comercio exterior de México.',
    };

    return '''
Eres el Copiloto de Comercio Exterior de Aduanas 801, un asistente IA especializado en comercio exterior, logística internacional y trámites aduanales de México.

Fecha actual: $date
Usuario: ${widget.userName}
Perfil: $personaDesc
${widget.activeClientName.isNotEmpty ? 'Cliente activo: ${widget.activeClientName}' : ''}

Tus especialidades:
- Ley Aduanera de México y su Reglamento
- Tarifa TIGIE (Tarifa de la Ley de los Impuestos Generales de Importación y Exportación)
- Reglas Generales de Comercio Exterior (RGCE)
- Acuerdos comerciales: TMEC/USMCA, TIPAN, TLC con UE, AELC
- Cálculos: IGI, DTA, IVA de importación, PRV, cuotas compensatorias
- Reglas de Origen y Certificados de Origen
- IMMEX, OEA, Recintos Fiscalizados Estratégicos
- Permisos previos: COFEPRIS, SENASICA, SE, SEMARNAT
- Incoterms 2020
- Programas de fomento: Duty Drawback, PROSEC
- Operaciones de comercio digital y e-commerce transfronterizo

Reglas:
1. Responde SIEMPRE en español, de forma clara y práctica
2. Cuando des cifras de aranceles o impuestos, aclara que pueden variar y se debe verificar en el DOF o SAT
3. Para clásificación arancelaria, da una fracción tentativa pero recomienda verificar con un agente aduanal
4. Si el usuario pregunta algo fuera de tu especialidad de ComEx, redirige amablemente al tema
5. Usa emojis ocasionalmente para hacer la respuesta más amigable
6. Respuestas concisas: máximo 4 párrafos a menos que el usuario pida más detalle
7. Termina cada respuesta con una pregunta de seguimiento o un tip adicional relevante
''';
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _isLoading) return;

    final canQuery = await QueryLimitService.instance.canQuery();
    if (!mounted) return;
    if (!canQuery) {
      _showLimitReachedDialog();
      return;
    }

    _msgCtrl.clear();
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      unawaited(_saveToFirestore(text, true));
      unawaited(AnalyticsService.instance.logCopilotoQuery(widget.userPersona));

      if (!_modelInitialized) {
        throw Exception('Model not initialized');
      }

      final response = await _chat.sendMessage(Content.text(text)).timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException(
                'El Copiloto tardó demasiado en responder'),
          );
      final responseText =
          response.text ?? 'No pude generar una respuesta. Inténtalo de nuevo.';

      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(text: responseText, isUser: false));
          _isLoading = false;
        });
        unawaited(_saveToFirestore(responseText, false));
        _scrollToBottom();
      }
      await QueryLimitService.instance.incrementCount();
      unawaited(_loadQueryCount());
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text:
                '⏱️ El Copiloto tardó demasiado en responder. Verifica tu conexión e intenta de nuevo.',
            isUser: false,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text:
                'Error al conectar con el Copiloto. Verifica tu conexión e intenta de nuevo. 🙏',
            isUser: false,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _showLimitReachedDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: Color(0xFFF59E0B)),
            SizedBox(width: 8),
            Text('Límite mensual alcanzado',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Has usado tus 10 consultas gratuitas este mes.',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
            SizedBox(height: 12),
            Text(
                'Actualiza a PRO para consultas ilimitadas + todas las funciones avanzadas.',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Ahora no',
                style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/subscription');
            },
            child: const Text('Ver planes PRO',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _saveToFirestore(String text, bool isUser) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await FirebaseFirestore.instance
          .collection(FirestoreCollections.copilotoChats)
          .add({
        'uid': uid,
        'text': text,
        'isUser': isUser,
        'persona': widget.userPersona,
        'activeClient': widget.activeClientName,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {} // fire and forget
  }

  List<String> _getSuggestedQuestions() {
    return switch (widget.userPersona) {
      'novato' => [
          '¿Qué documentos necesito para importar?',
          '¿Cuánto tiempo tarda una importación?',
          '¿Qué es la fracción arancelaria?',
          '¿Necesito RFC para importar?',
        ],
      'agente' => [
          '¿Cuáles son los cambios recientes en RGCE?',
          '¿Cómo aplica el Art. 303 TMEC para drawback?',
          'Criterios para reconocimiento aduanal Art. 43',
          '¿Cuándo aplica PRV vs IVA estándar?',
        ],
      'exportador' => [
          '¿Cómo obtengo un Certificado de Origen TMEC?',
          '¿Qué es el Duty Drawback y cómo aplicarlo?',
          '¿Mi producto cumple Reglas de Origen?',
          '¿Cuáles son los documentos para exportar a EU?',
        ],
      _ => [
          '¿Cómo ahorro impuestos con TMEC?',
          '¿Qué es el Duty Drawback?',
          '¿Cuál es la diferencia entre FOB y CIF?',
          '¿Mi producto necesita permiso previo?',
        ],
    };
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      snap: true,
      snapSizes: const [0.4, 0.75, 0.95],
      builder: (_, scrollController) => DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            _buildHandle(),
            _buildHeader(),
            Expanded(child: _buildMessageList()),
            if (_isLoading) _buildTypingIndicator(),
            _buildSuggestedQuestions(),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.smart_toy_outlined,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Copiloto ComEx',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              if (!_isPro)
                Text(
                  '$_remainingQueries / 10 consultas restantes este mes',
                  style: TextStyle(
                    color: _remainingQueries <= 3
                        ? Colors.orange
                        : const Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              if (_isPro)
                const Text('✨ PRO — Consultas ilimitadas',
                    style: TextStyle(color: Color(0xFFF59E0B), fontSize: 11)),
            ],
          ),
          const Spacer(),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
                color: Color(0xFF10B981), shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          const Text('En línea',
              style: TextStyle(color: Color(0xFF10B981), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (_, i) => _buildMessageBubble(_messages[i]),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: msg.isUser ? AppColors.blue : AppColors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 16),
          ),
          border: msg.isUser ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!msg.isUser)
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.smart_toy_outlined,
                      color: AppColors.gold, size: 12),
                  SizedBox(width: 4),
                  Text('Copiloto',
                      style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            if (!msg.isUser) const SizedBox(height: 4),
            SelectableText(
              msg.text,
              style: TextStyle(
                color: msg.isUser ? Colors.white : Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(msg.timestamp),
              style: TextStyle(
                color: msg.isUser ? Colors.white54 : AppColors.sub,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
                color: AppColors.gold, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          const Text('Copiloto está escribiendo...',
              style: TextStyle(color: AppColors.sub, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSuggestedQuestions() {
    if (_messages.length == 1) {
      return SizedBox(
        height: 36,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: _getSuggestedQuestions()
              .map((q) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () {
                        _msgCtrl.text = q;
                        _sendMessage();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.5)),
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.gold.withValues(alpha: 0.08),
                        ),
                        child: Text(q,
                            style: const TextStyle(
                                color: AppColors.gold, fontSize: 12)),
                      ),
                    ),
                  ))
              .toList(),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              maxLines: 3,
              minLines: 1,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Pregunta sobre comercio exterior...',
                hintStyle: const TextStyle(color: AppColors.sub, fontSize: 13),
                border: InputBorder.none,
                filled: true,
                fillColor: AppColors.bg,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.gold),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isLoading ? null : _sendMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: _isLoading
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                color: _isLoading ? AppColors.border : null,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                _isLoading ? Icons.hourglass_empty : Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }
}
