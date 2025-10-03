import 'package:flutter/material.dart';

class EntradasCounter extends StatefulWidget {
  final ValueChanged<int> onChange;
  final int max;
  final bool enabled;
  final int initialValue;

  const EntradasCounter(
      {Key? key,
      required this.onChange,
      required this.max,
      required this.enabled,
      this.initialValue = 0})
      : super(key: key);

  @override
  _EntradasCounterState createState() => _EntradasCounterState();
}

class _EntradasCounterState extends State<EntradasCounter> {
  late int count;

  @override
  void initState() {
    super.initState();
    count = widget.initialValue; // inicializamos con el valor pasado
  }

  @override
  void didUpdateWidget(covariant EntradasCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      setState(() {
        count = widget.initialValue; // actualizamos el estado interno
      });
    }
  }

  void _increment() {
    if (count >= widget.max) {
      // Mostrar SnackBar si ya llegó al máximo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solo quedan ${widget.max} entradas de este tipo.'),
        ),
      );
      return;
    }

    setState(() {
      count += 1;
    });
    widget.onChange.call(count);
  }

  void _decrement() {
    if (count > 0) {
      setState(() {
        count -= 1;
      });
      widget.onChange.call(count);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min, // que se ajuste al contenido
      children: [
        IconButton(
          icon: Icon(Icons.remove, size: 30),
          onPressed: widget.enabled ? _decrement : null,
        ),
        Container(
          width: 40,
          alignment: Alignment.center,
          child: Text(
            '$count',
            style: TextStyle(fontSize: 20),
          ),
        ),
        IconButton(
          icon: Icon(Icons.add, size: 30),
          onPressed: widget.enabled ? _increment : null,
        ),
      ],
    );
  }
}
