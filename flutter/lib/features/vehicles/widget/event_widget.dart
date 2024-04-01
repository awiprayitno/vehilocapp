import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:VehiLoc/core/model/response_daily.dart';

class EventWidget extends StatefulWidget {
  final List<InputLogsItem> eventData;

  const EventWidget({
    Key? key,
    required this.eventData,
  }) : super(key: key);

  @override
  _EventWidgetState createState() => _EventWidgetState();
}

class _EventWidgetState extends State<EventWidget> with AutomaticKeepAliveClientMixin<EventWidget> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); 

    if (widget.eventData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/no-event.png',
              height: 100,
              width: 100,
            ),
            const SizedBox(height: 10), 
            const Text(
              'No Event available',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: DataTable(
            columnSpacing: 0,
            headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
            columns: const [
              DataColumn(
                label: Text(
                  'Time',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins'),
                ),
              ),
              DataColumn(
                label: Text(
                  'Event',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins'),
                ),
              ),
            ],
            rows: widget.eventData.map((inputLogs) {
              return DataRow(cells: [
                DataCell(Text(
                  DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(inputLogs.dt * 1000)),
                  style: const TextStyle(fontSize: 18, fontFamily: 'Poppins'),
                )),
                DataCell(Text(
                  '${inputLogs.sensorName} was ${inputLogs.newStateDesc}',
                  style: const TextStyle(fontSize: 18, fontFamily: 'Poppins'),
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
