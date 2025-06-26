import 'package:flutter/material.dart';
import 'package:worldwildprova/models_fromddbb/item.dart';

class ItemAmountCounter extends StatefulWidget {
  final double neededAmount;
  final double assignedAmount;

  final ValueChanged<double> onChanged;

  ItemAmountCounter(
      {required this.neededAmount,
      required this.assignedAmount,
      required this.onChanged});

  @override
  _ItemAmountCounterState createState() => _ItemAmountCounterState();
}

class _ItemAmountCounterState extends State<ItemAmountCounter> {
  late double value = widget.assignedAmount;

  void increment() {
    if (value < widget.neededAmount) {
      setState(() {
        value++;
        widget.onChanged(value);
      });
    }
  }

  void decrement() {
    if (value > widget.assignedAmount) {
      setState(() {
        value--;
        widget.onChanged(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: decrement,
          icon: Icon(Icons.remove),
        ),
        Text(
          '$value / ${widget.neededAmount}',
          style: TextStyle(fontSize: 18),
        ),
        IconButton(
          onPressed: increment,
          icon: Icon(Icons.add),
        ),
      ],
    );
  }
}
