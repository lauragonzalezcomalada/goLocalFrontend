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
import 'package:worldwildprova/models_fromddbb/promo.dart';
import 'package:worldwildprova/widgets/authservice.dart';
import 'package:worldwildprova/widgets/mainscaffold.dart';
import 'package:worldwildprova/widgets/mapafrombckdng.dart';
import 'package:worldwildprova/widgets/usages.dart';

class PromoDetail extends StatefulWidget {
  final String promoUuid;

  const PromoDetail({super.key, required this.promoUuid});

  @override
  _PromoDetailState createState() => _PromoDetailState();
}

class _PromoDetailState extends State<PromoDetail> {
  late String promoUuid;
  late String date;
  late String startTime;
  late String endTime;
  late int asistentes;

  bool _asistenciaController = false;
  @override
  void initState() {
    super.initState();
    promoUuid = widget.promoUuid;
    fetchPromo();
    initializeDateFormatting('es_ES', null);
  }

  Promo? promo;

  //Función para hacer la solicitud GET
  Future<void> fetchPromo() async {
    try {
      final response = await http
          .get(Uri.parse('${Config.serverIp}/promos/?promo_uuid=$promoUuid'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          promo = Promo.fromServerJson(data);
          date = DateFormat('dd/MM/yyyy').format(promo!.dateTime);
          startTime = DateFormat('HH:mm').format(promo!.dateTime);
          endTime = DateFormat('HH:mm').format(promo!.endDateTime);
          asistentes = promo!.asistentes;
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

  @override
  Widget build(BuildContext context) {
    if (promo == null) {
      return const Center(child: CircularProgressIndicator());
    }
    String formattedStartDate =
        DateFormat('EEEE, d \'de\' MMMM', 'es_ES').format(promo!.dateTime);
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
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
                  child: promo!.imageUrl == null
                      ? ClipRRect(
                          child: Container(
                            height: 200,
                            color: Colors.blue,
                          ),
                        )
                      : Stack(children: [
                          Image.network(
                            promo!
                                .imageUrl!, // o usa NetworkImage con Image.network()
                            fit: BoxFit.cover,
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
                                    Colors.white
                                        .withOpacity(0.7), // color de baix
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
                                promo!.name,
                                style: TextStyle(
                                    color: Color.fromARGB(255, 1, 16, 79),
                                    fontSize: 30,
                                    height: 1.0),
                                softWrap: true,
                                overflow: TextOverflow.visible,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          )
                        ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(
                        formattedStartDate,
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(
                        ' de $startTime a $endTime',
                        style: TextStyle(fontSize: 20),
                      ),
                      Spacer(),
                      const Text('🤸🏻', style: TextStyle(fontSize: 20)),
                      Text(asistentes.toString(),
                          style: TextStyle(fontSize: 20)),
                      /* ElevatedButton(
                          onPressed: () {
                            _asistenciaController == true
                                ? _registrarAsistencia(-1)
                                : _registrarAsistencia(1);
                          },
                          child: (_asistenciaController == true)
                              ? const Text('yendo!')
                              : const Text('vas a ir?'))*/
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      promo!.desc!,
                      style: TextStyle(
                          color: Color.fromARGB(255, 1, 16, 79),
                          fontSize: 20,
                          fontFamily: 'Georgia'),
                    )),
                MapaDesdeBackend(
                  lat: promo!.lat!,
                  long: promo!.long!,
                  imageUrl: promo!.imageUrl!,
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // mismo control
        onTap: (index) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MainScaffold(initialIndex: index)),
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.place), label: 'Lugares'),
          BottomNavigationBarItem(icon: Icon(Icons.brush), label: 'Crear plan'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
