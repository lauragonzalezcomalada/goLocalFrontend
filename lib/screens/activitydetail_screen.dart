import 'dart:ffi';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:worldwildprova/models_fromddbb/activity.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:worldwildprova/models_fromddbb/asistentes.dart';
import 'package:worldwildprova/models_fromddbb/tagChip.dart';
import 'package:worldwildprova/screens/profile_screen.dart';
import 'package:worldwildprova/widgets/dateBox.dart';
import 'package:worldwildprova/widgets/mainscaffold.dart';
import 'package:worldwildprova/widgets/mapafrombckdng.dart';
import 'package:worldwildprova/widgets/usages.dart';

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
  late List<Asistente> asistentes;
  late bool _asistenciaController;

  bool _showAsistentes = false;

  @override
  void initState() {
    super.initState();
    activityUuid = widget.activityUuid;
    fetchActivity();
  }

  Activity? activity;

  //Función para hacer la solicitud GET
  Future<void> fetchActivity() async {
    try {
      final response = await http.get(
          Uri.parse(
              'http://192.168.0.17:8000/api/activities/?activity_uuid=$activityUuid'),
          headers: {'Authorization': 'Bearer ${widget.userToken}'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          activity = Activity.fromServerJson(data);
          date = DateFormat('dd/MM/yyyy').format(activity!.dateTime);
          time = DateFormat('HH:mm').format(activity!.dateTime);
          asistentes = activity!.asistentes!;
          _asistenciaController = activity!.going!;
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
    final response = await http.post(
        Uri.parse(
          'http://192.168.0.17:8000/api/actualizar_asistencia/',
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
            .map((asistenteJson) => Asistente.fromJson(asistenteJson))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (activity == null) {
      return const Center(child: CircularProgressIndicator());
    }
    String formattedStartDate =
        DateFormat('EEEE, d \'de\' MMMM \'a las\' HH:mm ', 'es_ES').format(activity!.dateTime);
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
                  child: activity!.activityImageUrl == null
                      ? ClipRRect(
                          child: Container(
                            height: 200,
                            color: Colors.blue,
                          ),
                        )
                      : Stack(children: [
                          Image.network(
                            activity!
                                .activityImageUrl!, // o usa NetworkImage con Image.network()
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
                                activity!.name,
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
                     
                      Spacer(),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              _showAsistentes = !_showAsistentes;
                            });
                          },
                          child: Row(
                            children: [
                              const Text('🤸🏻',
                                  style: TextStyle(fontSize: 20)),
                              Text(asistentes.length.toString()),
                            ],
                          ))
                    ],
                  ),
                ),
                
                Stack(children: [
                  Column(children: [
                   /* Align(
                      alignment: Alignment.bottomLeft,
                      child: SizedBox(
                        height: 30,
                        width: 100,
                        child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(0),
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            onPressed: () {
                              if (activity!.gratis == true) {
                                return;
                              } /* actions: [
                                      TextButton(
                                        child: const Text("Ver mi plan"),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Cierra el dialog
                                        },
                                      )
                                    ]*/
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                        contentPadding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        title: const Text(
                                          "Compra tus entradas!",
                                          style: TextStyle(fontSize: 18),
                                          textAlign: TextAlign.center,
                                        ),
                                        content: Column(children: [
                                          Text(activity!.dateTime.toString())
                                        ]));
                                  });
                            },
                            child: activity!.gratis == true
                                ? const Text('Gratis')
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 0, 0, 0),
                                          child: Text('ARS ' +
                                              activity!.price.toString())),
                                      const Icon(Icons.arrow_drop_down)
                                    ],
                                  )),
                      ),
                    ),*/
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          activity!.desc!,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 1, 16, 79),
                              fontSize: 20,
                              fontFamily: 'BarlowCondensed_Regular'),
                        )),
                    Wrap(
                      spacing: 2.0, //espacio horizontal
                      runSpacing: 0, // espacio vertical entre líneas de chips
                      children: activity!.tags!
                          .map((tag) => TagChip(tag: tag))
                          .toList(),
                    ),
                    MapaDesdeBackend(
                      lat: activity!.lat!,
                      long: activity!.long!,
                      imageUrl: activity!.activityImageUrl,
                    ),
                    SizedBox(height: 70),
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
                                      print('vamos a profilescreen');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ProfileScreen(
                                                foreignUserUuid:
                                                    asistentes[index].uuid)),
                                      );
                                    },
                                    child: Card(
                                      color: Colors.amber,
                                      margin: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: ListTile(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          leading: Padding(
                                            padding: const EdgeInsets.all(0),
                                            child: CircleAvatar(
                                              radius: 20,
                                              backgroundImage: asistentes[index]
                                                          .asistenteImageUrl !=
                                                      null
                                                  ? NetworkImage(
                                                      asistentes[index]
                                                          .asistenteImageUrl!)
                                                  : AssetImage(
                                                          'assets/boton_sol.png')
                                                      as ImageProvider,
                                            ),
                                          ),
                                          title: Text(asistentes[index].name)),
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
      bottomSheet: GestureDetector(
        onTap: () {
          if (activity!.gratis) if (_asistenciaController == true) {
            _registrarAsistencia(-1);
          } else {
            if (activity!.conReserva!) {
              //codigo per fer la reserva
              _registrarAsistencia(1);

              return;
            }
            _registrarAsistencia(1);
          }
        },
        child: Container(
          height: 60,
          width: double.infinity,
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
          padding: const EdgeInsets.all(8),
          child: activity!.gratis
              ? Center(
                  child: (_asistenciaController == true)
                      ? const Text('yendo!',
                          style: TextStyle(fontWeight: FontWeight.bold))
                      : activity!.conReserva!
                          ? const Text('Haz tu reserva',
                              style: TextStyle(fontWeight: FontWeight.bold))
                          : const Text('GRATIS, vas a ir?',
                              style: TextStyle(fontWeight: FontWeight.bold)))
              : const Center(
                  child: Text(
                    'DE PAGO',
                    style: TextStyle(fontWeight: FontWeight.bold),
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

class PortalEntry {}
