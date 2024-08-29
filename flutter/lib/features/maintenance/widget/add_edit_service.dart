
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

import '../../../core/Api/api_service.dart';
import '../../../core/model/response_vehicles.dart';
import '../../../core/utils/colors.dart';
import '../../../core/utils/loading_widget.dart';
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
  final _formKey = GlobalKey<FormState>();


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


              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: TextFormField(
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
                        validator: (value){
                          if(value?.trim() == ""){
                            return "Tanggal tidak boleh kosong";
                          }else{
                            return null;
                          }
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
                      child: TextFormField(
                        validator: (value){
                          if(value?.trim() == ""){
                            return "Km tidak boleh kosong";
                          }else{
                            return null;
                          }
                        },
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
                      child: TextFormField(
                        controller: titleController,
                        validator: (value){
                          if(value?.trim() == ""){
                            return "Title tidak boleh kosong";
                          }else{
                            return null;
                          }
                        },
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
                      child: TextFormField(
                        validator: (value){
                          if(value?.trim() == ""){
                            return "Workshop tidak boleh kosong";
                          }else{
                            return null;
                          }
                        },
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
                      child: TextFormField(
                        validator: (value){
                          if(value?.trim() == ""){
                            return "Duration tidak boleh kosong";
                          }else{
                            return null;
                          }
                        },
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
                      child: TextFormField(
                        validator: (value){
                          if(value?.trim() == ""){
                            return "Next Service Date tidak boleh kosong";
                          }else{
                            return null;
                          }
                        },
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
                      child: TextFormField(
                        validator: (value){
                          if(value?.trim() == ""){
                            return "Next Service KM tidak boleh kosong";
                          }else{
                            return null;
                          }
                        },
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
                      child: TextFormField(
                        validator: (value){
                          if(value?.trim() == ""){
                            return "SparePart  tidak boleh kosong";
                          }else{
                            return null;
                          }
                        },
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
                      child: TextFormField(
                        validator: (value){
                          if(value?.trim() == ""){
                            return "Service Cost tidak boleh kosong";
                          }else{
                            return null;
                          }
                        },
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
                      await apiService.deleteServiceData(serviceId: widget.arguments["item"]["id"].toString()).then((value){
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
              if(_formKey.currentState!.validate()){
                circularLoading(context);
                try{
                  Map dataTemp = {};
                  dataTemp = {
                    "service_id" : widget.arguments["item"] == null ? "" : widget.arguments["item"]["id"].toString(),
                    "vehicle_id" : vehicleId,
                    "date" : dateTimeController.text,
                    "km" : kmController.text.trim(),
                    "next_service_date" : nextServiceDateController.text.trim(),
                    "next_service_km" : nextServiceKmController.text.trim(),
                    "duration" : durationController.text.trim(),
                    "workshop" : workshopController.text.trim(),
                    "title" : titleController.text.trim(),
                    "sparepart_cost" : sparepartCostController.text.trim(),
                    "service_cost" : serviceCostController.text.trim(),
                    "description" : notesController.text.trim()
                  };
                  logger.i("data temp");
                  logger.d(dataTemp);
                  apiService.addServiceData(data: dataTemp).then((value) {
                    logger.i(value);
                    if (jsonDecode(value)["status"] == "SUCCESS") {
                      Navigator.of(context).pop(true);
                      Navigator.of(context).pop(true);
                    }else{
                      Navigator.of(context).pop(true);
                    }
                  });
                }catch(e){
                  Navigator.of(context).pop(true);
                  logger.e("error edit fuel");
                  logger.e(e);
                }
              }

            }, child: Text(widget.arguments["item"] == null ? "Save" : "Edit", style: const TextStyle(
                color: Colors.white
            ))),
            // widget.arguments["item"] == null ?
            // ElevatedButton(style: const ButtonStyle(
            //     backgroundColor: MaterialStatePropertyAll(Colors.green)
            // ),
            //     onPressed: (){
            //   if(vehicleId == ""){
            //     ScaffoldMessenger.of(context).clearSnackBars();
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(
            //         content: Text(
            //           'Data tidak lengkap',
            //           textAlign: TextAlign.center,
            //           style: TextStyle(fontSize: 16),
            //         ),
            //         duration: Duration(seconds: 1),
            //       ),
            //     );
            //   }else{
            //     Map dataTemp = {};
            //     dataTemp = {
            //       "service_id" : "",
            //       "vehicle_id" : vehicleId,
            //       "date" : dateTimeController.text,
            //       "km" : kmController.text,
            //       "next_service_date" : nextServiceDateController.text,
            //       "duration" : durationController.text,
            //       "workshop" : workshopController.text,
            //       "title" : titleController.text,
            //       "sparepart_cost" : sparepartCostController.text,
            //       "service_cost" : serviceCostController.text,
            //       "description" : notesController.text
            //     };
            //     apiService.addServiceData(data: dataTemp).then((value){
            //       logger.i(value);
            //       if(jsonDecode(value)["status"] == "SUCCESS"){
            //
            //         dateTimeController.clear();
            //         selectedDt = DateTime.now();
            //         ScaffoldMessenger.of(context).clearSnackBars();
            //         ScaffoldMessenger.of(context).showSnackBar(
            //           const SnackBar(
            //             content: Text(
            //               'Berhasil menambahkan data',
            //               textAlign: TextAlign.center,
            //               style: TextStyle(fontSize: 16),
            //             ),
            //             duration: Duration(seconds: 1),
            //           ),
            //         );
            //       }
            //     });
            //   }
            //
            // }, child: const Text("Save and Add",
            //         style: TextStyle(
            //     color: Colors.white
            // ))) : const SizedBox(),
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