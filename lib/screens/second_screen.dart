import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:multi_select_flutter/bottom_sheet/multi_select_bottom_sheet_field.dart';
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:worldwildprova/models_fromddbb/tag.dart';
import 'package:worldwildprova/models_fromddbb/activity.dart';
import 'package:worldwildprova/models_fromddbb/tagChip.dart';
import 'package:worldwildprova/screens/activitydetail_screen.dart';
import 'package:worldwildprova/widgets/activitiesList.dart';
import 'package:worldwildprova/widgets/mainscaffold.dart';
import 'package:worldwildprova/widgets/privatePlansList.dart';
import 'package:worldwildprova/widgets/promoList.dart';
import 'package:worldwildprova/widgets/tagSelector.dart';

class SecondScreen extends StatefulWidget {
  final String placeUuid;
  final String placeName;
  final bool fromMainScaffold;

  const SecondScreen(
      {super.key,
      required this.placeUuid,
      required this.placeName,
      required this.fromMainScaffold});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen>
    with SingleTickerProviderStateMixin {

        late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 2 pestañas
  }

  @override
  void dispose() {
    _tabController.dispose(); // Limpieza
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Que hacer en ${widget.placeName}'),
          bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Planes'),
            Tab(text: 'Promos'),
            Tab(text: 'Planes privados')
          ],
        ),
        ),
        body: TabBarView(
        controller: _tabController,

          children:[ ActivitiesList(
              placeUuid: widget.placeUuid, placeName: widget.placeName),
              PromoList(placeUuid: widget.placeUuid, placeName: widget.placeName),
              const PrivatePlansList()
              ]
        ),
        bottomNavigationBar: widget.fromMainScaffold == false
            ? BottomNavigationBar(
                currentIndex: 0, // mismo control
                onTap: (index) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MainScaffold(initialIndex: index)),
                  );
                },
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.place), label: 'Lugares'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.brush), label: 'Crear plan'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person), label: 'Perfil'),
                ],
              )
            : null);
  }
}
