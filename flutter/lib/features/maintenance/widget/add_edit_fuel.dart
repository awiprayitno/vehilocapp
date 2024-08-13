
import 'dart:convert';

import 'package:VehiLoc/core/utils/colors.dart';
import 'package:VehiLoc/core/utils/loading_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';


import '../../../core/Api/api_service.dart';
import '../../../core/model/response_vehicles.dart';
import '../../../core/utils/logger.dart';


class AddEditFuel extends ConsumerStatefulWidget {
  final arguments;
  const AddEditFuel(this.arguments, {Key? key}) : super(key: key);
  @override
  ConsumerState<AddEditFuel> createState() => _AddEditFuelState();
}

class _AddEditFuelState extends ConsumerState<AddEditFuel> {
  final ApiService apiService = ApiService();

  DateTime selectedDt = DateTime.now();


  TextEditingController dateTimeController = TextEditingController();
  TextEditingController litreController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController spbuController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  List<DropdownMenuEntry> vehiclesData = [];

  String vehicleId = "";

  // fuel type
  // 1 bensin
  // 2 solar

  bool fuelBensin = false;

  addFuelData(){
    Map dataTemp = {
    };
  }

  @override
  void initState() {
    logger.i("vehicle data");
    logger.wtf(widget.arguments);
    for(Vehicle i in widget.arguments["vehicles"]){
      if(i.vehicleId != null){
        vehiclesData.add(DropdownMenuEntry(value: i.vehicleId, label: i.name.toString()));
      }
    }

    if(widget.arguments["item"] != null){
        fuelBensin = widget.arguments["item"]["type"] == 1;
        litreController.text = widget.arguments["item"]["volume"].toString();
        priceController.text = widget.arguments["item"]["price"].toString();
        spbuController.text = widget.arguments["item"]["spbu"];
        notesController.text = widget.arguments["item"]["note"];
        dateTimeController.text = DateFormat("yyyy-MM-dd HH:mm").format(DateTime.fromMillisecondsSinceEpoch(
            widget.arguments["item"]["dt"] * 1000).toLocal());
        selectedDt = DateTime.fromMillisecondsSinceEpoch(
            widget.arguments["item"]["dt"] * 1000).toLocal();
    }

    vehicleId = widget.arguments["item"] != null ? widget.arguments["item"]["vehicle_id"].toString():
    widget.arguments["selected_vehicle"].toString();

    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white
        ),
        title: const Text("Add/Edit Fuel", style: TextStyle(
          color: Colors.white
        ),),
        backgroundColor: GlobalColor.mainColor,
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: DropdownMenu(
                  initialSelection: widget.arguments["item"] != null ? widget.arguments["item"]["vehicle_id"]:
                  widget.arguments["selected_vehicle"],

                  menuHeight: MediaQuery.of(context).size.height -500,
                  width: MediaQuery.of(context).size.width -20,
                  hintText: "Vehicle",
                  dropdownMenuEntries: vehiclesData,
                  onSelected: (value){
                    setState(() {
                      vehicleId = value.toString();
                    });

                    logger.i(value);
                  },
                ),),
              vehicleId == ""
                  ? Container(
                alignment: Alignment.centerLeft,
                child: const Text("*Vehicle tidak boleh kosong", style: TextStyle(color: Colors.red),),)
                  : const SizedBox(),


              Container(
                margin: const EdgeInsets.only(top: 10),
                child: TextField(
                    onTap: () async{
                    await showOmniDateTimePicker(
                      is24HourMode: true,
                       initialDate: selectedDt,
                       context: context,
                     ).then((value){
                       selectedDt = value!;
                       dateTimeController.text = DateFormat("yyyy-MM-dd HH:mm").format(value);
                    });
                    },
                  controller: dateTimeController,
                  readOnly: true,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: "Date Time",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: GlobalColor.mainColor, width: 1),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),),


              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Column(children: [
                  RadioMenuButton(value: fuelBensin, groupValue: true, onChanged: (v){
                    setState(() {
                      fuelBensin = !v!;
                    });

                  }, child: const Text(
                      "Bensin"
                  )),
                  RadioMenuButton(value: !fuelBensin, groupValue: true, onChanged: (v){
                    setState(() {
                      fuelBensin = v!;
                    });

                  }, child: const Text(
                      "Solar"
                  )),
                ],),),

              Container(
                margin: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: litreController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: "Litre",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: GlobalColor.mainColor, width: 1),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: "Price",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: GlobalColor.mainColor, width: 1),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),),

              Container(
                margin: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: spbuController,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: "SPBU",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: GlobalColor.mainColor, width: 1),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),),

              Container(
                margin: const EdgeInsets.only(top: 10),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  controller: notesController,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: "Notes",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: GlobalColor.mainColor, width: 1),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widget.arguments["item"] != null ?
            IconButton(onPressed: () async {
              showDialog(context: context, builder: (BuildContext c){
                return AlertDialog(
                  title: const Text("Konfirmasi Hapus"),
                  content: const Text("Yakin ingin menghapus data?"),
                  actions: [
                    ElevatedButton(onPressed: () async {
                      Navigator.of(c).pop();
                      circularLoading(context);
                      await apiService.deleteFuelData(fuelId: widget.arguments["item"]["id"].toString()).then((value){
                        Navigator.of(context).pop();
                        try{
                          if(jsonDecode(value)["status"] == "SUCCESS"){
                            logger.i("success");
                            Navigator.of(context).pop(true);
                          }else{
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  jsonDecode(value)["result"].toString(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        }catch(e){
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      });
                    }, child: const Text("Ya")),
                    ElevatedButton(onPressed: (){
                      Navigator.of(c).pop();
                    }, child: const Text("Batal")),
                  ],
                );
              });

            }, icon: const Icon(Icons.delete, color: Colors.red,))
                : const SizedBox(),
            ElevatedButton(style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.green)
            ),onPressed: (){
              circularLoading(context);
              if(vehicleId == ""){
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Data tidak lengkap',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    duration: Duration(seconds: 1),
                  ),
                );
                Navigator.of(context).pop(true);
              }else {
                try{
                    Map dataTemp = {};
                    dataTemp = {
                      "fuel_id": widget.arguments["item"] == null ? "" : widget.arguments["item"]["id"].toString(),
                      "vehicle_id": vehicleId,
                      "date": dateTimeController.text,
                      "type": fuelBensin ? "1" : "2",
                      "volume": litreController.text,
                      "spbu": spbuController.text,
                      "note": notesController.text,
                      "price": priceController.text
                    };
                    apiService.addFuelData(data: dataTemp).then((value) {
                      logger.i(value);
                      Navigator.of(context).pop(true);
                      if (jsonDecode(value)["status"] == "SUCCESS") {
                        Navigator.of(context).pop(true);
                      }
                    });
                }catch(e){
                  Navigator.of(context).pop(true);
                  logger.e("error edit fuel");
                  logger.e(e);
                }
                  }
                }, child:  Text(widget.arguments["item"] == null ? "Save" : "Edit", style: const TextStyle(
                color: Colors.white
            ))),
            widget.arguments["item"] == null ?
            ElevatedButton(style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.green)
            ),onPressed: (){
              if(vehicleId == ""){
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Data tidak lengkap',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    duration: Duration(seconds: 1),
                  ),
                );
              }else{
                Map dataTemp = {};
                dataTemp = {
                  "fuel_id" : "",
                  "vehicle_id" : vehicleId,
                  "date" : dateTimeController.text,
                  "type" : fuelBensin ? "1" : "2",
                  "volume" : litreController.text,
                  "spbu" : spbuController.text,
                  "note" : notesController.text,
                  "price" : priceController.text
                };
                apiService.addFuelData(data: dataTemp).then((value){
                  logger.i(value);
                  if(jsonDecode(value)["status"] == "SUCCESS"){
                    dateTimeController.clear();
                    litreController.clear();
                    priceController.clear();
                    spbuController.clear();
                    notesController.clear();
                    selectedDt = DateTime.now();
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Berhasil menambahkan data',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                });
              }

            }, child: const Text("Save and Add", style: TextStyle(
                color: Colors.white
            )))
            : const SizedBox(),
            ElevatedButton(style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.red)
            ),onPressed: (){
              Navigator.of(context).pop(false);
            }, child: const Text("Cancel", style: TextStyle(
                color: Colors.white
            ),)),

          ],
        ),
      ),
    );
  }
}