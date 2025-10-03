import 'dart:convert';
import 'package:http/http.dart' as http;

class MercadoPagoService {
  final String publicKey =
      "TU_PUBLIC_KEY"; // Ojo: siempre la PUBLIC_KEY, no el access_token

  Future<String?> crearCardToken({
    required String cardNumber,
    required int expMonth,
    required int expYear,
    required String cvv,
    required String cardholderName,
  }) async {
    final url = Uri.parse(
        "https://api.mercadopago.com/v1/card_tokens?public_key=$publicKey");

    final body = {
      "card_number": cardNumber,
      "expiration_month": expMonth,
      "expiration_year": expYear,
      "security_code": cvv,
      "cardholder": {"name": cardholderName},
    };

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['id'];
      } else {
        print("Error creando card_token: ${res.body}");
        return null;
      }
    } catch (e) {
      print("Excepción creando card_token: $e");
      return null;
    }
  }
}
