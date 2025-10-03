import 'package:flutter/material.dart';
import 'package:worldwildprova/models_fromddbb/activity.dart';
import 'package:worldwildprova/models_fromddbb/promo.dart';
import 'package:worldwildprova/widgets/dateBox.dart';

class PromoCard extends StatelessWidget {
  final Promo promo;
  const PromoCard({super.key, required this.promo});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 220),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        child: Column(
          children: [
            Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  height: 110,
                  child: promo.imageUrl == null
                      ? Image.asset('assets/solocarita.png')
                      : Image.network(
                          promo
                              .imageUrl!, // o usa NetworkImage con Image.network()
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ]),
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: 110),
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(252, 110, 75, 0.966),
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
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              promo.name,
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.w700),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            if (promo.shortDesc != null) ...[
                              Text(promo.shortDesc!,
                                  style: TextStyle(fontSize: 20)),
                              SizedBox(height: 5)
                            ],
                            SizedBox(height: 8),
                            if (promo.tags != null && promo.tags!.isNotEmpty)
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.70,
                                child: Wrap(
                                  spacing: 4,
                                  runSpacing: 2,
                                  children: (promo.tags ?? []).map((tag) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 1.5,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        tag.name,
                                        style: TextStyle(
                                          fontSize: 12,
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
                      )
                    ],
                  ),
                )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
