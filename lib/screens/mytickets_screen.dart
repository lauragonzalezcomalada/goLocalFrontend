import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:worldwildprova/config.dart';
import 'package:worldwildprova/models_fromddbb/ticket.dart';
import 'package:worldwildprova/widgets/authservice.dart';
import 'package:worldwildprova/widgets/mainscaffold.dart';

class MyTicketsScreen extends StatefulWidget {
  final String eventUuid;
  const MyTicketsScreen({super.key, required this.eventUuid});

  @override
  State<MyTicketsScreen> createState() => _MyticketsScreenState();
}

class _MyticketsScreenState extends State<MyTicketsScreen> {
  List<Ticket> myTickets = [];
  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  void _fetchTickets() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userToken = await authService.getAccessToken();
    print(userToken);
    final response = await http.get(
      Uri.parse(
          Config.serverIp + '/get_tickets?activity_uuid=${widget.eventUuid}'),
      headers: {'Authorization': 'Bearer ${userToken}'},
    );

    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        myTickets = data
            .map((ticketJson) => Ticket.fromServerJson(ticketJson))
            .toList();
      });
    }
    print(myTickets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: SizedBox.expand(
            child: PageView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: myTickets.length,
                itemBuilder: (context, index) {
                  var ticket = myTickets[index];
                  String formattedStartDate = DateFormat(
                          'EEEE, d \'de\' MMMM \'a las\' HH:mm ', 'es_ES')
                      .format(ticket!.eventStartDateTime);
                  return Center(
                    child: Container(
                      height: 600,
                      width: 350,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 15.0, 0),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadiusGeometry.circular(20)),
                                elevation: 0,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(15.0, 8, 15, 8),
                                  child: Text(
                                    (index + 1).toString() +
                                        ' / ' +
                                        myTickets.length.toString(),
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 2),
                          Container(
                            height: 150,
                            width: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  16), // ajustá el radio que prefieras
                              image: DecorationImage(
                                image: NetworkImage(ticket!.eventImageUrl!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Card(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadiusGeometry.circular(20)),
                            elevation: 0,
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 12, 20, 12),
                              child: Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                runSpacing: 8,
                                children: [
                                  Text(
                                    ticket.eventName,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            height: 200,
                            width: 200,
                            child: Image.network(
                              ticket!
                                  .qrUrl!, // o usa NetworkImage con Image.network()
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(formattedStartDate),
                          Text(
                            ticket.compradorName,
                            style: TextStyle(fontSize: 20),
                          )
                        ],
                      ),
                    ),
                  );
                })),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0, // mismo control
          onTap: (index) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainScaffold(
                  initialIndex: index,
                ),
              ),
            );
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.place), label: 'Lugares'),
            BottomNavigationBarItem(
                icon: Icon(Icons.brush), label: 'Crear plan'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ));
  }
}
