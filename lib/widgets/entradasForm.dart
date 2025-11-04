import 'package:flutter/material.dart';
import 'package:worldwildprova/models_fromddbb/entrada.dart';

class EntradasForm extends StatefulWidget {
  final Function(List<Entrada>) onEntradasChanged; // callback hacia el padre

  const EntradasForm({super.key, required this.onEntradasChanged});

  @override
  _EntradasFormState createState() => _EntradasFormState();
}

class _EntradasFormState extends State<EntradasForm> {
  List<Entrada> entradas = [];
  bool mostrarNuevaEntrada = false;

  final nombreController = TextEditingController();
  final descripcionController = TextEditingController();
  final precioController = TextEditingController();
  final cantidadController = TextEditingController();

  void guardarEntrada() {
    final nombre = nombreController.text.trim();
    final descripcion = descripcionController.text.trim();
    final precio = double.tryParse(precioController.text.trim()) ?? 0;
    final cantidad = int.tryParse(cantidadController.text.trim()) ?? 0;

    if (nombre.isEmpty || descripcion.isEmpty || precio <= 0 || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Completá todos los campos correctamente')),
      );
      return;
    }

    setState(() {
      entradas.add(Entrada(
        titulo: nombre,
        desc: descripcion,
        precio: precio,
        disponibles: cantidad,
      ));
      mostrarNuevaEntrada = false;
    });

    nombreController.clear();
    descripcionController.clear();
    precioController.clear();
    cantidadController.clear();

    widget.onEntradasChanged(entradas); // enviamos al padre cada vez que cambia
  }

  void cancelarEntrada() {
    setState(() {
      mostrarNuevaEntrada = false;
    });
    nombreController.clear();
    descripcionController.clear();
    precioController.clear();
    cantidadController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var entrada in entradas)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[400],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entrada.titulo,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(entrada.desc ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.w300, fontSize: 14)),
                    ],
                  ),
                ),
                Text(
                    'Precio: \$${entrada.precio} | Cantidad: ${entrada.disponibles}',
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        if (!mostrarNuevaEntrada)
          GestureDetector(
            onTap: () => setState(() => mostrarNuevaEntrada = true),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
              padding: const EdgeInsets.symmetric(vertical: 20),
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: const Column(
                children: [
                  Icon(Icons.add, size: 30),
                  Text('Crear nueva entrada', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        if (mostrarNuevaEntrada)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                TextField(
                  controller: nombreController,
                  decoration:
                      const InputDecoration(labelText: 'Nombre de la entrada'),
                ),
                TextField(
                  controller: descripcionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: precioController,
                  decoration: const InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: cantidadController,
                  decoration: const InputDecoration(labelText: 'Cantidad'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: guardarEntrada,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Aceptar',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 20),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: cancelarEntrada,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 20),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
