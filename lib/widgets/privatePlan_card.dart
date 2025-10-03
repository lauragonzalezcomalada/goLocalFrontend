import 'package:flutter/material.dart';
import 'package:worldwildprova/models_fromddbb/activity.dart';
import 'package:worldwildprova/models_fromddbb/privatePlan.dart';
import 'package:worldwildprova/widgets/dateBox.dart';

class PrivatePlanCard extends StatelessWidget {
  final PrivatePlan privatePlan;
  const PrivatePlanCard({super.key, required this.privatePlan});

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
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  height: 110,
                  width: double.infinity,
                  child: privatePlan.imageUrl == null
                      ? Image.asset('assets/solocarita.png')
                      : Image.network(
                          privatePlan
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
                  borderRadius: const BorderRadius.only(
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
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              privatePlan.name,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w700),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                            if (privatePlan.shortDesc != null) ...[
                              Text(privatePlan.shortDesc!,
                                  style: TextStyle(fontSize: 20)),
                              SizedBox(
                                height: 5,
                              )
                            ]
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
