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
import 'package:worldwildprova/widgets/createReservaBottomSheet.dart';
import 'package:worldwildprova/widgets/entradasCounter.dart';
import 'package:worldwildprova/widgets/mainscaffold.dart';
import 'package:worldwildprova/widgets/mapafrombckdng.dart';
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

  @override
  void initState() {
    super.initState();
    activityUuid = widget.activityUuid;
    _initLocale();
    fetchActivity();
    authService = Provider.of<AuthService>(context, listen: false);
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
              Config.serverIp + '/activities/?activity_uuid=$activityUuid'),
          headers: {'Authorization': 'Bearer ${widget.userToken}'});
      if (response.statusCode == 200) {
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
        });
      } else {
        // Si la respuesta es un error, muestra un mensaje
        throw Exception('Failed to load places');
      }
    } catch (e) {
      // Si ocurre un error en la solicitud
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
        authService.currentUser!.availableFreePlans == 0) {
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Color.fromARGB(255, 1, 16, 79).withOpacity(0.5),
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Color.fromARGB(255, 1, 16, 79), // ✅ Color del borde
              width: 2, // ✅ Grosor del borde
            ), // ✅ Bordes redondeados
          ),
          content: Text(
              'Se te terminaron los planes gratuitos. Entra a esta página para más información xxxx'),
        ),
      );
    }
    if (activity!.gratis == false && authService.currentUser!.creador == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('¡Recuerda que és más fácil gestionar esto desde la web!'),
          duration: Duration(seconds: 3), // tiempo que estará visible
          behavior:
              SnackBarBehavior.floating, // hace que no se quede pegado al borde
          margin: EdgeInsets.only(
              bottom: 100, left: 20, right: 20), // opcional, para ubicarlo
        ),
      );
    }

    //SI ARRIBA FINS AQUÍ ES PERQUÈ ES GRATIS, I TENS PLANS PER PUBLICAR-LO

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

    /* cantidades (MapEntry(3b49d4bf-c4e3-40ef-bf31-d8a433cb421c: 1), MapEntry(573eb5e5-51ae-449d-afb1-edb6e5ce3b65: 1)) */
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
      // o 'sandbox_init_point'
      print('url: ${url}');
      final uri = Uri.parse(url);

      //final uri = Uri.parse("https://flutter.dev");
      //if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      /* } else {
        throw 'No se pudo abrir la URL de Mercado Pago';
      }*/
    } else {
      throw 'Error creando preference: ${response.body}';
    }

    if (anyCreated == true) {
      setState(() {
        _isLoading = false;
        activity?.going = true; // actualizamos la variable
        _totalEntradas =
            0; // si querés resetear el contador de entradas seleccionadas
        cantidades.updateAll((key, value) => 0);
      });
    }
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
    return Scaffold(
      appBar: AppBar(),
      body: Stack(children: [
        SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0), //espacio externo
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.8,
              ), // Ancho máximo
              decoration: BoxDecoration(
                //color: Colors.amber,
                borderRadius: BorderRadius.circular(16), // Bordes redondeados
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(
                          16), // Solo bordes superiores redondeados
                      topRight: Radius.circular(16),
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
                                'assets/solocarita.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 300, // altura del degradat
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomRight,
                              end: Alignment.topRight,
                              colors: [
                                Colors.white54, // color de baix
                                Colors.transparent, // color de dalt
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
                              color: Color.fromARGB(255, 47, 1, 1),
                              fontSize: 40,
                              height: 1.0,
                              fontWeight: FontWeight.w700,
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
                                    ? Colors.green
                                    : Colors.red, // color de fondo
                                foregroundColor:
                                    Colors.white, // color del texto
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8), // bordes redondeados
                                ),
                              ),
                              onPressed: () {
                                handleTurnVisibleChange();
                              },
                              child: Text(
                                (active ?? false)
                                    ? 'EVENTO VISIBLE'
                                    : 'EVENTO NO VISIBLE',
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
                            style: TextStyle(fontSize: 23)),
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
                              const Text('🤸🏻',
                                  style: TextStyle(fontSize: 20)),
                              Text(asistentes.length.toString(),
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black)),
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
                      SizedBox(
                        height: 20,
                      ),
                      Wrap(
                        spacing: 2.0, //espacio horizontal
                        runSpacing: 0, // espacio vertical entre líneas de chips
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
                        imageUrl: activity!.imageUrl,
                      ),
                      SizedBox(height: 20),
                      if (activity!.entradas != null &&
                          activity!.entradas!.isNotEmpty) ...[
                        Container(
                          height: 300,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: activity!.entradas!.length,
                            itemBuilder: (context, index) {
                              var entrada = activity!.entradas![index];
                              // calculamos la opacidad según el índice
                              final double baseOpacity =
                                  0.4; // primera opacidad
                              final double increment =
                                  0.2; // cuánto sube cada uno
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
                        ),
                      ],
                      if (activity!.tickets_link != null) ...[
                        Text(
                            'Las entradas para este evento se compran en una plataforma externa'),
                      ],
                      SizedBox(height: 20),
                      /*  Text(
                        'Este evento está organizado por: ',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),*/
                      SizedBox(height: 100),
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
                          child:
                              Container(), // debe haber algo aquí aunque sea vacío
                        ),
                      ),
                    if (_showAsistentes)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 180,
                          padding: EdgeInsets.all(0),
                          constraints: BoxConstraints(
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
                backgroundColor: const Color.fromARGB(235, 249, 129, 55),
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
                backgroundColor: const Color.fromARGB(235, 249, 129, 55),
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
                      : Theme.of(context).colorScheme.primary.withOpacity(0.5)
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
                                fontWeight: FontWeight.bold, fontSize: 30))
                        : activity!.conReserva!
                            ? const Text('Haz tu reserva',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 30))
                            : const Text('GRATIS, vas a ir?',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 30)))
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
                                style: TextStyle(fontSize: 30),
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
          const BottomNavigationBarItem(
              icon: Icon(Icons.place, size: 35), label: 'Lugares'),
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
