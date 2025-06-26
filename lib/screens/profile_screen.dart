import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:worldwildprova/models_fromddbb/tagChip.dart';
import 'package:worldwildprova/screens/second_screen.dart';
import 'package:worldwildprova/widgets/activitycard.dart';
import 'package:worldwildprova/widgets/authservice.dart';
import 'package:provider/provider.dart';
import 'package:worldwildprova/models_fromddbb/userprofile.dart';
import 'package:worldwildprova/widgets/tagSelector.dart';

class ProfileScreen extends StatefulWidget {
  final String? foreignUserUuid;

  ProfileScreen({
    this.foreignUserUuid,
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserProfile?> userProfile;
  late AuthService authService;
  late String? userToken;
  late bool itsMe;
  bool _showEditTags = false;
  bool _showEditDescription = false;
  final TextEditingController _descriptionChangeController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    authService = Provider.of<AuthService>(context, listen: false);

    setState(() {
      userProfile = loadUserProfile(authService);
      itsMe = widget.foreignUserUuid == null;
    });
    _loadUserToken();
  }

  Future<void> _loadUserToken() async {
    userToken = await authService.getAccessToken();
  }

  Future<UserProfile?> loadUserProfile(AuthService authService) async {
    if (widget.foreignUserUuid == null) {
      final accessToken = await authService.getAccessToken();
      final userProfile = await authService.getUserProfile(accessToken);
      if (userProfile!.bio!.isNotEmpty) {
        _descriptionChangeController.text = userProfile.bio!;
      }
      return userProfile;
    }

    // Si s'està enviant un foreignUserUuid es perquè estem mirant el perfil d'algú altre
    print('foreign user');
    final body = jsonEncode({'user_uuid': widget.foreignUserUuid});

    final response =
        await http.post(Uri.parse('http://192.168.0.17:8000/api/userProfile/'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: body);

    if (response.statusCode == 200) {
      var a = UserProfile.fromJson(jsonDecode(response.body));
      print('ahi va el userprofile');
      print(a);
      return a;
    } else {
      return null;
    }
  }

  void submitPartialUpdate(String uuid, String field, String value) async {
    final body = jsonEncode({'user_uuid': uuid, field: value});

    final response = await http.post(
        Uri.parse(
          'http://192.168.0.17:8000/api/actualizar_usuario/',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body);

    if (response.statusCode == 200) {
      setState(() {
        userProfile = loadUserProfile(authService);
      });
    }
  }

  void _addDescription(String userUuid) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ingresá algo'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Escribí acá',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                submitPartialUpdate(userUuid, 'description', _controller.text);
                Navigator.of(context).pop(); // cierra el diálogo
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _addTags(String userUuid) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          List<int> selectedTags = [];
          return AlertDialog(
            actions: [
              TagSelector(onChanged: (tags) {
                setState(() {
                  selectedTags = tags;
                });
              }),
              ElevatedButton(
                  onPressed: () {
                    submitPartialUpdate(
                        userUuid, 'tags', selectedTags.toString());
                    Navigator.of(context).pop(); // cierra el diálogo
                  },
                  child: Text('Hecho!'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      endDrawer: itsMe
          ? FutureBuilder<UserProfile?>(
              future: userProfile,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return const Text('Error cargando perfil');
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Text('Perfil no disponible');
                } else {
                  final user = snapshot.data!;
                  List<int> selectedTags =
                      user.tags!.map((tag) => tag.id).toList();
                  return Drawer(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      child: ListView(
                        children: [
                          TextButton(
                              style: TextButton.styleFrom(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _showEditDescription = !_showEditDescription;
                                });
                              },
                              child: const Text('Editar mi descripción')),
                          if (_showEditDescription == true)
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16.0, 0, 16.0, 0),
                                  child: TextField(
                                    controller: _descriptionChangeController,

                                    // decoration: InputDecoration(hintText: user.bio),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    child: const Text('Confirmar'),
                                    onPressed: () {
                                      submitPartialUpdate(
                                          snapshot.data!.uuid,
                                          'description',
                                          _descriptionChangeController.text);

                                      _showEditDescription = false;

                                      // Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          TextButton(
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _showEditTags = !_showEditTags;
                                });
                                print(_showEditTags);
                              },
                              child: Text('Editar mis tags')),
                          if (_showEditTags == true)
                            Column(
                              children: [
                                TagSelector(
                                  selectedTags: selectedTags,
                                  onChanged: (newTags) {
                                    selectedTags = newTags;
                                  },
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    child: Text('Confirmar'),
                                    onPressed: () {
                                      submitPartialUpdate(snapshot.data!.uuid,
                                          'tags', selectedTags.toString());

                                      _showEditTags = false;

                                      // Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          TextButton(
                              onPressed: () {
                                authService.logout();
                              },
                              child: Text('cerrar sesión'))
                        ],
                      ));
                }
              },
            )
          : null,
      body: FutureBuilder(
          future: userProfile,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError || snapshot.data == null) {
              // Si hubo error o no hay datos, cerramos sesión automáticamente
              WidgetsBinding.instance.addPostFrameCallback((_) {
                authService.logout(); // Limpia tokens
              });

              return const Center(
                  child: Text('Sesión inválida. Redirigiendo...'));
            } else {
              final userProfile = snapshot.data;
              final PageController _pageController =
                  PageController(viewportFraction: 0.40);
              // ajusta el tamaño visible
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.start, // centra verticalmente
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '@${userProfile!.username}',
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary),
                          )),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Container(
                              width: MediaQuery.of(context).size.width *
                                  0.4, // limita al 50% del ancho de pantalla
                              child: Column(children: [
                                if (userProfile.originLocation != null)
                                  Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                          '📍${userProfile.originLocation}')),
                                SizedBox(height: 20),
                                if (userProfile.bio!.isNotEmpty)
                                  Text(userProfile.bio!, softWrap: true),
                                if (userProfile.bio!.isEmpty)
                                  TextButton(
                                      onPressed: () {
                                        _addDescription(userProfile.uuid);
                                      },
                                      child:
                                          Text('cuéntanos un poco sobre ti...'))
                              ]),
                            ),
                          ),
                          SizedBox(width: 5),
                          Container(
                              width: MediaQuery.of(context).size.width *
                                  0.45, // limita al 45% del ancho de pantalla
                              height: MediaQuery.of(context).size.height * 0.35,
                              color: Colors.black54,
                              child: userProfile.userImageUrl != null
                                  ? Image.network(
                                      userProfile.userImageUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : Center(
                                      child: Icon(Icons.camera_alt,
                                          size: 40,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    )),
                        ],
                      ),
                      SizedBox(height: 10),
                      if (userProfile.tags!.isNotEmpty)
                        Wrap(
                          spacing: 2.0, //espacio horizontal
                          runSpacing:
                              0, // espacio vertical entre líneas de chips
                          children: userProfile.tags!
                              .map((tag) => TagChip(tag: tag))
                              .toList(),
                        ),
                      if (userProfile.tags!.isEmpty)
                        TextButton(
                            onPressed: () {
                              _addTags(userProfile.uuid);
                            },
                            child: Text('+  Añade tus tags')),
                      SizedBox(height: 10),
                      if (userProfile.activities!.isEmpty)
                        Stack(children: [
                          SizedBox(
                              height: 200,
                              child: PageView.builder(
                                  controller: _pageController,
                                  itemCount: 5,
                                  padEnds: false,
                                  itemBuilder: (context, index) {
                                    return SizedBox(
                                        child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            15), // Bordes redondeados
                                      ),
                                      elevation: 5,
                                      child: Center(
                                        child: Text(
                                          '¿?',
                                          style: TextStyle(
                                              fontSize: 40,
                                              color: Colors.blueAccent),
                                        ),
                                      ),
                                    ));
                                  })),
                          Positioned.fill(
                            child: Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SecondScreen(
                                        placeName: 'Buenos Aires',
                                        placeUuid:
                                            '0cffbdd2-c0ce-4b6d-94a3-0bb7e2123c1f',
                                        fromMainScaffold: false,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'encuentra tus primeros planes',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                        ])
                      else
                        SizedBox(
                          height: 200, // o el alto que necesites
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: userProfile.activities!.length,
                            padEnds: false,
                            itemBuilder: (context, index) {
                              final activity = userProfile.activities![index];
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: ActivityCard(
                                    activityUuid: activity.uuid,
                                    imageUrl: activity.activityImageUrl,
                                    activityTitle: activity.name,
                                    activityDateTime: activity.dateTime,
                                    created_by_user: activity.created_by_user!,
                                    userToken: userToken),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }
          }),
    );
  }
}
