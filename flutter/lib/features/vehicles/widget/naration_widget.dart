import 'package:flutter/material.dart';
import 'package:VehiLoc/core/model/response_daily.dart';
import 'package:VehiLoc/core/utils/naration_func.dart';
import 'package:VehiLoc/core/Api/api_service.dart';
import 'package:logger/logger.dart';

class NarationWidget extends StatefulWidget {
  final Logger logger = Logger();
  final ApiService apiService = ApiService();
  final List<JdetailsItem> narationData;
  final Future<List<JdetailsItem>> Function() fetchNarationData;
  final void Function(double lat, double lon)? onMapButtonPressed;
  int stopNumber;

  NarationWidget({
    Key? key,
    required this.narationData,
    required this.fetchNarationData,
    this.onMapButtonPressed,
    required this.stopNumber,
  }) : super(key: key);

  @override
  _NarationWidgetState createState() => _NarationWidgetState();
}

class _NarationWidgetState extends State<NarationWidget> {
  Map<int, String> addresses = {};
  final Map<int, bool> buttonPressedMap = {};
  bool isFetchingAddress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.stopNumber = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.narationData.isEmpty) {
      return const Center(child: Text('No Journey Available'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: widget.narationData.isEmpty
              ? const Center(
                  child: Text(
                    'No data available',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : DataTable(
                  columnSpacing: 20,
                  headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                  dataRowMinHeight: 55,
                  dataRowMaxHeight: 55,
                  columns: const [
                    DataColumn(
                      label: SizedBox(
                        width: 120, 
                        child: Text('Waktu',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins'
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text('Narasi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins'
                        ),
                      ),
                    ),
                  ],
                  rows: widget.narationData.map((jDetails) {
                    final buttonPressed = buttonPressedMap[jDetails.startdt] ?? false;
                    final address = addresses[jDetails.startdt] ?? '';

                    if (jDetails.type == 1) {
                      widget.stopNumber++;
                    }

                    return DataRow(
                      cells: [
                        DataCell(
                          SizedBox(
                            width: 120, 
                            child: Text(
                              '${formatTime(jDetails.startdt)} - ${formatTime(jDetails.enddt)}',
                              style: const TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                            ),
                          ),
                        ),
                        DataCell(
                          jDetails.type == 1
                              ? TableRowInkWell(
                                  onTap: () async {
                                    if (addresses[jDetails.startdt] == null) {
                                      final _address = await fetchGeocode(jDetails.lat, jDetails.lon);
                                      setState(() {
                                        buttonPressedMap[jDetails.startdt] = true;
                                        addresses[jDetails.startdt] = _address;
                                      });
                                    }
                                  },
                                  child: IntrinsicHeight(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start, 
                                            children: [
                                              Text(
                                                formatNaration(jDetails),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontFamily: 'Poppins'
                                                ),
                                              ),
                                              if (buttonPressed)
                                                Text(
                                                  address,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            widget.onMapButtonPressed?.call(jDetails.lat, jDetails.lon);
                                          },
                                          icon: Stack(
                                            children: [
                                              const Icon(Icons.map, color: Colors.red),
                                              if (jDetails.type == 1)
                                                Positioned(
                                                  right: 0,
                                                  top: 0,
                                                  child: Container(
                                                    padding: const EdgeInsets.all(2),
                                                    decoration: const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.white,
                                                    ),
                                                    child: Text(
                                                      '${widget.stopNumber}',
                                                      style: const TextStyle(
                                                        color: Colors.red,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              : IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              formatNaration(jDetails),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'Poppins'
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ),
    );
  }

  Future<String> fetchGeocode(double lat, double lon) async {
    try {
      final _address = await widget.apiService.fetchAddress(lat, lon);
      widget.stopNumber = 0;
      return _address;
    } catch (e) {
      // widget.logger.e("Error fetching address: $e");
      return "";
    }
  }
}
