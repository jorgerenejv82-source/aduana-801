import 'dart:async';
import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/query_limit_service.dart';
import '../../core/services/subscription_service.dart';

const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _verde = AppColors.green;
const Color _ambar = AppColors.gold;

class CopilotoScreen extends StatefulWidget {
  const CopilotoScreen({super.key});
  @override
  State<CopilotoScreen> createState() => _CopilotoScreenState();
}

class _CopilotoScreenState extends State<CopilotoScreen> {
  final _textCtrl = TextEditingController();
  final _scroll = ScrollController();
  bool _typing = false;
  int? _hoveredChip;
  bool _sendHovered = false;

  late final GenerativeModel _model;
  late final ChatSession _chat;

  final List<Map<String, dynamic>> _msgs = [
    {
      'role': 'ai',
      'text':
          'Sistema en línea conectado a Gemini 1.5 Flash. Soy tu Copiloto Aduanero. ¿En qué te puedo ayudar hoy?'
    },
  ];

  int _remainingQueries = 10;
  bool _isPro = false;

  @override
  void initState() {
    super.initState();
    _loadQueryCount();
    _model = FirebaseAI.vertexAI().generativeModel(
      model: 'gemini-1.5-flash',
      systemInstruction: Content.system(
          'Eres el Agente Cognitivo Aduanero (Copiloto) de Aduanas 801, una plataforma experta en la Ley Aduanera de México, IMMEX, Anexo 22, TIGIE y OEA. '
          'Tu tarea es asistir a importadores, exportadores y agentes aduanales resolviendo dudas complejas de comercio exterior. '
          'Debes responder de manera profesional, precisa y estructurada usando Markdown para resaltar conceptos clave. '
          'Si no sabes algo, indícalo claramente. Nunca des asesoría fiscal definitiva sin recomendar consultar a un especialista.'),
    );
    _chat = _model.startChat();
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

  Future<void> _enviar(String texto) async {
    if (texto.trim().isEmpty) return;

    final canQuery = await QueryLimitService.instance.canQuery();
    if (!canQuery) {
      _showLimitReachedDialog();
      return;
    }

    final prompt = texto.trim();
    setState(() {
      _msgs.add({'role': 'user', 'text': prompt});
      _typing = true;
      _textCtrl.clear();
    });

    // Auto-scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });

    try {
      final response = await _chat.sendMessage(Content.text(prompt));
      final text = response.text;
      if (!mounted) return;
      setState(() {
        _msgs.add({'role': 'ai', 'text': text ?? 'Sin respuesta.'});
        _typing = false;
      });
      await QueryLimitService.instance.incrementCount();
      unawaited(_loadQueryCount());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _msgs.add({'role': 'ai', 'text': 'Error de conexión con la IA: '});
        _typing = false;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final chips = [
      '¿Cómo funciona IMMEX?',
      '¿Qué es la Regla 4.3.5?',
      'Mermas y desperdicios',
      'Pedimentos tipo A3',
      'Certificación OEA'
    ];
    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: _bg,
            child: Row(children: [
              InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _bord)),
                      child: const Icon(Icons.chevron_left,
                          color: _ambar, size: 20))),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Agente Cognitivo Aduanero',
                      style: TextStyle(
                          color: _ambar,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
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
                        style:
                            TextStyle(color: Color(0xFFF59E0B), fontSize: 11)),
                ],
              ),
              const Spacer(),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: _verde.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _verde.withValues(alpha: 0.3))),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.circle, color: _verde, size: 8),
                    SizedBox(width: 6),
                    Text('En línea (Gemini)',
                        style: TextStyle(
                            color: _verde,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ])),
            ])),
        const Divider(height: 1, color: _bord),
        Expanded(
            child: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.all(24),
          itemCount: _msgs.length + (_typing ? 1 : 0),
          itemBuilder: (_, i) {
            if (i == _msgs.length) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16, right: 80),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: _card,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomRight: Radius.circular(16)),
                      border: Border.all(color: _bord)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              color: _ambar, strokeWidth: 2)),
                      SizedBox(width: 12),
                      Text('Gemini está analizando la regulación...',
                          style: TextStyle(
                              color: _sec,
                              fontSize: 13,
                              fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              );
            }
            final m = _msgs[i];
            final isUser = m['role'] == 'user';
            return Align(
              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(
                    bottom: 16, left: isUser ? 80 : 0, right: isUser ? 0 : 80),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isUser ? _ambar.withValues(alpha: 0.1) : _card,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft:
                        isUser ? const Radius.circular(16) : Radius.zero,
                    bottomRight:
                        isUser ? Radius.zero : const Radius.circular(16),
                  ),
                  border: Border.all(
                      color: isUser ? _ambar.withValues(alpha: 0.3) : _bord),
                ),
                child: MarkdownBody(
                  data: m['text'].toString(),
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                        color: isUser ? _ambar : _texto,
                        fontSize: 14,
                        height: 1.5),
                    strong: TextStyle(
                        color: isUser ? _ambar : _texto,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          },
        )),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
              color: _bg, border: Border(top: BorderSide(color: _bord))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(chips.length, (i) {
                    final c = chips[i];
                    return MouseRegion(
                      onEnter: (_) => setState(() => _hoveredChip = i),
                      onExit: (_) => setState(() => _hoveredChip = null),
                      child: GestureDetector(
                        onTap: () => _enviar(c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8, bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _hoveredChip == i
                                ? _ambar.withValues(alpha: 0.2)
                                : _card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: _hoveredChip == i ? _ambar : _bord),
                          ),
                          child: Text(c,
                              style: TextStyle(
                                  color: _hoveredChip == i ? _ambar : _sec,
                                  fontSize: 12)),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: _bord)),
                      child: TextField(
                        controller: _textCtrl,
                        style: const TextStyle(color: _texto, fontSize: 14),
                        decoration: const InputDecoration(
                            hintText:
                                'Pregúntale a tu copiloto sobre TIGIE, Anexo 22, multas...',
                            hintStyle: TextStyle(color: _sec, fontSize: 14),
                            border: InputBorder.none),
                        onSubmitted: _typing ? null : _enviar,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  MouseRegion(
                    onEnter: (_) => setState(() => _sendHovered = true),
                    onExit: (_) => setState(() => _sendHovered = false),
                    child: GestureDetector(
                      onTap: () => _typing ? null : _enviar(_textCtrl.text),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _typing
                              ? _card
                              : (_sendHovered
                                  ? _ambar
                                  : _ambar.withValues(alpha: 0.8)),
                          shape: BoxShape.circle,
                          boxShadow: _sendHovered && !_typing
                              ? [
                                  BoxShadow(
                                      color: _ambar.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4))
                                ]
                              : [],
                        ),
                        child: Icon(Icons.send,
                            color: _typing ? _sec : _bg, size: 20),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
