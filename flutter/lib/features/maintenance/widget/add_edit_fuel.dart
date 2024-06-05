
import 'dart:convert';

import 'package:VehiLoc/core/utils/colors.dart';
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
    for(Vehicle i in widget.arguments){
      if(i.vehicleId != null){
        vehiclesData.add(DropdownMenuEntry(value: i.vehicleId, label: i.name.toString()));
      }
    }


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
            IconButton(onPressed: (){}, icon: const Icon(Icons.camera_alt)),
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
              }else {
                    Map dataTemp = {};
                    dataTemp = {
                      "fuel_id": "",
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
                      if (jsonDecode(value)["status"] == "SUCCESS") {
                        Navigator.of(context).pop(true);
                      }
                    });
                  }
                }, child: const Text("Save", style: TextStyle(
                color: Colors.white
            ))),
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
            ))),
            ElevatedButton(style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.red)
            ),onPressed: (){
              Navigator.of(context).pop(true);
            }, child: const Text("Cancel", style: TextStyle(
                color: Colors.white
            ),)),

          ],
        ),
      ),
    );
  }
}