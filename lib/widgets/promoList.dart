import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worldwildprova/config.dart';
import 'package:worldwildprova/models_fromddbb/promo.dart';
import 'package:worldwildprova/models_fromddbb/tag.dart';
import 'package:http/http.dart' as http;
import 'package:worldwildprova/screens/activitydetail_screen.dart';
import 'package:worldwildprova/screens/promodetail_screen.dart';
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
  List<Promo> _filteredPromos = [];

  TextEditingController _searchController = TextEditingController();

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
    _searchController.addListener(() {
      filterPromos();
    });
  }

  void filterPromos() {
    final query = _searchController.text.toLowerCase();
    final selectedTagIds = _selectedTags;

    setState(() {
      _filteredPromos = promos.where((item) {
        final matchesName = item.name.toLowerCase().contains(query);

        //no hi ha tags
        if (selectedTagIds.isEmpty) {
          return matchesName;
        }

        final activityTagIds = (item.tags ?? []).map((tag) => tag.id).toList();
        final matchesTags =
            activityTagIds.any((tagId) => selectedTagIds.contains(tagId));

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
      final response = await http
          .get(Uri.parse('${Config.serverIp}/promos/?place_uuid=$placeUuid'));

      if (response.statusCode == 200) {
        print('response okay');
        List<dynamic> data = json.decode(response.body);
        print('decode okay');
        setState(() {
          promos = data
              .map((activityJson) => Promo.fromJson(activityJson, false))
              .toList();
          _filteredPromos = promos;
        });
      } else {
        print('error de load promos');
        // Si la respuesta es un error, muestra un mensaje
        throw Exception('Failed to load places');
      }
    } catch (e) {
      print('error al trycatch');
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

    print('is logged in');
    print(isLoggedIn);
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
                  children: [
                    Text('No hay ningúna promo registrado aún para $placeName'),
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
                      child: const Text('Crea una promo!'),
                    )
                  ],
                )))
        : Column(children: [
            // 🔍 Buscador
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
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
                        style: TextStyle(fontSize: 10),
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

class PrommoCard extends StatelessWidget {
  const PrommoCard({
    super.key,
    required this.promo,
  });

  final Promo promo;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PromoDetail(
                        promoUuid: promo.uuid,
                      )));
        },
        child: Column(children: [
          Container(
            height: 100,
            width: MediaQuery.of(context).size.width * 0.95,
            child: Stack(
              children: [
                // Imagen de fondo
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: promo.imageUrl == null
                        ? Container(
                            color: Colors.blue, // Color fijo
                            width: 200,
                            height: 150,
                          )
                        : Image.network(
                            promo
                                .imageUrl!, // o usa NetworkImage con Image.network()
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                // Capa oscura para mejor lectura del texto
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ),
                ),

                Positioned(
                    bottom: 5,
                    left: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(promo.name,
                            style: const TextStyle(
                              color: Colors.white,
                            )),
                        if (promo.shortDesc != null)
                          Text(
                            promo.shortDesc!,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                      ],
                    )),
                Positioned(
                  bottom: 6,
                  right: 5,
                  child: Row(
                    children: [
                      if (promo.activityCreatorImageUrl != null)
                        CircleAvatar(
                            backgroundImage:
                                NetworkImage(promo.activityCreatorImageUrl!),
                            radius: 18)
                      else
                        CircleAvatar(backgroundColor: Colors.amber, radius: 30),
                    ],
                  ),
                ),

                if (promo.tags!.isNotEmpty)
                  Positioned(
                    top: 6,
                    right: 5,
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: (promo.tags ?? []).map((tag) {
                        return Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            tag.name,
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 5)
        ]));
  }
}
