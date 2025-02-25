import 'package:VehiLoc/core/utils/colors.dart';
import 'package:VehiLoc/core/utils/user_provider.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue_plus;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';


import '../../../core/utils/global_func.dart';
import '../../../core/utils/logger.dart';


class Printer2 extends ConsumerStatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<Printer2> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  bool _connected = false;
  bool theresdata = false;
  late Future data;
  int? status;
  int? connectingID;

  final sharedPreference = SpData();

  // final SingletonModel _singleton = SingletonModel();

  @override
  void initState() {
    super.initState();
    initBluetooth();
    Future.delayed(const Duration(seconds: 3), () {
      checkBluetoothPermissionandStatus().then((value) {
        setState(() {
          status = value;
        });
      });
    });
  }

  @override
  void dispose() {
    //bluetoothPrint.destroy();
    super.dispose();
  }

  Future<int> checkBluetoothPermissionandStatus() async {
    var bluetoothPermission = await Permission.bluetooth.status;
    var locationPermission = await Permission.location.status;
    var bluetoothStatus = await blue_plus.FlutterBluePlus.adapterState.first == blue_plus.BluetoothAdapterState.on ? true : false;
    var locationStatus = await Permission.locationWhenInUse.serviceStatus.isEnabled;

    if (bluetoothPermission.isGranted && locationPermission.isGranted && bluetoothStatus && locationStatus) {
      return 0; // this means everything is good
    } else {
      if (bluetoothPermission.isGranted == false || locationPermission.isGranted == false) {
        return 1; // this means bluetooth or location permission is not allowed
      } else if (bluetoothStatus == false || locationStatus == false) {
        return 2; // this means bluetooth or location is not enabled
      } else {
        return 3; // this means all permission and status is off
      }
    }
  }

  initBluetooth() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 4));

    bool isConnected = await bluetoothPrint.isConnected ?? false;

    bluetoothPrint.state.listen((state) {
      print('******************* cur device status: $state');

      switch (state) {
        case BluetoothPrint.CONNECTED:
          if (this.mounted) {
            setState(() {
              _connected = true;
              logger.i("connected");
            });
          }
          break;
        case BluetoothPrint.DISCONNECTED:
          if (this.mounted) {
            setState(() {
              _connected = false;
              logger.i('not connected');
            });
          }
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  Future<void> handleClick(Map item) async {
    //logger.i("handleClickEditData", item);
    if (item["type"] == "forget") {
      await bluetoothPrint.disconnect().then((value) {
        //_singleton.selectedDevice = null;
        sharedPreference.resetPrinter();

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Berhasil forget printer"),
        ));
        //
        // showSnackBarSuccess(context, "Berhasil forget printer", Colors.white, 2000);
        // logger.e(_singleton.selectedDevice);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: GlobalColor.mainColor,
          leading: InkWell(
            onTap: () async {
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          title: const Text('Setup Bluetooth Printer', style: TextStyle(
            color: Colors.white
          ),),
        ),
        body: RefreshIndicator(
          onRefresh: () =>
              bluetoothPrint.startScan(timeout: const Duration(seconds: 4)),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                StreamBuilder<List<BluetoothDevice>>(
                    stream: bluetoothPrint.scanResults,
                    initialData: const [],
                    builder: (c, snapshot) {
                      List<Widget> widgets = [];
                      snapshot.data!.asMap().forEach((index, data) {
                        widgets.add(
                            Card(
                              margin: const EdgeInsets.all(5),
                              child: ListTile(
                                leading: Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      connectingID == index && _connected ?
                                      const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      ) : connectingID == index ?
                                      const SizedBox(
                                        child: CircularProgressIndicator(),
                                      ) : Text("${index + 1}",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 18
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                title: Text(data.name??''),
                                subtitle: Text(data.address??''),
                                onTap:  connectingID == index && _connected ?
                                    () async {
                                  setState(() {
                                    connectingID = null;
                                    _connected = false;
                                  });
                                  await bluetoothPrint.disconnect().then((value) {
                                    sharedPreference.resetPrinter();
                                    // _singleton.selectedDevice = null;
                                    // logger.e(_singleton.selectedDevice);
                                  });
                                } : () async {
                                  setState(() {
                                    connectingID = index;
                                  });
                                  await bluetoothPrint.connect(data).then((value) {
                                    //_singleton.selectedDevice = data;
                                    sharedPreference.savePrinter('printerAddress', data.address);
                                    //logger.e(_singleton.selectedDevice);
                                  });
                                },
                                trailing: connectingID == index && _connected ?
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton.icon(
                                      label: const Text("Test"),
                                      icon: const Icon(Icons.print),
                                      onPressed: () async {
                                        List<LineText> list = [];
                                        Map<String, dynamic> config = Map();

                                        list.add(LineText(type: LineText.TYPE_IMAGE,
                                          content: await imageAssetToBase64("assets/logo/vehiloc-logo.png"),
                                          align: LineText.ALIGN_CENTER,
                                          height: 200,
                                          width: 400,
                                        ));
                                        list.add(LineText(type: LineText.TYPE_TEXT, height: 1, width: 1, align: LineText.ALIGN_CENTER, linefeed: 1, content: 'Test Print'));
                                        list.add(LineText(type: LineText.TYPE_TEXT, height: 1, width: 1, align: LineText.ALIGN_CENTER, linefeed: 1, content: 'Berhasil'));
                                        list.add(LineText(type: LineText.TYPE_TEXT, height: 1, width: 1, align: LineText.ALIGN_CENTER, linefeed: 1, content: ''));
                                        list.add(LineText(type: LineText.TYPE_TEXT, height: 1, width: 1, align: LineText.ALIGN_CENTER, linefeed: 1, content: ''));
                                        await bluetoothPrint.printReceipt(config, list);
                                      },
                                    ),
                                    PopupMenuButton<Map>(
                                        onSelected: (item) => handleClick(item),
                                        itemBuilder: (context) {
                                          return [
                                            PopupMenuItem(
                                              value: {
                                                "type" : "forget",
                                                "address" : data.address
                                              },
                                              child: const Text("Forget Printer"),
                                            ),
                                          ];
                                        }
                                    )
                                  ],
                                ) : const SizedBox(),
                              ),
                            )
                        );
                      });
                      return Column(
                        children: widgets,
                      );
                    }
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: StreamBuilder<bool>(
          stream: bluetoothPrint.isScanning,
          initialData: false,
          builder: (c, snapshot) {
            if (status == 0) {
              if (snapshot.data == true) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 160,
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        border: Border.all(
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.all(
                            Radius.circular(5.0) //                 <--- border radius here
                        ),
                      ),
                      child: Text("Mencari perangkat...",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white
                        ),
                      ),
                    ),
                    FloatingActionButton(
                      child: Container(
                        width: 45,
                        height: 45,
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      onPressed: () => bluetoothPrint.stopScan(),
                      backgroundColor: Colors.red,
                    )
                  ],
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 280,
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        border: Border.all(
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.all(
                            Radius.circular(5.0)
                        ),
                      ),
                      child: Text("Klik Tombol untuk mencari perangkat",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white
                        ),
                      ),
                    ),
                    FloatingActionButton(
                        child: Icon(Icons.search),
                        onPressed: () => bluetoothPrint.startScan(timeout: Duration(seconds: 4)))
                  ],
                );
              }
            } else {
              if (status == 1 || status == 3) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 280,
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        border: Border.all(
                          color: Colors.transparent,
                        ),
                        borderRadius: const BorderRadius.all(
                            Radius.circular(5.0)
                        ),
                      ),
                      child: const Text("Aplikasi tidak diperbolehkan mengakses bluetooth atau lokasi, silahkan atur di pengaturan perangkat atau tekan tombol di samping",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white
                        ),
                      ),
                    ),
                    FloatingActionButton(
                        child: Icon(Icons.settings),
                        onPressed: () async => await openAppSettings().then((value) {
                          checkBluetoothPermissionandStatus().then((value) {
                            setState(() {
                              status = value;
                            });
                          });
                        })
                    )
                  ],
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 280,
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        border: Border.all(
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.all(
                            Radius.circular(5.0)
                        ),
                      ),
                      child: Text("Bluetooth atau lokasi perangkat tidak dinyalakan, mohon nyalakan terlebih dahulu",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white
                        ),
                      ),
                    ),
                    FloatingActionButton(
                        child: Icon(Icons.refresh),
                        onPressed: () {
                          checkBluetoothPermissionandStatus().then((value) {
                            setState(() {
                              status = value;
                            });
                          });
                        }
                    )
                  ],
                );
              }
            }
          },
        ),
      ),
    );
  }
}