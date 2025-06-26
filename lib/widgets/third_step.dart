import 'package:flutter/material.dart';
import 'package:worldwildprova/widgets/tagSelector.dart';

class ThirdStep extends StatefulWidget {
  final void Function(List<int>) updateSelectedTags;

  ThirdStep(
      {
      required this.updateSelectedTags,
      super.key});
  @override
  State<ThirdStep> createState() => _ThirdStepState();
}

class _ThirdStepState extends State<ThirdStep> {
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
            children: [
              TagSelector(
                onChanged: (tags) {
                  setState(() {
                    widget.updateSelectedTags(
                        tags); // Aquí se actualiza la lista de tags seleccionados
                  });
                },
              ),
            ],
          ),
        ));
  }
}
