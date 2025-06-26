import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worldwildprova/models_fromddbb/activity.dart';
import 'package:worldwildprova/models_fromddbb/tag.dart';
import 'package:http/http.dart' as http;
import 'package:worldwildprova/screens/activitydetail_screen.dart';
import 'package:worldwildprova/widgets/activityCardForListing.dart';
import 'package:worldwildprova/widgets/authservice.dart';
import 'package:worldwildprova/widgets/aux_ActivityCard.dart';
import 'dart:convert';

import 'package:worldwildprova/widgets/mainscaffold.dart';
import 'package:worldwildprova/widgets/tagSelector.dart';
import 'package:worldwildprova/widgets/usages.dart';

class ActivitiesList extends StatefulWidget {
  final String placeUuid; // Recibimos el UUID del lugar
  final String placeName;
  const ActivitiesList(
      {super.key,
      required this.placeUuid,
      required this.placeName}); // Constructor que recibe el UUID

  @override
  _ActivitiesListState createState() => _ActivitiesListState();
}

class _ActivitiesListState extends State<ActivitiesList> {
  bool _showTagSelector = false;
  bool? _gratisSelector;

  List<Activity> activities = [];

  TextEditingController _searchController = TextEditingController();
  List<Activity> _filteredActivities = [];

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
    fetchActivities();
    fetchTags();
    initSelectedTags();
    _searchController.addListener(() {
      filterActivities(_gratisSelector);
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
    }
  }

  void filterActivities(gratis) {
    final query = _searchController.text.toLowerCase();
    final selectedTagIds = _selectedTags;

    setState(() {
      _filteredActivities = activities.where((item) {
        final matchesName = item.name.toLowerCase().contains(query);

        final matchesGratis = (gratis == null) || (item.gratis == gratis);
        //no hi ha tags
        if (selectedTagIds.isEmpty) {
          return matchesName && matchesGratis;
        }

        final activityTagIds = (item.tags ?? []).map((tag) => tag.id).toList();
        final matchesTags =
            activityTagIds.any((tagId) => selectedTagIds.contains(tagId));

        // La actividad debe cumplir ambos filtros
        return matchesName && matchesTags && matchesGratis;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Función para hacer la solicitud GET
  Future<void> fetchActivities() async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.0.17:8000/api/activities/?place_uuid=$placeUuid'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          activities = data
              .map((activityJson) => Activity.fromJson(activityJson, false))
              .toList();
          _filteredActivities = activities;
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

  Future<void> fetchTags() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.0.17:8000/api/tags/'));

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

  void _activityPressed(String activity_uuid) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isLoggedIn = await authService.isLoggedIn();

    if (!isLoggedIn) {
      Future.microtask(() => showLoginAlert(context,
          'Regístrate para poder tener más información de los planes!'));
      return;
    }
    userToken = await authService.getAccessToken();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ActivityDetail(
                  activityUuid: activity_uuid,
                  userToken: userToken!,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return activities.isEmpty
        ? Center(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 150, horizontal: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('No hay ningún plan registrado aún para $placeName'),
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
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                        onPressed: () {
                          _gratisSelector =
                              (_gratisSelector == null) ? true : null;
                          filterActivities(_gratisSelector);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4), // menos padding
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2),
                          backgroundColor: _gratisSelector != null
                              ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.7)
                              : Colors.white,
                          minimumSize: const Size(
                              0, 0), // para evitar tamaño mínimo fijo
                        ),
                        child: const Text('GRATIS',
                            style: TextStyle(fontSize: 12))),
                    const SizedBox(width: 8),
                    if(tags.isNotEmpty)
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
                                  filterActivities(_gratisSelector);
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  backgroundColor: Colors.grey.shade300,
                                  minimumSize: const Size(0, 0),
                                ),
                                child: Text(
                                  tag.name,
                                  style: const TextStyle(fontSize: 12),
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
                          style: TextStyle(fontSize: 12),
                        )),
                  ],
                ),
              ),

              if (_showTagSelector)
                TagSelector(
                  selectedTags: _selectedTags,
                  onChanged: (tags) {
                    setState(() {
                      filterActivities(_gratisSelector);
                      _selectedTags = tags;
                      // Aquí se actualiza la lista de tags seleccionados
                    });
                  },
                ),
              Expanded(
                child: ListView.builder(
                    itemCount: _filteredActivities.length,
                    itemBuilder: (context, index) {
                      final activity = _filteredActivities[index];
                      bool showHeader = false;
                      if (index == 0) {
                        showHeader = true;
                      } else {
                        final previousActivity = activities[index - 1];
                        showHeader = activity.dateTime.day !=
                            previousActivity.dateTime.day;
                      }

                      return Column(
                        children: [
                          if (showHeader)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: headerForDate(activity.dateTime),
                            ),
                          GestureDetector(
                              onTap: () {
                                _activityPressed(activity.uuid);
                              },
                              child: Column(children: [
                                AuxActivityCard(activity: activity),
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
