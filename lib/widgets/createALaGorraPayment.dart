import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:worldwildprova/models_fromddbb/activity.dart';
import 'package:worldwildprova/models_fromddbb/campo.dart';
import 'package:worldwildprova/models_fromddbb/reserva.dart';
import 'package:worldwildprova/models_fromddbb/userprofile.dart';
import 'package:worldwildprova/widgets/appTheme.dart';
import 'package:worldwildprova/widgets/authservice.dart';

class CreateALaGorraPaymentSheet extends StatefulWidget {
  final String event_uuid;
  final String? event_image;
  final String event_name;
  final double? recommendedAmount;

  CreateALaGorraPaymentSheet(
      {super.key,
      required this.event_uuid,
      this.event_image,
      required this.event_name,
      this.recommendedAmount});

  @override
  State<CreateALaGorraPaymentSheet> createState() =>
      _CreateALaGorraPaymentSheetState();
}

class _CreateALaGorraPaymentSheetState
    extends State<CreateALaGorraPaymentSheet> {
  // Map para guardar los controllers dinámicamente
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      builder: (context, scrollController) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.9,
          child: SingleChildScrollView(
            controller: scrollController,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.65,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 60.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 12),
                        const Text(
                          'HACÉ TU APORTACIÓN A LA GORRA PARA',
                          style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.logo),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 100,
                          width: MediaQuery.of(context).size.width * 0.8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: ClipRRect(
                              child: widget.event_image != null
                                  ? Image.network(
                                      widget.event_image!,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset('./assets/solocarita.png',
                                      fit: BoxFit.fitHeight),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        const Align(
                          alignment: AlignmentGeometry.topLeft,
                          child: Text(
                            'Cuánto querés aportar?',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.logo,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          style: const TextStyle(
                              fontSize: 20,
                              color: AppTheme.logo,
                              fontWeight: FontWeight.w600),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          controller: _amountController,
                          decoration: InputDecoration(
                            hintText: widget.recommendedAmount != null
                                ? 'Recomendado: ${widget.recommendedAmount}'
                                : '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            filled: true,
                            fillColor: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.logo,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 10),
                      ),
                      onPressed: () {},
                      child: const Text(
                        'SIGUIENTE',
                        style: TextStyle(
                          fontSize: 35,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
