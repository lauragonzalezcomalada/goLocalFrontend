import 'dart:ffi' hide Size;
import 'package:flutter/cupertino.dart' hide Size;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide Size;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:worldwildprova/config.dart';
import 'package:worldwildprova/models_fromddbb/activity.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:worldwildprova/models_fromddbb/asistentes.dart';
import 'package:worldwildprova/models_fromddbb/item.dart';
import 'package:worldwildprova/models_fromddbb/privatePlan.dart';
import 'package:worldwildprova/models_fromddbb/tagChip.dart';
import 'package:worldwildprova/widgets/authservice.dart';
import 'package:worldwildprova/widgets/dateBox.dart';
import 'package:worldwildprova/widgets/itemAmountCounter.dart';
import 'package:worldwildprova/widgets/mainscaffold.dart';
import 'package:worldwildprova/widgets/mapafrombckdng.dart';
import 'package:worldwildprova/widgets/usages.dart';

class PrivatePlanDetail extends StatefulWidget {
  final String privatePlanUuid;
  final String userToken;

  const PrivatePlanDetail(
      {super.key, required this.privatePlanUuid, required this.userToken});

  @override
  _PrivatePlanDetailState createState() => _PrivatePlanDetailState();
}

class _PrivatePlanDetailState extends State<PrivatePlanDetail> {
  PrivatePlan? privatePlan;
  late String privatePlanUuid;
  late String date;
  late String time;
  late String userToken;
  List<double?> originalAmountValues = [];
  List<double?> assignedAmountValues = [];
  List<bool> itemChecked = []; // una checkbox por item
  //late List<Asistente> asistentes;
  // late bool _asistenciaController;

  bool _showAsistentes = false;
  bool _showNewItemForm = false;

  bool _snackShown = false;

  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    privatePlanUuid = widget.privatePlanUuid;
    fetchPrivatePlan().then((_) {
      print('PrivatePlanDetail: privatePlanUuid: $privatePlanUuid');
      if (privatePlan!.userIsGoing == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showJoinPlanDialog();
        });
      }
    });
    setState(() {
      userToken = widget.userToken;
    });
  }

  //Función para hacer la solicitud GET
  Future<void> fetchPrivatePlan() async {
    try {
      final response = await http.get(
          Uri.parse(
              '${Config.serverIp}/private_plans/?privatePlanUuid=$privatePlanUuid'),
          headers: {'Authorization': 'Bearer ${widget.userToken}'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          privatePlan = PrivatePlan.fromJson(data);
          assignedAmountValues = [];
          itemChecked = [];
          for (var item in privatePlan!.items!) {
            originalAmountValues.add(item.assignedAmount);
            assignedAmountValues.add(item.assignedAmount);
            itemChecked.add(false);
          }
        });

        if (privatePlan!.userIsGoing == false) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('¿Querés unirte a este plan?'),
                action: SnackBarAction(
                  label: 'Unirme',
                  onPressed: () {
                    _joinPlan();
                  },
                ),
              ),
            );
          });
        }
      } else if (response.statusCode == 401) {
        // unauthorized
        final authService = Provider.of<AuthService>(context, listen: false);
        final _refreshedUserToken = await authService.getAccessToken();
        if (_refreshedUserToken != null) {
          setState(() {
            userToken = _refreshedUserToken;
          });
        } else {
          print('userTokne = null');
        }
      } else {
        // Si la respuesta es un error, muestra un mensaje
        throw Exception('Failed to load places');
      }
    } catch (e) {
      // Si ocurre un error en la solicitud
      print('Error: $e');
    }
  }

  void _joinPlan() async {
    print(Uri.parse('${Config.serverIp}/accept_invitation/'));
    final response =
        await http.post(Uri.parse('${Config.serverIp}/accept_invitation/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${widget.userToken}'
            },
            body: jsonEncode({"private_plan_uuid": privatePlanUuid}));

    if (response.statusCode == 200) {
      // Si la invitación es aceptada, actualiza el estado
      setState(() {
        privatePlan!.userIsGoing = true;
      });
    } else {
      // Manejo de errores
      print('Error al unirse al plan: ${response.body}');
    }
  }

  void _showJoinPlanDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Quieres unirte a este plan?'),
          /* content: const Text(
              'Si te unes, podrás ver los detalles y colaborar con los demás asistentes.'),*/
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Por ahora no'),
            ),
            ElevatedButton(
              onPressed: () {
                _joinPlan();
                Navigator.of(context).pop();
              },
              child: const Text('Dale'),
            ),
          ],
        );
      },
    );
  }

  void _showDialogBringingItem(Item item, double? amount, int index) {
    if (amount == originalAmountValues[index]) {
      // si no es modifica res, no apareix popup
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              'Te encargas de llevar ${amount! - originalAmountValues[index]!} de  ${item.name}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  assignedAmountValues[index] = originalAmountValues[index];
                });
              },
              child: const Text('Mejor no'),
            ),
            ElevatedButton(
              onPressed: () {
                _submitBringingItem(item, amount);
                Navigator.of(context).pop();
              },
              child: const Text('Re, sí'),
            ),
          ],
        );
      },
    );
  }

  void _submitBringingItem(Item item, double? amount) async {
    if (amount == item.assignedAmount) {
      setState(() {
        isChecked = false;
      });
      return;
    }

    final response = await http.post(
        Uri.parse(
          '${Config.serverIp}/update_item/',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.userToken}'
        },
        body: jsonEncode({
          "uuid": item.uuid,
          "plan_uuid": privatePlan!.uuid,
          "newAssignedAmountValue": amount
        }));

    if (response.statusCode == 200) {
      setState(() {
        assignedAmountValues = [];
        itemChecked = [];
        privatePlan = PrivatePlan.fromJson(json.decode(response.body));
        for (var item in privatePlan!.items!) {
          assignedAmountValues.add(item.assignedAmount);
          itemChecked.add(false);
        }
      });
    }
  }

  void _addNewItemToPlan() async {
    String itemName = _itemNameController.text;
    double itemAmount = double.parse(_amountController.text);

    print(itemName);
    print(itemAmount);

    final response = await http.post(
      Uri.parse('${Config.serverIp}/add_item/'),
      headers: {
        'Content-Type': 'application/json', // Tipo de contenido JSON
        'Authorization': 'Bearer ${widget.userToken}'
      },
      body: jsonEncode({
        "name": itemName,
        "neededAmount": itemAmount,
        "plan_uuid": privatePlan!.uuid
      }),
    );

    if (response.statusCode == 200) {
      var newItem = Item.fromJson(json.decode(response.body));
      setState(() {
        privatePlan!.items!.add(newItem);
        assignedAmountValues.add(newItem.assignedAmount);
        itemChecked.add(false);
        _itemNameController.clear();
        _amountController.clear();
        _showNewItemForm = false;
      });
    } else {
      throw Exception('Failed to add item');
    }
  }

  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    if (privatePlan == null) {
      return const Center(child: CircularProgressIndicator());
    }
    String formattedStartDate =
        DateFormat('EEEE, d \'de\' MMMM \'a las\' HH:mm ', 'es_ES')
            .format(privatePlan!.dateTime);

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
                  child: privatePlan!.imageUrl == null
                      ? ClipRRect(
                          child: Container(
                            height: 200,
                            color: Colors.blue,
                          ),
                        )
                      : Stack(children: [
                          Image.network(
                            privatePlan!
                                .imageUrl!, // o usa NetworkImage con Image.network()
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 300, // altura del degradat
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white70, // color de baix
                                    Colors.transparent, // color de dalt
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                              top: 20,
                              right: 20,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(
                                      16), // Rounded corners
                                ),
                                height: 50,
                                width: 200,
                                child: Center(
                                    child: SelectableText(
                                        privatePlan!.invitationCode!,
                                        style: const TextStyle(fontSize: 35))),
                              )),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 300, // altura del degradat
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomRight,
                                  end: Alignment.topRight,
                                  colors: [
                                    Colors.white, // color de baix
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
                                privatePlan!.name,
                                style: const TextStyle(
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
                        style: const TextStyle(fontSize: 20),
                      ),
                      //  Text(' de $startTime a $endTime',style: TextStyle(fontSize: 20),),
                      const Spacer(),

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
                Stack(children: [
                  Column(children: [
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          privatePlan!.desc!,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 1, 16, 79),
                              fontSize: 20,
                              fontFamily: 'BarlowCondensed_Regular'),
                        )),
                    MapaDesdeBackend(
                      lat: privatePlan!.lat!,
                      long: privatePlan!.long!,
                      imageUrl: privatePlan!.imageUrl,
                    ),
                    const SizedBox(height: 10),
                    if (privatePlan!.items != null)
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(8.0, 10.0, 8.0, 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Que traes?',
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxHeight: 500, // hasta 200, pero no fija
                      ),
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: privatePlan!.items!.length,
                          itemBuilder: (context, index) {
                            Item item = privatePlan!.items![index];

                            bool accomplished =
                                item.assignedAmount == item.neededAmount;

                            return Column(
                              children: [
                                Container(
                                  height: 70,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: accomplished
                                        ? Colors.grey
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: Colors.blue, // Color del borde
                                      width: 2.0, // Grosor del borde
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        12), // Bordes redondeados
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16.0, 8.0, 16.0, 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(fontSize: 25),
                                        ),
                                        const Spacer(),
                                        ItemAmountCounter(
                                            neededAmount: item.neededAmount,
                                            assignedAmount: item.assignedAmount,
                                            onChanged: (newValue) {
                                              setState(() {
                                                assignedAmountValues[index] =
                                                    newValue;
                                              });
                                            }),
                                        if (!accomplished)
                                          Checkbox(
                                              value: itemChecked[index],
                                              onChanged: (bool? selected) {
                                                setState(() {
                                                  itemChecked[index] =
                                                      selected!;
                                                });
                                                if (selected! == true) {
                                                  _showDialogBringingItem(
                                                      item,
                                                      assignedAmountValues[
                                                          index],
                                                      index);
                                                  /* _submitBringingItem(
                                                        item,
                                                        assignedAmountValues[
                                                            index],
                                                        index);*/
                                                }
                                              }),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                              ],
                            );
                          }),
                    ),
                    const SizedBox(height: 10),
                    if (_showNewItemForm == false)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showNewItemForm = !_showNewItemForm;
                          });
                        },
                        child: Container(
                          height: 50,
                          width: 300,
                          decoration: BoxDecoration(
                            color: _showNewItemForm == true
                                ? Colors.grey
                                : Colors.transparent,
                            border: Border.all(
                              color: Colors.blue, // Color del borde
                              width: 2.0, // Grosor del borde
                            ),
                            borderRadius: BorderRadius.circular(30), //
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Text('+ añade más cositas')],
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    if (_showNewItemForm)
                      Column(
                        children: [
                          Divider(
                            color: Colors.black,
                            thickness: 1,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: 250,
                                child: TextField(
                                  controller: _itemNameController,
                                  decoration: const InputDecoration(
                                    hintText: 'nombre',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                              const Spacer(),
                              SizedBox(
                                width: 100,
                                child: TextField(
                                  controller: _amountController,
                                  decoration: const InputDecoration(
                                    hintText: 'cantidad',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      print(_itemNameController.text.isEmpty);
                                      if (_itemNameController.text.isNotEmpty &&
                                          _amountController.text.isNotEmpty) {
                                        // Validar que los campos no estén vacíos
                                        _addNewItemToPlan();
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text(
                                              'Por favor, completa todos los campos.'),
                                        ));
                                      }
                                    },
                                    child: Text('añadir'),
                                    style: ElevatedButton.styleFrom(
                                      alignment: Alignment
                                          .center, // Centra el contenido (opcional pero explícito)

                                      minimumSize: Size(0, 30),
                                      side: BorderSide(
                                        color: Colors.red, // color del borde
                                        width: 2, // grosor del borde
                                      ),
                                    ))
                              ])
                        ],
                      ),
                    const SizedBox(height: 70),
                  ]),
                ])
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
