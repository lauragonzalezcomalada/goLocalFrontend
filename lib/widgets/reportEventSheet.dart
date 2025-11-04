import 'package:flutter/widgets.dart';

class ReportEventSheet extends StatefulWidget {
  final String event_uuid;

  const ReportEventSheet({required this.event_uuid, super.key});

  @override
  State<ReportEventSheet> createState() => _ReportEventSheetState();
}

class _ReportEventSheetState extends State<ReportEventSheet> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        builder: (context, scrollController) {
          return Container(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'TE AYUDAMOS A DENUNCIAR ESTE EVENTO',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.w800),
                        )
                      ],
                    ),
                  )),
            ),
          );
        });
  }
}
