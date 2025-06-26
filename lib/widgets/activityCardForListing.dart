import 'package:flutter/material.dart';
import 'package:worldwildprova/models_fromddbb/activity.dart';


class ActivityCardForListing extends StatelessWidget {
  const ActivityCardForListing({
    super.key,
    required this.activity,
  });

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: MediaQuery.of(context).size.width * 0.95,
      child: Column(
        children:[ 
          Expanded(child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
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
        Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
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
          // Capa oscura para mejor lectura del texto
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          ),
    
          Positioned(
              bottom: 5,
              left: 10,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(activity.name,
                      style: const TextStyle(
                        color: Colors.white,
                      )),
                  if (activity.shortDesc != null)
                    Text(
                      activity.shortDesc!,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                ],
              )),
          Positioned(
            bottom: 6,
            right: 5,
            child: Row(
              children: [
                if (activity.activityCreatorImageUrl !=
                    null)
                  CircleAvatar(
                      backgroundImage: NetworkImage(
                          activity
                              .activityCreatorImageUrl!),
                      radius: 18)
                else
                  CircleAvatar(
                      backgroundColor: Colors.amber,
                      radius: 30),
                      SizedBox(width: 2,),
                if (activity.gratis)
                  Container(
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
                    child: Text('GRATIS', style: TextStyle(fontSize: 10),),
                  ),
              ],
            ),
          ),
    
          if (activity.tags!.isNotEmpty)
            Positioned(
              top: 6,
              right: 5,
              child: Wrap(
                spacing: 4,
                runSpacing: 2,
                children:
                    (activity.tags ?? []).map((tag) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          Colors.white.withOpacity(0.8),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                        width: 1.5,
                      ),
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: Text(
                      tag.name,
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    ]));
  }
}
