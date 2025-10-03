import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:worldwildprova/models_fromddbb/activity.dart';
import 'package:worldwildprova/models_fromddbb/userprofile.dart';
import 'package:worldwildprova/widgets/authservice.dart';

class BuyTicketsBottomSheet extends StatelessWidget {
  final Activity activity;
  final Map<String, int> cantidades;
  final double totalEntradas;
  final void Function(String name, String email) onConfirm;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  BuyTicketsBottomSheet({
    super.key,
    required this.activity,
    required this.cantidades,
    required this.totalEntradas,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthService>(context).currentUser;

    _nameController.text = user!.username;
    _emailController.text = user.email!;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.9,
          child: SingleChildScrollView(
            controller: scrollController,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 12),
                        const Text(
                          'Quieres confirmar tu compra para...',
                          style: TextStyle(
                              fontSize: 50, fontWeight: FontWeight.bold),
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
                          child: Row(
                            children: [
                              ClipRRect(
                                child: activity.imageUrl != null
                                    ? Image.network(
                                        activity.imageUrl!,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 100,
                                        color: Colors.grey[200],
                                      ),
                              ),
                              const SizedBox(width: 8),
                              Text(activity.name),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Nombre',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            filled: true,
                            fillColor: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            filled: true,
                            fillColor: Colors.white70,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email para mandar los tickets';
                            }
                            return null;
                          },
                          maxLines: null,
                        ),
                        const SizedBox(height: 20),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: cantidades.values
                              .where((valor) => valor > 0)
                              .length,
                          itemBuilder: (context, index) {
                            var itemId = cantidades.entries
                                .where((entry) => entry.value > 0)
                                .map((entry) => [entry.key, entry.value])
                                .toList()[index];
                            var itemEntrada = activity.entradas!
                                .firstWhere((e) => e.uuid == itemId[0]);

                            return Container(
                              margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                              child: ListTile(
                                tileColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                title: Text(
                                    '${itemId[1]} x ${itemEntrada.titulo}'),
                                trailing: Text(
                                  '${(itemId[1] as int) * itemEntrada.precio} ARS',
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            );
                          },
                        ),
                        Text(
                          'Total: $totalEntradas ARS',
                          style: const TextStyle(
                              fontSize: 40, fontFamily: 'BarlowCondensed'),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 20),
                      ),
                      onPressed: () {
                        onConfirm(_nameController.text, _emailController.text);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Confirmar compra',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                    SizedBox(height: 20)
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
