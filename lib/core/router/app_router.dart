import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aduana_801/features/landing/landing_screen.dart';
import 'package:aduana_801/features/home/widgets/recent_routes_tracker.dart';
import 'page_transitions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/onboarding/persona_selection_screen.dart';
import '../../features/onboarding/guided_onboarding_screen.dart';
import '../../features/calculator/utilidad_neta_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/alerts/alerts_screen.dart';

import 'package:go_router/go_router.dart';
import 'package:aduana_801/features/dashboard/roi_dashboard_screen.dart';
import 'package:aduana_801/core/services/subscription_service.dart';
import 'package:aduana_801/core/widgets/premium_gate.dart';
import 'package:aduana_801/features/profile/subscription_screen.dart';
import 'package:aduana_801/features/crypto/boveda_fiel_screen.dart';
import 'package:aduana_801/features/despacho/despacho_hub_screen.dart';
import 'package:aduana_801/features/despacho/despacho_screen.dart';
import 'package:aduana_801/features/audit/invoice_vs_pedimento_screen.dart';
import 'package:aduana_801/features/audit/swarm_ai_screen.dart' deferred as swarm_ai;
import 'package:aduana_801/features/supply_chain/po_list_screen.dart';
import 'package:aduana_801/features/supply_chain/tco_comparator_screen.dart';
import 'package:aduana_801/features/financial/importer_dashboard_screen.dart';
import 'package:aduana_801/features/supply_chain/po_form_screen.dart';
import 'package:aduana_801/features/supply_chain/supplier_scorecard_screen.dart';
import 'package:aduana_801/features/financial/letter_of_credit_screen.dart';
import 'package:aduana_801/features/financial/duty_drawback_screen.dart';
import 'package:aduana_801/features/logistics/freight_quotes_screen.dart';
import 'package:aduana_801/features/regulatory/noms_advisor_screen.dart';
import 'package:aduana_801/features/crm/suppliers_list_screen.dart';
import 'package:aduana_801/features/crm/supplier_form_screen.dart';
import 'package:aduana_801/features/crm/supplier_edit_screen.dart';
import 'package:aduana_801/features/crm/rfc_verificador_screen.dart';

import 'package:aduana_801/features/auth/login_screen.dart';
import 'package:aduana_801/features/auth/register_screen.dart';
import 'package:aduana_801/features/profile/profile_screen.dart';
import 'package:aduana_801/features/auth/role_selection_screen.dart';
import 'package:aduana_801/features/home/home_screen.dart' deferred as home_screen;
import 'package:aduana_801/features/previo/previo_screen.dart';
import 'package:aduana_801/features/pre_glosa/pre_glosa_screen.dart';
import 'package:aduana_801/features/calculator/calculator_screen.dart';
import 'package:aduana_801/features/classifier/classifier_screen.dart';
import 'package:aduana_801/features/financial/financial_dashboard_screen.dart';
import 'package:aduana_801/features/hubs/broker_hub_screen.dart';
import 'package:aduana_801/features/regulatory/immex_screen.dart';
import 'package:aduana_801/features/regulatory/tmec_screen.dart';
import 'package:aduana_801/features/ai_copilot/ai_copilot_screen.dart';
import 'package:aduana_801/features/compliance/compliance_screen.dart';
import 'package:aduana_801/features/kanban/kanban_screen.dart';
import 'package:aduana_801/features/calculator/fraccion_simulator_screen.dart';
import 'package:aduana_801/features/calculator/regimen_comparator_screen.dart';
import 'package:aduana_801/features/compliance/nom_calendar_screen.dart';
import 'package:aduana_801/features/home/notification_center_screen.dart';

import 'package:aduana_801/features/history/history_screen.dart';
import 'package:aduana_801/features/home/glosario_screen.dart';
import 'package:aduana_801/features/home/faq_screen.dart';
import 'package:aduana_801/features/financial/cashflow_screen.dart';
import 'package:aduana_801/features/financial/landed_cost_screen.dart';
import 'package:aduana_801/features/financial/demurrage_screen.dart';
import 'package:aduana_801/features/financial/roi_calculator_screen.dart';
import 'package:aduana_801/features/compliance/permisos_previos_screen.dart';
import 'package:aduana_801/features/regulatory/carta_de_cupo_screen.dart';
import 'package:aduana_801/features/financial/annual_summary_screen.dart';
import 'package:aduana_801/features/hubs/importer_hub_screen.dart';
import 'package:aduana_801/features/calculator/simple_estimator_screen.dart';
import 'package:aduana_801/features/importer/mi_primer_despacho_screen.dart';

import 'package:aduana_801/features/hubs/shared_workspace_screen.dart';
import 'package:aduana_801/features/hubs/virtual_ops_screen.dart';
import 'package:aduana_801/features/hubs/ctpat_hub_screen.dart';
import 'package:aduana_801/features/regulatory/incoterms_screen.dart';
import 'package:aduana_801/features/regulatory/carta_porte_screen.dart';
import 'package:aduana_801/features/regulatory/global_sourcing_screen.dart';
import 'package:aduana_801/features/compliance/aml_scanner_screen.dart';
import 'package:aduana_801/features/eagle_eye/eagle_eye_screen.dart';
import 'package:aduana_801/features/sat_radar/sat_radar_screen.dart';
import 'package:aduana_801/features/ml_predictor/ml_audit_predictor_screen.dart';
import 'package:aduana_801/features/audit/auditor_screen.dart';
import 'package:aduana_801/features/audit/blockchain_auditor_screen.dart';
import 'package:aduana_801/features/audit/m3_analyzer_screen.dart';
import 'package:aduana_801/features/scanner/scanner_screen.dart';
import 'package:aduana_801/features/pre_glosa/saai_screen.dart';
import 'package:aduana_801/features/profile/configuracion_screen.dart';
import 'package:aduana_801/features/audit/blockchain_ledger_screen.dart';
import 'package:aduana_801/features/regulatory/pre_validador_m3_screen.dart';
import 'package:aduana_801/features/regulatory/validador_xml_screen.dart';
import 'package:aduana_801/features/regulatory/apendice8_screen.dart';
import 'package:aduana_801/features/regulatory/m3_forensics_screen.dart';
import 'package:aduana_801/features/regulatory/motor_a22_screen.dart';
import 'package:aduana_801/features/regulatory/rectificacion_m11_screen.dart';
import 'package:aduana_801/features/regulatory/clasificador_ia_screen.dart';
import 'package:aduana_801/features/regulatory/simulador_pedimento_screen.dart';
import 'package:aduana_801/features/compliance/lista_negra_sat_screen.dart';
import 'package:aduana_801/features/regulatory/vucem_sync_screen.dart';
import 'package:aduana_801/features/regulatory/manifestacion_valor_screen.dart';
import 'package:aduana_801/features/regulatory/historial_m3_screen.dart';
import 'package:aduana_801/features/regulatory/oea_seciit_screen.dart';
import 'package:aduana_801/features/regulatory/consultor_tigie_screen.dart';
import 'package:aduana_801/features/regulatory/warroom_simulator_screen.dart';
import 'package:aduana_801/features/regulatory/conciliador_visor_b_screen.dart';
import 'package:aduana_801/features/regulatory/anexo30_screen.dart';
import 'package:aduana_801/features/regulatory/integracion_cuantica_screen.dart';
import 'package:aduana_801/features/regulatory/conciliador_sap_screen.dart';
import 'package:aduana_801/features/intelligence/agace_screen.dart';
import 'package:aduana_801/features/intelligence/ar_visor_screen.dart';
import 'package:aduana_801/features/intelligence/copiloto_screen.dart';
import 'package:aduana_801/features/intelligence/border_sync_screen.dart';
import 'package:aduana_801/features/hubs/catalogo_apps_screen.dart';
import 'package:aduana_801/features/regulatory/merceologia_screen.dart';
import 'package:aduana_801/features/regulatory/agenda_vencimientos_screen.dart';
import 'package:aduana_801/features/intelligence/swarm_ai_screen.dart';
import 'package:aduana_801/features/intelligence/api_gateway_screen.dart';
import 'package:aduana_801/features/intelligence/data_integration_screen.dart';
import 'package:aduana_801/features/calculator/cotizador_servicios_screen.dart';
import 'package:aduana_801/features/regulatory/escritos_legales_screen.dart';
import 'package:aduana_801/features/regulatory/motor_proformas_screen.dart';
import 'package:aduana_801/features/regulatory/trafico_despacho_screen.dart';
import 'package:aduana_801/features/regulatory/cross_match_glosa_screen.dart';
import 'package:aduana_801/features/regulatory/generador_doda_pita_screen.dart';
import 'package:aduana_801/features/regulatory/monitor_encargos_screen.dart';
import 'package:aduana_801/features/regulatory/boveda_vucem_screen.dart';
import 'package:aduana_801/features/regulatory/auditor_tmec_bom_screen.dart';
import 'package:aduana_801/features/financial/cotizador_door_to_door_screen.dart';
import 'package:aduana_801/features/regulatory/sli_vgm_generator_screen.dart';
import 'package:aduana_801/features/logistics/rutas_globales_screen.dart';
import 'package:aduana_801/features/regulatory/traductor_corporativo_screen.dart';
import 'package:aduana_801/features/financial/calculadora_seguros_screen.dart';
import 'package:aduana_801/features/regulatory/rescate_enterprise_screen.dart';
import 'package:aduana_801/features/regulatory/glosa_colaborativa_screen.dart';
import 'package:aduana_801/features/logistics/traffic_tower_screen.dart';
import 'package:aduana_801/features/regulatory/esg_calculator_screen.dart';
import 'package:aduana_801/features/regulatory/comando_fiscal_screen.dart';
import 'package:aduana_801/features/crm/clientes_list_screen.dart';
import 'package:aduana_801/features/crm/cliente_detail_screen.dart';
import 'package:aduana_801/features/crm/cliente_form_screen.dart';
import 'package:aduana_801/features/expediente/expediente_list_screen.dart';
import 'package:aduana_801/features/expediente/expediente_detail_screen.dart';
import 'package:aduana_801/features/shipment_tracker/shipment_tracker_hub_screen.dart';
import 'package:aduana_801/features/shipment_tracker/nuevo_embarque_screen.dart';
import 'package:aduana_801/features/semaforo/semaforo_screen.dart';

import 'package:aduana_801/features/home/learning_center_screen.dart';
import 'package:aduana_801/features/regulatory/requisitos_producto_screen.dart';
import 'package:aduana_801/features/logistics/timeline_estimator_screen.dart';
import 'package:aduana_801/features/pricing/pricing_screen.dart';

import '../services/analytics_service.dart';

class DeferredLoader extends StatefulWidget {
  final Future<void> Function() loadLibrary;
  final Widget Function() builder;
  const DeferredLoader({super.key, required this.loadLibrary, required this.builder});

  @override
  State<DeferredLoader> createState() => _DeferredLoaderState();
}

class _DeferredLoaderState extends State<DeferredLoader> {
  bool _loaded = false;
  @override
  void initState() {
    super.initState();
    widget.loadLibrary().then((_) {
      if (mounted) setState(() { _loaded = true; });
    });
  }
  @override
  Widget build(BuildContext context) {
    if (_loaded) return widget.builder();
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  observers: [AnalyticsService.instance.observer, SentryNavigatorObserver()],
  redirect: (BuildContext context, GoRouterState state) async {
    final prefs = await SharedPreferences.getInstance();
    final personaSelected = prefs.getString('persona_selected');
    final loc = state.matchedLocation;
    final skipRoutes = [
      '/login',
      '/register',
      '/persona_selection',
      '/role_selection',
      '/guided_onboarding'
    ];
    if (skipRoutes.contains(loc)) return null;
    if (personaSelected == null) return '/persona_selection';
    return null;
  },
  routes: [
          GoRoute(
        path: '/swarm_ai',
        pageBuilder: (context, state) => AppPageTransition.buildPage(
          context: context,
          state: state,
          child: DeferredLoader(loadLibrary: swarm_ai.loadLibrary, builder: () => swarm_ai.SwarmAiScreen()),
        ),
      ),
      GoRoute(
      path: '/search',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final persona = extra?['persona'] as String?;
        return SearchScreen(initialPersona: persona);
      },
    ),
    GoRoute(
      path: '/calculator/roi',
      builder: (context, state) => const RoiCalculatorScreen(),
    ),
    GoRoute(
      path: '/annual_summary',
      builder: (context, state) => const AnnualSummaryScreen(),
    ),
    GoRoute(
      path: '/persona_selection',
      builder: (context, state) => const PersonaSelectionScreen(),
    ),
    GoRoute(
      path: '/guided_onboarding',
      builder: (context, state) => const GuidedOnboardingScreen(),
    ),
    GoRoute(
      path: '/',
      redirect: (context, state) {
        final user = FirebaseAuth.instance.currentUser;
        return user != null ? '/home' : '/landing';
      },
    ),
    GoRoute(
      path: '/landing',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => AppPageTransition.buildPage(
        context: context,
        state: state,
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => AppPageTransition.buildPage(
        context: context,
        state: state,
        child: const RegisterScreen(),
      ),
    ),
    GoRoute(
      path: '/role_selection',
      pageBuilder: (context, state) => AppPageTransition.buildPage(
        context: context,
        state: state,
        child: const RoleSelectionScreen(),
      ),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => AppPageTransition.buildPage(
        context: context,
        state: state,
        child: DeferredLoader(loadLibrary: home_screen.loadLibrary, builder: () => home_screen.HomeScreen()),
      ),
    ),
    GoRoute(
      path: '/previo',
      pageBuilder: (context, state) => AppPageTransition.buildPage(
        context: context,
        state: state,
        child: const PrevioScreen(),
      ),
    ),
    GoRoute(
      path: '/pre_glosa',
      pageBuilder: (context, state) => AppPageTransition.buildPage(
        context: context,
        state: state,
        child: const PreGlosaScreen(),
      ),
    ),
    GoRoute(
      path: '/calculator',
      pageBuilder: (context, state) => AppPageTransition.buildPage(
        context: context,
        state: state,
        child: const TipoCambioScreen(),
      ),
    ),
    GoRoute(
      path: '/classifier',
      pageBuilder: (context, state) => AppPageTransition.buildPage(
        context: context,
        state: state,
        child: const ClassifierScreen(),
      ),
    ),
    GoRoute(
      path: '/financial_dashboard',
      pageBuilder: (context, state) => AppPageTransition.buildPage(
        context: context,
        state: state,
        child: const FinancialDashboardScreen(),
      ),
    ),
    GoRoute(
      path: '/broker_hub',
      pageBuilder: (context, state) => AppPageTransition.buildPage(
        context: context,
        state: state,
        child: const BrokerHubScreen(),
      ),
    ),
    GoRoute(
      path: '/immex',
      pageBuilder: (context, state) => AppPageTransition.buildPage(
        context: context,
        state: state,
        child: const ImmexScreen(),
      ),
    ),
    GoRoute(
      path: '/tmec',
      redirect: (context, state) {
        RecentRoutesTracker.recordVisit('/tmec', 'Análisis TMEC');
        return null;
      },
      pageBuilder: (context, state) => AppPageTransition.buildPage(
        context: context,
        state: state,
        child: const TmecScreen(),
      ),
    ),
    GoRoute(
        path: '/escritos_legales',
        builder: (context, state) => const EscritosLegalesScreen()),
    GoRoute(
        path: '/motor_proformas',
        builder: (context, state) => const MotorProformasScreen()),
    GoRoute(
        path: '/trafico_despacho',
        builder: (context, state) => const TraficoDespachoScreen()),
    GoRoute(
        path: '/cross_match_glosa',
        builder: (context, state) => const CrossMatchGlosaScreen()),
    GoRoute(
        path: '/generador_doda_pita',
        builder: (context, state) => const GeneradorDodaPitaScreen()),
    GoRoute(
        path: '/monitor_encargos',
        builder: (context, state) => const MonitorEncargosScreen()),
    GoRoute(
        path: '/boveda_vucem',
        builder: (context, state) => const BovedaVucemScreen()),
    GoRoute(
        path: '/auditor_tmec_bom',
        builder: (context, state) => const AuditorTmecBomScreen()),
    GoRoute(
        path: '/cotizador_d2d',
        builder: (context, state) => const CotizadorDoorToDoorScreen()),
    GoRoute(
        path: '/sli_vgm',
        builder: (context, state) => const SliVgmGeneratorScreen()),
    GoRoute(
        path: '/rutas_globales',
        builder: (context, state) => const RutasGlobalesScreen()),
    GoRoute(
        path: '/traductor_corp',
        builder: (context, state) => const TraductorCorporativoScreen()),
    GoRoute(
      path: '/cuotas_compensatorias',
      builder: (context, state) => const _ComingSoonScreen(
          title: 'Cuotas Compensatorias',
          subtitle: 'Anti-dumping y cuotas compensatorias vigentes'),
    ),
    GoRoute(
      path: '/coming_soon',
      builder: (context, state) {
        final title =
            (state.extra as Map<String, dynamic>?)?['title'] as String? ??
                'Próximamente';
        return _ComingSoonScreen(
            title: title, subtitle: 'Esta función estará disponible pronto');
      },
    ),
    GoRoute(
        path: '/calculadora_seguros',
        builder: (context, state) => const CalculadoraSegurosScreen()),
    GoRoute(
        path: '/rescate',
        builder: (context, state) => const RescateEnterpriseScreen()),
    GoRoute(
        path: '/glosa_colab',
        builder: (context, state) => const GlosaColaborativaScreen()),
    GoRoute(
        path: '/traffic_tower',
        builder: (context, state) => const TrafficTowerScreen()),
    GoRoute(
        path: '/esg', builder: (context, state) => const EsgCalculatorScreen()),
    GoRoute(
        path: '/comando_fiscal',
        builder: (context, state) => const ComandoFiscalScreen()),
    GoRoute(
        path: '/agenda_venc',
        builder: (context, state) => const AgendaVencimientosScreen()),
    GoRoute(
      path: '/swarm_ai',
      builder: (context, state) => const PremiumGate(
        requiredPlan: UserPlan.enterprise,
        featureName: 'Swarm AI',
        featureDescription:
            'Inteligencia colaborativa para predicción aduanera y operaciones distribuidas.',
        child: SwarmAiScreen(),
      ),
    ),
    GoRoute(
        path: '/api_gateway',
        builder: (context, state) => const ApiGatewayScreen()),
    GoRoute(
        path: '/data_integration',
        builder: (context, state) => const DataIntegrationScreen()),
    GoRoute(
        path: '/ai_copilot',
        builder: (context, state) => const AiCopilotScreen()),
    GoRoute(
        path: '/compliance',
        builder: (context, state) => const ComplianceScreen()),
    GoRoute(
      path: '/kanban',
      builder: (context, state) => const PremiumGate(
        requiredPlan: UserPlan.pro,
        featureName: 'Kanban Operativo',
        featureDescription:
            'Gestión visual de flujos de trabajo y operaciones aduaneras.',
        child: KanbanScreen(),
      ),
    ),

    // Auth
    GoRoute(
        path: '/tools_hub',
        builder: (context, state) => const CatalogoAppsScreen()),

    // Conectando las pantallas generadas
    GoRoute(
        path: '/profile', builder: (context, state) => const ProfileScreen()),
    GoRoute(
        path: '/history', builder: (context, state) => const HistoryScreen()),
    GoRoute(
        path: '/scanner', builder: (context, state) => const ScannerScreen()),
    GoRoute(
      path: '/ml_audit_predictor',
      builder: (context, state) => const PremiumGate(
        requiredPlan: UserPlan.enterprise,
        featureName: 'ML Audit Predictor',
        featureDescription:
            'Predice auditorías de comercio exterior usando Machine Learning avanzado.',
        child: MlAuditPredictorScreen(),
      ),
    ),
    GoRoute(
        path: '/eagle_eye',
        builder: (context, state) => const EagleEyeScreen()),
    GoRoute(
        path: '/sat_radar',
        builder: (context, state) => const SatRadarScreen()),
    GoRoute(
        path: '/aml_scanner',
        builder: (context, state) => const AmlScannerScreen()),
    GoRoute(
      path: '/cashflow',
      builder: (context, state) => const PremiumGate(
        requiredPlan: UserPlan.pro,
        featureName: 'Cashflow',
        featureDescription:
            'Control y proyecciones de flujo de caja para operaciones.',
        child: CashflowScreen(),
      ),
    ),
    GoRoute(
        path: '/landed_cost',
        redirect: (context, state) {
          RecentRoutesTracker.recordVisit('/landed_cost', 'Landed Cost');
          return null;
        },
        builder: (context, state) => const LandedCostScreen()),
    GoRoute(
        path: '/demurrage',
        builder: (context, state) => const DemurrageScreen()),
    GoRoute(
        path: '/importer_hub',
        builder: (context, state) => const ImporterHubScreen()),
    GoRoute(
        path: '/simple_estimator',
        builder: (context, state) => const SimpleEstimatorScreen()),
    GoRoute(
        path: '/mi_primer_despacho',
        builder: (context, state) => const MiPrimerImportacionScreen()),

    GoRoute(
        path: '/shared_workspace',
        builder: (context, state) => const SharedWorkspaceScreen()),
    GoRoute(
        path: '/virtual_ops',
        builder: (context, state) => const VirtualOpsScreen()),
    GoRoute(
        path: '/ctpat_hub',
        builder: (context, state) => const CtpatHubScreen()),
    GoRoute(
        path: '/incoterms',
        builder: (context, state) => const IncotermsScreen()),
    GoRoute(
        path: '/carta_porte',
        builder: (context, state) => const CartaPorteScreen()),
    GoRoute(
        path: '/global_sourcing',
        builder: (context, state) => const GlobalSourcingScreen()),
    GoRoute(
        path: '/auditor', builder: (context, state) => const AuditorScreen()),
    GoRoute(
        path: '/blockchain_auditor',
        builder: (context, state) => const BlockchainAuditorScreen()),
    GoRoute(
        path: '/m3_analyzer',
        builder: (context, state) => const M3AnalyzerScreen()),
    GoRoute(path: '/saai', builder: (context, state) => const SaaiScreen()),
    GoRoute(
        path: '/configuracion',
        builder: (context, state) => const ConfiguracionScreen()),
    GoRoute(
        path: '/blockchain_ledger',
        builder: (context, state) => const BlockchainLedgerScreen()),
    GoRoute(
        path: '/pre_validador_m3',
        builder: (context, state) => const PreValidadorM3Screen()),
    GoRoute(
        path: '/validador_xml',
        builder: (context, state) => const ValidadorXmlScreen()),
    GoRoute(
        path: '/apendice8_matrix',
        builder: (context, state) => const Apendice8Screen()),
    GoRoute(
      path: '/m3_forensics',
      builder: (context, state) => const PremiumGate(
        requiredPlan: UserPlan.enterprise,
        featureName: 'M3 Forense',
        featureDescription:
            'Análisis forense de pedimentos con IA. Detecta inconsistencias y errores en clasificación arancelaria.',
        child: M3ForensicsScreen(),
      ),
    ),
    GoRoute(
        path: '/motor_a22',
        builder: (context, state) => const MotorA22Screen()),
    GoRoute(
        path: '/clasificador_ia',
        builder: (context, state) => const ClasificadorIaScreen()),
    GoRoute(
        path: '/simulador_pedimento',
        builder: (context, state) => const SimuladorPedimentoScreen()),
    GoRoute(
        path: '/historial_m3',
        builder: (context, state) => const HistorialM3Screen()),
    GoRoute(
        path: '/oea_seciit',
        builder: (context, state) => const OeaSeciitScreen()),
    GoRoute(
        path: '/consultor_tigie',
        builder: (context, state) => const ConsultorTigieScreen()),
    GoRoute(
      path: '/warroom_simulator',
      builder: (context, state) => const PremiumGate(
        requiredPlan: UserPlan.enterprise,
        featureName: 'Warroom Simulator',
        featureDescription:
            'Simulador de escenarios de riesgo aduanero y auditorías complejas.',
        child: WarroomSimulatorScreen(),
      ),
    ),
    GoRoute(
        path: '/conciliador_visor_b',
        builder: (context, state) => const ConciliadorVisorBScreen()),
    GoRoute(
        path: '/anexo30', builder: (context, state) => const Anexo30Screen()),
    GoRoute(
        path: '/integracion_cuantica',
        builder: (context, state) => const IntegracionCuanticaScreen()),
    GoRoute(
        path: '/conciliador_sap',
        builder: (context, state) => const ConciliadorSapScreen()),
    GoRoute(path: '/agace', builder: (context, state) => const AgaceScreen()),
    GoRoute(
        path: '/ar_visor', builder: (context, state) => const ArVisorScreen()),
    GoRoute(
        path: '/copiloto', builder: (context, state) => const CopilotoScreen()),
    GoRoute(
        path: '/border_sync',
        builder: (context, state) => const BorderSyncScreen()),
    GoRoute(
        path: '/merceologia',
        builder: (context, state) => const MerceologiaScreen()),
    GoRoute(
        path: '/vencimientos',
        builder: (context, state) => const AgendaVencimientosScreen()),
    GoRoute(path: '/alerts', builder: (context, state) => const AlertsScreen()),
    GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationCenterScreen()),
    GoRoute(
        path: '/cotizador_servicios',
        builder: (context, state) => const CotizadorServiciosScreen()),
    GoRoute(
        path: '/despacho_hub',
        builder: (context, state) => const DespachoHubScreen()),
    GoRoute(
        path: '/boveda_fiel',
        builder: (context, state) => const BovedaFielScreen()),
    GoRoute(
        path: '/lista_negra_sat',
        builder: (context, state) => const ListaNegraSatScreen()),
    GoRoute(
        path: '/vucem_sync',
        builder: (context, state) => const VucemSyncScreen()),
    GoRoute(
        path: '/manifestacion_valor',
        builder: (context, state) => const ManifestacionValorScreen()),
    GoRoute(
        path: '/rectificacion_m11',
        builder: (context, state) => const RectificacionM11Screen()),
    GoRoute(path: '/control_immex', redirect: (_, __) => '/immex'),
    GoRoute(
        path: '/despacho',
        builder: (context, state) {
          final tipo = state.uri.queryParameters['tipo'] ?? 'importacion';
          return DespachoScreen(tipo: tipo);
        }),
    GoRoute(
        path: '/clientes',
        redirect: (context, state) {
          RecentRoutesTracker.recordVisit('/clientes', 'CRM Clientes');
          return null;
        },
        builder: (context, state) => const ClientesListScreen()),
    GoRoute(
        path: '/clientes/nuevo',
        builder: (context, state) => const ClienteFormScreen()),
    GoRoute(
        path: '/clientes/edit/:id',
        builder: (context, state) =>
            ClienteFormScreen(clienteId: state.pathParameters['id'])),
    GoRoute(
        path: '/clientes/:id',
        builder: (context, state) =>
            ClienteDetailScreen(clienteId: state.pathParameters['id']!)),
    GoRoute(
        path: '/rfc_verificador',
        builder: (context, state) =>
            RfcVerificadorScreen(initialRfc: state.uri.queryParameters['rfc'])),
    GoRoute(
        path: '/expedientes',
        redirect: (context, state) {
          RecentRoutesTracker.recordVisit('/expedientes', 'Expedientes');
          return null;
        },
        builder: (context, state) => const ExpedienteListScreen()),
    GoRoute(
        path: '/expedientes/:id',
        builder: (context, state) =>
            ExpedienteDetailScreen(expedienteId: state.pathParameters['id']!)),
    GoRoute(
        path: '/suppliers',
        builder: (context, state) => const SuppliersListScreen()),
    GoRoute(
        path: '/suppliers/nuevo',
        builder: (context, state) => const SupplierFormScreen()),
    GoRoute(
        path: '/suppliers/:id/edit',
        builder: (context, state) =>
            SupplierEditScreen(supplierId: state.pathParameters['id']!)),
    GoRoute(
        path: '/supply_chain/po',
        redirect: (context, state) {
          RecentRoutesTracker.recordVisit(
              '/supply_chain/po', 'Órdenes de Compra');
          return null;
        },
        builder: (context, state) => const PoListScreen()),
    GoRoute(
        path: '/tco_comparator',
        redirect: (context, state) {
          RecentRoutesTracker.recordVisit('/tco_comparator', 'Comparador TCO');
          return null;
        },
        builder: (context, state) => const TcoComparatorScreen()),
    GoRoute(
      path: '/importer_dashboard',
      redirect: (context, state) {
        RecentRoutesTracker.recordVisit(
            '/importer_dashboard', 'Dashboard Importador');
        return null;
      },
      builder: (context, state) => const PremiumGate(
        requiredPlan: UserPlan.pro,
        featureName: 'Dashboard Importador',
        featureDescription:
            'Dashboard financiero completo con KPIs, flujo de caja y análisis de operaciones. Disponible en el plan PRO Pyme.',
        child: ImporterDashboardScreen(),
      ),
    ),
    GoRoute(
        path: '/supply_chain/po/nueva',
        builder: (context, state) => const PoFormScreen()),
    GoRoute(
        path: '/financial/lc',
        builder: (context, state) => const LetterOfCreditScreen()),
    GoRoute(
        path: '/logistics/freight_quotes',
        builder: (context, state) => const FreightQuotesScreen()),
    GoRoute(
        path: '/regulatory/noms_advisor',
        builder: (context, state) => const NomsAdvisorScreen()),
    GoRoute(
        path: '/audit/invoice_match',
        builder: (context, state) => const InvoiceVsPedimentoScreen()),
    GoRoute(
        path: '/shipment_tracker',
        redirect: (context, state) {
          RecentRoutesTracker.recordVisit(
              '/shipment_tracker', 'Torre de Tráfico');
          return null;
        },
        builder: (context, state) => const ShipmentTrackerHubScreen()),
    GoRoute(
        path: '/shipment_tracker/nuevo',
        builder: (context, state) => const NuevoEmbarqueScreen()),
    GoRoute(
        path: '/semaforo', builder: (context, state) => const SemaforoScreen()),
    GoRoute(
        path: '/fraccion_simulator',
        builder: (context, state) => const FraccionSimulatorScreen()),
    GoRoute(
        path: '/regimen_comparator',
        builder: (context, state) => const RegimenComparatorScreen()),
    GoRoute(
        path: '/nom_calendar',
        redirect: (context, state) {
          RecentRoutesTracker.recordVisit('/nom_calendar', 'Calendario NOMs');
          return null;
        },
        builder: (context, state) => const NomCalendarScreen()),
    GoRoute(
        path: '/supplier_scorecard',
        builder: (context, state) => const SupplierScorecardScreen()),
    GoRoute(
        path: '/duty_drawback',
        redirect: (context, state) {
          RecentRoutesTracker.recordVisit('/duty_drawback', 'Duty Drawback');
          return null;
        },
        builder: (context, state) => const DutyDrawbackScreen()),
    GoRoute(
        path: '/roi_calculator',
        builder: (ctx, s) => const RoiCalculatorScreen()),
    GoRoute(
        path: '/permisos_previos',
        builder: (ctx, s) => const PermisosPreviosScreen()),
    GoRoute(
        path: '/carta_de_cupo', builder: (ctx, s) => const CartaDeCupoScreen()),
    GoRoute(
        path: '/learning_center',
        builder: (ctx, s) => const LearningCenterScreen()),
    GoRoute(
        path: '/requisitos_producto',
        builder: (ctx, s) => const RequisitosProductoScreen()),
    GoRoute(
        path: '/timeline_estimator',
        builder: (ctx, s) => const TimelineEstimatorScreen()),
        GoRoute(
        path: '/roi_dashboard',
        builder: (ctx, s) => const RoiDashboardScreen()),

    GoRoute(path: '/glosario', builder: (ctx, s) => const GlosarioScreen()),
    GoRoute(path: '/faq', builder: (ctx, s) => const FaqScreen()),
    GoRoute(path: '/pricing', builder: (ctx, s) => const PricingScreen()),
    GoRoute(
        path: '/subscription', builder: (ctx, s) => const SubscriptionScreen()),
    GoRoute(
        path: '/utilidad_neta',
        builder: (context, state) => const UtilidadNetaScreen()),
  ],
);

class _ComingSoonScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  const _ComingSoonScreen({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFF59E0B)),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.rocket_launch_outlined,
                color: Color(0xFFF59E0B), size: 64),
            const SizedBox(height: 24),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFF59E0B)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Disponible en la próxima versión',
                  style: TextStyle(color: Color(0xFFF59E0B), fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
