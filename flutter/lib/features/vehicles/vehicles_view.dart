


import 'dart:async';
import 'dart:convert';

import 'package:VehiLoc/core/utils/loading_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:VehiLoc/core/utils/user_provider.dart';
import 'package:VehiLoc/features/map/widget/bottom_bar.dart';
import 'package:VehiLoc/features/vehicles/models/vehicle_models.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:VehiLoc/core/model/response_vehicles.dart';
import 'package:VehiLoc/core/utils/colors.dart';
import 'package:VehiLoc/core/utils/vehicle_func.dart';

import 'package:VehiLoc/core/Api/api_service.dart';
import 'package:VehiLoc/features/vehicles/details_view.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import 'package:VehiLoc/core/utils/logger.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/global_func.dart';

class VehicleView extends ConsumerStatefulWidget {
  const VehicleView({Key? key}) : super(key: key);

  @override
  _VehicleViewState createState() => _VehicleViewState();
}

class _VehicleViewState extends ConsumerState<VehicleView> with AutomaticKeepAliveClientMixin<VehicleView>{
  @override
  bool get wantKeepAlive => true;
  final ApiService apiService = ApiService();
  List? _allCustomer;
  final List _vehicleLoading = [];
  final List <Map<int,List<Widget>>> _vehicleWidgets = [];
  bool _isLoading = false;
  //final Map<Vehicle, String> _vehicleToAddress = {};

  final List<Map<int, ExpansionTileController>> _customerController = [];
  final sharePreference = SpData();
  TextEditingController searchController = TextEditingController();
  RefreshController refreshController = RefreshController();

  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  bool initialConnecting = false;
  bool canPrint = false;
  Timer? timer;
  int state = 0;

  Map userModels = {};

  BluetoothDevice? _selectedDevice;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    connectToPrinter().then((value){
      _fetchData();
    });
    
    // _filteredVehicles = [];
    // _allVehicles = [];
    // _groupedVehicles = {};

    


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

  Future<LineText> createPrintTemplate(Map data) async {
    //LineText(type: LineText.TYPE_TEXT, height: 1, width: 1, align: LineText.ALIGN_CENTER, linefeed: 1, content: vehicle.plateNo);
    LineText lineText = LineText(
      type: data["type"] == "image" ? LineText.TYPE_IMAGE : LineText.TYPE_TEXT,
      height: data["type"] == "image" ? data["height"]:data["font_size"],
      width: data["type"] == "image" ? data["width"] :data["font_size"],
      align: data["alignment"] == "center" ?
      LineText.ALIGN_CENTER : data["alignment"] == "left" ? LineText.ALIGN_LEFT
          : LineText.ALIGN_RIGHT,
      content: data["type"] == "image" ?
      await networkImageToBase64(Uri.parse(data["data"]))
          : data["data"],
      linefeed: 1
    );

    // list.add(LineText(type: LineText.TYPE_TEXT, height: 0, width: 0, align: LineText.ALIGN_CENTER, linefeed: 1, content: ""));

    return lineText;
  }


  Future<String> _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? '';
  }

  Future connectToPrinter() async {

    sharePreference.loadPrinter().then((String? printerAddress) async {
      logger.i('$printerAddress - from cache');
      if (printerAddress != null ) {
        canPrint = true;
        initBluetooth();
        setState(() {
          initialConnecting = true;
        });
        //logger.d('get printer from local storage', printerAddress);
        _selectedDevice = BluetoothDevice();
        _selectedDevice!.address = printerAddress;
        timer = Timer(const Duration(seconds: 5), () {
          setState(() {
            initialConnecting = false;
          });
          bluetoothPrint.connect(_selectedDevice!);
        });
      } else {
        canPrint = false;
        logger.d('no device');
      }
    });
  }

  initBluetooth() async {
    bluetoothPrint.state.listen((state) {
      logger.i('******************* cur device status: $state');
      logger.i(BluetoothPrint.CONNECTED);
      if(state == 0){
        setState(() {
          canPrint = false;
        });
      }

      if(state == 1){
        setState(() {
          canPrint = true;
        });
      }

      // if(BluetoothPrint.CONNECTED == 1){
      //   setState(() {
      //     canPrint = true;
      //   });
      // }else if(BluetoothPrint.CONNECTED == 0){
      //   setState(() {
      //     canPrint = true;
      //   });
      // }
      switch (state) {
        case BluetoothPrint.CONNECTED:
          if (mounted) {
            setState(() {
              canPrint = true;
              logger.i("connected to printer");
            });
          }
          break;
        case BluetoothPrint.DISCONNECTED:
          if (mounted) {
            setState(() {
              canPrint = false;
              logger.i('not connected to printer');
            });
          }
          break;
        default:
          break;
      }
    });
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

  Future<String> fetchGeocode(Vehicle vehicle) async {
    String address = "";
    if (vehicle.lat != null && vehicle.lon != null) {
      final double? lat = vehicle.lat;
      final double? lon = vehicle.lon;
      try {
        address = await apiService.fetchAddress(lat!, lon!);
        // setState(() {
        //   _vehicleToAddress[vehicle] = address;
        // });
      } catch (e) {
        logger.e("error : $e");
      }
    }
    return address;
  }

  void _onRefresh() async {
    // monitor network fetch


      connectToPrinter().then((value){
        if(searchController.text.isNotEmpty){
          onSearch(searchController.text.trim());
        }else{
          _fetchData();
        }
      });



    refreshController.refreshCompleted();


  }

  void _onLoading() async {
    refreshController.loadComplete();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    ref.read(selectedCustomerProvider.notifier).state.clear();
    _vehicleLoading.clear();
    _vehicleWidgets.clear();
    _customerController.clear();


    final List customer = await apiService.fetchCustomers();
    if (mounted) {
      setState(() {
        _allCustomer = customer;

        if(_vehicleLoading.isEmpty){
          for(int i = 0; i< _allCustomer!.length; i++){
            _vehicleLoading.add({i:false});
            _vehicleWidgets.add({i:[]});
            _customerController.add({i : ExpansionTileController()});
          }
        }


        // _filteredVehicles = vehicles;
        // _groupVehicles(vehicles);
        _isLoading = false;
      });

      // WidgetsBinding.instance
      //     .addPostFrameCallback((_){
      //       _allCustomer!.asMap().forEach((key, value) {
      //         // logger.i("key value");
      //         // if(_allCustomer!.length <=  6){
      //         //   _customerController[key][key]?.expand();
      //         //   apiService.fetchCustomerVehicles(value["id"]).then((value){
      //         //     onExpansionChanged(value);
      //         //   });
      //         //
      //         // }
      //         // //logger.i(_allCustomer);
      //         // logger.i(key);
      //         // logger.i(value);
      //         ref.read(selectedCustomerProvider.notifier).update((state) {
      //           return [...state, _allCustomer![key]];
      //         });
      //       });
      //
      //
      //
      //
      // });
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


  void initiateRequest(String value) {
    if (state > 100) state = 0;
    state++;
    int localState = state;

    logger.d("states");
    logger.i(state);
    Future.delayed(const Duration(milliseconds: 500)).then((_) {
      if (localState != state) {
        return;
      }
     onSearch(value);
    });
  }

  Future<void> onSearch(String query) async {


        logger.i(query);
        ref.read(selectedCustomerProvider.notifier).state.clear();

        _allCustomer!.clear();
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
              List<Vehicle> vehicles = c["vehicles"].map((vehicleJson) => Vehicle.fromJson(vehicleJson))
                  .cast<Vehicle>()
                  .toList();
              _allCustomer!.add({
                "id": c["id"],
                "name" : c["name"],
                "salt" : c["salt"],
                "vehicles_count" : c["vehicles"].length,
                "vehicles" : vehicles,
              });
            }



            if(_vehicleLoading.isEmpty){
              for(int s =0; s < searchData.length; s++){
                List<Widget> vehicleWidgets = await onExpansionChanged(searchData[s]["vehicles"]
                    .map((vehicleJson) => Vehicle.fromJson(vehicleJson))
                    .cast<Vehicle>()
                    .toList(), true);

                _vehicleWidgets.add({s: vehicleWidgets});
              }
              for(int i =0; i < _allCustomer!.length; i++){
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
              // logger.i("allCustomerLength");
              // logger.i(_allCustomer?.length);

              if(_allCustomer!.length <= 2){
                for(int i =0; i < _allCustomer!.length; i++){
                  if(_allCustomer![i]["vehicles_count"] <= 6 && _allCustomer![i]["vehicles_count"] != null && _allCustomer![i]["vehicles_count"] != 0){
                    _customerController[i][i]?.expand();
                  }
                }
              }
            });
          }


          setState(() {
            _isLoading = false;
          });
        }






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

  Future<List<Widget>> onExpansionChanged(List<Vehicle> vehicles, bool expanded) async {
    List<Widget> vehiclesWidget = [];

    List<ExpansionTileController> expansionTileControllers = [];

      for(int i = 0; i < vehicles.length;i++){
        Vehicle vehicle = vehicles[i];
        DateTime? gpsdtWIB;

        expansionTileControllers.add(ExpansionTileController());



        if (vehicle.gpsdt != null) {
          DateTime gpsdtUtc = DateTime.fromMillisecondsSinceEpoch(vehicle.gpsdt! * 1000, isUtc: true);
          gpsdtWIB = gpsdtUtc.add(const Duration(hours: 7));
        }

        vehiclesWidget.add(
          ExpansionTile(
            controller: expansionTileControllers[i],
              onExpansionChanged: (isExpand){
                // if(isExpand){
                //   setState(() {
                //     fetchGeocode(vehicle);
                //   });
                // }
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
                      child: GestureDetector(
                          onTap: () async {
                            await fetchGeocode(vehicle).then((address){
                              showDialog(context: context, builder: (BuildContext context){
                                return AlertDialog(
                                  title: Text(
                                    vehicle.name.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  content: Text(
                                    address.toString()
                                  ),
                                );
                              });
                            });
                          },
                          child: ListTile(
                            title: Text(
                              vehicle.name ?? '',
                              style: const TextStyle(fontSize: 14),
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
                                // if (_vehicleToAddress.containsKey(vehicle))
                                //   Text(
                                //     _vehicleToAddress[vehicle]!,
                                //     style: TextStyle(
                                //       color: GlobalColor.buttonColor,
                                //       fontSize: 12,
                                //     ),
                                //   ),
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
                          )
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
                        width: userModels["roles"]["can_last_update_print"] ? (MediaQuery.of(context).size.width / 3) :  (MediaQuery.of(context).size.width / 2) - 10,
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
                              FaIcon(FontAwesomeIcons.magnifyingGlassLocation, color: Colors.white, size: 16,),
                              Text(" Map", style: TextStyle(color: Colors.white),)
                            ]
                        )),
                      ),
                      SizedBox(
                        width: userModels["roles"]["can_last_update_print"] ? (MediaQuery.of(context).size.width / 3) :  (MediaQuery.of(context).size.width / 2) - 10,
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
                                FaIcon(FontAwesomeIcons.info, color: Colors.white, size: 16,),
                                Text(" Details", style: TextStyle(color: Colors.white),)
                              ],
                            )),

                      ),
                      userModels["roles"]["can_last_update_print"] ?
                      SizedBox(
                        width: (MediaQuery.of(context).size.width / 3) - 20,
                        child:
                        ElevatedButton(
                            style:ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(canPrint ?GlobalColor.mainColor : Colors.grey),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                        side: BorderSide(color: Colors.white)
                                    )
                                )
                            ),
                            onPressed:
                            //                         (){
    //                           setState(() {
    //                             canPrint = !canPrint;
    //                           });
    //                           logger.i("setstafsghjuags");
    // },
                            canPrint ? () async {
                              // BuildContext? c;
                              circularLoading(context);
                              try{
                              await apiService.fetchPrintData(vehicle.vehicleId!, DateTime.now().timeZoneOffset.inHours).then((value) async {
                                Map printData = jsonDecode(value);
                                List<LineText> list = [];
                                Map<String, dynamic> config = Map();
                                if(printData["status"] == "SUCCESS"){
                                  Navigator.of(context, rootNavigator: true).pop();
                                  for(var i in printData["result"]){
                                    list.add(await createPrintTemplate(i));
                                  }
                                  logger.d("list data");
                                  logger.i(list);
                                  logger.i(list.length);
                                  //list.add(LineText(type: LineText.TYPE_TEXT, height: 0, width: 0, align: LineText.ALIGN_CENTER, linefeed: 1, content: ""));
                                  await bluetoothPrint.printReceipt(config, list);
                                }else if(printData["status"] == "FAILED"){
                                  Navigator.of(context, rootNavigator: true).pop();
                                 showDialog(context: context, builder: (BuildContext ct){
                                   return AlertDialog(
                                     content: Text(printData["result"]),
                                     actions: [
                                       TextButton(onPressed: (){
                                         Navigator.of(ct, rootNavigator: true).pop();
                                       }, child: const Text("Ok"))
                                     ],
                                   );
                                 });
                                }
                                logger.i(value);

                              });
                              }catch(e,t){
                                Navigator.of(context, rootNavigator: true).pop();
                                logger.w(t);
                                logger.e(e);
                                // showDialog(context: context, builder: (BuildContext ct){
                                //   return AlertDialog(
                                //     content: Text(e.toString()),
                                //     actions: [
                                //       TextButton(onPressed: (){
                                //         Navigator.of(ct, rootNavigator: true).pop();
                                //       }, child: const Text("Ok"))
                                //     ],
                                //   );
                                // });
                              }


                              // Navigator.of(c).pop();

                              //
                              // logger.i(canPrint);
                              // logger.d("user provider");
                              // logger.d(ref.watch(userProvider.notifier).state);
                              // List<LineText> list = [];
                              // String gpsDate = DateFormat("dd MMMM yyyy", "id").format(DateTime.fromMillisecondsSinceEpoch(vehicle.gpsdt! * 1000));
                              // String gpsTime = DateFormat("HH:mm", "id").format(DateTime.fromMillisecondsSinceEpoch(vehicle.gpsdt! * 1000));
                              // String dateNow = DateFormat("dd MMMM yyyy", "id").format(DateTime.now());
                              // String timeNow = DateFormat("HH:mm:ss", "id").format(DateTime.now());
                              //
                              // String username = await _getUsername();
                              // Map<String, dynamic> config = Map();
                              //
                              // // list.add(LineText(type: LineText.TYPE_IMAGE,
                              // //     content: await imageAssetToBase64("assets/logo/vehiloc-logo.png"),
                              // //   align: LineText.ALIGN_CENTER,
                              // //   height: 200,
                              // //   width: 400,
                              // // ));
                              // list.add(LineText(type: LineText.TYPE_TEXT, height: 1, width: 1, align: LineText.ALIGN_CENTER, linefeed: 1, content: vehicle.plateNo));
                              // list.add(LineText(type: LineText.TYPE_TEXT, height: 1, width: 1, align: LineText.ALIGN_CENTER, linefeed: 1, content: vehicle.customerName));
                              // list.add(LineText(type: LineText.TYPE_TEXT, height: 0, width: 0, align: LineText.ALIGN_LEFT, linefeed: 1, content: "Last Update : $gpsDate"));
                              // list.add(LineText(type: LineText.TYPE_TEXT, height: 0, width: 0, align: LineText.ALIGN_RIGHT, linefeed: 1, content: "$gpsTime  "));
                              // list.add(LineText(type: LineText.TYPE_TEXT, height: 0, width: 0, align: LineText.ALIGN_LEFT, linefeed: 1, content: "Dicetak : $dateNow"));
                              // list.add(LineText(type: LineText.TYPE_TEXT, height: 0, width: 0, align: LineText.ALIGN_RIGHT, linefeed: 1, content: "$timeNow  "));
                              // list.add(LineText(type: LineText.TYPE_TEXT, height: 0, width: 0, align: LineText.ALIGN_LEFT, linefeed: 1, content: "Username : $username"));
                              //
                              // try{
                              // await bluetoothPrint.printReceipt(config, list);
                              // }catch(e){
                              //   logger.e(e);
                              // }
                            } : null,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                FaIcon(FontAwesomeIcons.print, color: Colors.white, size: 16,),
                                Text(" Print", style: TextStyle(color: Colors.white),)
                              ],
                            )),

                      ) : const SizedBox(),





                    ],
                  ),
                )

              ],


            ),


        );
        // WidgetsBinding.instance
        //     .addPostFrameCallback((_){
        //   // logger.i("allCustomerLength");
        //   // logger.i(_allCustomer?.length);
        //
        //   if(expanded){
        //     try{
        //       setState(() {
        //         expansionTileControllers[i].expand();
        //       });
        //
        //
        //     }catch(e){
        //       logger.e(e);
        //     }
        //     // for(var i in expansionTileControllers){
        //     //   i.expand();
        //     // }
        //     logger.i("expand vehilce");
        //   }
        // });
      }

    return vehiclesWidget;
  }

  @override
  Widget build(BuildContext context) {

    userModels = ref.watch(userProvider.notifier).state;



    super.build(context);
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: TextField(
            controller: searchController,
            onEditingComplete: (){
              FocusManager.instance.primaryFocus?.unfocus();
             // onSearch(searchController.text.trim());
            },
            onChanged: (value){

      if(searchController.text.trim().length >= 4){
        initiateRequest(searchController.text.trim());
      }else if(searchController.text.trim().isEmpty){
        initiateRequest(searchController.text.trim());
      }


            },
            style: TextStyle(color: GlobalColor.textColor),
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: TextStyle(color: GlobalColor.textColor),
              border: InputBorder.none,
            ),
          ),
          actions: [
            IconButton(onPressed: (){
              FocusManager.instance.primaryFocus?.unfocus();
              onSearch(searchController.text.trim());
            }, icon: const Icon(Icons.search), color: Colors.white,),
            IconButton(onPressed: (){
              FocusManager.instance.primaryFocus?.unfocus();
              searchController.clear();
              onSearch(searchController.text.trim());
            }, icon: const Icon(Icons.cancel), color: Colors.white,)
          ],
          backgroundColor: GlobalColor.mainColor,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    List<Widget> customerWidgets = [];


    if(!_isLoading){
      _allCustomer!.asMap().forEach((index, value) {
        customerWidgets.add( ExpansionTile(
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
                  await apiService.fetchCustomerVehicles(_allCustomer![index]["id"]).then((vehicles) async {
                    await apiService.fetchGeofencesPerCustomer(_allCustomer![index]["id"]).then((geofences){
                      onExpansionChanged(vehicles, false).then((v){
                        _allCustomer![index]["vehicles"] = vehicles;
                        _allCustomer![index]["geofences"] = geofences;
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
                logger.i("on expand");
                //_allCustomer[index]["vehicles"] = await apiService.fetchCustomerVehicles(_allCustomer[index]["id"]);

                ref.read(selectedCustomerProvider.notifier).update((state) {
                  return [...state, _allCustomer![index]];
                });
              } else {
                ref.read(selectedCustomerProvider.notifier).update((state) {
                  return state.where((element) => element["id"] != _allCustomer![index]["id"]).toList();
                });
              }
            },
            title: Row(children: [
              Text("${_allCustomer![index]["name"]} ", style: const TextStyle(
                  fontWeight: FontWeight.bold),),
              searchController.text.trim().isNotEmpty && _allCustomer![index]["vehicles"] != null && _allCustomer![index]["vehicles"].length == 0 ? const SizedBox():
              Container(
                padding: const EdgeInsets.only(left: 3, right: 3, top: 1, bottom: 1),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.black
                ),
                child:Text("${_allCustomer![index]["vehicles_count"] == 0 ?
                _allCustomer![index]["vehicles"].length : _allCustomer![index]["vehicles_count"]}", style: const TextStyle(
                    color: Colors.white
                ),),)],),

            children: _vehicleLoading[index][index] ? [const CircularProgressIndicator()]:_vehicleWidgets[index][index]!

        ),);
      });
    }



    return SmartRefresher(
    enablePullDown: true,
      enablePullUp: false,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      controller: refreshController,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allCustomer!.isEmpty
          ? const Center(
        child: Text(
          "Tidak ada data",
          style: TextStyle(
            fontSize: 16
          ),
        ),
      )
          :
          SingleChildScrollView(
            child:
            Column(
              children: customerWidgets,
            ),
          )
      // ListView.builder(
      //         itemCount: _allCustomer.length + (_isLoading ? 1 : 0),
      //         itemBuilder: (context, index) {
      //
      //
      //           if (_isLoading) {
      //             return const Center(child: CircularProgressIndicator());
      //           }
      //           // String customerName = _groupedVehicles.keys.elementAt(index);
      //           // List<Vehicle> customerVehicles = _groupedVehicles[customerName]!;
      //           return Column(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             children: customerWidget,
      //           );
      //         },
      //       ),
    );
  }
}
