import 'package:flutter/material.dart';
import 'package:worldwildprova/models_fromddbb/activity.dart';
import 'package:worldwildprova/widgets/dateBox.dart';

class AuxActivityCard extends StatelessWidget {
  final Activity activity;
  const AuxActivityCard({super.key, required this.activity});

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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  child: activity.activityImageUrl == null
                      ? Container(
                          color: Colors.blue, // Color fijo
                          width: 200,
                          height: 150,
                        )
                      : Image.network(
                          activity
                              .activityImageUrl!, // o usa NetworkImage con Image.network()
                          fit: BoxFit.cover,
                        ),
                ),
              ),

               if (activity.gratis)
                  Positioned(
                    top:8,
                    right:8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            Colors.white.withOpacity(0.7),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(
                                  0.8), // Color del borde
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
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DateBox(date: activity.dateTime),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(activity.name,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15)),
                          if (activity.shortDesc != null)
                            Text(activity.shortDesc!),
                          Spacer(),
                          if (activity.tags!.isNotEmpty)
                            Wrap(
                              spacing: 4,
                              runSpacing: 2,
                              children: (activity.tags ?? []).map((tag) {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    border: Border.all(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    tag.name,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
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
