import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:worldwildprova/widgets/appTheme.dart';
import 'package:worldwildprova/widgets/text_form_field_customized.dart';

class SecondStep extends StatefulWidget {
  late TextEditingController descriptionController;
  late File? imageFile;
  final void Function(File) updateImage;

  SecondStep(
      {super.key,
      required this.descriptionController,
      this.imageFile,
      required this.updateImage});

  @override
  State<SecondStep> createState() => _SecondStepState();
}

class _SecondStepState extends State<SecondStep> {
  final GlobalKey<FormFieldState> _descriptionFieldKey =
      GlobalKey<FormFieldState>();
  final FocusNode _focusDescriptionNode = FocusNode();

  File? _localImage = null;

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
      widget.updateImage(File(picked.path));
      // widget.onImageSelected(_imageFile);
    }
  }

  void _removeImage() {
    setState(() => _localImage = null);
    widget.updateImage(File(''));
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text(
                'CAMBIAR IMAGEN',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: AppTheme.logo),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text(
                'ELIMINAR IMAGEN',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
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
    );
  }

  @override
  void initState() {
    super.initState();
    _localImage = widget.imageFile;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
        child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.8,
            ), // Ancho máximo
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16), // Bordes redondeados
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // Para que ocupe todo el ancho
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _localImage == null ? _pickImage : _showImageOptions,
                    child: Container(
                      width: 150,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Theme.of(context).colorScheme.primary),
                        borderRadius: BorderRadius.circular(8),
                        image: _localImage != null
                            ? DecorationImage(
                                image: FileImage(_localImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _localImage == null
                          ? Center(
                              child: Icon(Icons.camera_alt,
                                  size: 40,
                                  color: Theme.of(context).colorScheme.primary),
                            )
                          : null,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextFormFieldCustomized(
                      controller: widget.descriptionController,
                      fieldKey: _descriptionFieldKey,
                      focusNode: _focusDescriptionNode,
                      labelText: 'CONTÁNOS UN POCO SOBRE VOS!',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Daaaalee...';
                        }
                        return null;
                      }),
                ),
              ],
            )));
  }
}
