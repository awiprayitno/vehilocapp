
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../../../core/Api/api_service.dart';
import '../../../core/model/response_vehicles.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/logger.dart';


class AddEditService extends ConsumerStatefulWidget {
  final arguments;
  const AddEditService(this.arguments, {Key? key}) : super(key: key);
  @override
  ConsumerState<AddEditService> createState() => _AddEditServiceState();
}

class _AddEditServiceState extends ConsumerState<AddEditService> {
  final ApiService apiService = ApiService();
  DateTime selectedDt = DateTime.now();
  List<DropdownMenuEntry> vehiclesData = [];
  String vehicleId = "";

  TextEditingController dateTimeController = TextEditingController();
  TextEditingController kmController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController workshopController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController nextServiceDateController = TextEditingController();
  TextEditingController nextServiceKmController = TextEditingController();
  TextEditingController sparepartCostController = TextEditingController();
  TextEditingController serviceCostController = TextEditingController();


  @override
  void initState() {
    logger.i("vehicle data");
    logger.wtf(widget.arguments);
    for(Vehicle i in widget.arguments["vehicles"]) {
      if (i.vehicleId != null) {
        vehiclesData.add(
            DropdownMenuEntry(value: i.vehicleId, label: i.name.toString()));
      }
    }
    if(widget.arguments["item"] != null){
      kmController.text = widget.arguments["item"]["km"].toString();
      titleController.text =  widget.arguments["item"]["title"];
      workshopController.text = widget.arguments["item"]["workshop"];
      notesController.text = widget.arguments["item"]["description"];
      durationController.text = widget.arguments["item"]["days"].toString();
      nextServiceDateController.text = DateFormat("yyyy-MM-dd").format(DateTime.fromMillisecondsSinceEpoch(
          widget.arguments["item"]["next_service_dt"] * 1000).toLocal());
      nextServiceKmController.text = widget.arguments["item"]["next_service_km"].toString();
      sparepartCostController.text = widget.arguments["item"]["sparepart_cost"].toString();
      serviceCostController.text = widget.arguments["item"]["service_cost"].toString();
      dateTimeController.text = DateFormat("yyyy-MM-dd").format(DateTime.fromMillisecondsSinceEpoch(
          widget.arguments["item"]["dt"] * 1000).toLocal());
      selectedDt = DateTime.fromMillisecondsSinceEpoch(
          widget.arguments["item"]["dt"] * 1000).toLocal();

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
        title: const Text("Add/Edit Service", style: TextStyle(
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

                  initialSelection: widget.arguments["item"] != null ? widget.arguments["item"]["vehicle_id"]: "",
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
                      type: OmniDateTimePickerType.date,
                      is24HourMode: true,
                      initialDate: selectedDt,
                      context: context,
                    ).then((value){
                      selectedDt = value!;
                      dateTimeController.text = DateFormat("yyyy-MM-dd").format(value);
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
                child: TextField(
                  controller: kmController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: "KM",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: GlobalColor.mainColor, width: 1),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: "Title",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: GlobalColor.mainColor, width: 1),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: workshopController,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: "Workshop",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: GlobalColor.mainColor, width: 1),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: TextField(
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

              Container(
                margin: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: "Duration (days)",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: GlobalColor.mainColor, width: 1),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: TextField(
                  onTap: () async{
                    await showOmniDateTimePicker(
                      type: OmniDateTimePickerType.date,
                      is24HourMode: true,
                      //initialDate: selectedDt,
                      context: context,
                    ).then((value){
                      // selectedDt = value!;
                      nextServiceDateController.text = DateFormat("yyyy-MM-dd").format(value!);
                    });
                  },
                  controller: nextServiceDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: "Next Service Date",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: GlobalColor.mainColor, width: 1),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: nextServiceKmController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: "Next Service KM",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: GlobalColor.mainColor, width: 1),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: sparepartCostController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: "Spare part Cost",
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: GlobalColor.mainColor, width: 1),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: TextField(
                  controller: serviceCostController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: "Service Cost",
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
            //IconButton(onPressed: (){}, icon: const Icon(Icons.camera_alt)),
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
                  "service_id" : "",
                  "vehicle_id" : vehicleId,
                  "date" : dateTimeController.text,
                  "km" : kmController.text,
                  "next_service_date" : nextServiceDateController.text,
                  "duration" : durationController.text,
                  "workshop" : workshopController.text,
                  "title" : titleController.text,
                  "sparepart_cost" : sparepartCostController.text,
                  "service_cost" : serviceCostController.text,
                  "description" : notesController.text
                };
                logger.i("data temp");
                logger.d(dataTemp);
                apiService.addServiceData(data: dataTemp).then((value) {
                  logger.i(value);
                  if (jsonDecode(value)["status"] == "SUCCESS") {
                    Navigator.of(context).pop(true);
                  }
                });
              }
            }, child: Text(widget.arguments["item"] == null ? "Save" : "Edit", style: TextStyle(
                color: Colors.white
            ))),
            widget.arguments["item"] == null ?
            ElevatedButton(style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.green)
            ),
                onPressed: (){
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
                  "service_id" : "",
                  "vehicle_id" : vehicleId,
                  "date" : dateTimeController.text,
                  "km" : kmController.text,
                  "next_service_date" : nextServiceDateController.text,
                  "duration" : durationController.text,
                  "workshop" : workshopController.text,
                  "title" : titleController.text,
                  "sparepart_cost" : sparepartCostController.text,
                  "service_cost" : serviceCostController.text,
                  "description" : notesController.text
                };
                apiService.addServiceData(data: dataTemp).then((value){
                  logger.i(value);
                  if(jsonDecode(value)["status"] == "SUCCESS"){

                    dateTimeController.clear();
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

            }, child: const Text("Save and Add",
                    style: TextStyle(
                color: Colors.white
            ))) : SizedBox(),
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