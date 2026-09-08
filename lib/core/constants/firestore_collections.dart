/// Centralized Firestore collection name constants.
/// Always use these constants instead of hardcoded strings.
abstract final class FirestoreCollections {
  // Auth / Users
  static const String users = 'users';

  // Operations
  static const String expedientesCompletos = 'expedientes_completos';
  static const String expedientes = 'expedientes';
  static const String operaciones = 'operaciones';

  // Supply Chain
  static const String purchaseOrders = 'purchase_orders';
  static const String suppliers = 'suppliers';
  static const String embarques = 'embarques';
  static const String trackingEvents = 'tracking_events';

  // CRM
  static const String clientesCrm = 'clientes_crm';

  // Compliance
  static const String nomVigencias = 'nom_vigencias';
  static const String immexInventario = 'immex_inventario';

  // Financial
  static const String drawbackHistorial = 'drawback_historial';
  static const String tcoAnalisis = 'tco_analisis';

  // Notifications / Alerts
  static const String notificaciones = 'notificaciones';
  static const String notificacionesLeidas = 'notificaciones_leidas';

  // Customs/Agent
  static const String preGlosas = 'pre_glosas';
  static const String glosas = 'glosas';
  static const String previos = 'previos';
  static const String clasificaciones = 'clasificaciones';
  static const String encargos = 'encargos';

  // Board
  static const String kanban = 'kanban';

  // AI
  static const String copilotoChats = 'copiloto_chats';

  // Config
  static const String config = 'config';
}
