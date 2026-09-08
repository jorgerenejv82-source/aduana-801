import 'package:aduana_801/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'models/tracking_event_model.dart';
import 'services/shipping_tracking_service.dart';

class ShipmentTrackerHubScreen extends StatefulWidget {
  const ShipmentTrackerHubScreen({super.key});

  @override
  State<ShipmentTrackerHubScreen> createState() =>
      _ShipmentTrackerHubScreenState();
}

class _ShipmentTrackerHubScreenState extends State<ShipmentTrackerHubScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ShippingTrackingService _trackingService = ShippingTrackingService();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    setState(() {
      _searchQuery = _searchController.text.trim().toUpperCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        title: const Text('Trazabilidad de Contenedores',
            style: TextStyle(color: AppColors.text)),
        iconTheme: const IconThemeData(color: AppColors.text),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ej. MSCU1234567 o Num. B/L',
                      hintStyle: const TextStyle(color: AppColors.sub),
                      prefixIcon:
                          const Icon(Icons.search, color: AppColors.sub),
                      filled: true,
                      fillColor: AppColors.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Rastrear',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _searchQuery.isEmpty
          ? const Center(
              child: Text(
                'Ingresa un número de contenedor para ver el estatus real.',
                style: TextStyle(color: AppColors.sub, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )
          : StreamBuilder<List<TrackingEvent>>(
              stream: _trackingService.getContainerEvents(_searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppColors.blue));
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: const TextStyle(color: AppColors.red)));
                }

                final events = snapshot.data ?? [];

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Resultados para: $_searchQuery',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          ElevatedButton.icon(
                            onPressed: () =>
                                ShippingTrackingService.exportTrackingReportPdf(
                              containerNumber: _searchQuery,
                              events: events,
                            ),
                            icon: const Icon(Icons.picture_as_pdf,
                                color: Colors.white, size: 18),
                            label: const Text('Exportar',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.red,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: events.isEmpty
                          ? const Center(
                              child: Text(
                                'No se encontraron eventos en la naviera para este contenedor.',
                                style: TextStyle(
                                    color: AppColors.sub, fontSize: 16),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: () async {
                                setState(() {});
                                await Future<void>.delayed(
                                    const Duration(milliseconds: 800));
                              },
                              color: AppColors.gold,
                              backgroundColor: AppColors.card,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                itemCount: events.length,
                                itemBuilder: (context, index) {
                                  final e = events[index];
                                  final isFirst = index == 0;

                                  return IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(
                                          width: 40,
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 16,
                                                height: 16,
                                                decoration: BoxDecoration(
                                                  color: isFirst
                                                      ? AppColors.green
                                                      : AppColors.sub,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              if (index != events.length - 1)
                                                Expanded(
                                                  child: Container(
                                                    width: 2,
                                                    color: AppColors.border,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 24),
                                            child: Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: AppColors.card,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: isFirst
                                                      ? AppColors.green
                                                          .withValues(
                                                              alpha: 0.5)
                                                      : AppColors.border,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(e.status,
                                                          style: TextStyle(
                                                            color: isFirst
                                                                ? AppColors
                                                                    .green
                                                                : Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          )),
                                                      Text(
                                                          DateFormat(
                                                                  'dd/MMM/yy HH:mm')
                                                              .format(
                                                                  e.timestamp),
                                                          style:
                                                              const TextStyle(
                                                                  color:
                                                                      AppColors
                                                                          .sub,
                                                                  fontSize:
                                                                      12)),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                          Icons.location_on,
                                                          color: AppColors.gold,
                                                          size: 14),
                                                      const SizedBox(width: 4),
                                                      Text(e.location,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      14)),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(e.description,
                                                      style: const TextStyle(
                                                          color: AppColors.sub,
                                                          fontSize: 13)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
