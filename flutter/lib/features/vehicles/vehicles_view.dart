import 'package:VehiLoc/features/map/widget/bottom_bar.dart';
import 'package:VehiLoc/features/vehicles/models/vehicle_models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:VehiLoc/core/model/response_vehicles.dart';
import 'package:VehiLoc/core/utils/colors.dart';
import 'package:VehiLoc/core/utils/vehicle_func.dart';
import 'package:VehiLoc/core/Api/api_provider.dart';
import 'package:VehiLoc/core/Api/api_service.dart';
import 'package:VehiLoc/features/vehicles/details_view.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:VehiLoc/core/Api/websocket.dart';
import 'package:VehiLoc/core/utils/logger.dart';

class VehicleView extends ConsumerStatefulWidget {
  const VehicleView({Key? key}) : super(key: key);

  @override
  _VehicleViewState createState() => _VehicleViewState();
}

class _VehicleViewState extends ConsumerState<VehicleView> with AutomaticKeepAliveClientMixin<VehicleView>{
  @override
  bool get wantKeepAlive => true;
  final ApiService apiService = ApiService();
  late List<Vehicle> _allVehicles;
  late List<Vehicle> _filteredVehicles;
  late Map<String, List<Vehicle>> _groupedVehicles;
  bool _isLoading = false;
  final Map<Vehicle, String> _vehicleToAddress = {};

  void realtimeHandler(Vehicle vehicle) {
    for (var current in _allVehicles) {
      if (current.vehicleId == vehicle.vehicleId) {
        setState(() {
          current.merge(vehicle);
          // logger.i('WebSocket message vehicle: ${current.customerName} ${current.name}');
        });
        break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _filteredVehicles = [];
    _allVehicles = [];
    _groupedVehicles = {};
    _fetchData();
    WebSocketProvider.subscribe(realtimeHandler);
    logger.i("Vehicle subscribe websocket");
    // final Logger logger = Logger();
    // WebSocketChannel channel = connectToWebSocket(LoginState.userSalt);

    // channel.stream.listen(
    //   (message) {
    //     var vehicleRaw = json.decode(message);
    //     Vehicle vehicle = Vehicle.fromJson(vehicleRaw);
    //     for (var current in _allVehicles) {
    //       if (current.vehicleId == vehicle.vehicleId) {
    //         setState(() {
    //           current.merge(vehicle);
    //           logger.i('WebSocket message: ' + current.customerName.toString() + current.plateNo.toString());
    //         });
    //         break;
    //       }
    //     }
    //   },
    //   onError: (error) {
    //     logger.e('Error: $error');
    //   },
    //   onDone: () {
    //     logger.i('WebSocket closed');
    //   },
    // );
  }
  void showModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.close,
              color: Colors.red,
              size: 88,
            ),
            const SizedBox(height: 16),
            Text(
              'You cannot access details because the vehicle is disabled',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      );
      },
    );
  }

  void fetchGeocode(Vehicle vehicle) async {
    if (vehicle.lat != null && vehicle.lon != null) {
      final double? lat = vehicle.lat;
      final double? lon = vehicle.lon;
      try {
        final address = await apiService.fetchAddress(lat!, lon!);
        setState(() {
          _vehicleToAddress[vehicle] = address;
        });
      } catch (e) {
        logger.e("error : $e");
      }
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    final List<Vehicle> vehicles = await ApiProvider().getApiResponse();
    if (mounted) {
      setState(() {
        _allVehicles = vehicles;
        _filteredVehicles = vehicles;
        _groupVehicles(vehicles);
        _isLoading = false;
      });
    }
    WebSocketProvider.subscribe(realtimeHandler);
  }

  // void _groupVehicles(List<Vehicle> vehicles) {
  //   _groupedVehicles.clear();
  //   for (Vehicle vehicle in vehicles) {
  //     if (!_groupedVehicles.containsKey(vehicle.customerName)) {
  //       _groupedVehicles[vehicle.customerName!] = [];
  //     }
  //     _groupedVehicles[vehicle.customerName!]!.add(vehicle);
  //   }
  // }

  void _groupVehicles(List<Vehicle> vehicles) {
    _groupedVehicles.clear();
    for (Vehicle vehicle in vehicles) {
      if (!_groupedVehicles.containsKey(vehicle.customerName)) {
        _groupedVehicles[vehicle.customerName!] = [];
      }
      _groupedVehicles[vehicle.customerName!]!.add(vehicle);
    }
  }

  void _filterVehicles(String query) {
    setState(() {
      _filteredVehicles = _allVehicles.where((vehicle) {
        final nameLower = vehicle.name?.toLowerCase() ?? '';
        final plateNoLower = vehicle.plateNo?.toLowerCase() ?? '';
        final customerNameLower = vehicle.customerName?.toLowerCase() ?? "";
        final searchLower = query.toLowerCase();
        return nameLower.contains(searchLower) || plateNoLower.contains(searchLower) || customerNameLower.contains(searchLower);
      }).toList();
      _groupVehicles(_filteredVehicles);
    });
  }

  void _convertAndNavigateToDetailsPage(Vehicle vehicle) {
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
        withNavBar: true,
        pageTransitionAnimation: PageTransitionAnimation.fade,
      );
    } else {
      showModal();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: TextField(
            onChanged: _filterVehicles,
            style: TextStyle(color: GlobalColor.textColor),
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(color: GlobalColor.textColor),
              border: InputBorder.none,
            ),
          ),
          backgroundColor: GlobalColor.mainColor,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: _isLoading && _allVehicles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _groupedVehicles.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isLoading && index == _groupedVehicles.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                String customerName = _groupedVehicles.keys.elementAt(index);
                List<Vehicle> customerVehicles = _groupedVehicles[customerName]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExpansionTile(
                      onExpansionChanged: (onExpand){

                        //logger.i(_groupedVehicles.keys.elementAt(index));
                        if(onExpand){
                          ref.read(selectedCustomerProvider.notifier).state.addSelectedCustomer({
                            "customer_name" : customerName
                          });
                        }else{
                          ref.read(selectedCustomerProvider.notifier).state.removSelectedCustomer({
                            "customer_name" : customerName
                          });
                        }
                        logger.i("selected customer");
                        logger.i(ref.watch(selectedCustomerProvider.notifier).state.customer);
                        logger.i(customerName);
                        logger.i(onExpand);
                      },
                      title: Row(children: [Text("$customerName ", style: const TextStyle(
                      fontWeight: FontWeight.bold
                    ),), Container(
                      padding: const EdgeInsets.only(left: 3, right: 3, top: 1, bottom: 1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.black
                      ),
                      child:Text(customerVehicles.length.toString(), style: const TextStyle(
                        color: Colors.white
                      ),),)],),
                    children:  customerVehicles.asMap().entries.map((entry) {
                      Vehicle vehicle = entry.value;
                      DateTime? gpsdtWIB;
                      if (vehicle.gpsdt != null) {
                        DateTime gpsdtUtc = DateTime.fromMillisecondsSinceEpoch(vehicle.gpsdt! * 1000, isUtc: true);
                        gpsdtWIB = gpsdtUtc.add(const Duration(hours: 7));
                      }

                      return Slidable(
                        actionPane: const SlidableDrawerActionPane(),
                        actionExtentRatio: 0.3,
                        actions: <Widget>[
                          IconSlideAction(
                            caption: 'Map',
                            color: GlobalColor.mainColor,
                            icon: Icons.map_outlined,
                            onTap: () {
                              // PersistentNavBarNavigator.pushNewScreen(
                              //   context,
                              //   screen: BottomBar(
                              //     lat: vehicle.lat!,
                              //     lon: vehicle.lon!,
                              //   ),
                              //   withNavBar: false,
                              //   pageTransitionAnimation: PageTransitionAnimation.fade,
                              // );
                              // BottomBar.currentIndex = 0;
                              BottomBar.globalSetState?.call(vehicle.lat!, vehicle.lon!,);
                            },
                          ),
                        ],
                        secondaryActions: <Widget>[
                          IconSlideAction(
                            caption: 'Details',
                            color: GlobalColor.mainColor,
                            icon: Icons.book_online,
                            onTap: () {
                              _convertAndNavigateToDetailsPage(vehicle);
                            },
                          ),
                        ],
                        child: Card(
                          clipBehavior: Clip.hardEdge,
                          child: InkWell(
                            splashColor: Colors.grey.withAlpha(30),
                            onTap: () {
                              setState(() {
                                fetchGeocode(vehicle);
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: ListTile(
                                      title: Text(
                                        vehicle.name ?? '',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.circular(4.0),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child: Text(
                                                vehicle.plateNo ?? '',
                                                style: TextStyle(
                                                  color: GlobalColor.textColor,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (_vehicleToAddress.containsKey(vehicle))
                                            Text(
                                              _vehicleToAddress[vehicle]!,
                                              style: TextStyle(
                                                color: GlobalColor.buttonColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                        ],
                                      ),
                                      leading: Column(
                                        children: [
                                          SizedBox(
                                            width: 60,
                                            height: vehicle.type == 4 ? 25 : 56,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: getVehicleColor(vehicle.speed ?? 0, vehicle.gpsdt ?? 0),
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              child: Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      '${vehicle.speed ?? 0}',
                                                      style: TextStyle(
                                                        color: GlobalColor.textColor,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                    if (vehicle.type != 4)
                                                      Align(
                                                        alignment: Alignment.center,
                                                        child: Text(
                                                          'kmh',
                                                          style: TextStyle(
                                                            color: GlobalColor.textColor,
                                                            fontSize: 15,
                                                            fontWeight:FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (vehicle.type == 4)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Container(
                                                width: 60,
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.blue.shade200),
                                                  borderRadius:BorderRadius.circular(5),
                                                ),
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Padding(
                                                    padding:const EdgeInsets.all(4.0),
                                                    child: Text(
                                                      vehicle.baseMcc != null
                                                          ? '${vehicle.baseMcc! / 10}°'
                                                          : '',
                                                      style: const TextStyle(
                                                        color: Colors.blue,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (gpsdtWIB != null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0, top: 2),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            formatDateTime(gpsdtWIB),
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Row(
                                            children: [
                                              ...(vehicle.sensors?.take(2).map((sensor) {
                                                return Padding(
                                                  padding:const EdgeInsets.only(right: 2,bottom: 2),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: getSensorColor(sensor.status),
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    child: Text(
                                                      sensor.name ?? '',
                                                      style: TextStyle(
                                                        color: GlobalColor.textColor,
                                                        fontSize: 8,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList() ??
                                                  []),
                                            ],
                                          ),
                                          if ((vehicle.sensors?.length ?? 0) > 2)
                                            Row(
                                              children: [
                                                ...(vehicle.sensors?.skip(2).take(2).map((sensor) {
                                                  return Padding(
                                                    padding: const EdgeInsets.only(right: 2, top: 3, bottom: 3),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration:BoxDecoration(
                                                        color: getSensorColor(sensor.status),
                                                        borderRadius: BorderRadius.circular(5),
                                                      ),
                                                      child: Text(
                                                        sensor.name ?? '',
                                                        style: TextStyle(
                                                          color: GlobalColor.textColor,
                                                          fontSize: 8,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList() ??
                                                    []),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Text(
                    //     customerName,
                    //     style: const TextStyle(
                    //       fontWeight: FontWeight.bold,
                    //       fontSize: 16,
                    //     ),
                    //   ),
                    // ),
                    // Column(
                    //   children: customerVehicles.asMap().entries.map((entry) {
                    //     Vehicle vehicle = entry.value;
                    //     DateTime? gpsdtWIB;
                    //     if (vehicle.gpsdt != null) {
                    //       DateTime gpsdtUtc = DateTime.fromMillisecondsSinceEpoch(vehicle.gpsdt! * 1000, isUtc: true);
                    //       gpsdtWIB = gpsdtUtc.add(const Duration(hours: 7));
                    //     }
                    //
                    //     return Slidable(
                    //       actionPane: const SlidableDrawerActionPane(),
                    //       actionExtentRatio: 0.3,
                    //       actions: <Widget>[
                    //         IconSlideAction(
                    //           caption: 'Map',
                    //           color: GlobalColor.mainColor,
                    //           icon: Icons.map_outlined,
                    //           onTap: () {
                    //             // PersistentNavBarNavigator.pushNewScreen(
                    //             //   context,
                    //             //   screen: BottomBar(
                    //             //     lat: vehicle.lat!,
                    //             //     lon: vehicle.lon!,
                    //             //   ),
                    //             //   withNavBar: false,
                    //             //   pageTransitionAnimation: PageTransitionAnimation.fade,
                    //             // );
                    //             // BottomBar.currentIndex = 0;
                    //             BottomBar.globalSetState?.call(vehicle.lat!, vehicle.lon!,);
                    //           },
                    //         ),
                    //       ],
                    //       secondaryActions: <Widget>[
                    //         IconSlideAction(
                    //           caption: 'Details',
                    //           color: GlobalColor.mainColor,
                    //           icon: Icons.book_online,
                    //           onTap: () {
                    //             _convertAndNavigateToDetailsPage(vehicle);
                    //           },
                    //         ),
                    //       ],
                    //       child: Card(
                    //         clipBehavior: Clip.hardEdge,
                    //         child: InkWell(
                    //           splashColor: Colors.grey.withAlpha(30),
                    //           onTap: () {
                    //             setState(() {
                    //               fetchGeocode(vehicle);
                    //             });
                    //           },
                    //           child: Padding(
                    //             padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    //             child: Row(
                    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //               children: [
                    //                 Expanded(
                    //                   child: ListTile(
                    //                     title: Text(
                    //                       vehicle.name ?? '',
                    //                       style: const TextStyle(fontSize: 12),
                    //                     ),
                    //                     subtitle: Column(
                    //                       crossAxisAlignment: CrossAxisAlignment.start,
                    //                       children: [
                    //                         Container(
                    //                           decoration: BoxDecoration(
                    //                             color: Colors.black,
                    //                             borderRadius: BorderRadius.circular(4.0),
                    //                           ),
                    //                           child: Padding(
                    //                             padding: const EdgeInsets.all(4.0),
                    //                             child: Text(
                    //                               vehicle.plateNo ?? '',
                    //                               style: TextStyle(
                    //                                 color: GlobalColor.textColor,
                    //                                 fontSize: 10,
                    //                               ),
                    //                             ),
                    //                           ),
                    //                         ),
                    //                         if (_vehicleToAddress.containsKey(vehicle))
                    //                           Text(
                    //                             _vehicleToAddress[vehicle]!,
                    //                             style: TextStyle(
                    //                               color: GlobalColor.buttonColor,
                    //                               fontSize: 12,
                    //                             ),
                    //                           ),
                    //                       ],
                    //                     ),
                    //                     leading: Column(
                    //                       children: [
                    //                         SizedBox(
                    //                           width: 60,
                    //                           height: vehicle.type == 4 ? 25 : 56,
                    //                           child: DecoratedBox(
                    //                             decoration: BoxDecoration(
                    //                               color: getVehicleColor(vehicle.speed ?? 0, vehicle.gpsdt ?? 0),
                    //                               borderRadius: BorderRadius.circular(5),
                    //                             ),
                    //                             child: Center(
                    //                               child: Column(
                    //                                 mainAxisAlignment: MainAxisAlignment.center,
                    //                                 children: [
                    //                                   Text(
                    //                                     '${vehicle.speed ?? 0}',
                    //                                     style: TextStyle(
                    //                                       color: GlobalColor.textColor,
                    //                                       fontWeight: FontWeight.bold,
                    //                                       fontSize: 15,
                    //                                     ),
                    //                                   ),
                    //                                   if (vehicle.type != 4)
                    //                                     Align(
                    //                                       alignment: Alignment.center,
                    //                                       child: Text(
                    //                                         'kmh',
                    //                                         style: TextStyle(
                    //                                           color: GlobalColor.textColor,
                    //                                           fontSize: 15,
                    //                                           fontWeight:FontWeight.bold,
                    //                                         ),
                    //                                       ),
                    //                                     ),
                    //                                 ],
                    //                               ),
                    //                             ),
                    //                           ),
                    //                         ),
                    //                         if (vehicle.type == 4)
                    //                           Padding(
                    //                             padding: const EdgeInsets.only(top: 4),
                    //                             child: Container(
                    //                               width: 60,
                    //                               decoration: BoxDecoration(
                    //                                 border: Border.all(color: Colors.blue.shade200),
                    //                                 borderRadius:BorderRadius.circular(5),
                    //                               ),
                    //                               child: Align(
                    //                                 alignment: Alignment.center,
                    //                                 child: Padding(
                    //                                   padding:const EdgeInsets.all(4.0),
                    //                                   child: Text(
                    //                                     vehicle.baseMcc != null
                    //                                         ? '${vehicle.baseMcc! / 10}°'
                    //                                         : '',
                    //                                     style: const TextStyle(
                    //                                       color: Colors.blue,
                    //                                       fontSize: 12,
                    //                                       fontWeight: FontWeight.bold,
                    //                                     ),
                    //                                   ),
                    //                                 ),
                    //                               ),
                    //                             ),
                    //                           ),
                    //                       ],
                    //                     ),
                    //                   ),
                    //                 ),
                    //                 if (gpsdtWIB != null)
                    //                   Padding(
                    //                     padding: const EdgeInsets.only(right: 8.0, top: 2),
                    //                     child: Column(
                    //                       crossAxisAlignment: CrossAxisAlignment.end,
                    //                       children: [
                    //                         Text(
                    //                           formatDateTime(gpsdtWIB),
                    //                           style: const TextStyle(
                    //                             color: Colors.blue,
                    //                             fontSize: 12,
                    //                             fontWeight: FontWeight.bold,
                    //                           ),
                    //                         ),
                    //                         const SizedBox(height: 3),
                    //                         Row(
                    //                           children: [
                    //                             ...(vehicle.sensors?.take(2).map((sensor) {
                    //                                   return Padding(
                    //                                     padding:const EdgeInsets.only(right: 2,bottom: 2),
                    //                                     child: Container(
                    //                                       padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                    //                                       decoration: BoxDecoration(
                    //                                         color: getSensorColor(sensor.status),
                    //                                         borderRadius: BorderRadius.circular(5),
                    //                                       ),
                    //                                       child: Text(
                    //                                         sensor.name ?? '',
                    //                                         style: TextStyle(
                    //                                           color: GlobalColor.textColor,
                    //                                           fontSize: 8,
                    //                                           fontWeight: FontWeight.bold,
                    //                                         ),
                    //                                       ),
                    //                                     ),
                    //                                   );
                    //                                 }).toList() ??
                    //                                 []),
                    //                           ],
                    //                         ),
                    //                         if ((vehicle.sensors?.length ?? 0) > 2)
                    //                           Row(
                    //                             children: [
                    //                               ...(vehicle.sensors?.skip(2).take(2).map((sensor) {
                    //                                     return Padding(
                    //                                       padding: const EdgeInsets.only(right: 2, top: 3, bottom: 3),
                    //                                       child: Container(
                    //                                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    //                                         decoration:BoxDecoration(
                    //                                           color: getSensorColor(sensor.status),
                    //                                           borderRadius: BorderRadius.circular(5),
                    //                                         ),
                    //                                         child: Text(
                    //                                           sensor.name ?? '',
                    //                                           style: TextStyle(
                    //                                             color: GlobalColor.textColor,
                    //                                             fontSize: 8,
                    //                                             fontWeight: FontWeight.bold,
                    //                                           ),
                    //                                         ),
                    //                                       ),
                    //                                     );
                    //                                   }).toList() ??
                    //                                   []),
                    //                             ],
                    //                           ),
                    //                       ],
                    //                     ),
                    //                   ),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     );
                    //   }).toList(),
                    // ),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
    );
  }
}
