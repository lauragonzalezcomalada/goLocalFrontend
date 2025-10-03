import 'dart:io';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart'; // per les dates, per formatejarles
import 'package:worldwildprova/config.dart';
import 'package:worldwildprova/models_fromddbb/entrada.dart';
import 'package:worldwildprova/models_fromddbb/reserva.dart';
import 'package:worldwildprova/models_fromddbb/userprofile.dart';
import 'package:worldwildprova/screens/activitydetail_screen.dart';
import 'package:worldwildprova/screens/promodetail_screen.dart';
import 'package:worldwildprova/widgets/appTheme.dart';
import 'package:worldwildprova/widgets/entradasForm.dart';
import 'package:worldwildprova/widgets/privatePlanDetail.dart';
import 'package:worldwildprova/widgets/reservasForm.dart';
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
  late AuthService authService;
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    authService = Provider.of<AuthService>(context, listen: false);
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
  //final TextEditingController _priceController = TextEditingController();
  final TextEditingController _urlEntradas = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  List<int> _selectedTags = []; // Aquí almacenamos los tags seleccionados
  DateTime? _selectedDateTime;
  DateTime? _selectedEndDateTime;
  List<Entrada> entradasGuardadas = [];
  List<Reserva> reservasGuardadas = [];

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

  // Variable para controlar de es Gratis la opción seleccionada y el error
  bool? _selectedGratisOption;
  bool _showGratisError = false;

  // Variable para controlar de Se necesita reservala opción seleccionada y el error
  bool? _selectedReservaOption;
  bool _showReservaError = false;

  // Variable para controlar de Se necesita reservala opción seleccionada y el error
  bool? _selectedEntradasOption;
  bool _showEntradasError = false;

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
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$googleApiKey';
    final response = await http.get(Uri.parse(url));
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
    _urlEntradas.clear();

    setState(() {
      _selectedPlaceId = null;
      _selectedPlanType = null;
      direccion = null;
      _suggestions = [];
      _latitude = null;
      _longitude = null;
      _selectedGratisOption = null;
      _selectedPlaceId = null;
      _selectedTags = [];
      _selectedDateTime = null;
      _selectedEndDateTime = null;
      _selectedPlan = false;
      _selectedPromo = false;
      _selectedPrivatePlan = false;
      _selectedEntradasOption = null;
      _selectedReservaOption = null;
      entradasGuardadas = [];
      reservasGuardadas = [];
      _placeController.clear();
    });
    final token = await userToken;
    if (token == null) {
      showLoginAlert(
          context, 'Registrate para poder empezar a crear tus planes!');
      return;
    }
  }

  void handleEsGratisChange(bool? value) {
    if (value == null) return; // evita el crash

    if (value == false && authService.currentUser!.creador == false) {
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Color.fromARGB(255, 1, 16, 79).withOpacity(0.5),
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Color.fromARGB(255, 1, 16, 79), // ✅ Color del borde
              width: 2, // ✅ Grosor del borde
            ), // ✅ Bordes redondeados
          ),
          content: Text(
              'Si quieres crear un plan de pago, debes registrarte como creador. Puedes hacerlo desde esta página: xxx '),
        ),
      );
      return;
    }

    /* if (value == true && authService.currentUser!.availableFreePlans == 0) {
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Color.fromARGB(255, 1, 16, 79).withOpacity(0.5),
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Color.fromARGB(255, 1, 16, 79), // ✅ Color del borde
              width: 2, // ✅ Grosor del borde
            ), // ✅ Bordes redondeados
          ),
          content: Text(
              'Te quedaste sin planes gratuitos para crear, accede a esta página para más información.'),
        ),
      );
      return;
    }*/

    setState(() {
      _selectedGratisOption = value;
      _showGratisError = false; // Quita el error si selecciona
      _selectedReservaOption = null;
      _selectedEntradasOption = null;
    });
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

    if (_selectedGratisOption != null &&
        _selectedGratisOption == true &&
        _selectedReservaOption == null) {
      setState(() {
        _showReservaError = true;
      });
      other_errors = true;
    }

    //ERROR DE SI RESERVA = TRUE PERÒ NO HI HA RESERVES
    if (_selectedReservaOption == true && reservasGuardadas.isEmpty) {
      setState(() {
        _showReservaError = true;
      });
      other_errors = true;
    }

    if (_selectedEntradasOption == true && entradasGuardadas.isEmpty) {
      setState(() {
        _showEntradasError = true;
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
      request.fields['tags'] = jsonEncode(_selectedTags);
      //Default price 0 si es gratis
      //request.fields['price'] = '0';
      bool gratis = _selectedGratisOption ?? false;
      request.fields['gratis'] = gratis.toString();

      if (gratis) {
        bool reservaNecesaria = _selectedReservaOption ?? false;
        request.fields['reserva'] = reservaNecesaria.toString();
        if (reservaNecesaria) {
          request.fields['reservas'] = jsonEncode(
              reservasGuardadas.map((reserva) => reserva.toJson()).toList());
        }
      } else {
        // no gratis
        bool controlEntradas = _selectedEntradasOption ?? false;
        request.fields['centralizarEntradas'] = controlEntradas.toString();

        if (controlEntradas) {
          request.fields['entradas'] = jsonEncode(
              entradasGuardadas.map((entrada) => entrada.toJson()).toList());
        } else {
          request.fields['tickets_link'] = _urlEntradas.text;
        }
      }

      if (_selectedPlaceId != null) {
        await _getCoordinatesFromPlaceId(_selectedPlaceId!);
        request.fields['lat'] = _latitude!.toString();
        request.fields['lng'] = _longitude!.toString();
        request.fields['direccion'] = direccion!;
      }

      request.fields['startDateandtime'] = _selectedDateTime!.toIso8601String();

      switch (_selectedPlanType!) {
        case PlanType.plan:
          request.fields['tipoEvento'] = '0';

        case PlanType.promo:
          request.fields['tipoEvento'] = '1';
          request.fields['endDateandtime'] =
              _selectedEndDateTime!.toIso8601String();

        case PlanType.private:
          request.fields['tipoEvento'] = '2';
      }

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

      var response = await request.send();
      if (response.statusCode == 401) {
        await authService.refreshAccessToken();
        String? newAccessToken = await authService.getAccessToken();
        if (newAccessToken == null) return;
        final newRequest = http.MultipartRequest(request.method, request.url);
        newRequest.fields.addAll(request.fields);
        newRequest.files.addAll(request.files);
        newRequest.headers.addAll(request.headers);
        newRequest.headers['Authorization'] = 'Bearer $newAccessToken';
        response = await newRequest.send();
      }
      if (response.statusCode == 201) {
        var resp = await response.stream.bytesToString();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Text("¡Creáste tu plan 🎉!"),
              actions: [
                TextButton(
                  child: const Text("Ver mi plan"),
                  onPressed: () {
                    var response = jsonDecode(resp);

                    if (response['tipo'] == 0) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ActivityDetail(
                                  userToken: userToken!,
                                  activityUuid: response["uuid"],
                                )),
                        (route) => false,
                      );
                    } else if (response['tipo'] == 1) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PromoDetail(
                                  promoUuid: response["uuid"],
                                )),
                        (route) => false,
                      );
                    } else {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PrivatePlanDetail(
                                  userToken: userToken!,
                                  privatePlanUuid: response["uuid"],
                                )),
                        (route) => false,
                      );
                    }

                    //  Navigator.of(context).pop(); // Cierra el dialog
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
                  SizedBox(height: 30),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Creá tu',
                        style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.w600,
                            height: 0.8)),
                  ),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text('eVento lOcal',
                        style: TextStyle(
                            fontSize: 60,
                            fontWeight: FontWeight.w600,
                            height: 0.8)),
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Plan',
                              style: TextStyle(fontSize: 20),
                            ),
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
                            const Text(
                              'Promo',
                              style: TextStyle(fontSize: 20),
                            ),
                            Radio<PlanType>(
                              value: PlanType.promo,
                              groupValue: _selectedPlanType,
                              onChanged: (PlanType? value) {
                                setState(() {
                                  _selectedPlanType = value;
                                  _selectedPlan = false;
                                  _selectedPrivatePlan = false;
                                  _selectedPromo = true;
                                  _selectedGratisOption = true;
                                });
                              },
                            ),
                            const Text(
                              'Plan privado',
                              style: TextStyle(fontSize: 20),
                            ),
                            Radio<PlanType>(
                              value: PlanType.private,
                              groupValue: _selectedPlanType,
                              onChanged: (PlanType? value) {
                                setState(() {
                                  _selectedPlanType = value;
                                  _selectedPlan = false;
                                  _selectedPromo = false;
                                  _selectedPrivatePlan = true;
                                  _selectedGratisOption = true;
                                  _selectedReservaOption = false;
                                  _selectedEntradasOption = null;
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        //TÍTULO DEL EVENTO
                        TextFormField(
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'Título',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 1.5), // borde normal
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 3), // borde al enfocar
                              borderRadius: BorderRadius.circular(8),
                            ),
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
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                          controller: _shortDescriptionController,
                          decoration: InputDecoration(
                            hintText: 'Pequeña descripción',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 1.5), // borde normal
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 3), // borde al enfocar
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          maxLines: 1,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        //DESCRIPCIÓN DEL EVENTO
                        TextFormField(
                          controller: _descriptionController,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: 'Descripción',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 1.5), // borde normal
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 3), // borde al enfocar
                              borderRadius: BorderRadius.circular(8),
                            ),
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
                        if (_selectedPlanType == PlanType.plan)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Es gratis?      ',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w500),
                              ),
                              const Text(
                                'Sí',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w400),
                              ),
                              Radio<bool>(
                                  value: true,
                                  groupValue: _selectedGratisOption,
                                  // ignore: deprecated_member_use
                                  onChanged: (bool? value) {
                                    handleEsGratisChange(value);
                                  }),
                              const Text(
                                'No',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w400),
                              ),
                              Radio<bool>(
                                  value: false,
                                  groupValue: _selectedGratisOption,
                                  onChanged: (bool? value) {
                                    handleEsGratisChange(value);
                                  }),
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
                        if (_selectedGratisOption == true &&
                            _selectedPlanType != PlanType.private) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Se necesita reserva?      ',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w500),
                              ),
                              const Text(
                                'Sí',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w400),
                              ),
                              Radio<bool>(
                                value: true,
                                groupValue: _selectedReservaOption,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _selectedReservaOption = value;
                                    _showReservaError =
                                        false; // Quita el error si selecciona
                                  });
                                },
                              ),
                              const Text(
                                'No',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w400),
                              ),
                              Radio<bool>(
                                value: false,
                                groupValue: _selectedReservaOption,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _selectedReservaOption = value;
                                    _showReservaError =
                                        false; // Quita el error si selecciona
                                  });
                                },
                              ),
                            ],
                          ),
                        ],

                        if (_selectedGratisOption == false) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Vender entradas con GoLocal?   ',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w500),
                              ),
                              const Text(
                                'Sí',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w400),
                              ),
                              Radio<bool>(
                                value: true,
                                groupValue: _selectedEntradasOption,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _selectedEntradasOption = value;
                                    _showEntradasError =
                                        false; // Quita el error si selecciona
                                  });
                                },
                              ),
                              const Text(
                                'No',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w400),
                              ),
                              Radio<bool>(
                                value: false,
                                groupValue: _selectedEntradasOption,
                                onChanged: (bool? value) {
                                  setState(() {
                                    _selectedEntradasOption = value;
                                    _showEntradasError =
                                        false; // Quita el error si selecciona
                                  });
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
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
                        if (_selectedEntradasOption == false) ...[
                          TextFormField(
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500),
                            controller: _urlEntradas,
                            decoration: InputDecoration(
                              hintText: 'Link a la ticketera',
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 1.5), // borde normal
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black,
                                    width: 3), // borde al enfocar
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa la URL de la ticketera';
                              }
                              return null;
                            },
                            maxLines: null,
                          ),
                          SizedBox(height: 20)
                        ],

                        if (_selectedEntradasOption == true) ...[
                          EntradasForm(
                            onEntradasChanged: (entradas) {
                              setState(() {
                                entradasGuardadas =
                                    entradas; // actualizamos lista en el padre
                              });
                            },
                          ),
                          SizedBox(height: 20)
                        ],
                        if (_selectedReservaOption == true) ...[
                          ReservasForm(
                            onReservasChanged: (reservas) {
                              setState(() {
                                reservasGuardadas = reservas;
                              }); // actualizamos lista en el padre
                            },
                          ),
                          SizedBox(height: 20)
                        ],

                        TextFormField(
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                          controller: _placeController,
                          decoration: InputDecoration(
                            hintText: 'Lugar',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 1.5), // borde normal
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 3), // borde al enfocar
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            _getPlaceSuggestions(value);
                          },
                          /*    validator: (value) => _selectedPlaceId == null
                              ? 'Elegí un lugar válido'
                              : null,*/
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
                              : MainAxisAlignment.center,
                          children: [
                            _selectedImage != null
                                ? Image.file(_selectedImage!, height: 150)
                                : const SizedBox.shrink(),
                            SizedBox(
                              width: 200,
                              height: 60,
                              child: ElevatedButton(
                                style: ButtonStyle(),
                                onPressed: _pickImage,
                                child: _selectedImage == null
                                    ? const Text("Seleccionar imagen")
                                    : const Text('Cambiar de imagen'),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: _selectedDateTime == null
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 200,
                              height: 60,
                              child: TextButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty
                                        .resolveWith<Color>((states) {
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
                                      : formattedStartDate)),
                            )
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
                        SizedBox(height: 10),
                        if (_selectedPromo == true)
                          Row(
                            mainAxisAlignment: _selectedEndDateTime == null
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 60,
                                width: 200,
                                child: TextButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .resolveWith<Color>((states) {
                                        if (_selectedEndDateTime == null) {
                                          return Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.8);
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
                                        : 'Cambiar hora de fin')),
                              )
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
                                      ? Center(
                                          child: Image.asset(
                                            'assets/ojitos.gif',
                                            width: 100,
                                            height: 100,
                                          ),
                                        )
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
                                        color: AppTheme.logo.withOpacity(0.6),
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
                                  decoration: BoxDecoration(
                                    color: AppTheme.logo,
                                    border: Border.all(
                                      color: Colors.black, // color del borde
                                      width: 2, // grosor del borde
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        10), // 🔹 bordes redondeados
                                  ),
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
                        SizedBox(
                          height: 80,
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                              onPressed: _submitForm,
                              child: Text(
                                'Crea',
                                style: TextStyle(
                                    fontSize: 35,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                              )),
                        )
                      ],
                    ),
                  )
                ]),
          ),
        ));
  }
}
