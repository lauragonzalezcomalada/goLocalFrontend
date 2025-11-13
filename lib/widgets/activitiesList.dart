import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worldwildprova/config.dart';
import 'package:worldwildprova/models_fromddbb/activity.dart';
import 'package:worldwildprova/models_fromddbb/tag.dart';
import 'package:http/http.dart' as http;
import 'package:worldwildprova/screens/activitydetail_screen.dart';
import 'package:worldwildprova/widgets/appTheme.dart';
import 'package:worldwildprova/widgets/authservice.dart';
import 'package:worldwildprova/widgets/aux_ActivityCard.dart';
import 'dart:convert';

import 'package:worldwildprova/widgets/mainscaffold.dart';
import 'package:worldwildprova/widgets/tagSelector.dart';
import 'package:worldwildprova/widgets/usages.dart';

class ActivitiesList extends StatefulWidget {
  final String placeUuid;
  final String placeName;
  const ActivitiesList({
    super.key,
    required this.placeUuid,
    required this.placeName,
  });

  @override
  _ActivitiesListState createState() => _ActivitiesListState();
}

class _ActivitiesListState extends State<ActivitiesList> {
  bool _showTagSelector = false;
  bool? _gratisSelector;
  bool noActivities = false;

  List<Activity> activities = [];
  List<Activity> _filteredActivities = [];
  List<Tag> tags = [];
  List<int> _selectedTags = [];

  late String placeUuid;
  late String placeName;
  String? userToken = '';

  final TextEditingController _searchController = TextEditingController();
  late Future<bool> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    placeUuid = widget.placeUuid;
    placeName = widget.placeName;

    _activitiesFuture = fetchActivities();
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

        if (selectedTagIds.isEmpty) {
          return matchesName && matchesGratis;
        }

        final activityTagIds = (item.tags ?? []).map((tag) => tag.id).toList();
        final matchesTags =
            activityTagIds.any((tagId) => selectedTagIds.contains(tagId));

        return matchesName && matchesTags && matchesGratis;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> fetchActivities() async {
    try {
      final response =
          await http.get(Uri.parse('${Config.serverIp}/activities'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        if (data.isEmpty) {
          setState(() {
            noActivities = true;
          });
          return false;
        }

        setState(() {
          activities = data
              .map((activityJson) => Activity.fromJson(activityJson, false))
              .toList();
          _filteredActivities = activities;
          noActivities = false;
        });

        return true;
      } else {
        throw Exception('Failed to load activities');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        noActivities = true;
      });
      return false;
    }
  }

  Future<void> updateViews(String uuid) async {
    print('sactualitzen les views');
    try {
      final response = await http.get(Uri.parse(
          '${Config.serverIp}/register_view/?activity=True&uuid=$uuid'));

      if (response.statusCode != 200) {
        throw Exception('Failed to register view');
      }
    } catch (e) {
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
        throw Exception('Failed to load tags');
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
    updateViews(activity_uuid);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActivityDetail(
          activityUuid: activity_uuid,
          userToken: userToken!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _activitiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Image.asset(
              'assets/ojitos.gif',
              width: 150,
              height: 150,
            ),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Error al cargar las actividades'),
          );
        }

        if (noActivities || activities.isEmpty) {
          return Center(
              child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 150, horizontal: 50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'NO HAY NINGUN PLAN REGISTRADO AÚN',
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
                          backgroundColor:
                              WidgetStateProperty.all(AppTheme.logo),
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
                            'CREÁ UN PLAN!',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      )
                    ],
                  )));
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelStyle: const TextStyle(fontSize: 20),
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
                      _gratisSelector = (_gratisSelector == null) ? true : null;
                      filterActivities(_gratisSelector);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                      backgroundColor: _gratisSelector != null
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5)
                          : Colors.white,
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Text('GRATIS', style: TextStyle(fontSize: 15)),
                  ),
                  const SizedBox(width: 8),
                  if (tags.isNotEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: _selectedTags.map((tagId) {
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
                        width: 2,
                      ),
                      backgroundColor: _showTagSelector
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.7)
                          : Colors.white,
                    ),
                    child: const Text(
                      'TAGS',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
            if (_showTagSelector)
              TagSelector(
                selectedTags: _selectedTags,
                onChanged: (tags) {
                  setState(() {
                    _selectedTags = tags;
                    filterActivities(_gratisSelector);
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
                    showHeader =
                        activity.dateTime.day != previousActivity.dateTime.day;
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
                        child: Column(
                          children: [
                            AuxActivityCard(activity: activity),
                            const SizedBox(height: 5),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
