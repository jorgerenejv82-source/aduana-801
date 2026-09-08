import 'package:aduana_801/core/theme/app_colors.dart';
// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:firebase_ai/firebase_ai.dart';

// â”€â”€ Design Tokens â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const Color _bg = AppColors.bg;
const Color _card = AppColors.card;
const Color _card2 = AppColors.card;
const Color _bord = AppColors.border;
const Color _texto = AppColors.text;
const Color _sec = AppColors.sub;
const Color _gold = AppColors.gold;
const Color _rojo = AppColors.red;
const Color _azul = AppColors.blue;
const Color _verde = AppColors.green;
const Color _naran = AppColors.gold;

// â”€â”€ Tipo de Documento â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _TipoDoc {
  final String nombre;
  final String subtitulo;
  final String fundamento;
  final String placeholder;
  final Color color;
  final IconData icon;
  final List<Map<String, String>> articulosClave;
  const _TipoDoc({
    required this.nombre,
    required this.subtitulo,
    required this.fundamento,
    required this.placeholder,
    required this.color,
    required this.icon,
    required this.articulosClave,
  });
}

const List<_TipoDoc> _tipos = [
  _TipoDoc(
    nombre: 'Aclaracion de Pedimento',
    subtitulo: 'Art. 36-A LA: aclarar datos en pedimento',
    fundamento:
        'Articulo 36-A Ley Aduanera; Arts. 18, 19 CFF; Regla 6.1.1 RGCE vigentes.',
    placeholder:
        'Ej: El dia 15 de mayo de 2026, se presento el pedimento de importacion No. XXXX...',
    color: _azul,
    icon: Icons.edit_document,
    articulosClave: [
      {
        'art': 'Art. 36-A',
        'ley': 'Ley Aduanera',
        'desc':
            'Documentos que deben acompanar al pedimento; base para aclaracion de datos.'
      },
      {
        'art': 'Art. 18',
        'ley': 'CFF',
        'desc': 'Derecho de peticion ante autoridades fiscales.'
      },
      {
        'art': 'Art. 19',
        'ley': 'CFF',
        'desc': 'Forma de presentacion de promociones ante el SAT.'
      },
      {
        'art': 'Regla 6.1.1',
        'ley': 'RGCE',
        'desc': 'Procedimiento para rectificacion y aclaracion de pedimentos.'
      },
    ],
  ),
  _TipoDoc(
    nombre: 'Recurso de Revocacion',
    subtitulo: 'Arts. 116-133 CFF: impugnar resoluciones SAT',
    fundamento:
        'Arts. 116-133 CFF; Art. 121 CFF (plazo 30 dias); Art. 132 CFF; Art. 144 CFF.',
    placeholder:
        'Ej: Con fecha XX de 2026, la autoridad aduanera emitio la resolucion impugnada mediante oficio...',
    color: _rojo,
    icon: Icons.gavel,
    articulosClave: [
      {
        'art': 'Arts. 116-133',
        'ley': 'CFF',
        'desc': 'Regimen legal completo del Recurso de Revocacion ante el SAT.'
      },
      {
        'art': 'Art. 121',
        'ley': 'CFF',
        'desc': 'Plazo de 30 dias habiles para interponer el recurso.'
      },
      {
        'art': 'Art. 132',
        'ley': 'CFF',
        'desc':
            'Resolucion del recurso: confirmacion, modificacion o revocacion.'
      },
      {
        'art': 'Art. 144',
        'ley': 'CFF',
        'desc': 'Suspension de la ejecucion del acto impugnado.'
      },
    ],
  ),
  _TipoDoc(
    nombre: 'Ampliacion de Plazo',
    subtitulo: 'Art. 66 CFF: solicitar mas tiempo para responder',
    fundamento:
        'Art. 12 CFF (computo de plazos); Art. 66 CFF; Art. 23 Ley Aduanera.',
    placeholder:
        'Ej: En respuesta al requerimiento de fecha XX/XX/2026, y dadas las circunstancias...',
    color: _naran,
    icon: Icons.timer_outlined,
    articulosClave: [
      {
        'art': 'Art. 12',
        'ley': 'CFF',
        'desc': 'Computo de plazos en dias habiles y naturales.'
      },
      {
        'art': 'Art. 66',
        'ley': 'CFF',
        'desc':
            'Autorizacion para ampliar plazos cuando existe causa justificada.'
      },
      {
        'art': 'Art. 23',
        'ley': 'Ley Aduanera',
        'desc': 'Plazos para el despacho aduanero de mercancias.'
      },
    ],
  ),
  _TipoDoc(
    nombre: 'Declaracion Bajo Protesta',
    subtitulo: 'Art. 59 LA: declarar valor real de mercancias',
    fundamento:
        'Art. 59 LA; Arts. 72-75 LA; Art. 1.2 Acuerdo Valoracion OMC; Art. 82 CFF.',
    placeholder:
        'Ej: El suscrito, en mi caracter de importador, DECLARO BAJO PROTESTA DE DECIR VERDAD que...',
    color: _verde,
    icon: Icons.verified_user_outlined,
    articulosClave: [
      {
        'art': 'Art. 59',
        'ley': 'Ley Aduanera',
        'desc': 'Obligaciones del importador al presentar pedimento.'
      },
      {
        'art': 'Arts. 72-75',
        'ley': 'Ley Aduanera',
        'desc': 'Determinacion del valor en aduana de las mercancias.'
      },
      {
        'art': 'Art. 1.2',
        'ley': 'Acuerdo de Valoracion OMC',
        'desc': 'Precio de transaccion como base para el valor en aduana.'
      },
      {
        'art': 'Art. 82',
        'ley': 'CFF',
        'desc': 'Responsabilidad penal por declaraciones falsas.'
      },
    ],
  ),
  _TipoDoc(
    nombre: 'Regularizacion IMMEX',
    subtitulo: 'Art. 135-A LA: regularizar mercancias temporales',
    fundamento:
        'Art. 21 Decreto IMMEX; Art. 106 LA; Art. 135-A LA; Regla 4.3.1 RGCE.',
    placeholder:
        'Ej: La empresa que represento opera bajo el programa IMMEX No. XXXX y requiere regularizar...',
    color: _gold,
    icon: Icons.factory_outlined,
    articulosClave: [
      {
        'art': 'Art. 21',
        'ley': 'Decreto IMMEX',
        'desc': 'Obligaciones del titular del programa IMMEX.'
      },
      {
        'art': 'Art. 106',
        'ley': 'Ley Aduanera',
        'desc': 'Regimen de importacion temporal y sus plazos.'
      },
      {
        'art': 'Art. 135-A',
        'ley': 'Ley Aduanera',
        'desc': 'Procedimiento de regularizacion de mercancias temporales.'
      },
      {
        'art': 'Regla 4.3.1',
        'ley': 'RGCE',
        'desc': 'Regularizacion administrativa de temporales en IMMEX.'
      },
    ],
  ),
  _TipoDoc(
    nombre: 'No Vinculacion',
    subtitulo: 'Art. 68 LA: demostrar independencia comprador-vendedor',
    fundamento:
        'Arts. 68, 72 LA; Art. 15 y Art. 1.2(a) Acuerdo Valoracion OMC.',
    placeholder:
        'Ej: La empresa que represento sostiene que la relacion comercial con el proveedor extranjero no...',
    color: _sec,
    icon: Icons.link_off,
    articulosClave: [
      {
        'art': 'Art. 68',
        'ley': 'Ley Aduanera',
        'desc': 'Presuncion de vinculacion entre comprador y vendedor.'
      },
      {
        'art': 'Art. 72',
        'ley': 'Ley Aduanera',
        'desc': 'Aceptacion del valor de transaccion pese a vinculacion.'
      },
      {
        'art': 'Art. 15',
        'ley': 'Acuerdo de Valoracion OMC',
        'desc': 'Definicion de personas vinculadas en comercio internacional.'
      },
      {
        'art': 'Art. 1.2(a)',
        'ley': 'Acuerdo de Valoracion OMC',
        'desc': 'Circunstancias de venta que demuestran precio no afectado.'
      },
    ],
  ),
  _TipoDoc(
    nombre: 'Devolucion Art. 22 CFF',
    subtitulo: 'Art. 22 CFF: recuperar contribuciones pagadas en exceso',
    fundamento: 'Art. 22 CFF; Art. 22-A CFF; Arts. 18, 19 CFF; Art. 146-A LA.',
    placeholder:
        'Ej: Con fundamento en el Art. 22 del CFF, solicito la devolucion de contribuciones pagadas en exceso...',
    color: _verde,
    icon: Icons.account_balance_wallet_outlined,
    articulosClave: [
      {
        'art': 'Art. 22',
        'ley': 'CFF',
        'desc':
            'Devolucion de cantidades pagadas indebidamente al Fisco Federal.'
      },
      {
        'art': 'Art. 22-A',
        'ley': 'CFF',
        'desc': 'Plazo de 40 dias para resolver solicitudes de devolucion.'
      },
      {
        'art': 'Art. 18',
        'ley': 'CFF',
        'desc': 'Requisitos de las promociones ante autoridades fiscales.'
      },
      {
        'art': 'Art. 146-A',
        'ley': 'Ley Aduanera',
        'desc':
            'Devolucion de contribuciones en operaciones de comercio exterior.'
      },
    ],
  ),
  _TipoDoc(
    nombre: 'Impugnacion de Multa',
    subtitulo: 'Arts. 70-91 CFF: contestar sanciones aduaneras',
    fundamento: 'Arts. 70-91 CFF; Art. 178 LA; Art. 121 CFF; Art. 76-A CFF.',
    placeholder:
        'Ej: Con fecha XX/XX/2026, la autoridad aduanera impuso multa por infraccion al Art. XX LA...',
    color: _rojo,
    icon: Icons.money_off_outlined,
    articulosClave: [
      {
        'art': 'Arts. 70-91',
        'ley': 'CFF',
        'desc': 'Infracciones y sanciones en materia fiscal y aduanera.'
      },
      {
        'art': 'Art. 178',
        'ley': 'Ley Aduanera',
        'desc': 'Infracciones especificas en materia aduanera.'
      },
      {
        'art': 'Art. 76-A',
        'ley': 'CFF',
        'desc': 'Reduccion de multas por correccion espontanea.'
      },
    ],
  ),
  _TipoDoc(
    nombre: 'Carta de Credito Fiscal',
    subtitulo: 'Solicitar certificacion de saldos a favor',
    fundamento: 'Arts. 22, 23 CFF; Reglas de caracter general SAT vigentes.',
    placeholder:
        'Ej: Solicito la emision de carta de credito fiscal por saldo a favor correspondiente al periodo...',
    color: _azul,
    icon: Icons.credit_card_outlined,
    articulosClave: [
      {
        'art': 'Art. 22',
        'ley': 'CFF',
        'desc': 'Saldos a favor y su aplicacion.'
      },
      {
        'art': 'Art. 23',
        'ley': 'CFF',
        'desc': 'Compensacion de contribuciones federales.'
      },
    ],
  ),
  _TipoDoc(
    nombre: 'Desistimiento de Operacion',
    subtitulo: 'Art. 150 LA: cancelar pedimento antes de liberar',
    fundamento: 'Art. 150 LA; Regla 6.2.1 RGCE; Art. 46 LA.',
    placeholder:
        'Ej: Por medio del presente escrito, solicito el desistimiento del pedimento de importacion...',
    color: _naran,
    icon: Icons.cancel_outlined,
    articulosClave: [
      {
        'art': 'Art. 150',
        'ley': 'Ley Aduanera',
        'desc':
            'Facultad del importador para desistir de la operacion aduanera.'
      },
      {
        'art': 'Regla 6.2.1',
        'ley': 'RGCE',
        'desc': 'Procedimiento de desistimiento ante la aduana.'
      },
      {
        'art': 'Art. 46',
        'ley': 'Ley Aduanera',
        'desc': 'Mercancias que pueden retirarse antes del reconocimiento.'
      },
    ],
  ),
  _TipoDoc(
    nombre: 'OEA â€” Operador Economico Autorizado',
    subtitulo: 'Arts. 100-A a 100-H LA: obtener certificacion OEA',
    fundamento:
        'Arts. 100-A â€” 100-H Ley Aduanera; Regla 7.2.1 RGCE; Marco SAFE OMA; Art. 1 LA.',
    placeholder:
        'Ej: La empresa que represento cumple con todos los requisitos del programa OEA y solicita...',
    color: _azul,
    icon: Icons.verified_outlined,
    articulosClave: [
      {
        'art': 'Arts. 100-A â€” 100-H',
        'ley': 'Ley Aduanera',
        'desc': 'Marco legal del Operador Economico Autorizado en Mexico.'
      },
      {
        'art': 'Regla 7.2.1',
        'ley': 'RGCE',
        'desc': 'Requisitos y procedimiento para obtener certificacion OEA.'
      },
      {
        'art': 'Marco SAFE',
        'ley': 'OMA',
        'desc':
            'Estandares internacionales de la Organizacion Mundial de Aduanas.'
      },
      {
        'art': 'Art. 1',
        'ley': 'Ley Aduanera',
        'desc': 'Objeto de la ley: facilitar el comercio exterior legitimo.'
      },
    ],
  ),
  _TipoDoc(
    nombre: 'Queja ante PRODECON',
    subtitulo: 'Ley Organica PRODECON: reclamar actos ilegales del SAT',
    fundamento:
        'Arts. 1-6 Ley Organica PRODECON; Arts. 14, 16 CPEUM; Art. 34 CFF.',
    placeholder:
        'Ej: Por medio del presente escrito presento queja ante la Procuraduria de la Defensa del Contribuyente...',
    color: _rojo,
    icon: Icons.report_outlined,
    articulosClave: [
      {
        'art': 'Arts. 1-6',
        'ley': 'Ley Organica PRODECON',
        'desc': 'Naturaleza, objeto y atribuciones de la Procuraduria.'
      },
      {
        'art': 'Art. 14',
        'ley': 'Constitucion Politica',
        'desc': 'Garantia de audiencia y debido proceso legal.'
      },
      {
        'art': 'Art. 16',
        'ley': 'Constitucion Politica',
        'desc':
            'Principio de legalidad: actos de autoridad fundados y motivados.'
      },
      {
        'art': 'Art. 34',
        'ley': 'CFF',
        'desc':
            'Consultas sobre situacion fiscal real y concreta del contribuyente.'
      },
    ],
  ),
];

// â”€â”€ Escrito guardado â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _Escrito {
  final String tipo;
  final String rfc;
  final String aduana;
  final String fecha;
  final String contenido;
  _Escrito(
      {required this.tipo,
      required this.rfc,
      required this.aduana,
      required this.fecha,
      required this.contenido});
}

// â”€â”€ Screen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class EscritosLegalesScreen extends StatefulWidget {
  const EscritosLegalesScreen({super.key});
  @override
  State<EscritosLegalesScreen> createState() => _EscritosLegalesScreenState();
}

class _EscritosLegalesScreenState extends State<EscritosLegalesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  // â”€â”€ Form state â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  int _tipoIdx = 0;
  final _rfcCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _domCtrl = TextEditingController();
  final _aduanaCtrl = TextEditingController();
  final _pedCtrl = TextEditingController();
  final _hechosCtrl = TextEditingController();
  DateTime _fecha = DateTime.now();
  bool _generating = false;
  String _escritoGenerado = '';

  final List<_Escrito> _historial = [];

  _TipoDoc get _tipo => _tipos[_tipoIdx];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _rfcCtrl.dispose();
    _nombreCtrl.dispose();
    _domCtrl.dispose();
    _aduanaCtrl.dispose();
    _pedCtrl.dispose();
    _hechosCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        _buildHeader(),
        Expanded(
            child: TabBarView(controller: _tabCtrl, children: [
          _tabGenerador(),
          _tabHistorial(),
          _tabBaseLegal(),
        ])),
      ]),
    );
  }

  Widget _buildHeader() => Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 14, 0),
        decoration: const BoxDecoration(
            color: _bg, border: Border(bottom: BorderSide(color: _bord))),
        child: Column(children: [
          Row(children: [
            InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _bord)),
                    child:
                        const Icon(Icons.chevron_left, color: _sec, size: 20))),
            const SizedBox(width: 12),
            Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: _gold.withAlpha(25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _gold.withAlpha(80))),
                child: const Icon(Icons.description_outlined,
                    color: _gold, size: 16)),
            const SizedBox(width: 10),
            const Text('Escritos Legales Aduanales',
                style: TextStyle(
                    color: _texto, fontSize: 15, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            indicatorColor: _gold,
            labelColor: _gold,
            unselectedLabelColor: _sec,
            labelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            tabs: const [
              Tab(icon: Icon(Icons.edit_note, size: 14), text: 'Generador'),
              Tab(icon: Icon(Icons.history, size: 14), text: 'Historial'),
              Tab(icon: Icon(Icons.menu_book, size: 14), text: 'Base Legal'),
            ],
          ),
        ]),
      );

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // TAB 1 â€” Generador
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _tabGenerador() =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // â”€â”€ Left sidebar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        SizedBox(
            width: 240,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                  color: _card2,
                  border: Border(right: BorderSide(color: _bord))),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tipo selector
                      _sideSection('Tipo de Documento Legal', _gold, children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                              color: _bg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _bord)),
                          child: DropdownButton<int>(
                            value: _tipoIdx,
                            isExpanded: true,
                            dropdownColor: _card2,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: _sec, size: 18),
                            style: const TextStyle(color: _texto, fontSize: 11),
                            items: _tipos
                                .asMap()
                                .entries
                                .map((e) => DropdownMenuItem(
                                      value: e.key,
                                      child: Text(e.value.nombre,
                                          overflow: TextOverflow.ellipsis),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() {
                              _tipoIdx = v!;
                              _escritoGenerado = '';
                            }),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                              color: _tipo.color.withAlpha(15),
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: _tipo.color.withAlpha(60))),
                          child: Row(children: [
                            Icon(_tipo.icon, color: _tipo.color, size: 12),
                            const SizedBox(width: 6),
                            Expanded(
                                child: Text(_tipo.subtitulo,
                                    style: TextStyle(
                                        color: _tipo.color,
                                        fontSize: 9,
                                        height: 1.4))),
                          ]),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      // Datos del solicitante
                      _sideSection('Datos del Solicitante', _azul, children: [
                        _sfi(_rfcCtrl, 'RFC Solicitante',
                            Icons.business_outlined),
                        const SizedBox(height: 8),
                        _sfi(_nombreCtrl, 'Nombre / Razon Social',
                            Icons.person_outlined),
                        const SizedBox(height: 8),
                        _sfi(_domCtrl, 'Domicilio Fiscal', Icons.home_outlined),
                        const SizedBox(height: 8),
                        _sfi(_aduanaCtrl, 'Aduana (ej. Manzanillo)',
                            Icons.location_on_outlined),
                        const SizedBox(height: 8),
                        _sfi(_pedCtrl, 'Numero de Pedimento',
                            Icons.receipt_outlined),
                        const SizedBox(height: 8),
                        // Date picker
                        InkWell(
                          onTap: () async {
                            final d = await showDatePicker(
                                context: context,
                                initialDate: _fecha,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                                builder: (c, ch) => Theme(
                                    data: ThemeData.dark().copyWith(
                                        colorScheme: const ColorScheme.dark(
                                            primary: _gold)),
                                    child: ch!));
                            if (d != null) setState(() => _fecha = d);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                                color: _bg,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _bord)),
                            child: Row(children: [
                              const Icon(Icons.calendar_today_outlined,
                                  color: _sec, size: 13),
                              const SizedBox(width: 8),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Fecha del Escrito',
                                        style: TextStyle(
                                            color: _sec, fontSize: 8)),
                                    Text(
                                        '${_fecha.day.toString().padLeft(2, '0')}/${_fecha.month.toString().padLeft(2, '0')}/${_fecha.year}',
                                        style: const TextStyle(
                                            color: _texto,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600)),
                                  ]),
                            ]),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      // Hechos y Antecedentes
                      _sideSection('Hechos y Antecedentes', _gold,
                          subtitle: 'Describe detalladamente los hechos',
                          children: [
                            TextField(
                              controller: _hechosCtrl,
                              maxLines: 6,
                              style:
                                  const TextStyle(color: _texto, fontSize: 11),
                              decoration: InputDecoration(
                                hintText: _tipo.placeholder,
                                hintStyle: const TextStyle(
                                    color: _sec, fontSize: 10, height: 1.5),
                                filled: true,
                                fillColor: _bg,
                                contentPadding: const EdgeInsets.all(10),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: _bord)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: _bord)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(color: _gold)),
                              ),
                            ),
                          ]),
                      const SizedBox(height: 14),
                      // Fundamento Legal (auto-sugerido)
                      _sideSection('Fundamento Legal', _verde,
                          badge: 'Auto-sugerido',
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: _bg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: _bord)),
                              child: Text(_tipo.fundamento,
                                  style: const TextStyle(
                                      color: _texto,
                                      fontSize: 10,
                                      height: 1.5)),
                            ),
                          ]),
                      const SizedBox(height: 14),
                      // Generar button
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _generating ? null : _generarEscrito,
                            icon: _generating
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                        color: Colors.black, strokeWidth: 2))
                                : const Icon(Icons.auto_awesome,
                                    size: 14, color: Colors.black),
                            label: Text(
                                _generating
                                    ? 'Generando...'
                                    : 'Generar Escrito con Gemini',
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _gold,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16))),
                          )),
                    ]),
              ),
            )),
        // â”€â”€ Right â€” Preview â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        Expanded(
          child: _escritoGenerado.isEmpty
              ? Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                              color: _gold.withAlpha(20),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _gold.withAlpha(60))),
                          child: const Icon(Icons.description_outlined,
                              color: _gold, size: 30)),
                      const SizedBox(height: 16),
                      const Text('Selecciona el tipo de documento,',
                          style: TextStyle(color: _sec, fontSize: 13)),
                      const Text('completa los datos y genera',
                          style: TextStyle(color: _sec, fontSize: 13)),
                      const Text('tu escrito legal con Gemini Pro.',
                          style: TextStyle(color: _sec, fontSize: 13)),
                      const SizedBox(height: 10),
                      Text('${_tipos.length} tipos de documentos disponibles',
                          style: const TextStyle(
                              color: _gold,
                              fontSize: 11,
                              decoration: TextDecoration.underline)),
                    ]))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(_tipo.icon, color: _tipo.color, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                              child: Text(_tipo.nombre.toUpperCase(),
                                  style: TextStyle(
                                      color: _tipo.color,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5))),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _historial.insert(
                                    0,
                                    _Escrito(
                                        tipo: _tipo.nombre,
                                        rfc: _rfcCtrl.text.isEmpty
                                            ? 'RFC-XXXX'
                                            : _rfcCtrl.text,
                                        aduana: _aduanaCtrl.text.isEmpty
                                            ? 'Aduana'
                                            : _aduanaCtrl.text,
                                        fecha:
                                            '${_fecha.day.toString().padLeft(2, '0')}/${_fecha.month.toString().padLeft(2, '0')}/${_fecha.year}',
                                        contenido: _escritoGenerado));
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Escrito guardado en Historial.'),
                                      backgroundColor: _verde,
                                      behavior: SnackBarBehavior.floating));
                            },
                            icon: const Icon(Icons.save_outlined,
                                size: 13, color: _verde),
                            label: const Text('Guardar',
                                style: TextStyle(color: _verde, fontSize: 11)),
                            style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: _verde),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6))),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    content: Text(
                                        'Escrito copiado al portapapeles.'),
                                    backgroundColor: _azul,
                                    behavior: SnackBarBehavior.floating)),
                            icon: const Icon(Icons.copy_outlined,
                                size: 13, color: _azul),
                            label: const Text('Copiar',
                                style: TextStyle(color: _azul, fontSize: 11)),
                            style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: _azul),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6))),
                          ),
                        ]),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: _card,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: _bord)),
                          child: Text(_escritoGenerado,
                              style: const TextStyle(
                                  color: _texto,
                                  fontSize: 12,
                                  height: 1.8,
                                  fontFamily: 'serif')),
                        ),
                      ]),
                ),
        ),
      ]);

  Future<void> _generarEscrito() async {
    setState(() => _generating = true);

    final rfc = _rfcCtrl.text.isEmpty
        ? '[RFC DEL SOLICITANTE]'
        : _rfcCtrl.text.toUpperCase();
    final nombre = _nombreCtrl.text.isEmpty
        ? '[NOMBRE / RAZON SOCIAL]'
        : _nombreCtrl.text.toUpperCase();
    final dom = _domCtrl.text.isEmpty ? '[DOMICILIO FISCAL]' : _domCtrl.text;
    final aduana = _aduanaCtrl.text.isEmpty ? '[ADUANA]' : _aduanaCtrl.text;
    final ped = _pedCtrl.text.isEmpty ? '[NUMERO DE PEDIMENTO]' : _pedCtrl.text;
    final hechos = _hechosCtrl.text.isEmpty
        ? '[DESCRIBIR LOS HECHOS Y ANTECEDENTES DE LA OPERACION ADUANERA.]'
        : _hechosCtrl.text;
    final fdia =
        '${_fecha.day.toString().padLeft(2, '0')} de ${_mesNombre(_fecha.month)} de ${_fecha.year}';

    try {
      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-1.5-flash',
        systemInstruction: Content.system(
            'Eres un abogado especialista en derecho aduanero mexicano. Genera el escrito legal solicitado con fundamentos en la Ley Aduanera, RGCE, y CFF.'),
      );

      final prompt = '''Genera un escrito legal aduanero.
Tipo de Documento: ${_tipo.nombre}
Fundamento Sugerido: ${_tipo.fundamento}
Aduana: $aduana
Fecha: $fdia
Nombre: $nombre
RFC: $rfc
Domicilio: $dom
Pedimento: $ped
Hechos: $hechos

Devuelve SOLO el texto completo del escrito legal listo para presentarse.''';

      final response = await model.generateContent([Content.text(prompt)]);

      setState(() {
        _generating = false;
        _escritoGenerado = response.text ?? 'Error al generar el escrito.';
      });
    } catch (e) {
      setState(() => _generating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Error: \$e', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red));
      }
    }
  }

  String _mesNombre(int m) => const [
        'enero',
        'febrero',
        'marzo',
        'abril',
        'mayo',
        'junio',
        'julio',
        'agosto',
        'septiembre',
        'octubre',
        'noviembre',
        'diciembre'
      ][m - 1];

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // TAB 2 â€” Historial
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _tabHistorial() => _historial.isEmpty
      ? Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.history, color: _sec.withAlpha(80), size: 52),
          const SizedBox(height: 16),
          const Text('No hay escritos guardados aun.',
              style: TextStyle(
                  color: _sec, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          const Text('Genera y guarda un escrito desde la pestana Generador.',
              style: TextStyle(color: _sec, fontSize: 11)),
        ]))
      : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: _historial.length,
          itemBuilder: (_, i) {
            final e = _historial[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _bord)),
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: _gold.withAlpha(20),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _gold.withAlpha(60))),
                      child: const Icon(Icons.description_outlined,
                          color: _gold, size: 18)),
                  title: Text(e.tipo,
                      style: const TextStyle(
                          color: _texto,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  subtitle: Text('${e.rfc} â€¢ ${e.aduana} â€¢ ${e.fecha}',
                      style: const TextStyle(color: _sec, fontSize: 10)),
                  trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: _verde.withAlpha(20),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: _verde.withAlpha(60))),
                      child: const Text('Guardado',
                          style: TextStyle(
                              color: _verde,
                              fontSize: 9,
                              fontWeight: FontWeight.bold))),
                  children: [
                    const Divider(color: _bord),
                    Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _bord)),
                        child: Text(e.contenido,
                            style: const TextStyle(
                                color: _texto, fontSize: 10, height: 1.7))),
                  ],
                ),
              ),
            );
          },
        );

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // TAB 3 â€” Base Legal
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  Widget _tabBaseLegal() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Articulos Clave por Tipo de Escrito',
              style: TextStyle(
                  color: _texto, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          ..._tipos.map((t) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border(
                        left: BorderSide(color: t.color, width: 3),
                        top: const BorderSide(color: _bord),
                        right: const BorderSide(color: _bord),
                        bottom: const BorderSide(color: _bord))),
                child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(t.icon, color: t.color, size: 14),
                            const SizedBox(width: 8),
                            Text(t.nombre,
                                style: TextStyle(
                                    color: t.color,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ]),
                          const SizedBox(height: 10),
                          ...t.articulosClave.map((a) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                              color: t.color.withAlpha(20),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              border: Border.all(
                                                  color:
                                                      t.color.withAlpha(60))),
                                          child: Text(a['art']!,
                                              style: TextStyle(
                                                  color: t.color,
                                                  fontSize: 8,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                      const SizedBox(width: 10),
                                      Expanded(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                            Text(a['ley']!,
                                                style: const TextStyle(
                                                    color: _texto,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.w600)),
                                            Text(a['desc']!,
                                                style: const TextStyle(
                                                    color: _sec,
                                                    fontSize: 10,
                                                    height: 1.4)),
                                          ])),
                                    ]),
                              )),
                        ])),
              )),
        ]),
      );

  // â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _sideSection(String title, Color c,
          {String? subtitle, String? badge, required List<Widget> children}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(title,
                style: TextStyle(
                    color: c, fontSize: 11, fontWeight: FontWeight.bold)),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: c.withAlpha(20),
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(badge,
                      style: TextStyle(
                          color: c, fontSize: 8, fontWeight: FontWeight.bold))),
            ],
          ]),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: _sec, fontSize: 9))
          ],
          const SizedBox(height: 8),
          ...children,
        ],
      );

  Widget _sfi(TextEditingController c, String hint, IconData icon) => TextField(
        controller: c,
        style: const TextStyle(color: _texto, fontSize: 11),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _sec, fontSize: 10),
          prefixIcon: Icon(icon, color: _sec, size: 13),
          filled: true,
          fillColor: _bg,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          isDense: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _bord)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _bord)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: _gold)),
        ),
      );
}
