import 'package:flutter/material.dart';
import 'package:worldwildprova/models_fromddbb/activity.dart';
import 'package:worldwildprova/models_fromddbb/privatePlan.dart';
import 'package:worldwildprova/widgets/dateBox.dart';

class PrivatePlanCard extends StatelessWidget {
  final PrivatePlan privatePlan;
  const PrivatePlanCard({super.key, required this.privatePlan});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: MediaQuery.of(context).size.width * 0.95,
      child: Column(
        children: [
          Expanded(
            child: Stack(children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  child: privatePlan.imageUrl == null
                      ? Container(
                          color: Colors.blue, // Color fijo
                          width: 200,
                          height: 150,
                        )
                      : Image.network(
                          privatePlan
                              .imageUrl!, // o usa NetworkImage con Image.network()
                          fit: BoxFit.cover,
                        ),
                ),
              ),

               if (privatePlan.gratis == true)
                  Positioned(
                    top:8,
                    right:8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            Colors.white,
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              , // Color del borde
                          width: 2.0, // Grosor del borde
                        ),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: Text('GRATIS', style: TextStyle(fontSize: 12),),
                    ),
                  ),
            ]),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius:const  BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DateBox(date: privatePlan.dateTime),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(privatePlan.name,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20)),
                          if (privatePlan.shortDesc != null)
                            Text(privatePlan.shortDesc!, style: TextStyle(fontSize: 20)),
                          Spacer(),
                         
                          
                        ],
                      ),
                    )
                  ],
                ),
              )),
            ),
          )
        ],
      ),
    );
  }
}
