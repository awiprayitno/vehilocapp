import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:VehiLoc/core/Api/api_service.dart';
import 'package:VehiLoc/core/model/vehicle_picture.dart';
import 'package:VehiLoc/core/utils/logger.dart';

class DashcamWidget extends StatefulWidget {
  final int? vehicleId;
  final int? startDt;
  final int? endDt;
  final Function() onUpdateStartEpoch; // Define the callback function
  const DashcamWidget({Key? key, this.vehicleId, this.startDt, this.endDt, required this.onUpdateStartEpoch}) : super(key: key);

  @override
  State<DashcamWidget> createState() => _DashcamWidgetState();
}

class _DashcamWidgetState extends State<DashcamWidget> with AutomaticKeepAliveClientMixin<DashcamWidget> {
  late int _currentPageIndex;
  late VehiclePicture vehiclePicture = VehiclePicture(); 
  late Map<String, String> imagePathsMap = {}; 

  @override
  void initState() {
    super.initState();
    _currentPageIndex = 0;
    imagePathsMap = {};
    fetchVehiclePicture();
  }

  void fetchVehiclePicture() async {
    try {
      final ApiService apiService = ApiService();
      final vehiclePicture = await apiService.fetchVehiclePicture(widget.vehicleId!, widget.startDt!, widget.endDt!);
      setState(() {
        this.vehiclePicture = vehiclePicture;
      });
      for (Result result in vehiclePicture.result ?? []) {
        if (result.picOid != null) {
          fetchPicture(result.picOid!);
        }
      }
    } catch (e) {
      logger.e('Error fetching picture vehicle data: $e');
    }
  }

  void fetchPicture(String picOid) async {
    try {
      final ApiService apiService = ApiService();
      final picture = await apiService.fetchPicture(picOid);
      setState(() {
        imagePathsMap[picOid] = picture.b64data!; 
      });
    } catch (e) {
      logger.e('Error fetching picture : $e');
    }
  }

  @override
  bool get wantKeepAlive => true;

  void _showImageModal(BuildContext context, Map<String, String> imagePathsMap, List<Result> results, Result selectedResult) {
  int selectedImageIndex = results.indexOf(selectedResult);
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: PageView.builder(
                      itemCount: results.length,
                      controller: PageController(initialPage: selectedImageIndex),
                      onPageChanged: (index) {
                        setState(() {
                          selectedResult = results[index];
                        });
                      },
                      itemBuilder: (BuildContext context, int index) {
                        String? imagePath = imagePathsMap[results[index].picOid!];
                        if (imagePath != null) {
                          return Image.memory(
                            base64.decode(imagePath), 
                            fit: BoxFit.fill,
                          );
                        } else {
                          return SizedBox(); 
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${selectedResult.gpsdt != null ? _formatEpochToTime(selectedResult.gpsdt!) : "Unknown"} ',
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

  String _formatEpochToTime(int epoch) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
    String formattedTime = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    List<Result> results = vehiclePicture.result ?? [];

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 10.0,
                  runSpacing: 10.0,
                  children: results.map((result) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: TextButton(
                        onPressed: () {
                          _showImageModal(context, imagePathsMap, results, result);
                        },
                        child: Text(
                          result.gpsdt != null ? _formatEpochToTime(result.gpsdt!) : "Unknown ${result.picOid}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  void didUpdateWidget(DashcamWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startDt != widget.startDt || oldWidget.endDt != widget.endDt) {
      fetchVehiclePicture();
    }
  }
}
