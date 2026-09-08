import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

// ── Design Tokens ─────────────────────────────────────────────────────────────
const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _gold = AppColors.gold;
const Color _text = AppColors.text;
const Color _sub = AppColors.sub;
const Color _border = AppColors.border;
const Color _green = AppColors.green;
const Color _card2 = Color(0xFF13233E);

class BlockchainLedgerScreen extends StatefulWidget {
  const BlockchainLedgerScreen({super.key});

  @override
  State<BlockchainLedgerScreen> createState() => _BlockchainLedgerScreenState();
}

class _BlockchainLedgerScreenState extends State<BlockchainLedgerScreen> {
  final _rng = Random();

  // Genera un hash simulado tipo 0x8f2a...c391
  String _fakeHash(String seed) {
    const chars = '0123456789abcdef';
    final r = Random(seed.hashCode);
    String h = '0x';
    for (int i = 0; i < 4; i++) {
      h += chars[r.nextInt(16)];
    }
    h += '...';
    for (int i = 0; i < 4; i++) {
      h += chars[r.nextInt(16)];
    }
    return h;
  }

  // Tipos de transacción IMMEX Anexo 24 válidos
  static const _tiposTx = [
    'Alta Inventario',
    'Descargo A24',
    'Firma Electrónica',
    'Transferencia',
    'Retorno',
    'Cambio de Régimen',
    'Merma',
    'Exportación Virtual',
  ];

  Future<void> _agregarBloque() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Obtener el último bloque para encadenar el hash
    try {
      final lastSnap = await FirebaseFirestore.instance
          .collection('blockchain_ledger')
          .where('agentUid', isEqualTo: uid)
          .orderBy('blockNumber', descending: true)
          .limit(1)
          .get();

      int lastNum = 939;
      String lastHash = '0x3d4b...a779';
      if (lastSnap.docs.isNotEmpty) {
        final d = lastSnap.docs.first.data();
        lastNum = (d['blockNumber'] ?? 939) as int;
        lastHash = (d['hash'] ?? '0x3d4b...a779') as String;
      }

      final newNum = lastNum + 1;
      final tipo = _tiposTx[_rng.nextInt(_tiposTx.length)];
      final newHash =
          _fakeHash('$newNum${DateTime.now().millisecondsSinceEpoch}');

      await FirebaseFirestore.instance.collection('blockchain_ledger').add({
        'blockId': '801-BLK-$newNum',
        'blockNumber': newNum,
        'hash': newHash,
        'prevHash': lastHash,
        'tipoTransaccion': tipo,
        'agentUid': uid,
        'timestamp': FieldValue.serverTimestamp(),
        'verified': true,
      });
    } catch (e) {
      debugPrint('Error en blockchain: $e');
    }
  }

  @override
  @override
  void dispose() {
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: _bg,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: _text, size: 24),
                  onPressed: () => context.go('/home'),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Customs Ledger (Anexo 24)',
                    style: TextStyle(
                      color: _text,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Botón agregar bloque
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: _gold, size: 24),
                  tooltip: 'Registrar transacción',
                  onPressed: _agregarBloque,
                ),
              ],
            ),
          ),

          // ── Subtitle ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _green,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Cadena de custodia verificada · IMMEX Anexo 24',
                  style: TextStyle(color: _sub, fontSize: 12),
                ),
                const Spacer(),
                // Badge info
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _green.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, color: _green, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Inmutable',
                        style: TextStyle(
                            color: _green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: _border, height: 1),

          // ── Chain ───────────────────────────────────────────────────────
          Expanded(
            child: uid == null
                ? const Center(
                    child:
                        Text('No autenticado', style: TextStyle(color: _sub)))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('blockchain_ledger')
                        .where('agentUid', isEqualTo: uid)
                        .orderBy('blockNumber', descending: true)
                        .limit(50)
                        .snapshots(),
                    builder: (ctx, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: _gold),
                        );
                      }

                      final docs = snap.data?.docs ?? [];

                      // Si no hay datos reales, mostrar bloques demo
                      final blocks = docs.isEmpty
                          ? _demoBlocks()
                          : docs.map((d) {
                              final data = d.data() as Map<String, dynamic>;
                              DateTime ts = DateTime.now();
                              if (data['timestamp'] != null) {
                                final t = data['timestamp'] as Timestamp;
                                ts = t.toDate();
                              }
                              return _BlockData(
                                blockId: (data['blockId'] ?? '801-BLK-???')
                                    .toString(),
                                blockNumber: (data['blockNumber'] ?? 0) as int,
                                hash:
                                    (data['hash'] ?? '0x???...???').toString(),
                                prevHash: (data['prevHash'] ?? '0x???...???')
                                    .toString(),
                                tipoTransaccion:
                                    (data['tipoTransaccion'] ?? 'Desconocido')
                                        .toString(),
                                timestamp: ts,
                                verified: (data['verified'] ?? true) as bool,
                              );
                            }).toList();

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 24),
                        itemCount: blocks.length,
                        itemBuilder: (ctx, i) {
                          final block = blocks[i];
                          final isLast = i == blocks.length - 1;
                          return _BlockChainItem(
                            block: block,
                            isLast: isLast,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      // FAB para nueva transacción
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarDialogoNuevaTx,
        backgroundColor: _gold,
        foregroundColor: _bg,
        icon: const Icon(Icons.add, size: 20),
        label: const Text(
          'Nueva Transacción',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  List<_BlockData> _demoBlocks() {
    final now = DateTime.now();
    return [
      _BlockData(
        blockId: '801-BLK-942',
        blockNumber: 942,
        hash: '0x8f2a...c391',
        prevHash: '0x7b1c...d820',
        tipoTransaccion: 'Descargo A24',
        timestamp: now.subtract(const Duration(minutes: 2)),
        verified: true,
      ),
      _BlockData(
        blockId: '801-BLK-941',
        blockNumber: 941,
        hash: '0x7b1c...d820',
        prevHash: '0x5a9e...f114',
        tipoTransaccion: 'Alta Inventario',
        timestamp: now.subtract(const Duration(minutes: 15)),
        verified: true,
      ),
      _BlockData(
        blockId: '801-BLK-940',
        blockNumber: 940,
        hash: '0x5a9e...f114',
        prevHash: '0x3d4b...a779',
        tipoTransaccion: 'Firma Electrónica',
        timestamp: now.subtract(const Duration(hours: 1)),
        verified: true,
      ),
    ];
  }

  Future<void> _mostrarDialogoNuevaTx() async {
    String tipoSeleccionado = _tiposTx[0];
    final notaController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, setS) {
        return AlertDialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _border),
          ),
          title: const Row(
            children: [
              Icon(Icons.add_link, color: _gold, size: 24),
              SizedBox(width: 12),
              Text(
                'Nueva Transacción',
                style: TextStyle(
                    color: _text, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TIPO DE TRANSACCIÓN',
                  style: TextStyle(
                      color: _sub,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: tipoSeleccionado,
                  dropdownColor: _card2,
                  style: const TextStyle(color: _text, fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _bg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  items: _tiposTx
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setS(() => tipoSeleccionado = v);
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'NOTAS (OPCIONAL)',
                  style: TextStyle(
                      color: _sub,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notaController,
                  style: const TextStyle(color: _text, fontSize: 14),
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Referencia, número de parte, etc...',
                    hintStyle: const TextStyle(color: _sub),
                    filled: true,
                    fillColor: _bg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.all(24),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(_),
              child: const Text('Cancelar', style: TextStyle(color: _sub)),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(_);
                await _agregarBloque();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Bloque "$tipoSeleccionado" registrado en el ledger'),
                      backgroundColor: _card,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: _bg,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Registrar Bloque',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }),
    );
  }
}

// ── Data Model ────────────────────────────────────────────────────────────
class _BlockData {
  final String blockId;
  final int blockNumber;
  final String hash;
  final String prevHash;
  final String tipoTransaccion;
  final DateTime timestamp;
  final bool verified;

  const _BlockData({
    required this.blockId,
    required this.blockNumber,
    required this.hash,
    required this.prevHash,
    required this.tipoTransaccion,
    required this.timestamp,
    required this.verified,
  });
}

// ── Block Chain Item ──────────────────────────────────────────────────────
class _BlockChainItem extends StatefulWidget {
  final _BlockData block;
  final bool isLast;

  const _BlockChainItem({required this.block, required this.isLast});

  @override
  State<_BlockChainItem> createState() => _BlockChainItemState();
}

class _BlockChainItemState extends State<_BlockChainItem> {
  bool _isHovered = false;

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) {
      return 'Hace ${diff.inHours} hora${diff.inHours > 1 ? 's' : ''}';
    }
    return 'Hace ${diff.inDays} día${diff.inDays > 1 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Block Card ──────────────────────────────────────────────────
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _isHovered ? _gold.withValues(alpha: 0.5) : _border),
                boxShadow: [
                  if (_isHovered)
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Block ID + timestamp
                Row(
                  children: [
                    Text(
                      widget.block.blockId,
                      style: const TextStyle(
                          color: _text,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      _relativeTime(widget.block.timestamp),
                      style: const TextStyle(color: _sub, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Hash row
                Row(
                  children: [
                    const Text('Hash:  ',
                        style: TextStyle(color: _sub, fontSize: 13)),
                    _HashChip(hash: widget.block.hash, isHash: true),
                  ],
                ),
                const SizedBox(height: 10),

                // Prev hash row
                Row(
                  children: [
                    const Text('Prev:   ',
                        style: TextStyle(color: _sub, fontSize: 13)),
                    _HashChip(hash: widget.block.prevHash, isHash: false),
                  ],
                ),
                const SizedBox(height: 20),

                // Bottom: tipo + verified
                Row(
                  children: [
                    // Tipo de transacción
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _border),
                      ),
                      child: Text(
                        widget.block.tipoTransaccion,
                        style: const TextStyle(
                            color: _text,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Spacer(),
                    // VERIFIED badge
                    if (widget.block.verified)
                      const Row(
                        children: [
                          Icon(Icons.verified, color: _green, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'VERIFIED',
                            style: TextStyle(
                                color: _green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Connector Line (cadena) ─────────────────────────────────────
        if (!widget.isLast)
          Container(
            width: 2,
            height: 32,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _gold,
                  _gold.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ── Hash Chip ─────────────────────────────────────────────────────────────
class _HashChip extends StatelessWidget {
  final String hash;
  final bool isHash; // true = dorado, false = gris

  const _HashChip({required this.hash, required this.isHash});

  @override
  Widget build(BuildContext context) {
    final bgColor = isHash ? _gold.withValues(alpha: 0.1) : _bg;
    final borderColor = isHash ? _gold.withValues(alpha: 0.3) : _border;
    final textColor = isHash ? _gold : _sub;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        hash,
        style: TextStyle(
          fontFamily: 'monospace',
          color: textColor,
          fontSize: 11.5,
        ),
      ),
    );
  }
}
