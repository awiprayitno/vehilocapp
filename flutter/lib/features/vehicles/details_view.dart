// import 'package:VehiLoc/core/model/response_geofences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:VehiLoc/core/model/response_daily.dart';
import 'package:VehiLoc/core/utils/colors.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:VehiLoc/core/Api/api_service.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:VehiLoc/features/vehicles/widget/custom_slider.dart';
import 'package:VehiLoc/features/vehicles/widget/naration_widget.dart';
import 'package:VehiLoc/features/vehicles/widget/event_widget.dart';
import 'package:logger/logger.dart';

class DetailsPageView extends StatefulWidget {
  final int vehicleId;
  final String? vehicleName;
  final int? type;
  late int gpsdt;
  late int initialGpsdt;
  late List<DataItem> dataItems;

  DetailsPageView({
    Key? key,
    required this.vehicleId,
    required this.vehicleName,
    required this.gpsdt,
    required this.type,
  }) : super(key: key) {
    initialGpsdt = gpsdt;
    dataItems = [];
  }

  @override
  _DetailsPageViewState createState() => _DetailsPageViewState();
}

class _DetailsPageViewState extends State<DetailsPageView>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin<DetailsPageView> {
  @override
  bool get wantKeepAlive => true;
  final Logger logger = Logger(
    printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true),
  );
  final ApiService apiService = ApiService();

  List<Marker> stopMarkers = [];

  // List<Geofences> _geofencesList = [];

  late LatLng _initialCameraPosition;

  final _cartesianChartKey = GlobalKey<SfCartesianChartState>();

  late DateTime _selectedDate;
  double _sliderValue = 100.0;

  late BitmapDescriptor _greenMarkerIcon;
  late BitmapDescriptor _redMarkerIcon;

  int stopNumber = 0;

  List<Data> allData = [];
  List<DataItem> dailyData = [];
  List<InputLogsItem> inputData = [];
  List<JdetailsItem> detailsItem = [];

  late GoogleMapController _mapController;

  int _selectedTabIndex = 0;
  late TabController _tabController;

  bool exportingImage = false;

  bool _isLoading = false;
  bool _isLoadingChangeStopMarker = false;

  bool _isSpeedChartVisible = true;
  bool _isTemperatureChartVisible = true;

  double? stopLatitude;
  double? stopLongitude;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);

    DateTime gpsdtUtc = DateTime.fromMillisecondsSinceEpoch(
      widget.gpsdt * 1000,
      isUtc: true,
    );
    DateTime gpsdtWIB = gpsdtUtc.add(const Duration(hours: 7));
    _selectedDate = DateTime(gpsdtWIB.year, gpsdtWIB.month, gpsdtWIB.day);

    setMarkerIcons();
    fetchAllData();
    // _fetchGeofencesData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    setState(() {
      _selectedTabIndex = _tabController.index;
    });
  }

  // // void _fetchGeofencesData() async {
  //   try {
  //     List<Geofences> geofencesList = await apiService.fetchGeofences();
  //     setState(() {
  //       _geofencesList = geofencesList;
  //     });
  //   } catch (e) {
  //     print("Error fetching geofences: $e");
  //   }
  // }

  void fetchAllData() async {
    final int vehicleId = widget.vehicleId;
    final int startEpoch = widget.gpsdt;

    try {
      final Data dataAll =
          await apiService.fetchDailyHistory(vehicleId, startEpoch);

      setState(() {
        allData = [dataAll];
        dailyData = allData.isNotEmpty ? allData[0].data : [];
        inputData = allData.isNotEmpty ? dataAll.inputlogs : [];
        detailsItem = allData.isNotEmpty ? dataAll.jdetails : [];
      });
    } catch (e) {
      logger.e("error : $e");
    }
  }

  void setMarkerIcons() async {
    final Uint8List greenMarkerIconData = await getBytesFromAsset('assets/icons/arrow_green.png', 50);
    final Uint8List redMarkerIconData = await getBytesFromAsset('assets/icons/arrow_red.png', 50);

    _greenMarkerIcon = BitmapDescriptor.fromBytes(greenMarkerIconData);
    _redMarkerIcon = BitmapDescriptor.fromBytes(redMarkerIconData);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Set<Polyline> _createPolylines() {
    if (dailyData.isEmpty || !_polylineOption) {
      return Set();
    }

    final List<LatLng> polylineCoordinates = dailyData
        .map((daily) => LatLng(daily.latitude, daily.longitude))
        .toList();

    final PolylineId polylineId = PolylineId('${widget.vehicleId}');
    final Polyline polyline = Polyline(
      polylineId: polylineId,
      color: Colors.red,
      points: polylineCoordinates,
      width: 2,
    );

    return Set.of([polyline]);
  }

  Set<Marker> _createMarkers(double sliderValue) {
    final Set<Marker> markers = {};

    if (dailyData.isNotEmpty) {
      int index = (sliderValue * dailyData.length / 100).round();
      if (index >= dailyData.length) index = dailyData.length - 1;

      final DataItem currentDaily = dailyData[index];

      markers.add(
        Marker(
          markerId: MarkerId("${widget.vehicleId}"),
          position: LatLng(currentDaily.latitude, currentDaily.longitude),
          rotation: currentDaily.bearing.toDouble(),
          icon: currentDaily.speed == 0
              ? _redMarkerIcon
              : _greenMarkerIcon,
          infoWindow: InfoWindow(
            title: "${widget.vehicleName}",
          ),
        ),
      );
    }

    if (_stopMarkerOption) {
      List<JdetailsItem> stopDetails =
          detailsItem.where((detail) => detail.type == 1).toList();

      final List<Marker> stopMarkers = stopDetails.asMap().entries.map((entry) {
        final int index = entry.key;
        final JdetailsItem detail = entry.value;
        return Marker(
          markerId: MarkerId("${detail.startdt}-${detail.enddt}"),
          position: LatLng(detail.lat, detail.lon),
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(
            title: "Stop ${index + 1}",
            snippet:
                "${DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(detail.startdt * 1000))} - ${DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(detail.enddt * 1000))}",
          ),
        );
      }).toList();

      markers.addAll(stopMarkers);
    }

    return markers;
  }

  // Set<Polygon> _createGeofences() {
  //   Set<Polygon> polygons = {};

  //   for (Geofences geofence in _geofencesList) {
  //     List<LatLng> points = geofence.geometry!
  //         .map((geometry) => LatLng(geometry.latitude!, geometry.longitude!))
  //         .toList();
  //     Polygon polygon = Polygon(
  //       polygonId: PolygonId(geofence.id.toString()),
  //       points: points,
  //       strokeWidth: 2,
  //       strokeColor: Colors.orange,
  //       fillColor: Colors.orange.withOpacity(0.2),
  //     );

  //     polygons.add(polygon);
  //   }

  //   return polygons;
  // }

  void _updateMap() {
    setState(() {
      if (_polylineOption) {}
      if (_stopMarkerOption) {}
    });
  }

  String _getTimeForSliderValue(double sliderValue) {
    if (dailyData.isEmpty) {
      return '';
    }

    int index = (sliderValue * dailyData.length / 100).round();
    if (index >= dailyData.length) index = dailyData.length - 1;

    final DataItem currentDaily = dailyData[index];
    return DateFormat.Hm()
        .format(DateTime.fromMillisecondsSinceEpoch(currentDaily.gpsdt * 1000));
  }

  String _getSpeedForSliderValue(double sliderValue) {
    if (dailyData.isEmpty) {
      return '';
    }

    int index = (sliderValue * dailyData.length / 100).round();
    if (index >= dailyData.length) index = dailyData.length - 1;

    final DataItem currentDaily = dailyData[index];
    return '${currentDaily.speed}';
  }

  double _getTemperatureForSliderValue(double sliderValue) {
    if (dailyData.isEmpty) {
      return 0.0;
    }

    int index = (sliderValue * dailyData.length / 100).round();
    if (index >= dailyData.length) index = dailyData.length - 1;

    final DataItem currentDaily = dailyData[index];
    return currentDaily.temp.toDouble() / 10;
  }

  bool _isForwardButtonEnabled() {
    DateTime maxDate = DateTime.fromMillisecondsSinceEpoch(
        widget.initialGpsdt * 1000,
        isUtc: true);
    DateTime selectedDateUtc = DateTime.utc(
        _selectedDate.year, _selectedDate.month, _selectedDate.day);
    return selectedDateUtc.isBefore(maxDate);
  }

  LatLng _calculatePolylineCenter() {
    if (dailyData.isEmpty) {
      return _initialCameraPosition;
    }

    final List<LatLng> polylineCoordinates = dailyData
        .map((daily) => LatLng(daily.latitude, daily.longitude))
        .toList();

    double sumLat = 0.0;
    double sumLng = 0.0;

    for (LatLng coordinate in polylineCoordinates) {
      sumLat += coordinate.latitude;
      sumLng += coordinate.longitude;
    }

    double averageLat = sumLat / polylineCoordinates.length;
    double averageLng = sumLng / polylineCoordinates.length;

    return LatLng(averageLat, averageLng);
  }

  LatLngBounds _calculatePolylineBounds() {
    if (dailyData.isEmpty) {
      return LatLngBounds(
        southwest: _initialCameraPosition,
        northeast: _initialCameraPosition,
      );
    }

    final List<LatLng> polylineCoordinates = dailyData
        .map((daily) => LatLng(daily.latitude, daily.longitude))
        .toList();

    double minLat = polylineCoordinates[0].latitude;
    double maxLat = polylineCoordinates[0].latitude;
    double minLng = polylineCoordinates[0].longitude;
    double maxLng = polylineCoordinates[0].longitude;

    for (LatLng coordinate in polylineCoordinates) {
      if (coordinate.latitude < minLat) minLat = coordinate.latitude;
      if (coordinate.latitude > maxLat) maxLat = coordinate.latitude;
      if (coordinate.longitude < minLng) minLng = coordinate.longitude;
      if (coordinate.longitude > maxLng) maxLng = coordinate.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  double _calculateZoomLevel(LatLngBounds bounds) {
    const double padding = 50.0;
    const double desiredWidth = 400.0;

    double angle = bounds.northeast.longitude - bounds.southwest.longitude;
    if (angle < 0) {
      angle += 360;
    }

    double zoom = _getBoundsZoomLevel(bounds, padding, desiredWidth);
    return zoom;
  }

  double _getBoundsZoomLevel(
      LatLngBounds bounds, double padding, double width) {
    double globeWidth = 256;
    double west = bounds.southwest.longitude;
    double east = bounds.northeast.longitude;
    double angle = east - west;
    if (angle < 0) {
      angle += 360;
    }

    double zoom = ((width - padding) * 360) / (angle * globeWidth);
    return zoom;
  }

  bool _polylineOption = true;
  bool _stopMarkerOption = true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 4,
      initialIndex: _selectedTabIndex,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          title: Text(
            "${widget.vehicleName}",
            style: GoogleFonts.poppins(
              textStyle: TextStyle(
                color: GlobalColor.textColor,
              ),
            ),
          ),
          backgroundColor: GlobalColor.mainColor,
          actions: _selectedTabIndex == 0
              ? [
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem(
                          child: StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return Row(
                                children: [
                                  Checkbox(
                                    value: _polylineOption,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _polylineOption = newValue!;
                                        _updateMap();
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 6), 
                                  const Text('Track line'),
                                ],
                              );
                            },
                          ),
                        ),
                        PopupMenuItem(
                          child: StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState) {
                              return Row(
                                children: [
                                  Checkbox(
                                    value: _stopMarkerOption,
                                    onChanged: (newValue) {
                                      setState(() {
                                        _stopMarkerOption = newValue!;
                                        _updateMap();
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('Stop'),
                                ],
                              );
                            },
                          ),
                        ),
                      ];
                    },
                  ),
                ]
              : null,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 5.0,
            tabs: const [
              Tab(
                icon: Icon(Icons.map, color: Colors.white),
              ),
              Tab(
                icon: Icon(Icons.article, color: Colors.white),
              ),
              Tab(
                icon: Icon(Icons.event, color: Colors.white),
              ),
              Tab(
                icon: Icon(Icons.insert_chart, color: Colors.white),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 5),
              child: Row(
                mainAxisAlignment: _selectedTabIndex == 0
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  _selectedTabIndex == 0
                      ? SizedBox(
                          width: 30,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                                _updateStartEpoch();
                              });
                            },
                            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                          ),
                        )
                      : Expanded(
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                                _updateStartEpoch();
                              });
                            },
                            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                          ),
                        ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: GlobalColor.buttonColor.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1.5,
                            blurRadius: 2,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () {
                          _selectDate(context);
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Visibility(
                              visible: !_isLoading,
                              child: Text(
                                '${_selectedDate.day} ${DateFormat.MMM().format(_selectedDate)}, ${_selectedDate.year}',
                                style: GoogleFonts.poppins(
                                  fontSize: _selectedTabIndex == 0 ? 14 : 14,
                                  color: GlobalColor.textColor,
                                ),
                              ),
                            ),
                            Visibility(
                              visible: _isLoading,
                              child: const CircularProgressIndicator(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _selectedTabIndex == 0
                      ? SizedBox(
                          width: 35,
                          child: IconButton(
                            onPressed: _isForwardButtonEnabled()
                                ? () {
                                    setState(() {
                                      _selectedDate = _selectedDate.add(const Duration(days: 1));
                                      _updateStartEpoch();
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.arrow_forward_ios, size: 20),
                          ),
                        )
                      : Expanded(
                          child: IconButton(
                            onPressed: _isForwardButtonEnabled()
                                ? () {
                                    setState(() {
                                      _selectedDate = _selectedDate.add(const Duration(days: 1));
                                      _updateStartEpoch();
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.arrow_forward_ios, size: 20),
                          ),
                        ),
                  if (_selectedTabIndex == 0)
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 25, color: Colors.black),
                        const SizedBox(width: 3),
                        Text(
                          _getTimeForSliderValue(_sliderValue),
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ),
                  const SizedBox(width: 6),
                  if (_selectedTabIndex == 0)
                    Row(
                      children: [
                        const Icon(Icons.speed, size: 25, color: Colors.black),
                        const SizedBox(width: 3),
                        Text(
                          '${_getSpeedForSliderValue(_sliderValue)} kmh',
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ),
                  if (_selectedTabIndex == 0 && widget.type == 4)
                    Row(
                      children: [
                        const Icon(Icons.thermostat, size: 25, color: Colors.black),
                        // const SizedBox(width: 10),
                        Text(
                          '${_getTemperatureForSliderValue(_sliderValue)}°',
                          style: GoogleFonts.poppins(),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10,)
                ],
              ),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: TabBarView(
                  physics: _selectedTabIndex == 0
                      ? const NeverScrollableScrollPhysics()
                      : null,
                  controller: _tabController,
                  children: [
                    _buildMapWidget(),
                    NarationWidget(
                      narationData: detailsItem,
                      fetchNarationData: () => fetchNarationData(),
                      onMapButtonPressed: (double lat, double lon) {
                        setState(() {
                          stopLatitude = lat;
                          stopLongitude = lon;
                          _tabController.animateTo(0);
                          _isLoadingChangeStopMarker = true;
                        });
                        Future.delayed(const Duration(milliseconds: 1000), () {
                          setState(() {
                            _isLoadingChangeStopMarker = false;
                          });
                        });
                      },
                      stopNumber: stopNumber,
                    ),
                    EventWidget(
                      eventData: inputData,
                    ),
                    _buildChartWidget(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingDialog() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildMapWidget() {
  if (_isLoadingChangeStopMarker) {
    return _buildLoadingDialog();
  } else if (dailyData.isEmpty || allData.isEmpty) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: const CameraPosition(
        target: LatLng(-6.966667, 110.416664),
        zoom: 16,
      ),
      markers: {},
      polylines: {},
      onMapCreated: (controller) {},
    );
  } else {
    return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    Expanded(
                      child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: stopLatitude != null && stopLongitude != null
                            ? CameraPosition(
                                target: LatLng(stopLatitude!, stopLongitude!),
                                zoom: 14,
                              )
                            : CameraPosition(
                                target: _calculatePolylineCenter(),
                                zoom: 12,
                              ),
                        markers: _createMarkers(_sliderValue),
                        polylines: _createPolylines(),
                        onMapCreated: (controller) {
                          setState(() {
                            _mapController = controller;
                          });

                          if (stopLatitude == null && stopLongitude == null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              LatLngBounds bounds = _calculatePolylineBounds();
                              _mapController.animateCamera(
                                CameraUpdate.newLatLngBounds(bounds, 50),
                              );
                            });
                          }
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: SizedBox(
                        height: 70,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.topRight,
                              colors: [
                                for (var dataItem in dailyData)
                                  getColorByBox(dataItem.colorBox),
                              ],
                            ),
                          ),
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 8,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                              valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                              valueIndicatorTextStyle:const TextStyle(color: Colors.black),
                              trackShape: CustomTrackShape(),
                            ),
                            child: Slider(
                              value: _sliderValue,
                              min: 0,
                              max: 100,
                              onChanged: (newValue) {
                                setState(() {
                                  _sliderValue = newValue;
                                  _updateCameraPosition(newValue);
                                });
                              },
                              activeColor: Colors.black,
                              inactiveColor: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
  }
}

  Widget _buildChartWidget() {
    if (dailyData.isEmpty) {
      return const Center(
        child: Text(
          'No Data Available',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
      );
    }

    double minTemperature = dailyData.map((data) => data.temp / 10).reduce((value, element) => value < element ? value : element);
    double maxTemperature = dailyData.map((data) => data.temp / 10).reduce((value, element) => value > element ? value : element);
    double minSpeed = dailyData.map((data) => data.speed.toDouble()).reduce((value, element) => value < element ? value : element);
    double maxSpeed = dailyData.map((data) => data.speed.toDouble()).reduce((value, element) => value > element ? value : element);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Checkbox(
                value: _isSpeedChartVisible,
                onChanged: (value) {
                  setState(() {
                    _isSpeedChartVisible = value!;
                  });
                },
              ),
              const Text('Speed'),
            if (widget.type == 4) ...[
              Checkbox(
                value: _isTemperatureChartVisible,
                onChanged: (value) {
                  setState(() {
                    _isTemperatureChartVisible = value!;
                  });
                },
              ),
              const Text('Temp'),
            ],
          ],
        ),

        if ((_isSpeedChartVisible || (_isTemperatureChartVisible && widget.type == 4))) ...[
          Expanded(
            child: FutureBuilder(
              future: Future.delayed(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return SingleChildScrollView(
                    child: SizedBox(
                      width: 1200,
                      height: 550,
                      child: SfCartesianChart(
                        key: _cartesianChartKey,
                        title: ChartTitle(
                          text: '${widget.vehicleName} \n ${_selectedDate.day} ${DateFormat.MMM().format(_selectedDate)}, ${_selectedDate.year}',
                          textStyle: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        tooltipBehavior: TooltipBehavior(enable: true, format: 'point.x point.y'),
                        series: <LineSeries<DataItem, DateTime>>[
                          if (_isSpeedChartVisible)
                            LineSeries<DataItem, DateTime>(
                              dataSource: dailyData,
                              xValueMapper: (DataItem data, _) => DateTime.fromMillisecondsSinceEpoch(data.gpsdt * 1000),
                              yValueMapper: (DataItem data, _) => _isSpeedChartVisible ? data.speed.toDouble() : null,
                              name: 'Speed',
                              color: Colors.orange[300],
                              yAxisName: 'Speed',
                              width: 1,
                              legendItemText: 'Speed (kmh)',
                              animationDuration: 0,
                            ),
                          if (_isTemperatureChartVisible && widget.type == 4)
                            LineSeries<DataItem, DateTime>(
                              dataSource: dailyData,
                              xValueMapper: (DataItem data, _) => DateTime.fromMillisecondsSinceEpoch(data.gpsdt * 1000),
                              yValueMapper: (DataItem data, _) => _isTemperatureChartVisible && widget.type == 4 ? data.temp / 10 : null,
                              name: 'Temp',
                              color: Colors.blue[700],
                              yAxisName: 'Temp',
                              width: 1,
                              legendIconType: LegendIconType.horizontalLine,
                              legendItemText: 'Temp (°C)',
                              animationDuration: 0,
                            ),
                        ],
                        primaryXAxis: DateTimeAxis(
                          title: const AxisTitle(
                            text: 'Time',
                            textStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          dateFormat: DateFormat.Hm(),
                        ),
                        primaryYAxis: NumericAxis(
                          opposedPosition: true,
                          name: 'Speed',
                          title: const AxisTitle(
                            textStyle: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          minimum: _isSpeedChartVisible ? minSpeed : null,
                          maximum: _isSpeedChartVisible ? maxSpeed + 10 : null,
                          interval: _isSpeedChartVisible ? 20 : null,
                        ),
                        axes: <ChartAxis>[
                          if (_isTemperatureChartVisible && widget.type == 4)
                            NumericAxis(
                              name: 'Temp',
                              opposedPosition: false,
                              title: const AxisTitle(
                                textStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              minimum: _isTemperatureChartVisible ? minTemperature - 5 : null,
                              maximum: _isTemperatureChartVisible ? maxTemperature + 5 : null,
                              interval: _isTemperatureChartVisible ? 10 : null,
                            ),
                        ],
                        legend: const Legend(
                          isVisible: true,
                          textStyle: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
          if (_isSpeedChartVisible || (_isTemperatureChartVisible && widget.type == 4))
            ElevatedButton(
              onPressed: () {
                _renderChartAsImage(context);
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.black.withOpacity(0.8)),
              ),
              child: Text(
                'Save image',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: GlobalColor.textColor,
                ),
              ),
            ),
        ],
      ],
    );
  }


  Future<void> _renderChartAsImage(BuildContext context) async {
    final ui.Image? data = await _cartesianChartKey.currentState!.toImage(pixelRatio: 3.0);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder,Rect.fromPoints(const Offset(0.0, 0.0), const Offset(1220.0, 1720.0)));
    canvas.drawColor(GlobalColor.textColor, BlendMode.dstOver);
    canvas.drawImage(data!, Offset.zero, Paint());
    final ui.Image finalImage = await recorder.endRecording().toImage(1220, 1720);

    final ByteData? bytes = await finalImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List imageBytes = bytes!.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);

    final result = await ImageGallerySaver.saveImage(imageBytes);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: result['isSuccess']
              ? const Text('Image saved')
              : const Text('Failed to saved image'),
          content: result['isSuccess']
              ? const Text('Image is saved on your galery.')
              : const Text('Failed to saved image on your galery'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _updateCameraPosition(double sliderValue) {
    if (dailyData.isEmpty) {
      return;
    }

    int index = (sliderValue * dailyData.length / 100).round();
    if (index >= dailyData.length) index = dailyData.length - 1;

    final DataItem currentDaily = dailyData[index];
    _mapController.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(currentDaily.latitude, currentDaily.longitude),
      ),
    );
  }

  void _updateStartEpoch() async {
    final int vehicleId = widget.vehicleId;
    final DateTime selectedDateUtc = _selectedDate.toUtc();
    final int startEpoch = selectedDateUtc.millisecondsSinceEpoch ~/ 1000;

    try {
      setState(() {
        widget.gpsdt = startEpoch;
        _isLoading = true;
        stopLatitude = null;
        stopLongitude = null;
      });

      final Data dataAll = await apiService.fetchDailyHistory(vehicleId, startEpoch);

      setState(() {
        allData = [dataAll];
        dailyData = allData.isNotEmpty ? allData[0].data : [];
        inputData = allData.isNotEmpty ? dataAll.inputlogs : [];

        if (dailyData.isNotEmpty) {
          final DataItem currentDaily = dailyData.first;
          _initialCameraPosition = LatLng(currentDaily.latitude, currentDaily.longitude);

          // _mapController.animateCamera(
          //   CameraUpdate.newLatLng(_initialCameraPosition),
          // );
        }

        if (_selectedTabIndex == 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            LatLngBounds bounds = _calculatePolylineBounds();
            _mapController.animateCamera(
              CameraUpdate.newLatLngBounds(bounds, 50),
            );
          });
        }

        detailsItem = allData.isNotEmpty ? dataAll.jdetails : [];
        final List<Marker> updatedStopMarkers = detailsItem.where((detail) => detail.type == 1).map((detail) {
          return Marker(
            markerId: MarkerId("${detail.startdt}-${detail.enddt}"),
            position: LatLng(detail.lat, detail.lon),
            icon: BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
              title: "Berhenti",
              snippet: DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(detail.startdt * 1000)),
            ),
          );
        }).toList();

        stopMarkers.clear();
        stopMarkers.addAll(updatedStopMarkers);

        stopNumber = 0;
      });
    } catch (e) {
      logger.e("error haha : $e");
      setState(() {
        allData = [];
        dailyData = [];
        detailsItem = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      selectableDayPredicate: (DateTime date) {
        DateTime lastSelectableDate = DateTime.fromMillisecondsSinceEpoch(widget.initialGpsdt * 1000, isUtc: true).add(const Duration(days: 1));
        return date.isBefore(lastSelectableDate);
      },
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: GlobalColor.mainColor,
              onPrimary: Colors.white,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      DateTime pickedWIB = picked.add(const Duration(hours: 7));
      if (pickedWIB !=
          DateTime(pickedWIB.year, pickedWIB.month, pickedWIB.day)) {
        setState(() {
          _selectedDate = picked;
        });
        _updateStartEpoch();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Anda tidak dapat memilih tanggal yang cocok dengan tanggal data."),
        ));
      }
    }
  }

  Future<List<InputLogsItem>> fetchEventData() async {
    final int vehicleId = widget.vehicleId;
    final int startEpoch = widget.gpsdt;

    try {
      final Data dataAll = await apiService.fetchDailyHistory(vehicleId, startEpoch);

      return dataAll.inputlogs;
    } catch (e) {
      logger.e("error : $e");
      rethrow;
    }
  }

  Future<List<JdetailsItem>> fetchNarationData() async {
    final int vehicleId = widget.vehicleId;
    final int startEpoch = widget.gpsdt;

    try {
      final Data dataAll = await apiService.fetchDailyHistory(vehicleId, startEpoch);

      return dataAll.jdetails;
    } catch (e) {
      logger.e("error : $e");
      rethrow;
    }
  }
}
