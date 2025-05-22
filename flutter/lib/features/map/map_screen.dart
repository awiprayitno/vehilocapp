import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:VehiLoc/core/Api/websocket.dart';
import 'package:VehiLoc/features/vehicles/models/vehicle_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:VehiLoc/core/model/response_vehicles.dart';
import 'package:VehiLoc/core/utils/colors.dart';
import 'package:VehiLoc/core/utils/logger.dart';
import 'package:VehiLoc/core/utils/vehicle_func.dart';
import 'dart:math';
import 'package:VehiLoc/core/model/response_geofences.dart';
import 'package:VehiLoc/core/Api/api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:label_marker/label_marker.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../vehicles/details_view.dart';

class MapScreen extends ConsumerStatefulWidget {
  double? lat;
  double? lon;

  MapScreen({super.key, this.lat, this.lon});
  static Function? globalSetState;

  @override 
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> with AutomaticKeepAliveClientMixin<MapScreen>{
  @override
  bool get wantKeepAlive => true;
  late BitmapDescriptor greenMarkerIcon;
  late BitmapDescriptor redMarkerIcon;
  late BitmapDescriptor greyMarkerIcon;
  final ApiService apiService = ApiService();
  List<Geofences> _fetchGeofences = [];
  Future<List<Vehicle>>? _fetchDataAndGeofences;
  List<Vehicle> _allVehicles = [];
  List customerSalts = [];
  bool switchGeofences = false;
  bool switchCurrentLocation = false;
  bool geofencesEnabled = false;
  late GoogleMapController _googleMapController;

  bool realtime = true;

  double? lat;
  double? lon;

  Set<Marker> m = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_){
      if(ref.watch(selectedCustomerProvider).isNotEmpty){
        for(var i in ref.watch(selectedCustomerProvider)){
          logger.d("selected customer");
          logger.i(i);
          _fetchGeofences = _fetchGeofences + (i["geofences"] ?? []);
          _allVehicles = _allVehicles + i["vehicles"];
          customerSalts.add(i["salt"]);
        }
        WebSocketProvider.subscribe(realtimeHandler, customerSalts);
      }
    });



    setMarkerIcons();
    // _fetchGeofences = fetchGeofencesData();
    // _fetchDataAndGeofences = fetchAllData();
    // _allVehicles = [];
    // WebSocketProvider.subscribe(realtimeHandler);
    // lat = widget.lat;
    // lon = widget.lon;

    MapScreen.globalSetState = (double? lat, double?lon){
      setState(() {
        this.lat = lat;
        this.lon = lon;
        _googleMapController.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat!, lon!), 16), animationDuration: const Duration(milliseconds: 2000));
      });
    };
  }

  void realtimeHandler(Vehicle vehicle) {
    logger.i("realtimes");
    logger.i(vehicle.vehicleId);
    m.clear();
    if (vehicle.lat != 0.0 && vehicle.lon != 0.0) {
      for (var current in _allVehicles) {
        if (current.vehicleId == vehicle.vehicleId) {
          setState(() {
            current.merge(vehicle);
            // logger.i('WebSocket message map: ${current.customerName} ${current.name}');
          });
          break;
        }
      }
    }
  }
  void _convertAndNavigateToDetailsPage(Vehicle vehicle) {
    logger.i("vehicle data");
    logger.d(vehicle.type);


    if (vehicle.gpsdt != null) {
      final DateTime now = DateTime.now();
      final DateTime gpsdtUtc = DateTime.fromMillisecondsSinceEpoch(
        vehicle.gpsdt! * 1000,
        isUtc: true,
      );

      DateTime gpsdtWIB;
      if (gpsdtUtc.year == now.year && gpsdtUtc.month == now.month && gpsdtUtc.day == now.day) {
        gpsdtWIB = DateTime(now.year, now.month, now.day, 0, 0, 0);
      } else {
        gpsdtWIB = DateTime(gpsdtUtc.year, gpsdtUtc.month, gpsdtUtc.day, 0, 0, 0);
      }


      PersistentNavBarNavigator.pushNewScreen(
        context,
        screen: DetailsPageView(
          vehicleId: vehicle.vehicleId!,
          // vehicleLat: vehicle.lat!,
          // vehicleLon: vehicle.lon!,
          vehicleName: vehicle.name!,
          gpsdt: gpsdtWIB.millisecondsSinceEpoch ~/ 1000,
          type: vehicle.type!,
          imei: vehicle.imei!,
        ),
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.fade,
      );
    }
  }


  void setMarkers(bool isRealtime){
    for(Vehicle vehicle in _allVehicles) {
      BitmapDescriptor markerIcon;
      DateTime? gpsdtWIB;

      if(vehicle.lat != null && vehicle.lon != null){
        if (vehicle.speed == 0) {
          markerIcon = redMarkerIcon;
        } else {
          markerIcon = greenMarkerIcon;
        }
        if (vehicle.gpsdt != null) {
          DateTime gpsdtUtc = DateTime.fromMillisecondsSinceEpoch(vehicle.gpsdt! * 1000, isUtc: true);
          gpsdtWIB = gpsdtUtc.add(const Duration(hours: 7));
          DateTime now = DateTime.now();
          int differenceInDays = now.difference(gpsdtWIB).inDays;

          if (differenceInDays > 7) {
            markerIcon = greyMarkerIcon;
          }
        }
        m.add(Marker(
            markerId: MarkerId('${vehicle.vehicleId}mkr'),
            position: LatLng(vehicle.lat!, vehicle.lon!),
            icon: markerIcon,
            infoWindow: InfoWindow(
              onTap: (){
                _convertAndNavigateToDetailsPage(vehicle);
              },
              title: ("${vehicle.name}"),
              snippet: ("${regexPlateNo.hasMatch(vehicle.name!)?"":vehicle.plateNo} ${vehicle.speed} kmh ${formatDateTime(gpsdtWIB!)} ${vehicle.type == 4 ? "${vehicle.baseMcc! ~/ 10}°C" : ""}"),
            ),
            rotation: vehicle.bearing?.toDouble() ?? 0.0
        ));
        if(!isRealtime){
          m.addLabelMarker(LabelMarker(
            markerId: MarkerId('${vehicle.vehicleId}lbl'),
            position: LatLng(vehicle.lat!, vehicle.lon!),
            icon: markerIcon,
            alpha: 0.8,
            backgroundColor: Colors.white,
            textStyle: const TextStyle(color: Colors.black, fontSize: 30),
            // infoWindow: InfoWindow(
            //   title: ("${vehicle.name}"),
            //   snippet: ("${regexPlateNo.hasMatch(vehicle.name!)?"":vehicle.plateNo} ${vehicle.speed} kmh ${formatDateTime(gpsdtWIB!)} ${vehicle.type == 4 ? "${vehicle.baseMcc! ~/ 10}°C" : ""}"),
            // ),
            label: '${vehicle.name} \n${regexPlateNo.hasMatch(vehicle.name!)?"":vehicle.plateNo} ${vehicle.speed} kmh ${formatDateTime(gpsdtWIB)} ${vehicle.type == 4 ? "${vehicle.baseMcc! ~/ 10}°C" : ""}',
          )).then((value){
            setState(() {
            });
          });
        }

      }
      //List? selectedCustomer = ref.watch(selectedCustomerProvider.notifier).state.customer;
    }
  }

  // Future<List<Geofences>> fetchGeofencesData() async {
  //   try {
  //     final List<Geofences> geofencesList = await apiService.fetchGeofences();
  //     return geofencesList;
  //   } catch (e) {
  //     logger.e("Error fetching geofences: $e");
  //     return [];
  //   }
  // }

  Future<List<Vehicle>> fetchAllData() async {

    try {
      final List<Vehicle> vehicles = await apiService.fetchAllVehicles();
      // Filter out vehicles with lat and lon equal to 0.0
      final List<Vehicle> validVehicles = vehicles.where((vehicle) => vehicle.lat != 0.0 && vehicle.lon != 0.0).toList();
      return validVehicles;
    } catch (e) {
      logger.e("Error fetching data: $e");
      return [];
    }
  }

  void setMarkerIcons() async {
    final Uint8List greenMarkerIconData = await getBytesFromAsset('assets/icons/arrow_green.png', 40);
    final Uint8List redMarkerIconData = await getBytesFromAsset('assets/icons/arrow_red.png', 40);
    final Uint8List greyMarkerIconData = await getBytesFromAsset('assets/icons/arrow_gray.png', 40);

    greenMarkerIcon = BitmapDescriptor.fromBytes(greenMarkerIconData);
    redMarkerIcon = BitmapDescriptor.fromBytes(redMarkerIconData);
    greyMarkerIcon = BitmapDescriptor.fromBytes(greyMarkerIconData);
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Set<Polygon> _createGeofences(List<Geofences> geofencesList) {
    if (!geofencesEnabled) {
      return {};
    }

    if(geofencesList.isEmpty){
      return {};
    }

    Set<Polygon> polygons = {};

    for (int i = 0; i < geofencesList.length; i++) {
      List<LatLng> points = geofencesList[i]
          .geometry!
          .map((geometry) => LatLng(geometry.latitude!, geometry.longitude!))
          .toList();

      polygons.add(
        Polygon(
          polygonId: PolygonId('geofence$i'),
          points: points,
          strokeWidth: 2,
          strokeColor: Colors.red,
          fillColor: Colors.red.withOpacity(0.2),
        ),
      );
    }

    return polygons;
  }

  final regexPlateNo = RegExp(r'\w* \d\d\d\d \w*');
  // logger.i("HAHAHAHA ${vehicle.name} = ${regexPlateNo.firstMatch(vehicle.name!)!.group(0)}");

  void _zoomOutMap() {
    _resetCameraPosition();
    lat = null;
    lon = null;
  }

  // void _refreshNoData() {
  //   setState(() {
  //     _fetchDataAndGeofences = fetchAllData();
  //     _fetchGeofences = fetchGeofencesData();
  //   });
  // }


void _resetCameraPosition() {
  LatLngBounds bounds = _getBounds(_allVehicles.where((vehicle) => vehicle.lat != null && vehicle.lon != null).toList());
  _googleMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 20), animationDuration: const Duration(milliseconds: 2000));
}

  // Future<void> _checkLocationPermission() async {
  //   PermissionStatus status = await Permission.location.status;
  //   if (status.isDenied) {
  //     PermissionStatus permissionStatus = await Permission.location.request();
  //     if (permissionStatus.isGranted) {
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (m.isEmpty) {
      setMarkers(realtime);
    }

    ref.listen(selectedCustomerProvider, (previous, next) {
      logger.i("selected change");
      WebSocketProvider.unsubscribe(realtimeHandler).then((value) async {
      _allVehicles.clear();
      customerSalts.clear();
      _fetchGeofences.clear();
      m.clear();

      if(ref.watch(selectedCustomerProvider).isNotEmpty){
        for(var i in ref.watch(selectedCustomerProvider)){
          logger.d("selected customer");
          logger.i(i);

          _fetchGeofences = _fetchGeofences + (i["geofences"] ?? []);
          _allVehicles = _allVehicles + i["vehicles"];
          customerSalts.add(i["salt"]);
        }
        setState(() {

        });
        WebSocketProvider.subscribe(realtimeHandler, customerSalts);
      }

      //logger.d(_allVehicles);
      logger.i("data change");
      logger.i(_fetchGeofences);


      });



    });


    //_allVehicles = ref.watch(selectedCustomerProvider)[0]["vehicles"];
    LatLngBounds bounds =_allVehicles.isEmpty ? LatLngBounds(southwest: const LatLng(-8.199279, 117.034681) , northeast: const LatLng(-1.121042, 106.050408)): _getBounds(_allVehicles);
    LatLng center = _allVehicles.isEmpty ? const LatLng(-4.942975, 111.157745):LatLng((bounds.southwest.latitude + bounds.northeast.latitude) / 2,(bounds.southwest.longitude + bounds.northeast.longitude) / 2);
    double zoomLevel = _allVehicles.isEmpty ? 7 :_calculateZoomLevel(bounds);
    // double zoomLevel = 7;

    double widthZoom = _calculateZoomLevel(LatLngBounds(
      southwest: LatLng(bounds.southwest.latitude, bounds.southwest.longitude),
      northeast: LatLng(bounds.southwest.latitude, bounds.northeast.longitude),
    ));
    double heightZoom = _calculateZoomLevel(LatLngBounds(
      southwest: LatLng(bounds.southwest.latitude, bounds.southwest.longitude),
      northeast: LatLng(bounds.northeast.latitude, bounds.southwest.longitude),
    ));

    logger.i("selected customer");
    logger.i(ref.watch(selectedCustomerProvider));

    //zoomLevel = max(zoomLevel, max(widthZoom, heightZoom));
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Map",
            style: GoogleFonts.poppins(
              color: GlobalColor.textColor,
            ),
          ),
          backgroundColor: GlobalColor.mainColor,
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.white,),
              itemBuilder: (BuildContext context) {
                List<PopupMenuItem> popUpMenuItem = [];
                if(_fetchGeofences.isNotEmpty){
                  popUpMenuItem.add(
                    PopupMenuItem(
                    child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return
                          Row(children: [
                            const Text("Geofence ",
                              style: TextStyle(fontSize: 16, color: Colors.black),),
                            SizedBox(
                              width: 51.0,
                              height: 31.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: CupertinoSwitch(
                                  value: switchGeofences,
                                  onChanged: (newValue) {
                                    setState(() {
                                      switchGeofences = newValue;
                                      geofencesEnabled = newValue;
                                      final snackBarMessage = SnackBar(
                                        content: Text(newValue
                                            ? 'Showing Geofences'
                                            : 'Hiding Geofences'),
                                        duration: const Duration(seconds: 2),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          snackBarMessage);
                                    });
                                  },
                                  activeColor: CupertinoColors.activeGreen,
                                ),
                              ),
                            )
                          ],);
                      },
                    ),
                  ),);
                }

                if(_allVehicles.isNotEmpty){
                  popUpMenuItem.add( PopupMenuItem(
                    child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return
                          Row(children: [
                            Container(
                              margin: const EdgeInsets.only(left: 15, right: 5),
                              child: const FaIcon(FontAwesomeIcons.info, size: 20,
                                color: Colors.black,),),
                            //const Text("  Name ", style: TextStyle(fontSize: 16, color: Colors.white),),
                            SizedBox(
                              width: 51.0,
                              height: 31.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child:
                                CupertinoSwitch(
                                  value: !realtime,
                                  onChanged: (newValue) {
                                    setState(() {
                                      realtime = !newValue;
                                    });
                                    final snackBarMessage = SnackBar(
                                      content: Text(newValue
                                          ? 'Showing Details (Disabled Realtime)'
                                          : 'Hiding Details (Enabled Realtime)'),
                                      duration: const Duration(seconds: 3),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        snackBarMessage);
                                    if (realtime) {
                                      WebSocketProvider.subscribe(realtimeHandler, customerSalts);
                                    } else {
                                      try {
                                        setMarkers(realtime);
                                      } catch (e) {
                                        logger.e(e);
                                      }
                                      WebSocketProvider.unsubscribe(realtimeHandler);
                                    }
                                  },
                                  activeColor: CupertinoColors.activeGreen,
                                ),
                              ),
                            )
                          ],);
                      },
                    ),
                  ));
                }

                popUpMenuItem.add(
                  PopupMenuItem(
                    child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return
                          TextButton(
                            onPressed: _zoomOutMap,
                            child: const Text(
                              '[   ]',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24.0,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          );
                      },
                    ),
                  ),);
                return popUpMenuItem;
              },
            ),





            // IconButton(
            //   icon: Icon(Icons.more_vert, color: GlobalColor.textColor),
            //   onPressed: _zoomOutMap,
            // )
            // Switch(
            //   value: switchCurrentLocation,
            //   onChanged: (newValue) {
            //     setState(() {
            //       switchCurrentLocation = newValue;
            //       logger.w("huehue test");

            //       _checkLocationPermission();
            //     });
            //   }
            // )
          ],
        ),
        body: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target:
            _allVehicles.isNotEmpty && _allVehicles.any((vehicle) => vehicle.lat != null && vehicle.lon != null)
                ? LatLng((_getBounds(_allVehicles.where((vehicle) => vehicle.lat != null && vehicle.lon != null).toList()).southwest.latitude + _getBounds(_allVehicles.where((vehicle) => vehicle.lat != null && vehicle.lon != null).toList()).northeast.latitude) / 2,
                (_getBounds(_allVehicles.where((vehicle) => vehicle.lat != null && vehicle.lon != null).toList()).southwest.longitude + _getBounds(_allVehicles.where((vehicle) => vehicle.lat != null && vehicle.lon != null).toList()).northeast.longitude) / 2)
                :center,
            zoom:
            _allVehicles.isNotEmpty && _allVehicles.any((vehicle) => vehicle.lat != null && vehicle.lon != null)
                ? _calculateZoomLevel(_getBounds(_allVehicles.where((vehicle) => vehicle.lat != null && vehicle.lon != null).toList()))
                 :zoomLevel,
          ),
          markers: m,
          polygons: _createGeofences(_fetchGeofences),
          myLocationEnabled: true,
          compassEnabled: true,
          zoomControlsEnabled: false,
          onMapCreated: (GoogleMapController controller) {
            _googleMapController = controller;
            if (_allVehicles.isNotEmpty && _allVehicles.any((vehicle) => vehicle.lat != null && vehicle.lon != null)) {
              Future.delayed(const Duration(milliseconds: 1000), () {
                LatLngBounds bounds = _getBounds(_allVehicles.where((vehicle) => vehicle.lat != null && vehicle.lon != null).toList());
                controller.animateCamera(
                    CameraUpdate.newLatLngBounds(bounds, 20), animationDuration: const Duration(milliseconds: 2000)
                );
              });
            }
          },
        ));}
      //
      // FutureBuilder<List<Vehicle>>(
      //   future: _fetchDataAndGeofences,
      //   builder: (context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return const Center(child: CircularProgressIndicator());
          // } else if (snapshot.hasError) {
          //   return Center(child: Text('Error : ${snapshot.error}'));
          // }
          // else
          //   if (snapshot.data == null || snapshot.data!.isEmpty) {
          //   return Center(
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         const Text('No data available, please check your connection or refresh'),
          //         const SizedBox(height: 16),
          //         IconButton(
          //           icon: const Icon(Icons.refresh),
          //           onPressed: () {
          //             _refreshNoData();
          //           },
          //         ),
          //       ],
          //     ),
          //   );
          // }
            //else {
            //_allVehicles = snapshot.data!;


    //        FutureBuilder<List<Geofences>>(
    //           future: _fetchGeofences,
    //           builder: (context, geofenceSnapshot) {

    //             if (geofenceSnapshot.connectionState == ConnectionState.waiting) {
    //               return const Center(child: CircularProgressIndicator());
    //             } else if (geofenceSnapshot.hasError) {
    //               return Center(
    //                   child: Text('Error: ${geofenceSnapshot.error}'));
    //             } else if (!geofenceSnapshot.hasData ||
    //                 geofenceSnapshot.data!.isEmpty) {
    //               return
    //                 GoogleMap(
    //                 mapType: MapType.normal,
    //                 initialCameraPosition: CameraPosition(
    //                   target: _allVehicles.isNotEmpty && _allVehicles.any((vehicle) => vehicle.lat != null && vehicle.lon != null)
    //                       ? LatLng((_getBounds(_allVehicles.where((vehicle) => vehicle.lat != null && vehicle.lon != null).toList()).southwest.latitude + _getBounds(_allVehicles.where((vehicle) => vehicle.lat != null && vehicle.lon != null).toList()).northeast.latitude) / 2,
    //                                (_getBounds(_allVehicles.where((vehicle) => vehicle.lat != null && vehicle.lon != null).toList()).southwest.longitude + _getBounds(_allVehicles.where((vehicle) => vehicle.lat != null && vehicle.lon != null).toList()).northeast.longitude) / 2)
    //                       : center,
    //                   zoom: _allVehicles.isNotEmpty && _allVehicles.any((vehicle) => vehicle.lat != null && vehicle.lon != null)
    //                       ? _calculateZoomLevel(_getBounds(_allVehicles.where((vehicle) => vehicle.lat != null && vehicle.lon != null).toList()))
    //                       : zoomLevel,
    //                 ),
    //                 markers: m,
    //                 // Set<Marker>.from(
    //                 //   _allVehicles.where((vehicle) => vehicle.lat != null && vehicle.lon != null).map((vehicle) {
    //                 //     BitmapDescriptor markerIcon;
    //                 //     DateTime? gpsdtWIB;
    //                 //
    //                 //     if (vehicle.speed == 0) {
    //                 //       markerIcon = redMarkerIcon;
    //                 //     } else {
    //                 //       markerIcon = greenMarkerIcon;
    //                 //     }
    //                 //
    //                 //     if (vehicle.gpsdt != null) {
    //                 //       DateTime gpsdtUtc = DateTime.fromMillisecondsSinceEpoch(vehicle.gpsdt! * 1000, isUtc: true);
    //                 //       gpsdtWIB = gpsdtUtc.add(const Duration(hours: 7));
    //                 //       DateTime now = DateTime.now();
    //                 //       int differenceInDays = now.difference(gpsdtWIB).inDays;
    //                 //
    //                 //       if (differenceInDays > 7) {
    //                 //         markerIcon = greyMarkerIcon;
    //                 //       }
    //                 //     }
    //                 //
    //                 //     return Marker(
    //                 //       markerId: MarkerId('${vehicle.vehicleId}'),
    //                 //       position: LatLng(vehicle.lat!, vehicle.lon!),
    //                 //       icon: markerIcon,
    //                 //       infoWindow: InfoWindow(
    //                 //         title: ("${vehicle.name}"),
    //                 //         snippet: ""
    //                 //         //("${regexPlateNo.hasMatch(vehicle.name!)?"":vehicle.plateNo} ${vehicle.speed} kmh ${formatDateTime(gpsdtWIB!)} ${vehicle.baseMcc! ~/ 10}°C"),
    //                 //       ),
    //                 //       rotation: vehicle.bearing?.toDouble() ?? 0.0,
    //                 //     );
    //                 //   }),
    //                 // ),
    //                 myLocationEnabled: true,
    //                 compassEnabled: true,
    //                 zoomControlsEnabled: false,
    //                 onMapCreated: (GoogleMapController controller) {
    //                   _googleMapController = controller;
    //                   if (_allVehicles.isNotEmpty && _allVehicles.any((vehicle) => vehicle.lat != null && vehicle.lon != null)) {
    //                     Future.delayed(const Duration(milliseconds: 1000), () {
    //                       LatLngBounds bounds = _getBounds(_allVehicles.where((vehicle) => vehicle.lat != null && vehicle.lon != null).toList());
    //                       controller.animateCamera(
    //                         CameraUpdate.newLatLngBounds(bounds, 20), animationDuration: const Duration(milliseconds: 2000)
    //                       );
    //                     });
    //                   }
    //                 },
    //               );
    //             } else {
    //               List<Geofences> geofences = geofenceSnapshot.data!;
    //               return
    //             }
    //           }
    //       //}
    //     //},
    //   //),
    // ));


  LatLngBounds _getBounds(List<Vehicle> vehicles) {
    List<LatLng> positions = vehicles.map((vehicle) {
      if (vehicle.lat != null && vehicle.lon != null) {
        return LatLng(vehicle.lat!, vehicle.lon!);
      } else {
        return const LatLng(0, 0);
      }
    }).toList();

    double minLat = positions.map((pos) => pos.latitude).reduce(min);
    double minLon = positions.map((pos) => pos.longitude).reduce(min);
    double maxLat = positions.map((pos) => pos.latitude).reduce(max);
    double maxLon = positions.map((pos) => pos.longitude).reduce(max);

    return LatLngBounds(
      southwest: LatLng(minLat, minLon),
      northeast: LatLng(maxLat, maxLon),
    );
  }

  double _calculateZoomLevel(LatLngBounds bounds) {
    const double padding = 50.0;
    double zoomWidth = _getZoomWidth(bounds.southwest.longitude, bounds.northeast.longitude, padding);
    double zoomHeight = _getZoomHeight(bounds.southwest.latitude, bounds.northeast.latitude, padding);
    double zoom = min(zoomWidth, zoomHeight);
    return zoom;
  }

  double _getZoomWidth(double minLon, double maxLon, double padding) {
    double angle = maxLon - minLon;
    double zoom = log(360.0 / angle) / ln2;
    return zoom - log(padding / 360) / ln2;
  }

  double _getZoomHeight(double minLat, double maxLat, double padding) {
    double angle = maxLat - minLat;
    double zoom = log(180.0 / angle) / ln2;
    return zoom - log(padding / 180) / ln2;
  }
}
