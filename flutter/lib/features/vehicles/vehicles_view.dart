import 'dart:convert';

import 'package:VehiLoc/core/utils/loading_widget.dart';
import 'package:VehiLoc/features/map/widget/bottom_bar.dart';
import 'package:VehiLoc/features/vehicles/models/vehicle_models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  late List _allCustomer;
  final List _vehicleLoading = [];
  final List <Map<int,List<Widget>>> _vehicleWidgets = [];
  bool _isLoading = false;
  final Map<Vehicle, String> _vehicleToAddress = {};

  final List<Map<int, ExpansionTileController>> _customerController = [];

  // void realtimeHandler(Vehicle vehicle) {
  //   for (var current in _allVehicles) {
  //     if (current.vehicleId == vehicle.vehicleId) {
  //       setState(() {
  //         current.merge(vehicle);
  //         // logger.i('WebSocket message vehicle: ${current.customerName} ${current.name}');
  //       });
  //       break;
  //     }
  //   }
  // }

  @override
  void initState() {
    super.initState();
    // _filteredVehicles = [];
    // _allVehicles = [];
    // _groupedVehicles = {};
    _fetchData();


    //WebSocketProvider.subscribe(realtimeHandler);
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


    final List customer = await apiService.fetchCustomers();
    if (mounted) {
      setState(() {
        _allCustomer = customer;

        if(_vehicleLoading.isEmpty){
          for(int i = 0; i< _allCustomer.length; i++){
            _vehicleLoading.add({i:false});
            _vehicleWidgets.add({i:[]});
            _customerController.add({i : ExpansionTileController()});
          }
        }


        // _filteredVehicles = vehicles;
        // _groupVehicles(vehicles);
        _isLoading = false;
      });

      WidgetsBinding.instance
          .addPostFrameCallback((_){
            _allCustomer.asMap().forEach((key, value) {
              logger.i("key value");
              if(value["vehicles_count"] <= 6){
                _customerController[key][key]?.expand();
                apiService.fetchCustomerVehicles(value["id"]).then((value){
                  onExpansionChanged(value);
                });

              }
              //logger.i(_allCustomer);
              logger.i(key);
              logger.i(value);
            });

      });
    }
    //WebSocketProvider.subscribe(realtimeHandler);
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

  // void _filterVehicles(String query) {
  //   setState(() {
  //     _filteredVehicles = _allVehicles.where((vehicle) {
  //       final nameLower = vehicle.name?.toLowerCase() ?? '';
  //       final plateNoLower = vehicle.plateNo?.toLowerCase() ?? '';
  //       final customerNameLower = vehicle.customerName?.toLowerCase() ?? "";
  //       final searchLower = query.toLowerCase();
  //       return nameLower.contains(searchLower) || plateNoLower.contains(searchLower) || customerNameLower.contains(searchLower);
  //     }).toList();
  //     _groupVehicles(_filteredVehicles);
  //   });
  // }

  void onSearch(String query){

    Future.delayed(const Duration(milliseconds: 500)).then((value) async {
      logger.i(query);

      _allCustomer.clear();
      _vehicleLoading.clear();
      _vehicleWidgets.clear();
      _customerController.clear();
      if(query.trim() == ""){
        _fetchData();
      }else{
        setState(() {
          _isLoading = true;
        });

        if (mounted) {
          List searchData = await apiService.searchVehicle(query);

            for(var c in searchData){
              _allCustomer.add({
                "id": c["id"],
                "name" : c["name"],
                "salt" : c["salt"],
                "vehicles_count" : c["vehicles"].length
              });
            }



            if(_vehicleLoading.isEmpty){
              for(int s =0; s < searchData.length; s++){
                List<Widget> vehicleWidgets = await onExpansionChanged(searchData[s]["vehicles"]
                    .map((vehicleJson) => Vehicle.fromJson(vehicleJson))
                    .cast<Vehicle>()
                    .toList());

                _vehicleWidgets.add({s: vehicleWidgets});
              }
              for(int i =0; i < _allCustomer.length; i++){
                _vehicleLoading.add({i:false});

                _customerController.add({i : ExpansionTileController()});
              }
            }

          setState(() {

            // _filteredVehicles = vehicles;
            // _groupVehicles(vehicles);
            _isLoading = false;
          });

          WidgetsBinding.instance
              .addPostFrameCallback((_){
            _allCustomer.asMap().forEach((key, value) {
              logger.i("key value");
              if(value["vehicles_count"] <= 6){
                _customerController[key][key]?.expand();

              }
              //logger.i(_allCustomer);
              logger.i(key);
              logger.i(value);
            });

          });
        }


        setState(() {
          _isLoading = false;
        });
      }

    });

    logger.i("search result");
    logger.i(_allCustomer.length);
    logger.i(_vehicleLoading);
    logger.i(_customerController);

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

  Future<List<Widget>> onExpansionChanged(List<Vehicle> vehicles) async {
    List<Widget> vehiclesWidget = [];

    List<Vehicle> value = vehicles;
      for(Vehicle v in value){
        Vehicle vehicle = v;
        DateTime? gpsdtWIB;
        if (vehicle.gpsdt != null) {
          DateTime gpsdtUtc = DateTime.fromMillisecondsSinceEpoch(vehicle.gpsdt! * 1000, isUtc: true);
          gpsdtWIB = gpsdtUtc.add(const Duration(hours: 7));
        }

        vehiclesWidget.add(
          ExpansionTile(
            onExpansionChanged: (isExpand){
              if(isExpand){
                setState(() {
                  fetchGeocode(vehicle);
                });
              }
            },

            title:InkWell(
              splashColor: Colors.grey.withAlpha(30),
              // onTap: () {
              //
              // },

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
                                      color: getSensorColor(sensor.bgColor?.toLowerCase()),
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
                                        color: getSensorColor(sensor.bgColor?.toLowerCase()),
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
            children: [
              Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    SizedBox(
                      width: (MediaQuery.of(context).size.width / 3) -10,
                      child: ElevatedButton(
                          style:ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(GlobalColor.mainColor),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                      side: BorderSide(color: Colors.white)
                                  )
                              )
                          ),
                          onPressed: (){
                            BottomBar.globalSetState?.call(vehicle.lat!, vehicle.lon!,);
                          }, child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(FontAwesomeIcons.magnifyingGlassLocation, color: Colors.white,),
                            Text(" Map", style: TextStyle(color: Colors.white),)
                          ]
                      )),
                    ),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width / 3) -10,
                      child: ElevatedButton(
                          style:ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(GlobalColor.mainColor),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                      side: BorderSide(color: Colors.white)
                                  )
                              )
                          ),
                          onPressed: (){
                            _convertAndNavigateToDetailsPage(vehicle);
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.clockRotateLeft, color: Colors.white,),
                              Text(" History", style: TextStyle(color: Colors.white),)
                            ],
                          )),

                    ),

                    SizedBox(
                      width: (MediaQuery.of(context).size.width / 3) -10,
                      child: ElevatedButton(
                          style:ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(GlobalColor.mainColor),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                      side: BorderSide(color: Colors.white)
                                  )
                              )
                          ),
                          onPressed: (){
                            apiService.sharedLinks(page: 1, perPage: 10, customerId: 2);
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.share, color: Colors.white,),
                              Text(" Share", style: TextStyle(color: Colors.white),)
                            ],
                          )),

                    ),


                  ],
                ),
              )

            ],


          )
        );
      }







    return vehiclesWidget;
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
            onChanged: onSearch,
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
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _allCustomer.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {


                if (_isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                // String customerName = _groupedVehicles.keys.elementAt(index);
                // List<Vehicle> customerVehicles = _groupedVehicles[customerName]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExpansionTile(
                      controller: _customerController[index][index],
                      //initiallyExpanded: _allCustomer[index]["vehicles_count"] <= 6 ? true : false,
                      onExpansionChanged: (onExpand) async {
                        logger.i("expanded");
                        logger.i(onExpand);
                        logger.i(index);
                        try{
                        if(_vehicleWidgets[index][index]!.isEmpty){
                          setState(() {
                            _vehicleLoading[index][index] = true;
                          });
                          await apiService.fetchCustomerVehicles(_allCustomer[index]["id"]).then((vehicles) async {
                            await apiService.fetchGeofencesPerCustomer(_allCustomer[index]["id"]).then((geofences){
                              onExpansionChanged(vehicles).then((v){
                                _allCustomer[index]["vehicles"] = vehicles;
                                _allCustomer[index]["geofences"] = geofences;
                                logger.i("done");
                                _vehicleLoading[index][index] = false;
                                _vehicleWidgets[index][index] = v;
                                setState(() {
                                });

                              });
                            });
                          });

                        }
                        }catch(e){
                          logger.e("error ");
                          logger.e(e);
                        }

                        logger.d("selected vehicle data");

                        logger.i(_vehicleLoading);

                        //logger.i(_groupedVehicles.keys.elementAt(index));
                        if(onExpand) {
                          //_allCustomer[index]["vehicles"] = await apiService.fetchCustomerVehicles(_allCustomer[index]["id"]);
                          ref.read(selectedCustomerProvider.notifier).update((state) {
                            return [...state, _allCustomer[index]];
                          });
                        } else {
                          ref.read(selectedCustomerProvider.notifier).update((state) {
                            return state.where((element) => element["id"] != _allCustomer[index]["id"]).toList();
                          });
                        }
                      },
                      title: Row(children: [
                        Text("${_allCustomer[index]["name"]} ", style: const TextStyle(
                            fontWeight: FontWeight.bold),),
                        Container(
                      padding: const EdgeInsets.only(left: 3, right: 3, top: 1, bottom: 1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.black
                      ),
                      child:Text("${_allCustomer[index]["vehicles_count"]} ", style: const TextStyle(
                        color: Colors.white
                      ),),)],),
                      
                      children: _vehicleLoading[index][index] ? [const CircularProgressIndicator()]:_vehicleWidgets[index][index]!

                    ),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
    );
  }
}
