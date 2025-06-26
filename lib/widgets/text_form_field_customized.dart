import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFormFieldCustomized extends StatefulWidget {
  final TextEditingController controller;
  final GlobalKey<FormFieldState> fieldKey;
  final FocusNode focusNode;
  final String labelText;
  final String? hintText;
  final String? Function(String?) validator;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;


  const TextFormFieldCustomized({
    super.key,
    required this.controller,
    required this.fieldKey,
    required this.focusNode,
    required this.labelText,
    this.hintText,
    required this.validator,
    this.inputFormatters,
    this.onChanged
  });

  @override
  State<TextFormFieldCustomized> createState() => _TextFormFieldCustomizedState();
}

class _TextFormFieldCustomizedState extends State<TextFormFieldCustomized> {
  bool _isValid = false;

  @override
  void initState() {
    super.initState();

    widget.focusNode.addListener(() {
      if (!widget.focusNode.hasFocus) {
        final valid = widget.fieldKey.currentState?.validate() ?? false;
        setState(() {
          _isValid = valid;
        });
      }
    });
  }

  @override
  void dispose() {
    widget.focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: widget.fieldKey,
      controller: widget.controller,
      focusNode: widget.focusNode,
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        border:  OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: _isValid ? Colors.green : Colors.blue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: _isValid ? Colors.green : Colors.grey),
        ),
        errorBorder:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
