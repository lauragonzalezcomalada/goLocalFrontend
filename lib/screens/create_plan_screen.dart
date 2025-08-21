import 'dart:io';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart'; // per les dates, per formatejarles
import 'package:worldwildprova/config.dart';
import 'package:worldwildprova/models_fromddbb/userprofile.dart';
import 'package:worldwildprova/widgets/usages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import 'package:worldwildprova/models_fromddbb/activitytypedropdown.dart';
import 'package:worldwildprova/widgets/authservice.dart';
import 'package:worldwildprova/screens/log_in_screen.dart';
import 'package:worldwildprova/widgets/mainscaffold.dart';
import 'package:worldwildprova/screens/placecarousel_screen.dart';
import 'package:worldwildprova/widgets/tagSelector.dart';

enum PlanType { plan, promo, private }

class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({super.key});
  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  String? userToken;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _checkLoggedStatus();
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        // Si se pierde el foco, se limpian resultados y texto
        setState(() {
          _searchController.clear();
          _searchResults = []; // <-- Tu lista de resultados
        });
      }
    });
  }

  Future<void> _checkLoggedStatus() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final isLoggedIn = await authService.isLoggedIn();
    if (!isLoggedIn) {
      Future.microtask(() => showLoginAlert(
          context, 'Registrate para poder empezar a crear tus planes!'));
    }
    userToken = await authService.getAccessToken();
  }

  final String googleApiKey = 'AIzaSyBM51UAqo5azY443B3CxM8VMv-IIRLIOR0';

  final _formKey = GlobalKey<FormState>();

  // els controladors
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _shortDescriptionController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _urlEntradas = TextEditingController();
  final TextEditingController _urlInstagram = TextEditingController();
  final TextEditingController _urlWeb = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  List<int> _selectedTags = []; // Aquí almacenamos los tags seleccionados
  DateTime? _selectedDateTime;
  DateTime? _selectedEndDateTime;

  TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<UserProfile> _searchResults = [];
  List<UserProfile> _selectedUsersUuid = [];
  bool _isLoading = false;

  // Per al camp de ubicació
  List<Map<String, dynamic>> _suggestions = [];
  String? _selectedPlaceId;
  double? _latitude;
  double? _longitude;
  String? direccion;

  // Variable para controlar la opción seleccionada y el error
  bool? _selectedGratisOption;
  bool _showGratisError = false;

  bool _showDateTimeError = false;
  bool _showNoEndDateTimeError = false;
  bool _showInvalidEndDateTimeError = false;

  // Variable para controlar la opción seleccionada y el error
  PlanType? _selectedPlanType;

  bool _selectedPlan = false;
  bool _selectedPromo = false;
  bool _selectedPrivatePlan = false;
  //per a carregar imatges
  File? _selectedImage;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  //Crear l'element per a triar la data i hora
  Future<void> pickStartDateTime() async {
    print(DateTime.now());
    print(DateTime.now().toLocal());
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;
    setState(() {
      _selectedDateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _showDateTimeError = false;
    });
  }

  //Crear l'element per a triar la data i hora de fin de promo
  Future<void> pickEndDateTime() async {
    final date = _selectedDateTime;
    // if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(date!),
    );
    print(time);
    if (time == null) return;
    setState(() {
      _selectedEndDateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
      _showNoEndDateTimeError = false;
      _showInvalidEndDateTimeError = false;
    });
  }

  //Obtener sugerencias desde Places Autocomplete
  Future<void> _getPlaceSuggestions(String input) async {
    print('get place suggestions');
    print(input);
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$googleApiKey';
    print(url);
    final response = await http.get(Uri.parse(url));
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _suggestions = (data['predictions'] as List)
            .map((item) => {
                  'description': item['description'],
                  'place_id': item['place_id'],
                })
            .toList();
      });
    } else {
      print("Autocomplete error: ${response.body}");
    }
  }

  //Obtener coordenadas con el place_id
  Future<void> _getCoordinatesFromPlaceId(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$googleApiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final location = data['result']['geometry']['location'];
      _latitude = location['lat'];
      _longitude = location['lng'];
      direccion = data['result']['formatted_address'];
    } else {
      print("Details error: ${response.body}");
    }
  }

  void _resetForm() async {
    _formKey.currentState?.reset();
    _titleController.clear();
    _shortDescriptionController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _urlEntradas.clear();
    _urlInstagram.clear();
    _urlWeb.clear();
    _placeController.clear();

    setState(() {
      _selectedPlaceId = null;
      _suggestions = [];
      _latitude = null;
      _longitude = null;
      _selectedGratisOption = null;
      _selectedTags = [];
      _selectedDateTime = null;
      _selectedEndDateTime = null;
      _selectedPlan = false;
      _selectedPromo = false;
      _selectedPrivatePlan = false;
    });
    final token = await userToken;
    if (token == null) {
      showLoginAlert(
          context, 'Registrate para poder empezar a crear tus planes!');
      return;
    }
  }

  bool _validate() {
    bool other_errors = false;
    bool? form_controllers_validate = _formKey.currentState?.validate();
    if (_selectedDateTime == null) {
      setState(() {
        _showDateTimeError = true;
      });
      other_errors = true;
    }
    if (_selectedGratisOption == null) {
      setState(() {
        _showGratisError = true;
      });
      other_errors = true;
    }

    if (_selectedPromo == true && _selectedEndDateTime == null) {
      setState(() {
        _showNoEndDateTimeError = true;
      });
      other_errors = true;
    }
    if (_selectedPromo == true &&
        _selectedEndDateTime != null &&
        _selectedEndDateTime!.isBefore(_selectedDateTime!)) {
      setState(() {
        _showInvalidEndDateTimeError = true;
      });
      other_errors = true;
    }

    if (_selectedPlan == false &&
        _selectedPromo == false &&
        _selectedPrivatePlan == false) {
      other_errors = true;
    }
    var result = !(other_errors) && (form_controllers_validate ?? false);
    return result;
  }

  void _submitForm() async {
    if (_validate()) {
      var createActivityUri = Uri.parse('${Config.serverIp}/createevent/');

      var request = http.MultipartRequest('POST', createActivityUri);
      final token = await userToken;
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['name'] = _titleController.text;
      request.fields['shortDesc'] = _shortDescriptionController.text;
      request.fields['desc'] = _descriptionController.text;
      request.fields['instagram_link'] = _urlInstagram.text;
      request.fields['tags'] = jsonEncode(_selectedTags);
      //Default price 0 si es gratis
      request.fields['price'] = '0';
      bool gratis = _selectedGratisOption ?? false;
      if (!gratis) {
        request.fields['gratis'] = gratis.toString();
        request.fields['price'] = _priceController.text;
        request.fields['tickets_link'] = _urlEntradas.text;
      }
      if (_selectedPlaceId != null) {
        await _getCoordinatesFromPlaceId(_selectedPlaceId!);
      }
      request.fields['lat'] = _latitude!.toString();
      request.fields['long'] = _longitude!.toString();
      request.fields['direccion'] = direccion!;
      request.fields['startDateandtime'] = _selectedDateTime!.toIso8601String();
      //request.fields['endDateandtime'] =
      //    _selectedEndDateTime!.toIso8601String();

      switch (_selectedPlanType!) {
        case PlanType.plan:
          request.fields['tipoEvento'] = '0';

        case PlanType.promo:
          request.fields['tipoEvento'] = '1';

        case PlanType.private:
          request.fields['tipoEvento'] = '2';
      }

      //request.fields['isPlanSelected'] = _selectedPlan.toString();

      if (_selectedImage != null) {
        final mimeType = lookupMimeType(_selectedImage!.path) ?? 'image/jpeg';

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _selectedImage!.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Text("¡Creáste tu plan 🎉!"),
              actions: [
                TextButton(
                  child: const Text("Ver mi plan"),
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el dialog
                  },
                ),
                TextButton(
                  child: const Text("Crear otro"),
                  onPressed: () {
                    _resetForm();
                    Navigator.of(context).pop(); // Cierra el dialog
                  },
                ),
              ],
            );
          },
        );
      } else {
        print('Error al crear plan: ${response.statusCode}');
        print(await response.stream.bytesToString());
      }
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isLoading = true);

    final response = await http
        .get(Uri.parse('${Config.serverIp}/search_users/?query=$query'));

    print(response.statusCode);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      final List<UserProfile> results =
          jsonList.map((json) => UserProfile.fromServerJson(json)).toList();

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } else {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedStartDate = _selectedDateTime != null
        ? DateFormat('EEEE, d \'de\' MMMM yyyy HH:mm', 'es_ES')
            .format(_selectedDateTime!)
        : 'Seleccionar fecha y hora';

    if (_selectedPlan == false && _selectedEndDateTime != null) {
      formattedStartDate +=
          ' - ' + DateFormat('HH:mm', 'es_ES').format(_selectedEndDateTime!);
    }

    String formattedEndDate = _selectedEndDateTime != null
        ? DateFormat('EEEE, d \'de\' MMMM yyyy HH:mm', 'es_ES')
            .format(_selectedEndDateTime!)
        : 'Seleccionar fecha y hora';

    return Padding(
        padding: const EdgeInsets.fromLTRB(15, 30, 15, 10),
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: BoxDecoration(
            // color: const Color.fromARGB(255, 237, 204, 104),
            //border: Border.all(
            //  color: const Color.fromARGB(255, 226, 179, 38), width: 2),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.white,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Crea tu', style: TextStyle(fontSize: 60)),
                  ),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text('evento local', style: TextStyle(fontSize: 60)),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Plan'),
                            Radio<PlanType>(
                              value: PlanType.plan,
                              groupValue: _selectedPlanType,
                              onChanged: (PlanType? value) {
                                setState(() {
                                  _selectedPlanType = value;
                                  _selectedPromo = false;
                                  _selectedPrivatePlan = false;
                                  _selectedPlan = true;
                                });
                              },
                            ),
                            const Text('Promo'),
                            Radio<PlanType>(
                              value: PlanType.promo,
                              groupValue: _selectedPlanType,
                              onChanged: (PlanType? value) {
                                setState(() {
                                  _selectedPlanType = value;
                                  _selectedPlan = false;
                                  _selectedPrivatePlan = false;
                                  _selectedPromo = true;
                                });
                              },
                            ),
                            const Text('Plan privado'),
                            Radio<PlanType>(
                              value: PlanType.private,
                              groupValue: _selectedPlanType,
                              onChanged: (PlanType? value) {
                                setState(() {
                                  _selectedPlanType = value;
                                  _selectedPlan = false;
                                  _selectedPromo = false;
                                  _selectedPrivatePlan = true;
                                });
                              },
                            ),
                          ],
                        ),

                        //TÍTULO DEL EVENTO
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'Título',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa un título';
                            }
                            return null;
                          },
                          maxLines: null,
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _shortDescriptionController,
                          decoration: InputDecoration(
                              hintText: 'Pequeña descripción',
                              border: const OutlineInputBorder()),
                          maxLines: 1,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        //DESCRIPCIÓN DEL EVENTO
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            hintText: 'Descripción',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Explícanos de que va tu evento';
                            }
                            return null;
                          },
                          minLines: 4,
                          maxLines: null,
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Text(
                              'Es gratis?      ',
                            ),
                            const Text('Sí'),
                            Radio<bool>(
                              value: true,
                              groupValue: _selectedGratisOption,
                              onChanged: (bool? value) {
                                setState(() {
                                  _selectedGratisOption = value;
                                  _showGratisError =
                                      false; // Quita el error si selecciona
                                });
                              },
                            ),
                            const Text('No'),
                            Radio<bool>(
                              value: false,
                              groupValue: _selectedGratisOption,
                              onChanged: (bool? value) {
                                setState(() {
                                  _selectedGratisOption = value;
                                  _showGratisError =
                                      false; // Quita el error si selecciona
                                });
                              },
                            ),
                          ],
                        ),
                        if (_showGratisError) //mostrar error si valides i no hi ha valor seleccionat
                          Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text(
                              'Selecciona una opción',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        if (_selectedGratisOption == false) ...[
                          TextFormField(
                            controller: _priceController,
                            decoration: InputDecoration(
                              hintText: 'Precio',
                              border: const OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa el precio';
                              }
                              final int? price = int.tryParse(value);
                              if (price == null) {
                                return 'Ingresa un número válido';
                              }
                            },
                          ),
                          /*TextFormField(
                            controller: _urlEntradas,
                            keyboardType: TextInputType.url,
                            decoration: const InputDecoration(
                              hintText: '(Opcional) link a tus entradas ',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final uri = Uri.tryParse(value);
                                if (uri == null ||
                                    !uri.isAbsolute ||
                                    uri.scheme.isEmpty) {
                                  return 'URL inválida';
                                }
                              }
                              return null;
                            },
                          )*/
                        ],
                        /*TextFormField(
                          controller: _urlInstagram,
                          keyboardType: TextInputType.url,
                          decoration: const InputDecoration(
                            hintText: 'Link al post ',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              final uri = Uri.tryParse(value);
                              if (uri == null ||
                                  !uri.isAbsolute ||
                                  uri.scheme.isEmpty) {
                                return 'URL inválida';
                              }
                            }
                            return null;
                          },
                        ),*/
                        TextFormField(
                          controller: _placeController,
                          decoration: InputDecoration(
                            labelText: 'Lugar',
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            _getPlaceSuggestions(value);
                          },
                          validator: (value) => _selectedPlaceId == null
                              ? 'Elegí un lugar válido'
                              : null,
                        ),

                        // ✅ Lista desplegable de sugerencias
                        ..._suggestions.map((s) => ListTile(
                              title: Text(s['description']!),
                              onTap: () {
                                _placeController.text = s['description']!;
                                _selectedPlaceId = s['place_id'];
                                _suggestions = [];
                                setState(() {});
                              },
                            )),
                        SizedBox(height: 10),
                        if (_selectedPrivatePlan == false)
                          Container(
                            width: double.infinity,
                            child: TagSelector(
                              onChanged: (tags) {
                                setState(() {
                                  _selectedTags =
                                      tags; // Aquí se actualiza la lista de tags seleccionados
                                });
                              },
                            ),
                          ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: _selectedImage != null
                              ? MainAxisAlignment.spaceBetween
                              : MainAxisAlignment.start,
                          children: [
                            _selectedImage != null
                                ? Image.file(_selectedImage!, height: 150)
                                : const SizedBox.shrink(),
                            ElevatedButton(
                              onPressed: _pickImage,
                              child: _selectedImage == null
                                  ? const Text("Seleccionar imagen")
                                  : const Text('Cambiar de imagen'),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.resolveWith<Color>(
                                          (states) {
                                    if (_selectedDateTime == null) {
                                      return Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.5);
                                    }
                                    return Colors
                                        .transparent; // fondo normal sin selección
                                  }),
                                ),
                                onPressed: pickStartDateTime,
                                child: Text(_selectedDateTime == null
                                    ? 'Seleccionar fecha y hora'
                                    : formattedStartDate))
                            // o formatear bonito con intl
                            ,
                            if (_showDateTimeError == true)
                              const Text(
                                'Campo requerido',
                                style:
                                    TextStyle(color: Colors.red, fontSize: 12),
                              )
                          ],
                        ),
                        if (_selectedPromo == true)
                          Row(
                            mainAxisAlignment: _selectedEndDateTime == null
                                ? MainAxisAlignment.spaceBetween
                                : MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty
                                        .resolveWith<Color>((states) {
                                      if (_selectedEndDateTime == null) {
                                        return Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.5);
                                      }
                                      return Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(
                                              0.2); // fondo normal sin selección
                                    }),
                                  ),
                                  onPressed: pickEndDateTime,
                                  child: Text(_selectedEndDateTime == null
                                      ? 'Seleccionar hora de fin'
                                      : 'Cambiar hora de fin'))
                              // o formatear bonito con intl
                              ,
                              if (_showNoEndDateTimeError == true)
                                Text(
                                  'Selecciona una fecha de fin',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 12),
                                )
                              else if (_showInvalidEndDateTimeError == true)
                                Text(
                                  'Selecciona una fecha de fin valida',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 12),
                                )
                            ],
                          ),
                        if (_selectedPrivatePlan == true)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                decoration: InputDecoration(
                                  labelText: 'Buscar usuario',
                                  suffixIcon: _isLoading
                                      ? CircularProgressIndicator()
                                      : Icon(Icons.search),
                                ),
                                onChanged: _searchUsers,
                              ),
                              const SizedBox(height: 10),
                              if (_searchResults.isNotEmpty)
                                Container(
                                  constraints: BoxConstraints(maxHeight: 200),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: _searchResults.length,
                                    itemBuilder: (context, index) {
                                      final user = _searchResults[index];
                                      return Container(
                                        color: Colors.red,
                                        child: ListTile(
                                            title: Text('@${user.username}'),
                                            trailing: Checkbox(
                                                value: _selectedUsersUuid
                                                    .map((e) => e.uuid)
                                                    .toList()
                                                    .contains(user.uuid),
                                                onChanged: (bool? selected) {
                                                  setState(() {
                                                    if (selected == true) {
                                                      _selectedUsersUuid
                                                          .add(user);
                                                    } else {
                                                      _selectedUsersUuid
                                                          .remove(user);
                                                    }
                                                  });
                                                })),
                                      );
                                    },
                                  ),
                                ),
                              const SizedBox(height: 10),
                              if (_selectedUsersUuid.isNotEmpty)
                                Container(
                                  color: Colors.amber,
                                  constraints: BoxConstraints(
                                    maxHeight: 200,
                                  ),
                                  child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: _selectedUsersUuid.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          title: Text(_selectedUsersUuid[index]
                                              .username),
                                          trailing: IconButton(
                                            icon: Icon(Icons.close),
                                            onPressed: () {
                                              _selectedUsersUuid.remove(
                                                  _selectedUsersUuid[index]);
                                              setState(() {});
                                            },
                                          ),
                                        );
                                      }),
                                )
                            ],
                          ),

                        SizedBox(height: 30),
                        ElevatedButton(
                            onPressed: _submitForm, child: Text('Crea'))
                      ],
                    ),
                  )
                ]),
          ),
        ));
  }
}
