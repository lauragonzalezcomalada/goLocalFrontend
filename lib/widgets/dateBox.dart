import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class DateBox extends StatelessWidget {
  DateTime date;

  DateBox({super.key, required this.date});


  @override
  Widget build(BuildContext context) {
    
    initializeDateFormatting('es_ES', null);

    return Container(
      width:70,
      height:70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Color.fromARGB(152, 0, 0, 0)
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
        
          Text(date.day.toString(), style: TextStyle(color: Colors.white, fontSize: 30, height: 1)),

          Text(DateFormat('MMMM', 'es_ES').format(date).substring(0,3).toUpperCase(),style: TextStyle(color: Colors.white, fontSize:20, height: 1))
        
        ],),
      ),
    );
  }
}
