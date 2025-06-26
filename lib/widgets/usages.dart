import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:worldwildprova/widgets/mainscaffold.dart';

String convertirFecha(String fechaInput) {
  // Ejemplo de entrada: "28/05/2025"
  List<String> partes = fechaInput.split('/');
  if (partes.length != 3) return '';

  String dia = partes[0];
  String mes = partes[1];
  String anio = partes[2];

  // Retorna "2025-05-28"
  return '$anio/$mes/$dia';
}

String formatDate(DateTime datetime) {
  //Comprobar si es hoy
  final now = DateTime.now();
  if (datetime.year == now.year &&
      datetime.month == now.month &&
      datetime.day == now.day) {
    return 'Hoy';
  }
  //Comprobar si es mañana
  else if (datetime.year == DateTime.now().add(const Duration(days: 1)).year &&
      datetime.month == DateTime.now().add(const Duration(days: 1)).month &&
      datetime.day == DateTime.now().add(const Duration(days: 1)).day) {
    return 'Mañana';
  }
  //Mandar la fecha sinó
  return DateFormat('dd/MM').format(datetime);
}

bool isPast(DateTime datetime) {
  return datetime.isBefore(
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
}

void showLoginAlert(context, body_text) {
  showDialog(
    context: context,
    barrierDismissible: false,
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
      title: Center(
          child: const Text(
        'Identifícate',
      )),
      content: Text(body_text),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            Future.microtask(() {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const MainScaffold(initialIndex: 2)),
              );
            });
          },
          child: const Text('Iniciar sesión', style: TextStyle(fontSize: 12)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MainScaffold(initialIndex: 0)));
          },
          child: const Text('Consultar planes', style: TextStyle(fontSize: 12)),
        ),
      ],
    ),
  );
}

Widget headerForDate(DateTime date) {
  initializeDateFormatting('es_ES', null);

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = DateTime(now.year, now.month, now.day + 1);
  final comparingDate = DateTime(date.year, date.month, date.day);

  if (comparingDate == today) {
    return sectionHeader('HOY');
  } else if (comparingDate == tomorrow) {
    return sectionHeader('MAÑANA');
  } else {
    // Formatear como '15 jun' en español
    final formatter = DateFormat('d MMM', 'es_ES');
    return sectionHeader(formatter.format(date));
  }
}

Widget sectionHeader(String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: <Widget>[
        const Expanded(
          child: Divider(
            color: Colors.black,
            thickness: 2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
      ],
    ),
  );
}
