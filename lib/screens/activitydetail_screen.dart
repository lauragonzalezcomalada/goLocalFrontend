import 'dart:ffi';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:worldwildprova/config.dart';
import 'package:worldwildprova/models_fromddbb/activity.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:worldwildprova/models_fromddbb/asistentes.dart';
import 'package:worldwildprova/models_fromddbb/tagChip.dart';
import 'package:worldwildprova/models_fromddbb/userprofile.dart';
import 'package:worldwildprova/screens/mytickets_screen.dart';
import 'package:worldwildprova/screens/profile_screen.dart';
import 'package:worldwildprova/widgets/authservice.dart';
import 'package:worldwildprova/widgets/dateBox.dart';
import 'package:worldwildprova/widgets/entradasCounter.dart';
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

  Map<String, int> cantidades = {}; // el uuid como clave
  double _totalEntradas = 0.0;
  @override
  void initState() {
    super.initState();
    activityUuid = widget.activityUuid;
    fetchActivity();
  }

  Activity? activity;

  //Función para hacer la solicitud GET
  Future<void> fetchActivity() async {
    print('fetch activity');
    try {
      final response = await http.get(
          Uri.parse(
              Config.serverIp + '/activities/?activity_uuid=$activityUuid'),
          headers: {'Authorization': 'Bearer ${widget.userToken}'});
      print(response.body);
      print(response.statusCode);
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
              cantidades[entrada.uuid] = 0;
            }
          }
        });
        print('usergoing?');
        print(activity!.going);
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
            .map((asistenteJson) => Asistente.fromJson(asistenteJson))
            .toList();
      });
    }
  }

  void _createTickets() async {
    print(cantidades);

    for (var item in cantidades.entries) {
      if (item.value > 0) {
        print('creando ticket para ${item.key} con cantidad ${item.value}');
        final response =
            await http.post(Uri.parse('${Config.serverIp}/create_tickets/'),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer ${widget.userToken}'
                },
                body: jsonEncode({
                  "entrada_uuid": item.key,
                  "cantidad": item.value,
                }));
        if (response.statusCode == 201) {
          print('satisfactory');
        }
      }
    }

    /* final response = await http.post(
      Uri.parse('${Config.serverIp}/create_tickets/'),
      headers: {
        'Content-Type': 'application/json', // Asegúrate de que el servidor acepte JSON
        'Authorization': 'Bearer ${widget.userToken}'
      },
      body: jsonEncode({
        "activity_uuid": activity!.uuid,
        "entradas": cantidades.entries
            .map((entry) => {
                  "uuid": entry.key,
                  "cantidad": entry.value
                })
            .toList()
      }),
    );

    if (response.statusCode == 200) {
      // Manejar la respuesta exitosa
      print('Entradas creadas exitosamente');
    } else {
      // Manejar el error
      print('Error al crear entradas: ${response.body}');
    }*/
  }

  @override
  Widget build(BuildContext context) {
    if (activity == null) {
      return const Center(child: CircularProgressIndicator());
    }
    String formattedStartDate =
        DateFormat('EEEE, d \'de\' MMMM \'a las\' HH:mm ', 'es_ES')
            .format(activity!.dateTime);
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
                  child: activity!.imageUrl == null
                      ? ClipRRect(
                          child: Container(
                            height: 200,
                            color: Colors.blue,
                          ),
                        )
                      : Stack(children: [
                          Image.network(
                            activity!
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
                        style: TextStyle(fontSize: 25),
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
                              Text(asistentes.length.toString(),
                                  style: TextStyle(fontSize: 20)),
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
                              fontSize: 25,
                              fontFamily: 'BarlowCondensed_Regular'),
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
                    Container(
                      height: 300,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: activity!.entradas!.length,
                        itemBuilder: (context, index) {
                          var entrada = activity!.entradas![index];
                          print(entrada.disponibles);

                          return Column(
                            children: [
                              Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  color: entrada.disponibles > 0
                                      ? Colors.transparent
                                      : Colors.grey, // fondo del container
                                  borderRadius: BorderRadius.circular(
                                      10), // bordes redondeados
                                  border: Border.all(
                                    color: Colors.blue, // color del borde
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
                                        children: [
                                          Text(
                                            entrada.titulo,
                                            style: TextStyle(fontSize: 20),
                                          ),
                                          Text(entrada.desc ?? '',
                                              style: TextStyle(fontSize: 18)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        EntradasCounter(
                                          onChange: (count) {
                                            setState(() {
                                              cantidades[entrada.uuid] = count;
                                            });
                                            _calcularTotalEntradas();
                                          },
                                          max: entrada.disponibles,
                                          enabled: entrada.disponibles > 0,
                                        ),
                                        Text(
                                          entrada.precio.toString() + ' ARS',
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
                    SizedBox(
                      height: 85,
                    ),
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
          if (activity!.gratis!) {
            if (_asistenciaController == true) {
              _registrarAsistencia(-1);
            } else {
              if (activity!.conReserva!) {
                _registrarAsistencia(1);
                return;
              }
              _registrarAsistencia(1);
            }
          } else {
            //ACTIVIDAD DE PAGO

            if (_totalEntradas > 0) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true, // 👈 esto permite altura completa
                backgroundColor: const Color.fromARGB(235, 249, 129, 55),
                builder: (context) {
                  return DraggableScrollableSheet(
                    expand: false,
                    initialChildSize: 0.9, // ocupa todo
                    builder: (context, scrollController) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 12),
                                const Text(
                                  'Quieres confirmar tu compra para...',
                                  style: TextStyle(
                                      fontSize: 50,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 20),
                                Container(
                                    height: 100,
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                            child: activity!.imageUrl != null
                                                ? Image.network(
                                                    activity!.imageUrl!,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Container(
                                                    width: 100,
                                                    color: Colors.grey[200],
                                                  )),
                                        const SizedBox(width: 8),
                                        Text(activity!.name)
                                      ],
                                    )),

                                const SizedBox(height: 20),

                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: cantidades.values
                                      .where((valor) => valor > 0)
                                      .length,
                                  itemBuilder: (context, index) {
                                    var itemId = cantidades.entries
                                        .where((entry) => entry.value > 0)
                                        .map(
                                            (entry) => [entry.key, entry.value])
                                        .toList()[index];
                                    print('item:');
                                    print(itemId);
                                    var itemEntrada = activity!.entradas![
                                        activity!.entradas!.indexWhere(
                                            (e) => e.uuid == itemId[0])];
                                    print(itemEntrada.titulo);

                                    return ListTile(
                                      title: Text(itemId[1].toString() +
                                          ' x ' +
                                          itemEntrada.titulo),
                                      trailing: Text(
                                        '${(itemId[1] as int) * itemEntrada.precio} ARS',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    );
                                  },
                                ),
                                // aquí podés mostrar el detalle de las entradas seleccionadas
                                // o cualquier otro contenido
                                Text('Total: $_totalEntradas ARS'),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    _createTickets();
                                    Navigator.pop(context);
                                    // aquí puedes llamar a tu función para comprar las entradas
                                  },
                                  child: const Text('Confirmar compra'),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
              color: _totalEntradas == 0
                  ? Theme.of(context).colorScheme.secondary.withOpacity(0.5)
                  : Theme.of(context).colorScheme.secondary.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.transparent,
                width: 3.0, // 👈 Cambiás el ancho acá
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainScaffold(initialIndex: index),
            ),
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
