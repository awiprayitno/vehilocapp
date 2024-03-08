import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:VehiLoc/core/model/response_daily.dart';
class EventWidget extends StatelessWidget {
  final List<InputLogsItem> eventData;

  const EventWidget({
    Key? key,
    required this.eventData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (eventData.isEmpty) {
      return const Center(child: Text('No Event Available'));
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
            rows: eventData.map((inputLogs) {
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
