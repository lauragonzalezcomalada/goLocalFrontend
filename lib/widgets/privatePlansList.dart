import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:worldwildprova/config.dart';
import 'package:worldwildprova/models_fromddbb/privatePlan.dart';
import 'package:worldwildprova/widgets/authservice.dart';
import 'package:worldwildprova/widgets/mainscaffold.dart';
import 'package:worldwildprova/widgets/privatePlanDetail.dart';
import 'package:worldwildprova/widgets/privatePlan_card.dart';
import 'package:worldwildprova/widgets/usages.dart';

class PrivatePlansList extends StatefulWidget {
  const PrivatePlansList({super.key});

  @override
  State<PrivatePlansList> createState() => _PrivatePlansListState();
}

class _PrivatePlansListState extends State<PrivatePlansList> {
  String? userToken;
  List<PrivatePlan> privatePlans = [];

  final TextEditingController _searchController = TextEditingController();
  List<PrivatePlan> _filteredPrivatePlans = [];

  @override
  void initState() {
    super.initState();
    _checkLoggedStatus();
  }

  void filterActivities() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredPrivatePlans = privatePlans.where((item) {
        final matchesName = item.name.toLowerCase().contains(query);
        // La privatePlan solo se filtra por nombre
        return matchesName;
      }).toList();
    });
  }

  Future<void> _checkLoggedStatus() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isLoggedIn = await authService.isLoggedIn();
    if (!isLoggedIn) {
      Future.microtask(() =>
          showLoginAlert(context, 'Registrate para ver tus planes privados'));
    }
    userToken = await authService.getAccessToken();

    if (userToken != null) {
      _loadUserPrivatePlans();
    }
  }

  Future<void> _loadUserPrivatePlans() async {
    try {
      final response = await http.get(
          Uri.parse('${Config.serverIp}/private_plans/'),
          headers: {'Authorization': 'Bearer $userToken'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          privatePlans = (data as List<dynamic>)
              .map((privatePlan) => PrivatePlan.fromJson(privatePlan))
              .toList();
        });
      } else {
        // Si la respuesta es un error, muestra un mensaje
        throw Exception('Failed to load private plans');
      }
    } catch (e) {
      // Si ocurre un error en la solicitud
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return privatePlans.isEmpty
        ? Center(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 150, horizontal: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('No hay ningún plan registrado aún para ti'),
                    const Text('Sé tu el primero!'),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const MainScaffold(initialIndex: 1),
                          ),
                        );
                      },
                      child: const Text('Crea un plan!'),
                    )
                  ],
                )))
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(fontSize: 20),
                    labelText: 'Buscar',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: privatePlans.length,
                    itemBuilder: (context, index) {
                      final privatePlan = privatePlans[index];
                      bool showHeader = false;
                      if (index == 0) {
                        showHeader = true;
                      } else {
                        final previousActivity = privatePlans[index - 1];
                        showHeader = privatePlan.dateTime.day !=
                            previousActivity.dateTime.day;
                      }

                      return Column(
                        children: [
                          if (showHeader)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: headerForDate(privatePlan.dateTime),
                            ),
                          GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PrivatePlanDetail(
                                              privatePlanUuid: privatePlan.uuid,
                                              userToken: userToken!,
                                            )));
                              },
                              child: Column(children: [
                                PrivatePlanCard(privatePlan: privatePlan),
                                const SizedBox(height: 5)
                              ])),
                        ],
                      );
                    }),
              ),
            ],
          );
  }
}
