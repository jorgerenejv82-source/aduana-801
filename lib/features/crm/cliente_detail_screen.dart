import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'models/cliente_crm_model.dart';

class ClienteDetailScreen extends StatelessWidget {
  final String clienteId;
  const ClienteDetailScreen({super.key, required this.clienteId});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => context.pop(),
        ),
        title: const Text('Detalle de Cliente',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.blue),
            tooltip: 'Editar cliente',
            onPressed: () => context.go('/clientes/edit/$clienteId'),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('clientes_crm')
            .doc(clienteId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.blue));
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return Center(
              child: Text(
                snapshot.hasError
                    ? 'Error: ${snapshot.error}'
                    : 'Cliente no encontrado.',
                style: const TextStyle(color: AppColors.red),
              ),
            );
          }

          final c = ClienteCrm.fromMap(
              snapshot.data!.data() as Map<String, dynamic>, snapshot.data!.id);
          final creditUsedPct = c.creditLimit > 0
              ? (c.currentBalance / c.creditLimit).clamp(0.0, 1.0)
              : 0.0;
          final isRisk = creditUsedPct > 0.8;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.gold.withValues(alpha: 0.2),
                        child: Text(
                          c.country.isNotEmpty
                              ? c.country.substring(0, 2).toUpperCase()
                              : '??',
                          style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('${c.industry}  •  ${c.country}',
                                style: const TextStyle(color: AppColors.sub)),
                            const SizedBox(height: 4),
                            Text('Tax ID: ${c.taxId}',
                                style: const TextStyle(
                                    color: AppColors.gold, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Credit status card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: isRisk
                            ? AppColors.red.withValues(alpha: 0.5)
                            : AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Estado Crediticio',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          if (isRisk)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: AppColors.red.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4)),
                              child: const Text('RIESGO',
                                  style: TextStyle(
                                      color: AppColors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Límite de Crédito',
                                  style: TextStyle(
                                      color: AppColors.sub, fontSize: 12)),
                              Text(fmt.format(c.creditLimit),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Saldo Actual (CxC)',
                                  style: TextStyle(
                                      color: AppColors.sub, fontSize: 12)),
                              Text(
                                fmt.format(c.currentBalance),
                                style: TextStyle(
                                    color: isRisk
                                        ? AppColors.red
                                        : AppColors.green,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: creditUsedPct,
                          backgroundColor: AppColors.border,
                          color: isRisk ? AppColors.red : AppColors.green,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(creditUsedPct * 100).toStringAsFixed(1)}% del límite utilizado',
                        style: TextStyle(
                            color: isRisk ? AppColors.red : AppColors.sub,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Contact & terms
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Datos de Contacto y Términos',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const Divider(color: AppColors.border, height: 24),
                      _infoRow(Icons.email_outlined, 'Correo', c.email),
                      const SizedBox(height: 12),
                      _infoRow(Icons.phone_outlined, 'Teléfono', c.phone),
                      const SizedBox(height: 12),
                      _infoRow(Icons.handshake_outlined, 'Términos de Pago',
                          c.paymentTerms),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Cumplimiento SAT e IMMEX
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color:
                            c.rfcListaNegra ? AppColors.red : AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cumplimiento SAT e IMMEX',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const Divider(color: AppColors.border, height: 24),
                      _infoRow(
                          Icons.verified_outlined,
                          'Padrón de Importadores',
                          c.enPadronImportadores
                              ? '✅ Inscrito'
                              : '❌ No inscrito'),
                      const SizedBox(height: 12),
                      _infoRow(
                          Icons.category_outlined,
                          'Padrón Sectorial',
                          c.enPadronSectorial
                              ? c.sectoresEspecificos.join(', ')
                              : 'N/A'),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.fact_check_outlined,
                              color: AppColors.gold, size: 18),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Estado RFC',
                                  style: TextStyle(
                                      color: AppColors.sub, fontSize: 12)),
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (c.rfcStatus.toLowerCase() == 'activo'
                                          ? AppColors.green
                                          : (c.rfcStatus.toLowerCase() ==
                                                      'suspendido' ||
                                                  c.rfcStatus.toLowerCase() ==
                                                      'cancelado'
                                              ? AppColors.red
                                              : Colors.grey))
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(c.rfcStatus,
                                    style: TextStyle(
                                        color: c.rfcStatus.toLowerCase() ==
                                                'activo'
                                            ? AppColors.green
                                            : (c.rfcStatus.toLowerCase() ==
                                                        'suspendido' ||
                                                    c.rfcStatus.toLowerCase() ==
                                                        'cancelado'
                                                ? AppColors.red
                                                : Colors.grey),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: c.rfcListaNegra
                              ? AppColors.red.withValues(alpha: 0.2)
                              : AppColors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: c.rfcListaNegra
                                  ? AppColors.red
                                  : AppColors.green.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                                c.rfcListaNegra
                                    ? Icons.warning_amber_rounded
                                    : Icons.check_circle_outline,
                                color: c.rfcListaNegra
                                    ? AppColors.red
                                    : AppColors.green,
                                size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(
                              'RFC Art. 69-B (EFOS): ${c.rfcListaNegra ? "🚨 EN LISTA NEGRA" : "✅ Limpio"}',
                              style: TextStyle(
                                  color: c.rfcListaNegra
                                      ? AppColors.red
                                      : AppColors.green,
                                  fontWeight: FontWeight.bold),
                            )),
                            IconButton(
                              icon: const Icon(Icons.search,
                                  color: AppColors.blue),
                              tooltip: 'Verificar en SAT',
                              onPressed: () =>
                                  context.go('/rfc_verificador?rfc=${c.taxId}'),
                            )
                          ],
                        ),
                      ),
                      if (c.hasImmex) ...[
                        const Divider(color: AppColors.border, height: 24),
                        const Text('IMMEX',
                            style: TextStyle(
                                color: AppColors.sub,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _infoRow(Icons.business_outlined, 'Tipo de Programa',
                            c.immexTipo),
                        const SizedBox(height: 12),
                        _buildImmexVigencia(c.immexVigencia),
                      ],
                      const Divider(color: AppColors.border, height: 24),
                      const Text('Datos Operativos',
                          style: TextStyle(
                              color: AppColors.sub,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _infoRow(Icons.local_shipping_outlined,
                          'Aduana Principal', c.aduana),
                      const SizedBox(height: 12),
                      _infoRow(Icons.article_outlined, 'Régimen Frecuente',
                          c.regimenFrecuente),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImmexVigencia(String? fechaStr) {
    if (fechaStr == null || fechaStr.isEmpty) {
      return _infoRow(
          Icons.date_range_outlined, 'Vigencia IMMEX', 'No especificada');
    }

    DateTime? fecha;
    try {
      fecha = DateTime.parse(fechaStr);
    } catch (_) {}

    if (fecha == null) {
      return _infoRow(Icons.date_range_outlined, 'Vigencia IMMEX', fechaStr);
    }

    final days = fecha.difference(DateTime.now()).inDays;
    Color statusColor = AppColors.green;
    String statusText = 'Vigente';
    if (days < 0) {
      statusColor = AppColors.red;
      statusText = 'Vencido';
    } else if (days < 60) {
      statusColor = Colors.orange;
      statusText = 'Por Vencer';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.date_range_outlined, color: AppColors.gold, size: 18),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vigencia IMMEX',
                style: TextStyle(color: AppColors.sub, fontSize: 12)),
            Row(
              children: [
                Text(fechaStr, style: const TextStyle(color: Colors.white)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(statusText,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.gold, size: 18),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: AppColors.sub, fontSize: 12)),
            Text(value.isNotEmpty ? value : 'No especificado',
                style: const TextStyle(color: Colors.white)),
          ],
        ),
      ],
    );
  }
}
