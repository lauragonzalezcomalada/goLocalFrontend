import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:worldwildprova/config.dart';
import 'package:worldwildprova/models_fromddbb/activity.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:worldwildprova/models_fromddbb/asistentes.dart';
import 'package:worldwildprova/models_fromddbb/promo.dart';
import 'package:worldwildprova/screens/profile_screen.dart';
import 'package:worldwildprova/widgets/appTheme.dart';
import 'package:worldwildprova/widgets/authservice.dart';
import 'package:worldwildprova/widgets/createReservaBottomSheet.dart';
import 'package:worldwildprova/widgets/mainscaffold.dart';
import 'package:worldwildprova/widgets/mapafrombckdng.dart';
import 'package:worldwildprova/widgets/usages.dart';

class PromoDetail extends StatefulWidget {
  final String promoUuid;
  final String userToken;

  const PromoDetail(
      {super.key, required this.promoUuid, required this.userToken});

  @override
  _PromoDetailState createState() => _PromoDetailState();
}

class _PromoDetailState extends State<PromoDetail> {
  late String promoUuid;
  late String date;

  late List<Usuario> asistentes;
  late AuthService authService;
  Promo? promo;

  bool _showAsistentes = false;

  late bool? active;
  bool _isLoading = false;

  bool _asistenciaController = false;
  @override
  void initState() {
    super.initState();
    promoUuid = widget.promoUuid;
    authService = Provider.of<AuthService>(context, listen: false);
    fetchPromo();
    initializeDateFormatting('es_ES', null);
  }

  //Función para hacer la solicitud GET
  Future<void> fetchPromo() async {
    try {
      final response = await http.get(
          Uri.parse('${Config.serverIp}/promos/?promo_uuid=$promoUuid'),
          headers: {'Authorization': 'Bearer ${widget.userToken}'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          promo = Promo.fromServerJson(data);
          date = DateFormat('dd/MM/yyyy').format(promo!.dateTime);
          _asistenciaController = promo!.going!;
          asistentes = promo!.asistentes!;
          active = promo!.active;
        });
      } else {
        // Si la respuesta es un error, muestra un mensaje
        throw Exception('Failed to load promos');
      }
    } catch (e) {
      // Si ocurre un error en la solicitud
      print('Error: $e');
    }
  }

  Future<void> handleTurnVisibleChange() async {
    var previousActiveStatus = promo!.active;

    if (previousActiveStatus == false &&
        authService.currentUser!.canCreateFreePlan == false) {
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Color.fromARGB(255, 1, 16, 79).withOpacity(0.5),
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Color.fromARGB(255, 1, 16, 79),
              width: 2,
            ),
          ),
          content: Text(
              'Se te terminaron los planes gratuitos. Entra a esta página para más información xxxx'),
        ),
      );
    }
    final response = await http.post(
        Uri.parse(
          '${Config.serverIp}/handle_visibility_change/',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await authService.getAccessToken()}'
        },
        body: jsonEncode({"tipo": 1, "uuid": promoUuid}));

    if (response.statusCode == 200) {
      setState(() {
        active = response.body.toLowerCase() == 'true';
      });
    }
  }

  void _registrarAsistencia(value) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isLoggedIn = await authService.isLoggedIn();
    if (!isLoggedIn) {
      Future.microtask(() => showLoginAlert(context,
          'Registrate para poder tener más información de las promos!'));
    }
    final userToken = await authService.getAccessToken();
    final response = await http.post(
        Uri.parse(
          '${Config.serverIp}/actualizar_asistencia/',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken'
        },
        body: jsonEncode({"promo_uuid": promo!.uuid, "update": value}));
    if (response.statusCode == 200) {
      setState(() {
        _asistenciaController = !_asistenciaController;
        asistentes = jsonDecode(response.body)['asistentes'];
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
              'Authorization': 'Bearer ${await authService.getAccessToken()}'
            },
            body: jsonEncode({
              "uuid": data['reserva_uuid'],
              "values": data['valores'],
            }));

    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
        promo!.going = true;
        _asistenciaController = true;
        asistentes = (jsonDecode(response.body) as List<dynamic>)
            .map((asistenteJson) => Usuario.fromJson(asistenteJson))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (promo == null) {
      return Center(
        child: Image.asset(
          'assets/ojitos.gif',
          width: 100,
          height: 100,
        ),
      );
    }
    String formattedStartDate =
        DateFormat('EEEE, d \'de\' MMMM', 'es_ES').format(promo!.dateTime);
    return Scaffold(
      appBar: AppBar(),
      body: Stack(children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Stack(children: [
                      SizedBox(
                          height: 400,
                          width: double.infinity,
                          child: promo?.imageUrl != null &&
                                  promo!.imageUrl!.isNotEmpty
                              ? Image.network(
                                  promo!.imageUrl!,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset('assets/solocarita.png',
                                  fit: BoxFit.cover)),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 300,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomRight,
                              end: Alignment.topRight,
                              colors: [
                                Colors.white54,
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
                            promo!.name,
                            style: const TextStyle(
                              color: Colors.black,
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
                      if (promo!.created_by_user == true)
                        Positioned(
                            top: 5.0,
                            left: 10.0,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: (active ?? false)
                                    ? Colors.green
                                    : Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
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
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          formattedStartDate,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          ' de ${DateFormat('HH:mm').format(promo!.dateTime)} a ${DateFormat('HH:mm').format(promo!.dateTime)}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                        Spacer(),
                        TextButton(
                          style: TextButton.styleFrom(
                            minimumSize: Size(0, 0),
                            padding: const EdgeInsets.symmetric(
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
                  Stack(
                    children: [
                      Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                promo!.desc!,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                              )),
                          MapaDesdeBackend(
                            lat: promo!.lat!,
                            long: promo!.long!,
                            direccion: promo!.direccion!,
                          ),
                          SizedBox(height: 100),
                        ],
                      ),
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
                                                padding:
                                                    const EdgeInsets.all(0),
                                                child: CircleAvatar(
                                                  radius: 20,
                                                  backgroundImage: asistentes[
                                                                  index]
                                                              .asistenteImageUrl !=
                                                          null
                                                      ? NetworkImage(asistentes[
                                                              index]
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
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
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
            if (promo!.conReserva == false) {
              if (_asistenciaController == true) {
                _registrarAsistencia(-1);
              } else {
                _registrarAsistencia(1);
              }
            } else if (promo!.conReserva == true) {
              if (_asistenciaController == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ya reservaste para este plan!'),
                    duration: Duration(seconds: 3), // tiempo que estará visible
                    behavior: SnackBarBehavior
                        .floating, // hace que no se quede pegado al borde
                    margin: EdgeInsets.only(
                        bottom: 80,
                        left: 0,
                        right: 0), // opcional, para ubicarlo
                  ),
                );
                return;
              } else {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: const Color.fromARGB(235, 249, 129, 55),
                  builder: (context) {
                    return CreateReservaBottomSheet(
                      reservas_forms: promo!.reservas_forms!,
                      onConfirm: (data) => _reservar(data), // función de compra
                    );
                  },
                );
              }
            }
          },
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _asistenciaController == true
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.9)
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.transparent,
                      width: 3.0,
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Center(
                      child: (_asistenciaController == true)
                          ? (promo?.conReserva == false)
                              ? Text('yendo!',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30))
                              : Text('Reservaste!',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30))
                          : promo!.conReserva!
                              ? const Text('Haz tu reserva',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30))
                              : const Text('GRATIS, vas a ir?',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30)))))),
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: const TextStyle(fontSize: 16),
        unselectedLabelStyle: const TextStyle(fontSize: 14),
        currentIndex: 0,
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
