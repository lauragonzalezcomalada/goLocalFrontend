import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:worldwildprova/config.dart';

class ShareEventButton extends StatefulWidget {
  final int eventType;
  final String eventUuid;

  const ShareEventButton(
      {super.key, required this.eventUuid, required this.eventType});

  @override
  State<ShareEventButton> createState() => _ShareEventButtonState();
}

class _ShareEventButtonState extends State<ShareEventButton> {
  @override
  void initState() {
    super.initState();
    updateSharings();
  }

  Future<void> updateSharings() async {
    try {
      final response = await http.get(Uri.parse(
          '${Config.serverIp}/register_share/?activity=${widget.eventType == 1 ? 'True' : 'False'}&promo=${widget.eventType == 2 ? 'True' : 'False'}&uuid=${widget.eventUuid}'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
      } else {
        // Si la respuesta es un error, muestra un mensaje
        throw Exception('Failed to load places');
      }
    } catch (e) {
      // Si ocurre un error en la solicitud
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        final url = "golocal://activity/${widget.eventUuid}";
        Share.share(
          "Mirá este evento: $url",
        );
      },
      child: const Icon(Icons.send),
    );
  }
}
