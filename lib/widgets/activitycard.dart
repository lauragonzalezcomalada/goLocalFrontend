import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:worldwildprova/screens/activitydetail_screen.dart';
import 'package:worldwildprova/widgets/usages.dart';

class ActivityCard extends StatelessWidget {
  final String activityUuid;
  final String? imageUrl;
  final String activityTitle;
  final DateTime activityDateTime;
  final bool created_by_user;
  final String? userToken;

  ActivityCard(
      {super.key,
      required this.activityUuid,
      this.imageUrl,
      required this.activityTitle,
      required this.activityDateTime,
      required this.created_by_user,
      this.userToken});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('tapèd');
        print(userToken);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ActivityDetail(
                      activityUuid: activityUuid,
                      userToken: userToken!,
                    )));
      },
      child: SizedBox(
        height: 200,
        width: 130,
        child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15), // Bordes redondeados
            ),
            elevation: 5, // Sombra para la tarjeta
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                children: [
                  Image.network(
                    imageUrl == null
                        ? 'https://camarasal.com/wp-content/uploads/2020/08/default-image-5-1.jpg'
                        : imageUrl!,
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height * 0.5,
                  ),
                  if (isPast(activityDateTime))
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 200, // altura del degradat
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomRight,
                            end: Alignment.topRight,
                            colors: [
                              Colors.black.withOpacity(0.8), // color de baix
                              Colors.black.withOpacity(0.8), // color de dalt
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (!isPast(activityDateTime))
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 150, // altura del degradat
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomRight,
                            end: Alignment.topRight,
                            colors: [
                              Colors.black.withOpacity(0.7), // color de baix
                              Colors.transparent, // color de dalt
                            ],
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2), // espacio interno
                        decoration: BoxDecoration(
                          color: Colors.white70, // color de fondo
                          //border:
                          //  Border.all(color: Colors.blue, width: 1.5), // borde
                          borderRadius:
                              BorderRadius.circular(10), // bordes redondeados
                        ),
                        child: Text(
                          formatDate(activityDateTime),
                        ),
                      )),
                  Positioned(
                      bottom: 5,
                      right: 8,
                      left: 8, // si es borra això no fa el softwrap
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          activityTitle,
                          softWrap: true,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      )),
                  if (created_by_user)
                    const Positioned(
                        top: 6,
                        right: 4,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(Icons.star,
                                size: 35,
                                color: Colors.amber), // fondo del icono
                            Text(
                              'mío',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 8),
                            ),
                          ],
                        )),
                ],
              ),
            )),
      ),
    );
  }
}
