import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:worldwildprova/config.dart';
import 'package:worldwildprova/models_fromddbb/activity.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:worldwildprova/models_fromddbb/asistentes.dart';
import 'package:worldwildprova/models_fromddbb/tagChip.dart';
import 'package:worldwildprova/screens/mytickets_screen.dart';
import 'package:worldwildprova/screens/profile_screen.dart';
import 'package:worldwildprova/widgets/appTheme.dart';
import 'package:worldwildprova/widgets/authservice.dart';
import 'package:worldwildprova/widgets/buyTicketsBottomSheet.dart';
import 'package:worldwildprova/widgets/createALaGorraPayment.dart';
import 'package:worldwildprova/widgets/createReservaBottomSheet.dart';
import 'package:worldwildprova/widgets/entradasCounter.dart';
import 'package:worldwildprova/widgets/mainscaffold.dart';
import 'package:worldwildprova/widgets/mapafrombckdng.dart';
import 'package:worldwildprova/widgets/reportEventSheet.dart';
import 'package:worldwildprova/widgets/shareEventButton.dart';

class ActivityDetail extends StatefulWidget {
  final String activityUuid;
  final String userToken;

  const ActivityDetail(
      {super.key, required this.activityUuid, required this.userToken});

  @override
  _ActivityDetailState createState() => _ActivityDetailState();
}

class _ActivityDetailState extends State<ActivityDetail> {
  late String activityUuid;
  late String date;
  late String time;
  late List<Usuario> asistentes;
  late bool _asistenciaController;

  late AuthService authService;

  late bool? active;

  bool _showAsistentes = false;

  Map<String, int> cantidades = {}; // el uuid como clave
  double _totalEntradas = 0.0;

  bool _isLoading = false;
  bool? aLaGorraActive = false;

  final ScrollController _scrollController = ScrollController();
  bool _isAtBottom = false;

  @override
  void initState() {
    super.initState();
    activityUuid = widget.activityUuid;
    _initLocale();
    authService = Provider.of<AuthService>(context, listen: false);
    fetchActivity();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        if (!_isAtBottom) {
          setState(() {
            _isAtBottom = true;
          });
        }
      } else {
        if (_isAtBottom) {
          setState(() {
            _isAtBottom = false;
          });
        }
      }
    });
  }

  Future<void> _initLocale() async {
    await initializeDateFormatting('es_ES', null);
  }

  Activity? activity;

  //Función para hacer la solicitud GET
  Future<void> fetchActivity() async {
    try {
      final response = await http.get(
          Uri.parse(
              '${Config.serverIp}/activities/?activity_uuid=$activityUuid'),
          headers: {
            'Authorization': 'Bearer ${await authService.getAccessToken()}'
          });

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = json.decode(response.body);

        setState(() {
          activity = Activity.fromServerJson(data);
          date = DateFormat('dd/MM/yyyy').format(activity!.dateTime);
          time = DateFormat('HH:mm').format(activity!.dateTime);
          asistentes = activity!.asistentes!;
          _asistenciaController = activity!.going!;
          if (activity!.entradas != null) {
            for (var entrada in activity!.entradas!) {
              cantidades[entrada.uuid!] = 0;
            }
          }
          active = activity!.active;
          if (activity!.dateTime.isBefore(DateTime.now())) {
            aLaGorraActive = activity!.aLaGorra;
          }
        });
      } else {
        throw Exception('Failed to load places');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _calcularTotalEntradas() {
    var total = 0.0;
    cantidades.forEach((uuid, count) {
      final entrada = activity!.entradas!.firstWhere((e) => e.uuid == uuid);
      total += entrada.precio * count;
    });
    setState(() {
      _totalEntradas = total;
    });
  }

  Future<void> handleTurnVisibleChange() async {
    var previousActiveStatus = activity!.active;

    if (previousActiveStatus == false &&
        activity!.gratis == true &&
        authService.currentUser!.canCreateFreePlan == false) {
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Color.fromARGB(255, 1, 16, 79).withOpacity(0.5),
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(
              color: Color.fromARGB(255, 1, 16, 79), // ✅ Color del borde
              width: 2, // ✅ Grosor del borde
            ), // ✅ Bordes redondeados
          ),
          content: const Text(
              'Se te terminaron los planes gratuitos. Entra a esta página para más información xxxx'),
        ),
      );
    }
    if (activity!.gratis == false &&
        authService.currentUser!.creador == false) {
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Color.fromARGB(255, 1, 16, 79).withOpacity(0.5),
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(
              color: Color.fromARGB(255, 1, 16, 79), // ✅ Color del borde
              width: 2, // ✅ Grosor del borde
            ), // ✅ Bordes redondeados
          ),
          content: const Text(
              'Necesitas tener un perfil de creador para poder activar planes pagos. Entra a este link y podrás configurarlo xxxx'),
        ),
      );
    }
    if (activity!.gratis == false &&
        authService.currentUser!.canCreatePaymentPlan == false &&
        authService.currentUser!.creador == true) {
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: const Color.fromARGB(255, 1, 16, 79).withOpacity(0.5),
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(
              color: Color.fromARGB(255, 1, 16, 79), // ✅ Color del borde
              width: 2, // ✅ Grosor del borde
            ), // ✅ Bordes redondeados
          ),
          content: const Text(
              'Se te terminaron los planes de pago que puedes crear. Para ampliarlos, entra en el portal web: xxxx'),
        ),
      );
    }
    if (activity!.gratis == false && authService.currentUser!.creador == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('¡Recuerda que és más fácil gestionar esto desde la web!'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 100, left: 20, right: 20),
        ),
      );
    }

    final response = await http.post(
        Uri.parse(
          '${Config.serverIp}/handle_visibility_change/',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.userToken}'
        },
        body: jsonEncode({"tipo": 0, "uuid": activityUuid}));

    if (response.statusCode == 200) {
      setState(() {
        active = response.body.toLowerCase() == 'true';
      });
    }
  }

  void _registrarAsistencia(value) async {
    final response = await http.post(
        Uri.parse(
          '${Config.serverIp}/actualizar_asistencia/',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.userToken}'
        },
        body: jsonEncode({"activity_uuid": activity!.uuid, "update": value}));

    if (response.statusCode == 200) {
      setState(() {
        _asistenciaController = !_asistenciaController;
        asistentes = (jsonDecode(response.body) as List)
            .map((asistenteJson) => Usuario.fromJson(asistenteJson))
            .toList();
      });
    }
  }

  void _reservar(data) async {
    setState(() {
      _isLoading = true;
    });
    final response =
        await http.post(Uri.parse('${Config.serverIp}/create_reserva/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${widget.userToken}'
            },
            body: jsonEncode({
              "uuid": data['reserva_uuid'],
              "values": data['valores'],
            }));

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
        activity!.going = true;
        _asistenciaController = true;
        asistentes = (jsonDecode(response.body) as List<dynamic>)
            .map((asistenteJson) => Usuario.fromJson(asistenteJson))
            .toList();
      });
    }
  }

  void _createTickets(String name, String email) async {
    setState(() {
      _isLoading = true;
    });
    bool anyCreated = false;

    final response =
        await http.post(Uri.parse('${Config.serverIp}/crear_compra_simple/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${widget.userToken}'
            },
            body: jsonEncode({
              "type": "compra-tickets",
              "entradas": cantidades.entries
                  .map((e) => {"uuid": e.key, "amount": e.value})
                  .toList(),
              "name": name,
              "email": email
            }));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final url = data['init_point'].toString().trim();
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'No se pudo abrir la URL de Mercado Pago';
      }
    } else {
      throw 'Error creando preference: ${response.body}';
    }

    if (anyCreated == true) {
      setState(() {
        _isLoading = false;
        activity?.going = true;
        _totalEntradas = 0;
        cantidades.updateAll((key, value) => 0);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (activity == null) {
      return Center(
          child: Image.asset(
        'assets/ojitos.gif',
        width: 100,
        height: 100,
      ));
    }
    String formattedStartDate =
        DateFormat('EEEE, d \'de\' MMMM \'a las\' HH:mm ', 'es_ES')
            .format(activity!.dateTime);
    print('activity deetail: ${activity!.created_by_user}');
    return Scaffold(
      appBar: AppBar(),
      body: Stack(children: [
        SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    child: Stack(children: [
                      SizedBox(
                        height: 400,
                        width: double.infinity,
                        child: activity?.imageUrl != null &&
                                activity!.imageUrl!.isNotEmpty
                            ? Image.network(
                                activity!.imageUrl!,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                './assets/solocarita.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 300,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomRight,
                              end: Alignment.topRight,
                              colors: [
                                Colors.black87,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 5.0,
                        right: 10.0,
                        left: 2.0,
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            activity!.name,
                            style: const TextStyle(
                              color: AppTheme.logo,
                              fontSize: 40,
                              height: 1.0,
                              fontWeight: FontWeight.w900,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                      if (activity!.created_by_user == true)
                        Positioned(
                            top: 5.0,
                            left: 10.0,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: (active ?? false)
                                    ? AppTheme.backgroundColor
                                    : AppTheme.logo,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: (active ?? false)
                                        ? AppTheme.logo
                                        : AppTheme.backgroundColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                handleTurnVisibleChange();
                              },
                              child: Text(
                                (active ?? false)
                                    ? 'EVENTO VISIBLE'
                                    : 'EVENTO NO VISIBLE',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'BarlowCondensed',
                                    color: (active ?? false)
                                        ? AppTheme.logo
                                        : Colors.white),
                              ),
                            )),
                      Positioned(
                        top: 5.0,
                        right: 10.0,
                        left: 2.0,
                        child: Container(
                            alignment: Alignment.centerRight,
                            child: ShareEventButton(
                              eventUuid: activityUuid,
                              eventType: 1,
                            )),
                      ),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Row(
                      children: [
                        Text(formattedStartDate,
                            style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.logo)),
                        Spacer(),
                        TextButton(
                          style: TextButton.styleFrom(
                            minimumSize: Size(0, 0),
                            padding: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            setState(() {
                              _showAsistentes = !_showAsistentes;
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/solocarita.png',
                                height: 22, // ajustá el tamaño
                                width: 22,
                              ),
                              SizedBox(width: 2),
                              Text(asistentes.length.toString(),
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: AppTheme.logo,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(children: [
                    Column(children: [
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            activity!.desc!,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 25,
                                fontWeight: FontWeight.w400),
                          )),
                      const SizedBox(
                        height: 20,
                      ),
                      Wrap(
                        spacing: 2.0,
                        runSpacing: 0,
                        children: activity!.tags!
                            .map((tag) => TagChip(tag: tag))
                            .toList(),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      MapaDesdeBackend(
                          lat: activity!.lat!,
                          long: activity!.long!,
                          direccion: activity!.direccion!),
                      SizedBox(height: 20),
                      if (activity!.entradas != null &&
                          activity!.entradas!.isNotEmpty) ...[
                        Column(
                          children: activity!.entradas!.map((entrada) {
                            final double baseOpacity = 0.4;
                            final double increment = 0.2;
                            final index = activity!.entradas!.indexOf(entrada);
                            double opacity = (baseOpacity + (index * increment))
                                .clamp(0.0, 1.0);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 5),
                              padding: const EdgeInsets.fromLTRB(8, 8, 5, 8),
                              decoration: BoxDecoration(
                                color: entrada.disponibles > 0
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(opacity)
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.black, width: 2),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(entrada.titulo,
                                          style: const TextStyle(
                                              fontSize: 25, height: 1.2)),
                                      Text(entrada.desc ?? '',
                                          style: const TextStyle(
                                              fontSize: 20, height: 1.3)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      EntradasCounter(
                                        initialValue:
                                            cantidades[entrada.uuid] ?? 0,
                                        onChange: (count) {
                                          setState(() {
                                            cantidades[entrada.uuid!] = count;
                                          });
                                          _calcularTotalEntradas();
                                        },
                                        max: entrada.disponibles,
                                        enabled: entrada.disponibles > 0,
                                      ),
                                      Text('${entrada.precio} ARS',
                                          style: const TextStyle(
                                            fontSize: 20,
                                          )),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        /* Container(
                          height: 300,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: activity!.entradas!.length,
                            itemBuilder: (context, index) {
                              var entrada = activity!.entradas![index];

                              final double baseOpacity = 0.4;
                              final double increment = 0.2;
                              double opacity =
                                  (baseOpacity + (index * increment))
                                      .clamp(0.0, 1.0);

                              return Column(
                                children: [
                                  Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: entrada.disponibles > 0
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(opacity)
                                          : Colors.grey, // fondo del container
                                      borderRadius: BorderRadius.circular(
                                          10), // bordes redondeados
                                      border: Border.all(
                                        color: Colors.black, // color del borde
                                        width: 2, // grosor del borde
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              2.0, 8.0, 2.0, 8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                entrada.titulo,
                                                style: TextStyle(
                                                    fontSize: 25, height: 1.2),
                                              ),
                                              Text(entrada.desc ?? '',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      height: 1.3)),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            EntradasCounter(
                                              initialValue:
                                                  cantidades[entrada.uuid] ?? 0,
                                              onChange: (count) {
                                                setState(() {
                                                  cantidades[entrada.uuid!] =
                                                      count;
                                                });
                                                _calcularTotalEntradas();
                                              },
                                              max: entrada.disponibles,
                                              enabled: entrada.disponibles > 0,
                                            ),
                                            Text(
                                              entrada.precio.toString() +
                                                  ' ARS',
                                              style: TextStyle(
                                                  fontSize: 20, height: 1),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                ],
                              );
                            },
                          ),
                        ),*/
                      ],
                      if (activity!.tickets_link != null) ...[
                        const Text(
                            'Las entradas para este evento se compran en una plataforma externa'),
                      ],
                      SizedBox(height: 20),
                      if (aLaGorraActive == false)
                        const Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                textAlign: TextAlign.justify,
                                'Este es un evento a la gorra. Podrás hacer tu aportación cuando haya empezado.',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.logo))),
                      const SizedBox(height: 20),
                      if (aLaGorraActive == false) const SizedBox(height: 100),
                      if (aLaGorraActive == true) ...[
                        Container(
                          height: 100,
                          alignment: Alignment.centerLeft,
                          child: const Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'HACÉ TU APORTE: ',
                              style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.logo),
                            ),
                          ),
                        ),
                        SizedBox(height: 20)
                      ],
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Este evento está organizado por: ',
                              style: TextStyle(
                                fontSize: 20,
                                color: AppTheme.logo,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfileScreen(
                                        foreignUserUuid:
                                            activity!.creador!.uuid,
                                        fromActivityDetail: true)),
                              );
                            },
                            child: CircleAvatar(
                              radius: 30, // puedes ajustar el tamaño
                              backgroundImage: activity!
                                          .creador!.asistenteImageUrl !=
                                      null
                                  ? NetworkImage(
                                      activity!.creador!.asistenteImageUrl!)
                                  : const AssetImage('assets/solocarita.png')
                                      as ImageProvider,
                              backgroundColor: Colors.transparent,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '¿Algo anduvo mal?',
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 15,
                                  color: AppTheme.logo,
                                  fontWeight: FontWeight.w500),
                            ),
                            TextButton(
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: AppTheme.naranja_light,
                                  builder: (context) {
                                    return ReportEventSheet(
                                        event_uuid: activityUuid);
                                  },
                                );
                              },
                              child: const Text(
                                ' Denunciá el evento!',
                                style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: AppTheme.logo),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 80)
                    ]),
                    if (_showAsistentes)
                      Positioned.fill(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            setState(() {
                              _showAsistentes = false;
                            });
                          },
                          child: Container(),
                        ),
                      ),
                    if (_showAsistentes)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 180,
                          padding: EdgeInsets.all(0),
                          constraints: const BoxConstraints(
                            maxHeight: 200, // límite vertical
                          ),
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: asistentes.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileScreen(
                                                      foreignUserUuid:
                                                          asistentes[index]
                                                              .uuid)),
                                        );
                                      },
                                      child: Card(
                                        color: AppTheme.naranja_light,
                                        margin: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: ListTile(
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 8.0),
                                            leading: Padding(
                                              padding: const EdgeInsets.all(0),
                                              child: CircleAvatar(
                                                radius: 20,
                                                backgroundImage: asistentes[
                                                                index]
                                                            .asistenteImageUrl !=
                                                        null
                                                    ? NetworkImage(
                                                        asistentes[index]
                                                            .asistenteImageUrl!)
                                                    : AssetImage(
                                                            'assets/solocarita.png')
                                                        as ImageProvider,
                                              ),
                                            ),
                                            title:
                                                Text(asistentes[index].name)),
                                      ),
                                    ),
                                    SizedBox(height: 2)
                                  ],
                                );
                              }),
                        ),
                      ),
                  ])
                ],
              ),
            ),
          ),
        ),
        /*  if (aLaGorraActive == true)
          Positioned(
            bottom: 90,
            right: 10,
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppTheme.naranja_light,
                  builder: (context) {
                    return CreateALaGorraPaymentSheet(
                      event_name: activity!.name,
                      event_image: activity!.imageUrl,
                      event_uuid: activity!.uuid,
                      recommendedAmount:
                          activity!.recommendedAmount, // función de compra
                    );
                  },
                );
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.logo, width: 3),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/aLaGorra.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),*/
        // Tu botón "A la Gorra"
        if (aLaGorraActive == true)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            bottom: _isAtBottom ? 250 : 90,
            right: _isAtBottom ? 50 : 10,
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppTheme.naranja_light,
                  builder: (context) {
                    return CreateALaGorraPaymentSheet(
                      event_name: activity!.name,
                      event_image: activity!.imageUrl,
                      event_uuid: activity!.uuid,
                      recommendedAmount: activity!.recommendedAmount,
                    );
                  },
                );
              },
              child: Container(
                width: _isAtBottom ? 120 : 100,
                height: _isAtBottom ? 120 : 100,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.logo, width: 3),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: ClipOval(
                    child: Image.asset(
                      './assets/aLaGorra.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        // Overlay del GIF
        if (_isLoading)
          Container(
            color: Colors.black54, // fondo semi-transparente
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Image.asset(
                'assets/ojitos.gif',
                width: 150,
                height: 150,
              ),
            ),
          ),
      ]),
      bottomSheet: GestureDetector(
        //
        onTap: () async {
          if (activity!.conReserva == false) {
            if (_asistenciaController == true) {
              _registrarAsistencia(-1);
            } else {
              _registrarAsistencia(1);
            }
          } else if (activity!.conReserva == true) {
            if (_asistenciaController == true) {
              return;
            } else {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppTheme.naranja_light,
                builder: (context) {
                  return CreateReservaBottomSheet(
                    reservas_forms: activity!.reservas_forms!,
                    onConfirm: (data) => _reservar(data), // función de compra
                  );
                },
              );
            }
          } else {
            //ACTIVIDAD DE PAGO
            if (activity!.tickets_link != null) {
              final uri = Uri.parse(activity!.tickets_link!);
              await launchUrl(uri,
                  mode: LaunchMode
                      .externalApplication); // revisar si funciona en dispositiu físic
            }
            if (_totalEntradas > 0) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppTheme.naranja_light,
                builder: (context) {
                  return BuyTicketsBottomSheet(
                    activity: activity!,
                    cantidades: cantidades,
                    totalEntradas: _totalEntradas,
                    onConfirm: (name, email) =>
                        _createTickets(name, email), // función de compra
                  );
                },
              );
            } else if (activity!.going == true) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MyTicketsScreen(eventUuid: widget.activityUuid)));
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: activity!.gratis!
                  ? _asistenciaController == true
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.9)
                      : AppTheme.naranja_light.withOpacity(0.7)
                  : _totalEntradas == 0
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
                      : Theme.of(context).colorScheme.primary.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.transparent,
                width: 3.0,
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: activity!.gratis!
                ? Center(
                    child: (_asistenciaController == true)
                        ? const Text('yendo!',
                            style: TextStyle(
                                color: AppTheme.backgroundColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 30))
                        : activity!.conReserva!
                            ? const Text('Haz tu reserva',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 30))
                            : const Text('GRATIS, vas a ir?',
                                style: TextStyle(
                                    color: AppTheme.logo,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30)))
                : (activity!.going! == true && _totalEntradas == 0)
                    ? const Center(
                        child: Text('ACCEDE A TUS ENTRADAS',
                            style: TextStyle(fontSize: 20)))
                    : activity!.tickets_link != null
                        ? Center(
                            child: Text(
                            '${activity?.tickets_link!}',
                            style: TextStyle(fontSize: 30),
                          ))
                        : _totalEntradas == 0
                            ? const Center(
                                child: Text(
                                'COMPRA TUS ENTRADAS',
                                style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.w800),
                              ))
                            : Center(
                                child: Text(
                                  '$_totalEntradas ARS',
                                  style: const TextStyle(fontSize: 30),
                                ),
                              ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: const TextStyle(fontSize: 16),
        unselectedLabelStyle: const TextStyle(fontSize: 14),
        currentIndex: 0, // mismo control
        onTap: (index) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MainScaffold(initialIndex: index),
            ),
            (route) => false,
          );
        },
        items: [
          BottomNavigationBarItem(
              icon: Image.asset(
                'assets/explorar.png',
                height: 30, // ajustá el tamaño
                width: 30,
              ),
              label: 'Explorar'),
          BottomNavigationBarItem(
              icon: Image.asset(
                'assets/pincel3.png',
                height: 24, // ajustá el tamaño
                width: 24,
              ),
              label: 'Crear Plan'),
          BottomNavigationBarItem(
              icon: Image.asset(
                'assets/solocarita.png',
                height: 24, // ajustá el tamaño
                width: 24,
              ),
              label: 'Perfil'),
        ],
      ),
    );
  }
}
