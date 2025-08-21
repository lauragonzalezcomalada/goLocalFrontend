import 'package:flutter/material.dart';
import 'package:worldwildprova/models_fromddbb/activity.dart';
import 'package:worldwildprova/models_fromddbb/promo.dart';
import 'package:worldwildprova/widgets/dateBox.dart';

class PromoCard extends StatelessWidget {
  final Promo promo;
  const PromoCard({super.key, required this.promo});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
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
                  child: promo.imageUrl == null
                      ? Container(
                          color: Colors.blue, // Color fijo
                          width: 200,
                          height: 150,
                        )
                      : Image.network(
                          promo
                              .imageUrl!, // o usa NetworkImage con Image.network()
                          fit: BoxFit.cover,
                        ),
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
                    DateBox(date: promo.dateTime),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(promo.name, style: TextStyle(fontSize: 25)),
                          if (promo.shortDesc != null)
                            Text(promo.shortDesc!,
                                style: TextStyle(fontSize: 20)),
                          Spacer(),
                          if (promo.tags!.isNotEmpty)
                            Wrap(
                              spacing: 4,
                              runSpacing: 2,
                              children: (promo.tags ?? []).map((tag) {
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
                                      fontSize: 12,
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
