import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:worldwildprova/widgets/appTheme.dart';
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
      backgroundColor: AppTheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppTheme.logo, // ✅ Color del borde
          width: 2, // ✅ Grosor del borde
        ), // ✅ Bordes redondeados
      ),
      title: Center(
          child: const Text(
        'IDENTIFICATE',
        style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: AppTheme.backgroundColor),
      )),
      content: Text(
        body_text,
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
        textAlign: TextAlign.justify,
      ),
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
          child: Center(
            child: const Text('INICIAR SESIÓN',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.backgroundColor)),
          ),
        ),
        /* TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const MainScaffold(initialIndex: 0)));
          },
          child: const Text('CONSULTAR PLANES', style: TextStyle(fontSize: 12)),
        ),*/
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
    padding: const EdgeInsets.symmetric(vertical: 1.0),
    child: Row(
      children: <Widget>[
        const Expanded(
          child: Divider(
            color: AppTheme.logo,
            thickness: 2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: AppTheme.logo),
          ),
        ),
      ],
    ),
  );
}
