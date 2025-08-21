import 'package:flutter/material.dart';

class EntradasCounter extends StatefulWidget {
  final ValueChanged<int> onChange;
  final int max;
  final bool enabled;

  const EntradasCounter(
      {Key? key,
      required this.onChange,
      required this.max,
      required this.enabled})
      : super(key: key);

  @override
  _EntradasCounterState createState() => _EntradasCounterState();
}

class _EntradasCounterState extends State<EntradasCounter> {
  int _count = 0;

  void _increment() {
    if (_count >= widget.max) {
      // Mostrar SnackBar si ya llegó al máximo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solo quedan ${widget.max} entradas de este tipo.'),
        ),
      );
      return;
    }

    setState(() {
      _count += 1;
    });
    widget.onChange.call(_count);
  }

  void _decrement() {
    if (_count > 0) {
      setState(() {
        _count -= 1;
      });
      widget.onChange.call(_count);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min, // que se ajuste al contenido
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: widget.enabled ? _decrement : null,
        ),
        Container(
          width: 40,
          alignment: Alignment.center,
          child: Text(
            '$_count',
            style: TextStyle(fontSize: 18),
          ),
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: widget.enabled ? _increment : null,
        ),
      ],
    );
  }
}
