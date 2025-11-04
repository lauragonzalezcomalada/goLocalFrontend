import 'dart:convert';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:worldwildprova/config.dart';
import 'package:worldwildprova/screens/profile_screen.dart';
import 'package:worldwildprova/screens/log_in_screen.dart';
import 'package:worldwildprova/widgets/appTheme.dart';

import 'package:worldwildprova/widgets/usages.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:worldwildprova/widgets/first_step.dart';
import 'package:worldwildprova/widgets/second_step.dart';
import 'package:worldwildprova/widgets/third_step.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class OnboardingScreen extends StatefulWidget {
  final String name;
  final String userUuid;
  const OnboardingScreen(
      {super.key, required this.name, required this.userUuid});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  final _formKey = GlobalKey<FormState>();
  bool isLastPage = false;

  //fields controllers
  //First Step
  /* final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  String? _selectedPlaceId;*/
  bool asCreator = false;
  //Second Step
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  //Third Step
  List<int> _selectedTags = []; // Aquí almacenamos los tags seleccionados

  /*void _updateSelectedPlaceId(String placeId) {
    setState(() {
      _selectedPlaceId = placeId;
    });
  }*/

  void _updateSelectedImage(File imageFile) {
    setState(() {
      _selectedImage = imageFile;
    });
  }

  void _updateSelectedTags(tags) {
    setState(() {
      _selectedTags = tags;
    });
  }

  void _handleAsCreatorChange() {
    setState(() {
      asCreator = !asCreator;
    });
  }

  void _showValues() async {
    var updateUserUri = Uri.parse('${Config.serverIp}/actualizar_usuario/');

    var request = http.MultipartRequest('POST', updateUserUri);
    request.fields['asCreator'] = asCreator.toString();
    request.fields['user_uuid'] = widget.userUuid;
    request.fields['description'] = _descriptionController.text;

    //  final birthdayDate = convertirFecha(_birthdayController.text);
    //   request.fields['birthday_date'] = birthdayDate;
    // request.fields['place_location'] = _placeController.text;
    //  request.fields['place_location_id'] = _selectedPlaceId!;
    request.fields['tags'] = jsonEncode(_selectedTags);

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

    if (response.statusCode == 200) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => LogInScreen(comingFromOnboarding: true)),
        (Route<dynamic> route) => false,
      );
    } else {
      print('Error al crear plan: ${response.statusCode}');
      print(await response.stream.bytesToString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      FirstStep(
          /* birthdayController: _birthdayController,
        placeController: _placeController,
        selectedPlaceId: _selectedPlaceId,
        onPlaceSelected: _updateSelectedPlaceId,*/
          asCreator: asCreator,
          asCreatorChange: _handleAsCreatorChange),
      SecondStep(
          descriptionController: _descriptionController,
          updateImage: _updateSelectedImage),
      ThirdStep(updateSelectedTags: _updateSelectedTags),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BIENVENIDO ${widget.name}!',
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.w800, color: AppTheme.logo),
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() => isLastPage = index == pages.length - 1);
                },
                children: pages,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    child: const Text(
                      'LO HAGO LUEGO!',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                LogInScreen(comingFromOnboarding: true)),
                        (Route<dynamic> route) => false,
                      );
                    },
                  ),
                  SmoothPageIndicator(
                    controller: _controller,
                    count: pages.length,
                    effect: const WormEffect(
                      dotHeight: 12,
                      dotWidth: 12,
                      activeDotColor: Colors.purple,
                    ),
                  ),
                  TextButton(
                      child: Text(
                        isLastPage ? 'FINALIZAR' : '',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      onPressed: () {
                        if (isLastPage) {
                          _showValues();
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      })
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
