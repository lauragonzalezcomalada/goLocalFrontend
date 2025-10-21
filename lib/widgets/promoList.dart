import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worldwildprova/config.dart';
import 'package:worldwildprova/models_fromddbb/promo.dart';
import 'package:worldwildprova/models_fromddbb/tag.dart';
import 'package:http/http.dart' as http;
import 'package:worldwildprova/screens/activitydetail_screen.dart';
import 'package:worldwildprova/screens/promodetail_screen.dart';
import 'package:worldwildprova/widgets/appTheme.dart';
import 'package:worldwildprova/widgets/authservice.dart';
import 'package:worldwildprova/widgets/aux_ActivityCard.dart';
import 'dart:convert';

import 'package:worldwildprova/widgets/mainscaffold.dart';
import 'package:worldwildprova/widgets/promoCard.dart';
import 'package:worldwildprova/widgets/tagSelector.dart';
import 'package:worldwildprova/widgets/usages.dart';

class PromoList extends StatefulWidget {
  final String placeUuid; // Recibimos el UUID del lugar
  final String placeName;

  const PromoList(
      {required this.placeName, required this.placeUuid, super.key});

  @override
  State<PromoList> createState() => _PromoListState();
}

class _PromoListState extends State<PromoList> {
  bool _showTagSelector = false;

  List<Promo> promos = [];

  final TextEditingController _searchController = TextEditingController();
  List<Promo> _filteredPromos = [];

  List<Tag> tags = [];

  List<int> _selectedTags = [];

  late String placeUuid;
  late String placeName;

  String? userToken = '';

  @override
  void initState() {
    super.initState();
    placeUuid = widget.placeUuid; // Asignamos el UUID recibido
    placeName = widget.placeName;
    fetchPromos();
    fetchTags();
    initSelectedTags();
    _searchController.addListener(() {
      filterPromos();
    });
  }

  void initSelectedTags() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    if (await authService.isLoggedIn() == true) {
      final user =
          await authService.getUserProfile(await authService.getAccessToken());
      if (user != null) {
        setState(() {
          _selectedTags = user.tags!.map((tagId) => tagId.id).toList();
        });
      }
      filterPromos();
    }
  }

  void filterPromos() {
    final query = _searchController.text.toLowerCase();
    final selectedTagIds = _selectedTags;

    setState(() {
      _filteredPromos = promos.where((item) {
        final matchesName = item.name.toLowerCase().contains(query);

        if (selectedTagIds.isEmpty) {
          return matchesName;
        }

        final promoTagIds = (item.tags ?? []).map((tag) => tag.id).toList();
        final matchesTags =
            promoTagIds.any((tagId) => selectedTagIds.contains(tagId));

        // La actividad debe cumplir ambos filtros
        return matchesName && matchesTags;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Función para hacer la solicitud GET
  Future<void> fetchPromos() async {
    try {
      final response = await http.get(Uri.parse('${Config.serverIp}/promos/'));
      print('status code promos: ${response.statusCode}');
      print('body promo: ${response.body}');
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          promos = data
              .map((activityJson) => Promo.fromJson(activityJson, false))
              .toList();
          _filteredPromos = promos;
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

  Future<void> updateViews(String uuid) async {
    try {
      final response = await http.get(
          Uri.parse('${Config.serverIp}/register_view/?promo=True&uuid=$uuid'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        /* setState(() {
          activities = data
              .map((activityJson) => Activity.fromJson(activityJson, false))
              .toList();
          _filteredActivities = activities;
        });*/
      } else {
        // Si la respuesta es un error, muestra un mensaje
        throw Exception('Failed to load places');
      }
    } catch (e) {
      // Si ocurre un error en la solicitud
      print('Error: $e');
    }
  }

  Future<void> fetchTags() async {
    try {
      final response = await http.get(Uri.parse('${Config.serverIp}/tags/'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          tags = data.map((tagJson) => Tag.fromJson(tagJson)).toList();
        });
      } else {
        throw Exception(' Failed to load tags');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _promoPressed(String promo_uuid) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isLoggedIn = await authService.isLoggedIn();
    if (isLoggedIn == false) {
      Future.microtask(() => showLoginAlert(context,
          'Regístrate para poder tener más información de los planes!'));
      return;
    }
    userToken = await authService.getAccessToken();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PromoDetail(
                  userToken: userToken!,
                  promoUuid: promo_uuid,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return promos.isEmpty
        ? Center(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 150, horizontal: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'NO HAY NINGUNA PROMO REGISTRADA AÚN PARA ${placeName.toUpperCase()}',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.logo),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      '¡SÉ EL PRIMERO!',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.logo),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(AppTheme.logo),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const MainScaffold(initialIndex: 1),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'CREÁ UNA PROMO!',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    )
                  ],
                )))
        : Column(children: [
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (tags.isNotEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: _selectedTags.map((tagId) {
                            // Busca el Tag completo por id para mostrar su nombre
                            final tag = tags.firstWhere((t) => t.id == tagId);
                            return TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedTags.remove(tagId);
                                });
                                filterPromos();
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                backgroundColor: Colors.grey.shade300,
                                minimumSize: const Size(0, 0),
                              ),
                              child: Text(
                                tag.name,
                                style: const TextStyle(fontSize: 15),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          _showTagSelector = !_showTagSelector;
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        minimumSize: const Size(0, 0),
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2),
                        backgroundColor: _showTagSelector == true
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.7)
                            : Colors.white,
                      ),
                      child: const Text(
                        'TAGS',
                        style: TextStyle(fontSize: 15),
                      )),
                ],
              ),
            ),
            if (_showTagSelector)
              TagSelector(
                selectedTags: _selectedTags,
                onChanged: (tags) {
                  setState(() {
                    filterPromos();
                    _selectedTags = tags;
                    // Aquí se actualiza la lista de tags seleccionados
                  });
                },
              ),
            Expanded(
              child: ListView.builder(
                  itemCount: _filteredPromos.length,
                  itemBuilder: (context, index) {
                    final promo = _filteredPromos[index];
                    bool showHeader = false;
                    if (index == 0) {
                      showHeader = true;
                    } else {
                      final previousPromo = promos[index - 1];
                      showHeader =
                          promo.dateTime.day != previousPromo.dateTime.day;
                    }

                    return Column(
                      children: [
                        if (showHeader)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: headerForDate(promo.dateTime),
                          ),
                        GestureDetector(
                            onTap: () {
                              _promoPressed(promo.uuid);
                            },
                            child: Column(children: [
                              PromoCard(promo: promo),
                              const SizedBox(height: 5)
                            ])),

                        //PrommoCard(promo: promo),
                      ],
                    );
                  }),
            )
          ]);
  }
}
