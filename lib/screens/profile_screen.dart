import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:worldwildprova/config.dart';
import 'package:worldwildprova/models_fromddbb/activity.dart';
import 'package:worldwildprova/models_fromddbb/promo.dart';
import 'package:worldwildprova/models_fromddbb/tagChip.dart';
import 'package:worldwildprova/screens/second_screen.dart';
import 'package:worldwildprova/widgets/appTheme.dart';
import 'package:worldwildprova/widgets/eventcard.dart';
import 'package:worldwildprova/widgets/authservice.dart';
import 'package:provider/provider.dart';
import 'package:worldwildprova/models_fromddbb/userprofile.dart';
import 'package:worldwildprova/widgets/mainscaffold.dart';
import 'package:worldwildprova/widgets/tagSelector.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  final String? foreignUserUuid;
  final bool? notFromMainScaffold;
  final bool? fromActivityDetail;

  ProfileScreen({
    this.foreignUserUuid,
    this.notFromMainScaffold,
    this.fromActivityDetail,
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
  bool _showMessages = false;
  final TextEditingController _descriptionChangeController =
      TextEditingController();

  String? _localImageUrl;
  File? _localImage;

  @override
  void initState() {
    super.initState();
    authService = Provider.of<AuthService>(context, listen: false);
    _loadUserToken();
    setState(() {
      userProfile = loadUserProfile(authService);
      itsMe = widget.foreignUserUuid == null;
    });
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
      setState(() {
        _localImageUrl = userProfile.userImageUrl;
        _localImage = null;
      });
      return userProfile;
    }

    // Si s'està enviant un foreignUserUuid es perquè estem mirant el perfil d'algú altre
    final body = jsonEncode({'user_uuid': widget.foreignUserUuid});

    final response =
        await http.post(Uri.parse('${Config.serverIp}/userProfile/'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: body);

    if (response.statusCode == 200) {
      UserProfile usPr = UserProfile.fromJson(jsonDecode(response.body));
      setState(() {
        _localImageUrl = usPr.userImageUrl;
        _localImage = null;
      });
      return usPr;
    } else {
      return null;
    }
  }

  void submitImageUpdate(File file) async {
    var uri = Uri.parse('${Config.serverIp}/update_profile_image/');
    var request = http.MultipartRequest('POST', uri);

    // 🔑 Header con el Bearer token
    request.headers['Authorization'] = 'Bearer $userToken';
    request.files.add(
      await http.MultipartFile.fromPath('image', file.path),
    );
    var response = await request.send();

    if (response.statusCode == 200) {
      setState(() {
        userProfile = loadUserProfile(authService);
      });
    } else {
      print("Error subiendo imagen: ${response.statusCode}");
    }
  }

  void submitPartialUpdate(String uuid, String field, String value) async {
    final body = jsonEncode({'user_uuid': uuid, field: value});

    final response = await http.post(
        Uri.parse(
          '${Config.serverIp}/actualizar_usuario/',
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

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        _localImage = File(picked.path);
      });

      submitImageUpdate(_localImage!);
    }
  }

  void _removeImage() async {
    setState(() {
      _localImage = null;
      _localImageUrl = null;
    });
    //submit partial update de la foto

    final response = await http.post(
      Uri.parse(
        '${Config.serverIp}/remove_profile_image/',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $userToken'
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        userProfile = loadUserProfile(authService);
        _localImage == null;
        _localImageUrl == null;
      });
    }
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppTheme.logo),
                title: const Text(
                  'CAMBIAR IMAGEN',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.logo),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppTheme.logo),
                title: const Text(
                  'ELIMINAR IMAGEN',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.logo),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _removeImage();
                },
              ),
            ],
          ),
        ),
      ),
    );
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
        appBar: AppBar(
          actionsIconTheme: IconThemeData(color: AppTheme.logo),
        ),
        /*AppBar(
          automaticallyImplyLeading: false,
          actions: [
            FutureBuilder<UserProfile?>(
              future: userProfile,
              builder: (context, snapshot) {
                final hasUnread = snapshot.hasData &&
                    snapshot.data != null &&
                    snapshot.data!.unreadMessages!.isNotEmpty;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    ),
                    if (hasUnread)
                      const Positioned(
                        right: 6,
                        top: 6,
                        child: CircleAvatar(
                          radius: 5,
                          backgroundColor: Colors.red,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),*/
        endDrawer: itsMe
            ? FutureBuilder<UserProfile?>(
                future: userProfile,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Image.asset(
                        'assets/ojitos.gif',
                        width: 100,
                        height: 100,
                      ),
                    );
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
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              TextButton(
                                  style: TextButton.styleFrom(
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showEditDescription =
                                          !_showEditDescription;
                                    });
                                  },
                                  child: const Text('EDITAR MI DESCRIPCIÓN',
                                      style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800))),
                              if (_showEditDescription == true)
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16.0, 0, 16.0, 0),
                                      child: TextField(
                                          controller:
                                              _descriptionChangeController,
                                          minLines: 3,
                                          maxLines: 6

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
                                              _descriptionChangeController
                                                  .text);

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
                                  },
                                  child: Text(
                                    'EDITAR MIS TAGS',
                                    style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800),
                                  )),
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
                                          submitPartialUpdate(
                                              snapshot.data!.uuid,
                                              'tags',
                                              selectedTags.toString());

                                          _showEditTags = false;

                                          // Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              /*TextButton(
                                  onPressed: () {
                                    if (user.unreadMessages!.length > 0) {
                                      setState(() {
                                        _showMessages = !_showMessages;
                                      });
                                    } else {
                                      print('no hay mensajes');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'No tienes mensajes por ahora...'),
                                          duration: Duration(
                                              seconds:
                                                  2), // tiempo que dura visible
                                        ),
                                      );
                                    }
                                  },
                                  child: Stack(
                                    clipBehavior: Clip
                                        .none, // para que el badge pueda "salirse"
                                    children: [
                                      const Text('MENSAJES'),
                                      if (user.unreadMessages!.length > 0)
                                        Positioned(
                                          right:
                                              -20, // mueve el badge hacia afuera a la derecha
                                          top: -10, // mueve el badge hacia arriba
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 20,
                                              minHeight: 20,
                                            ),
                                            child: Text(
                                              '${user.unreadMessages?.length}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (_showMessages == true)
                                  SizedBox(
                                    height: 200,
                                    child: ListView.builder(
                                      itemCount: user.unreadMessages?.length ?? 0,
                                      itemBuilder: (context, index) {
                                        final message = user.unreadMessages![index];
                                        return ListTile(
                                          title: Text(message.message),
                                        );
                                      },
                                    ),
                                  ),*/
                              TextButton(
                                  onPressed: () {
                                    authService.logout();
                                  },
                                  child: const Text(
                                    'CERRAR SESIÓN',
                                    style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800),
                                  ))
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
              )
            : null,
        body: FutureBuilder(
            future: userProfile,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Image.asset(
                    'assets/ojitos.gif',
                    width: 100,
                    height: 100,
                  ),
                );
              } else if (snapshot.hasError || snapshot.data == null) {
                // Si hubo error o no hay datos, cerramos sesión automáticamente
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  authService.logout(); // Limpia tokens
                });

                return const Center(
                    child: Text('Sesión inválida. Redirigiendo...'));
              } else {
                final userProfile = snapshot.data;
                final PageController pageController =
                    PageController(viewportFraction: 0.40);

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.fromActivityDetail == true)
                          Align(
                            alignment: AlignmentGeometry.topRight,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 0.0),
                              child: TextButton(
                                child: Text(
                                  'CONTACTÁNOS',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800),
                                ),
                                onPressed: () async {
                                  final email = userProfile?.email;
                                  final subject = Uri.encodeComponent(
                                      'Consulta sobre tu actividad');
                                  final body = Uri.encodeComponent(
                                      'Hola, quería consultarte sobre');

                                  final mailtoLink = Uri(
                                    scheme: 'mailto',
                                    path: email,
                                    query: 'subject=$subject&body=$body',
                                  );

                                  if (await canLaunchUrl(mailtoLink)) {
                                    await launchUrl(mailtoLink);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'No se pudo abrir la app de correo')),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        Transform.translate(
                          offset: const Offset(0, -10),
                          child: Center(
                            child: Container(
                              width: 205,
                              height: 205,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 5,
                                ),
                              ),
                              child: ClipOval(
                                child: itsMe
                                    ? GestureDetector(
                                        onTap: (userProfile?.userImageUrl ==
                                                    null ||
                                                userProfile!
                                                    .userImageUrl!.isEmpty)
                                            ? _pickImage
                                            : _showImageOptions,
                                        child: Container(
                                          width: 150,
                                          height: 200,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            image: (userProfile?.userImageUrl !=
                                                        null &&
                                                    userProfile!.userImageUrl!
                                                        .isNotEmpty)
                                                ? DecorationImage(
                                                    image: NetworkImage(
                                                        userProfile
                                                            .userImageUrl!),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                          ),
                                          child: (userProfile?.userImageUrl ==
                                                      null ||
                                                  userProfile!
                                                      .userImageUrl!.isEmpty)
                                              ? Center(
                                                  child: Icon(
                                                    Icons.camera_alt,
                                                    size: 40,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                )
                                              : null,
                                        ),
                                      )
                                    : Container(
                                        width: 150,
                                        height: 200,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            image: (userProfile?.userImageUrl !=
                                                        null &&
                                                    userProfile!.userImageUrl!
                                                        .isNotEmpty)
                                                ? DecorationImage(
                                                    image: NetworkImage(
                                                        userProfile
                                                            .userImageUrl!),
                                                    fit: BoxFit.cover,
                                                  )
                                                : const DecorationImage(
                                                    image: AssetImage(
                                                        'assets/solocarita.png'),
                                                    fit: BoxFit.cover))),
                              ),
                            ),
                          ),
                        ),
                        Align(
                            alignment: Alignment.center,
                            child: Text(
                              '@${userProfile!.username}',
                              style: TextStyle(
                                  fontSize: 35,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'BarlowCondensed',
                                  color: Theme.of(context).colorScheme.primary),
                            )),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.90,
                                child: Column(children: [
                                  if (userProfile.originLocation != null)
                                    Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                            '📍${userProfile.originLocation}')),
                                  SizedBox(height: 20),
                                  if (userProfile.bio!.isNotEmpty)
                                    Text(
                                      userProfile.bio!,
                                      textAlign: TextAlign.justify,
                                      softWrap: true,
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: 'BarlowCondensed'),
                                    ),
                                  if (userProfile.bio!.isEmpty && itsMe)
                                    TextButton(
                                        onPressed: () {
                                          _addDescription(userProfile.uuid);
                                        },
                                        child: Text(
                                            'cuéntanos un poco sobre ti...'))
                                ]),
                              ),
                            ),
                            SizedBox(width: 5),
                          ],
                        ),
                        SizedBox(height: 20),
                        if (userProfile.tags!.isNotEmpty && itsMe) ...[
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'TUS INTERESES',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.logo),
                              ),
                              SizedBox(width: 8), // espacio entre texto y línea
                              Expanded(
                                child: Divider(
                                  color: AppTheme.logo,
                                  thickness: 2,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Wrap(
                            spacing: 2.0, //espacio horizontal
                            runSpacing:
                                0, // espacio vertical entre líneas de chips
                            children: userProfile.tags!
                                .map((tag) => TagChip(tag: tag))
                                .toList(),
                          )
                        ],
                        if (userProfile.tags!.isEmpty && itsMe)
                          TextButton(
                              onPressed: () {
                                _addTags(userProfile.uuid);
                              },
                              child: Text('+  Añade tus tags')),
                        SizedBox(height: 10),
                        if (userProfile.eventos!.isEmpty)
                          /*Stack(children: [
                            SizedBox(
                                height: 200,
                                child: PageView.builder(
                                    controller: pageController,
                                    itemCount: 6,
                                    padEnds: false,
                                    itemBuilder: (context, index) {
                                      return SizedBox(
                                          child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              15), // Bordes redondeados
                                        ),
                                        elevation: 5,
                                        child: index % 2 == 0
                                            ? Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'Encue',
                                                    style: TextStyle(
                                                        fontSize: 40,
                                                        color: AppTheme.logo,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ),
                                                  Text(
                                                    'tus',
                                                    style: TextStyle(
                                                        fontSize: 40,
                                                        color: AppTheme.logo,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ),
                                                  Text(
                                                    'pla',
                                                    style: TextStyle(
                                                        fontSize: 40,
                                                        color: AppTheme.logo,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  )
                                                ],
                                              )
                                            : Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'ntra',
                                                    style: TextStyle(
                                                        fontSize: 40,
                                                        color: AppTheme.logo,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ),
                                                  Text(
                                                    'primeros',
                                                    style: TextStyle(
                                                        fontSize: 40,
                                                        color: AppTheme.logo,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'nes',
                                                        style: TextStyle(
                                                            fontSize: 40,
                                                            color:
                                                                AppTheme.logo,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w800),
                                                      ),
                                                      Image.asset(
                                                        './assets/solocarita.png',
                                                        width: 50,
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                      ));
                                    })),
                            Positioned.fill(
                              child: Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SecondScreen(
                                          placeName: 'Buenos Aires',
                                          placeUuid:
                                              '0cffbdd2-c0ce-4b6d-94a3-0bb7e2123c1f',
                                          fromMainScaffold: false,
                                        ),
                                      ),
                                      (route) => false,
                                    );
                                  },
                                  child: const Text(
                                    '',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            ),
                          ])*/

                          SizedBox(
                            height: 150,
                            child: Card(
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'ENCONTRÁ TU PRIMER PLAN!',
                                      style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.logo),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SecondScreen(
                                                placeName: 'Buenos Aires',
                                                placeUuid:
                                                    '0cffbdd2-c0ce-4b6d-94a3-0bb7e2123c1f',
                                                fromMainScaffold: false,
                                              ),
                                            ),
                                            (route) => false,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.add,
                                          color: AppTheme.logo,
                                          size: 40,
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else ...[
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'EVENTOS ASISTIDOS',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.logo),
                              ),
                              SizedBox(width: 8), // espacio entre texto y línea
                              Expanded(
                                child: Divider(
                                  color: AppTheme.logo,
                                  thickness: 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 300, // o el alto que necesites
                            child: PageView.builder(
                              controller: pageController,
                              itemCount: userProfile.eventos!.length,
                              padEnds: false,
                              itemBuilder: (context, index) {
                                final evento = userProfile.eventos![index];
                                final tipo;

                                if (evento is Activity)
                                  tipo = 'activity';
                                else if (evento is Promo)
                                  tipo = 'promo';
                                else
                                  tipo = 'privatePlan';
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: EventCard(
                                      tipo: tipo,
                                      activityUuid: evento.uuid,
                                      imageUrl: evento.imageUrl,
                                      activityTitle: evento.name,
                                      activityDateTime: evento.dateTime,
                                      created_by_user:
                                          evento.created_by_user != null
                                              ? evento.created_by_user!
                                              : false,
                                      userToken: userToken,
                                      tiene_tickets: evento.tiene_tickets,
                                      active: evento.active),
                                );
                              },
                            ),
                          ),
                        ],
                        SizedBox(height: 20),
                        if (userProfile.eventosCreados!.isNotEmpty) ...[
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'EVENTOS CREADOS',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.logo),
                              ),
                              SizedBox(width: 8), // espacio entre texto y línea
                              Expanded(
                                child: Divider(
                                  color: AppTheme.logo,
                                  thickness: 2,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                            height: 300, // o el alto que necesites
                            child: PageView.builder(
                              controller: pageController,
                              itemCount: userProfile.eventosCreados?.length,
                              padEnds: false,
                              itemBuilder: (context, index) {
                                final evento =
                                    userProfile.eventosCreados![index];
                                final tipo;
                                if (evento is Activity)
                                  tipo = 'activity';
                                else if (evento is Promo)
                                  tipo = 'promo';
                                else
                                  tipo = 'privatePlan';

                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: EventCard(
                                      tipo: tipo,
                                      activityUuid: evento.uuid,
                                      imageUrl: evento.imageUrl,
                                      activityTitle: evento.name,
                                      activityDateTime: evento.dateTime,
                                      created_by_user:
                                          evento.created_by_user != null
                                              ? evento.created_by_user!
                                              : false,
                                      userToken: userToken,
                                      tiene_tickets: evento.tiene_tickets,
                                      active: evento.active),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 20)
                        ]
                      ],
                    ),
                  ),
                );
              }
            }),
        bottomNavigationBar: widget.notFromMainScaffold == true
            ? BottomNavigationBar(
                selectedLabelStyle: const TextStyle(fontSize: 16),
                unselectedLabelStyle: const TextStyle(fontSize: 14),
                currentIndex: 0, // mismo control
                onTap: (index) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainScaffold(initialIndex: index),
                    ),
                    (route) => false,
                  );
                },
                items: [
                  BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/explorar.png',
                        height: 30, // ajustá el tamaño
                        width: 30,
                      ),
                      label: 'Explorar'),
                  BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/pincel3.png',
                        height: 24, // ajustá el tamaño
                        width: 24,
                      ),
                      label: 'Crear Plan'),
                  BottomNavigationBarItem(
                      icon: Image.asset(
                        'assets/solocarita.png',
                        height: 24, // ajustá el tamaño
                        width: 24,
                      ),
                      label: 'Perfil'),
                ],
              )
            : null);
  }
}
