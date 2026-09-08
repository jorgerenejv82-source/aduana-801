import 'package:aduana_801/core/theme/app_colors.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_ai/firebase_ai.dart';

class AiCopilotScreen extends StatefulWidget {
  const AiCopilotScreen({super.key});

  @override
  State<AiCopilotScreen> createState() => _AiCopilotScreenState();
}

class _AiCopilotScreenState extends State<AiCopilotScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Theme colors
  final Color bgColor = AppColors.bg;
  final Color panelColor = AppColors.card;
  final Color borderColor = AppColors.border;
  final Color accentGold = AppColors.gold;
  final Color textPrimary = AppColors.text;
  final Color textSecondary = AppColors.sub;
  final Color bubbleSystem = const Color(0xFF0A1628);
  final Color bubbleBorder = AppColors.border;

  // State variables
  int _charCount = 0;
  String _selectedMode = 'Consulta General';
  int _totalMessages = 0;
  int _userQuestions = 0;
  int _aiResponses = 0;
  int _sessionSeconds = 0;
  Timer? _timer;

  // Chat messages list
  final List<Map<String, String>> _messages = [];

  final List<Map<String, dynamic>> _modes = [
    {'name': 'Consulta General', 'icon': Icons.chat_outlined},
    {'name': 'Clasificación', 'icon': Icons.category_outlined},
    {'name': 'Cálculo de Impuestos', 'icon': Icons.calculate_outlined},
    {'name': 'Valoración', 'icon': Icons.monetization_on_outlined},
    {'name': 'Documentación', 'icon': Icons.description_outlined},
  ];

  final List<String> _quickActions = [
    'Genera un resumen ejecutivo de mis riesgos actuales',
    'Calcula DTA para valor \$50,000 USD',
    '¿Qué documentos necesito para importar?',
    '¿Cuáles son mis obligaciones como AA?',
    '¿Cómo funciona el IMMEX?',
    '¿Qué es la NOM?',
    'Genera un resumen de mis derechos como importador',
    '¿Cuáles son las cuotas compensatorias vigentes?',
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
    _addInitialMessage();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _sessionSeconds++;
        });
      }
    });
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _addInitialMessage() {
    setState(() {
      _messages.add({
        'role': 'system',
        'time': _getCurrentTime(),
        'content': '''¡Bienvenido a ADUANAS 801 COPILOT! ðŸ¤–
        
Soy tu asistente de inteligencia artificial especializado en **comercio exterior mexicano**. Puedo ayudarte con:
        
â€¢ ðŸ“¦ Clasificación arancelaria (LIGIE)
â€¢ ðŸ’° Cálculo de impuestos (IGI, IVA, DTA)
â€¢ âš–ï¸ Valoración aduanera (Arts. 64-78 LA)
â€¢ ðŸ“‹ Documentación y trámites
â€¢ ðŸ­ Régimen IMMEX y programas especiales
        
Selecciona un modo en el panel lateral o escribe tu consulta.'''
      });
      _totalMessages++;
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _handleSendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'role': 'user',
        'time': _getCurrentTime(),
        'content': text.trim(),
      });
      _userQuestions++;
      _totalMessages++;
      _textController.clear();
      _charCount = 0;
    });

    _scrollToBottom();
    _simulateAiResponse(text.trim());
  }

  void _simulateAiResponse(String userText) async {
    final aiIndex = _messages.length;
    setState(() {
      _messages.add({
        'role': 'ai',
        'time': _getCurrentTime(),
        'content': 'Consultando la base de conocimiento aduanal...',
      });
      _aiResponses++;
      _totalMessages++;
    });
    _scrollToBottom();

    try {
      final model = FirebaseAI.vertexAI().generativeModel(
          model: 'gemini-1.5-flash',
          systemInstruction: Content.system(
              'Eres el Copiloto de IA de Aduanas 801, un asistente experto en comercio exterior, aduanas mexicanas, clasificacion arancelaria, TIGIE, Ley Aduanera, RGCE, T-MEC, y logistica internacional. Responde de forma precisa, profesional y concisa en español. Incluye referencias legales cuando sea relevante.'));
      final response = await model.generateContent([Content.text(userText)]);
      if (!mounted) return;
      setState(() {
        _messages[aiIndex]['content'] = response.text ?? 'Sin respuesta';
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages[aiIndex]['content'] =
            'Hubo un error al generar la respuesta.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error AI: $e'), backgroundColor: Colors.red));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 700;

          return Column(
            children: [
              _buildHeader(isMobile),
              Divider(height: 1, color: borderColor, thickness: 1),
              Expanded(
                child: Row(
                  children: [
                    // Main Chat Area
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          Expanded(child: _buildMessagesList()),
                          _buildInputArea(),
                        ],
                      ),
                    ),
                    // Sidebar
                    if (!isMobile)
                      Container(
                        width: 300,
                        decoration: BoxDecoration(
                          color: panelColor,
                          border: Border(left: BorderSide(color: borderColor)),
                        ),
                        child: _buildSidebarContent(),
                      ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      color: panelColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: textPrimary),
            onPressed: () {
              if (GoRouter.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentGold.withValues(alpha: 0.3)),
            ),
            child: Icon(Icons.smart_toy, color: accentGold, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ADUANAS 801 COPILOT',
                style: TextStyle(
                  color: textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _selectedMode,
                style: TextStyle(
                  color: accentGold,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (isMobile)
            IconButton(
              icon: Icon(Icons.menu_open, color: textSecondary),
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: panelColor,
                  isScrollControlled: true,
                  builder: (context) => SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: _buildSidebarContent(),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.sub),
            tooltip: 'Reiniciar',
            onPressed: () {
              setState(() {
                _messages.clear();
                _totalMessages = 0;
                _userQuestions = 0;
                _aiResponses = 0;
                _addInitialMessage();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.sub),
            tooltip: 'Historial',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.save_alt, color: AppColors.sub),
            tooltip: 'Guardar sesión',
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final role = msg['role'];
        final time = msg['time'];
        final content = msg['content']!;

        if (role == 'system') {
          return _buildSystemMessage(content, time!);
        } else if (role == 'user') {
          return _buildUserMessage(content, time!);
        } else {
          return _buildAiMessage(content, time!);
        }
      },
    );
  }

  Widget _buildSystemMessage(String content, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.green, size: 14),
              const SizedBox(width: 6),
              Text(
                'Sistema $time',
                style: const TextStyle(
                    color: AppColors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: bubbleSystem,
                border: Border.all(color: bubbleBorder),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]),
            child: Text(
              content,
              style: TextStyle(color: textPrimary, fontSize: 14, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserMessage(String content, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                  color: accentGold,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(4)),
                  boxShadow: [
                    BoxShadow(
                        color: accentGold.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ]),
              child: Text(
                content,
                style: const TextStyle(
                    color: AppColors.bg,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiMessage(String content, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: panelColor,
                  border: Border.all(color: borderColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                      bottomLeft: Radius.circular(4)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ]),
              child: Text(
                content,
                style: TextStyle(color: textPrimary, fontSize: 14, height: 1.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      color: panelColor,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: AppColors.sub),
            onPressed: () {},
          ),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: TextField(
                controller: _textController,
                style: TextStyle(color: textPrimary),
                maxLines: 4,
                minLines: 1,
                maxLength: 3000,
                onChanged: (val) {
                  setState(() {
                    _charCount = val.length;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Escribe tu consulta aduanera...',
                  hintStyle: TextStyle(color: textSecondary),
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onSubmitted: _handleSendMessage,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              '$_charCount/3k',
              style: const TextStyle(color: AppColors.sub, fontSize: 11),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.mic_outlined, color: AppColors.sub),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: FloatingActionButton(
              backgroundColor: accentGold,
              elevation: 4,
              onPressed: () => _handleSendMessage(_textController.text),
              child: const Icon(Icons.send, color: AppColors.bg),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarContent() {
    return ColoredBox(
      color: panelColor,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'MODO DE CONSULTA',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ..._modes.map((mode) => _buildModeItem(mode)),
          const SizedBox(height: 32),
          const Text(
            'ACCIONES RÁPIDAS',
            style: TextStyle(
              color: AppColors.sub,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ..._quickActions.map((action) => _buildQuickActionItem(action)),
          const SizedBox(height: 32),
          const Text(
            'ESTADÍSTICAS DE SESIÃ“N',
            style: TextStyle(
              color: AppColors.sub,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                _buildStatRow(Icons.chat_bubble_outline, 'Mensajes totales',
                    '$_totalMessages', AppColors.blue),
                const Divider(color: AppColors.border, height: 24),
                _buildStatRow(Icons.person_outline, 'Tus preguntas',
                    '$_userQuestions', AppColors.green),
                const Divider(color: AppColors.border, height: 24),
                _buildStatRow(Icons.auto_awesome, 'Respuestas AI',
                    '$_aiResponses', AppColors.gold),
                const Divider(color: AppColors.border, height: 24),
                _buildStatRow(Icons.timer_outlined, 'Duración',
                    _formatDuration(_sessionSeconds), AppColors.red),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: bgColor,
              foregroundColor: textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppColors.border),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
            ),
            onPressed: () {},
            icon: const Icon(Icons.bookmark_outline, size: 18),
            label: const Text('Guardar Conversación',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildModeItem(Map<String, dynamic> mode) {
    final bool isSelected = _selectedMode == mode['name'];
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedMode = mode['name'].toString();
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? accentGold.withValues(alpha: 0.1) : bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isSelected
                    ? accentGold.withValues(alpha: 0.5)
                    : borderColor),
          ),
          child: Row(
            children: [
              Icon(
                mode['icon'] as IconData?,
                color: isSelected ? accentGold : textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  mode['name'].toString(),
                  style: TextStyle(
                    color: isSelected ? accentGold : textSecondary,
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(String action) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          _textController.text = action;
          setState(() {
            _charCount = action.length;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              const Icon(Icons.bolt, color: AppColors.gold, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  action,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(
      IconData icon, String label, String value, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: iconColor, size: 14),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(color: textSecondary, fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
              color: textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
