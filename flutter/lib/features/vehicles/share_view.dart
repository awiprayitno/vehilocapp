import 'dart:convert';

import 'package:VehiLoc/core/Api/api_service.dart';
import 'package:VehiLoc/core/model/response_vehicles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:VehiLoc/core/model/response_daily.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/colors.dart';
import '../../core/utils/loading_widget.dart';
import '../../core/utils/logger.dart';


class SharePageView extends StatefulWidget {
  int customerId;


  SharePageView({
    required this.customerId,
    Key? key,
  }) : super(key: key);

  @override
  _SharePageViewState createState() => _SharePageViewState();
}

class _SharePageViewState extends State<SharePageView>{
  bool _isLoading = false;
  ApiService apiService = ApiService();
  final int _pageSize = 20;
  final RefreshController _refreshController = RefreshController();
  final PagingController<int, dynamic> _pagingController =
  PagingController(firstPageKey: 1);
  TextEditingController searchVehicleController = TextEditingController();
  TextEditingController fromController = TextEditingController();
  TextEditingController toController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  List<DropdownMenuEntry> listVehicle = [];
  String? selectedVehicle;

  DateTime selectedFromDt = DateTime.now();
  DateTime selectedToDt = DateTime.now().add(const Duration(days: 1));
  final _formKey = GlobalKey<FormState>();
  
  int colorByte = int.parse("#f7ecda".replaceRange(0, 1, "0xff"));

  void _onRefresh() async {
    // monitor network fetch
    setState(() {
      _pagingController.refresh();
      //children = [];
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    _refreshController.loadComplete();
  }

  Future<void> _fetchPage (int pageKey) async {
    try {
      var newItems =
      await apiService.getSharedLinks(
          page: pageKey,
          perPage: _pageSize,
        customerId: widget.customerId);
      var items = jsonDecode(newItems);
      logger.d(items);


      final isLastPage = items["shared_links"].length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(items["shared_links"]);
      } else {
        pageKey = pageKey + 1;
        _pagingController.appendPage(items["shared_links"], pageKey);
      }
    } catch (error) {
      logger.e("error");
      logger.e(error);
      _pagingController.error = error;
    }
  }

  @override
  void initState() {
    _isLoading = true;
    apiService.fetchCustomerVehicles(widget.customerId).then((value){
      for(Vehicle vehicle in value){
        listVehicle.add(
            DropdownMenuEntry(value: vehicle.vehicleId.toString(), label: vehicle.name.toString(),));
      }

      setState(() {
        _isLoading = false;
      });

    });
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    Future<void> _launchUrl(String url) async {
      final Uri uri = Uri.parse(url);

      if (!await launchUrl(uri)) {
        throw 'Could not launch $uri';
      }
    }

      return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Share Link",
            style: GoogleFonts.poppins(
              color: GlobalColor.textColor,
            ),),
          backgroundColor: GlobalColor.mainColor,
          iconTheme: const IconThemeData(
              color: Colors.white
          ),
        ),
        body: _isLoading ?
        const Center(child: CircularProgressIndicator(),) :
        Container(
            margin: const EdgeInsets.all(10),
            child:
                Column(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Form(
                        key: _formKey,
                      child:
                      Column(
                        children: [

                            DropdownMenu(
                              width: MediaQuery.of(context).size.width - 20.0,
                              menuHeight: MediaQuery.of(context).size.height / 2,
                              label: const Text("select vehicle"),
                              controller: searchVehicleController,
                              //value: selectedVehicle.toString(),
                              //isExpanded: true,
                              //
                              // items: listVehicle,
                              onSelected: (item){
                                setState(() {
                                selectedVehicle = item;
                                logger.i("selectedVehicle");
                                logger.i(selectedVehicle);
                                });
                              },
                              dropdownMenuEntries: listVehicle,),

                          selectedVehicle == null ? Container(
                            alignment: Alignment.centerLeft,
                            child: const Text("*Vehicle tidak boleh kosong",

                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12

                            ),),): const SizedBox() ,

                          Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 2, top: 10),
                                      child: TextFormField(
                                        validator: (value){
                                          if(value == ""){
                                            return "Tanggal tidak boleh kosong";
                                          }else{
                                            return null;
                                          }
                                        },
                                        onTap: () async {
                                          await showOmniDateTimePicker(
                                            is24HourMode: true,
                                            isShowSeconds: true,
                                            initialDate: selectedFromDt,
                                            context: context,
                                          ).then((value){
                                            selectedFromDt = value!;
                                            fromController.text = DateFormat("yyyy-MM-dd HH:mm:ss").format(value);
                                          });
                                        },
                                        readOnly: true,
                                        controller: fromController,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          labelText: "From",
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: GlobalColor.mainColor, width: 1),
                                          ),
                                          border: const OutlineInputBorder(),
                                        ),
                                      ),),),
                                  Expanded(
                                      flex: 1,
                                      child: Container(
                                        margin: const EdgeInsets.only(left: 2, top: 10),
                                        child: TextFormField(
                                          validator: (value){
                                            if(value == ""){
                                              return "Tanggal tidak boleh kosong";
                                            }else{
                                              return null;
                                            }
                                          },
                                          onTap: () async {
                                            await showOmniDateTimePicker(
                                              isShowSeconds: true,
                                              is24HourMode: true,
                                              initialDate: selectedToDt,
                                              context: context,
                                            ).then((value){
                                              selectedToDt = value!;
                                              toController.text = DateFormat("yyyy-MM-dd HH:mm:ss").format(value);
                                            });
                                          },
                                          readOnly: true,
                                          controller: toController,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            labelText: "To",
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: GlobalColor.mainColor, width: 1),
                                            ),
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),)

                                  )


                                ],),
                          Container(
                                margin: const EdgeInsets.only(top: 10),
                                child: TextField(
                                  controller: noteController,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                    labelText: "Note",
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: GlobalColor.mainColor, width: 1),
                                    ),
                                    border: const OutlineInputBorder(),
                                  ),
                                ),),
                          Container(
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.only(top: 5),
                            child: ElevatedButton(
                              child: const Text("Create Link"),
                              onPressed: () async {
                                if(_formKey.currentState!.validate()){
                                  if(selectedVehicle != null){
                                    circularLoading(context);
                                    try{
                                    await apiService.postSharedLinks(vehicleId: selectedVehicle!,
                                        customerId: widget.customerId,
                                        startDt: fromController.text,
                                        endDt: toController.text,
                                        note: noteController.text).then((value){
                                          fromController.clear();
                                          toController.clear();
                                          noteController.clear();
                                          searchVehicleController.clear();
                                          selectedVehicle = null;
                                          Navigator.of(context).pop(true);
                                          _refreshController.requestRefresh();
                                    });
                                    }catch(e){
                                      Navigator.of(context).pop(true);
                                      logger.e(e);

                                    }
                                  }
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ),),
                    Expanded(
                      flex: 10,
                        child: SmartRefresher(
                      enablePullDown: true,
                      enablePullUp: false,
                      controller: _refreshController,
                      onRefresh: _onRefresh,
                      onLoading: _onLoading,
                      child: PagedListView <int, dynamic>(
                        addRepaintBoundaries: true,
                        cacheExtent: 10,
                        addSemanticIndexes: true,
                        pagingController: _pagingController,
                        builderDelegate: PagedChildBuilderDelegate<dynamic>(
                          animateTransitions: true,
                          noMoreItemsIndicatorBuilder: (_) => const Column(children: [
                            Divider(
                              height: 20,
                            ),
                          ]),
                          // [transitionDuration] has a default value of 250 milliseconds.
                          transitionDuration: const Duration(milliseconds: 250),
                          itemBuilder: (context, item, index) {
                            logger.i("index $index");
                            logger.wtf(item);
                            List<Widget> vehicles = [];
                            DateTime fromDt = DateTime.fromMillisecondsSinceEpoch(item["from_dt"] * 1000);
                            DateTime toDt = DateTime.fromMillisecondsSinceEpoch(item["to_dt"] * 1000);
                            DateTime createDt = DateTime.fromMillisecondsSinceEpoch(item["create_dt"] * 1000);
                            String url = item["url"];

                            for(var i in item["vehicles_name"]){
                              vehicles.add(
                                  Container(
                                    padding: const EdgeInsets.only(left: 3, right: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrangeAccent,
                                      borderRadius: BorderRadius.circular(5),

                                    ),
                                    child: Text(i, style: const TextStyle(
                                        color: Colors.white
                                    ),),
                                  )

                              );
                            }
                            return Card(
                              color: Color(colorByte),
                              child: Container(
                                padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5, top: 5),
                                child: Column(
                                  children: [
                                    Container(
                                      //margin: const EdgeInsets.only(bottom: 10),
                                        child:
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 8,
                                              child:  Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Expanded(
                                                    flex: 2,
                                                    child: Text("Vehicle"),),
                                                  const Text("  : "),
                                                  Expanded(
                                                    flex: 9,
                                                    child:
                                                    Wrap(
                                                      runSpacing: 3.0,
                                                      spacing: 1.0,
                                                      children: vehicles,
                                                    ),),
                                                ],),),
                                            Expanded(
                                              flex: 1,
                                              child: IconButton(color: Colors.red, iconSize: 20, onPressed: () async {
                                                showDialog(context: context, builder: (BuildContext c){
                                                  return AlertDialog(
                                                    title: const Text("Konfirmasi Hapus"),
                                                    content: const Text("Yakin ingin menghapus data?"),
                                                    actions: [
                                                      ElevatedButton(onPressed: (){
                                                        Navigator.of(c).pop();
                                                      }, child: const Text("Batal")),
                                                      ElevatedButton(onPressed: () async {
                                                        Navigator.of(c).pop();
                                                        circularLoading(context);
                                                        await apiService.deleteSharedLinks(sharedLinkId: item["id"], customerId: widget.customerId).then((value){
                                                          Navigator.of(context).pop();
                                                          try{
                                                            if(jsonDecode(value)["status"] == "SUCCESS"){
                                                              logger.i("success");
                                                              _refreshController.requestRefresh();
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

                                                    ],
                                                  );
                                                });

                                              }, icon: const Icon(Icons.delete),),)

                                          ],
                                        )
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Expanded(
                                            flex: 1,
                                            child: Text("Date"),),
                                          const Text(" : "),
                                          Expanded(
                                            flex: 5,
                                            child:
                                            Wrap(
                                              runSpacing: 3.0,
                                              spacing: 1.0,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.deepOrangeAccent,
                                                    borderRadius: BorderRadius.circular(5),

                                                  ),
                                                  child: Text( DateFormat("dd MMMM yyyy hh:mm").format(fromDt),
                                                    style: const TextStyle(
                                                        color: Colors.white
                                                    ),),
                                                ),
                                                const Text(" to ", style: TextStyle(
                                                    fontWeight: FontWeight.bold
                                                ),),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.deepOrangeAccent,
                                                    borderRadius: BorderRadius.circular(5),

                                                  ),
                                                  child: Text( DateFormat("dd MMMM yyyy hh:mm").format(toDt),
                                                    style: const TextStyle(
                                                        color: Colors.white
                                                    ),),
                                                ),
                                              ],
                                            ),),

                                        ],),
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Expanded(
                                          flex: 1,
                                          child: Text("Note"),),
                                        const Text(" : "),
                                        Expanded(
                                          flex: 5,
                                          child: Text("${item["note"]}"),),

                                      ],),
                                    Row(
                                      children: [
                                        const Icon(Icons.link),
                                        const SizedBox(width: 5,),
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(0),
                                            ),
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            visualDensity: VisualDensity.compact,
                                            minimumSize: const Size(0, 0),
                                          ),
                                          onPressed: () {
                                            _launchUrl(url);
                                          },
                                          child: Text(url),
                                        ),
                                        IconButton(onPressed: () async {
                                          await Clipboard.setData(ClipboardData(text: url)).then((value){
                                            Fluttertoast.showToast(
                                              msg: "Link copied to clipboard",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 1,
                                              textColor: Colors.black,
                                              fontSize: 16.0,
                                              backgroundColor: Colors.white,
                                            );
                                          });
                                        }, icon: const FaIcon(FontAwesomeIcons.clipboard))
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("created ${DateFormat("dd MMMM yyyy hh:mm").format(createDt)} by ${item["username"]}",
                                          style: const TextStyle(
                                              fontStyle: FontStyle.italic
                                          ),),
                                        Row(
                                          children: [
                                            const Icon(Icons.remove_red_eye, size: 18,),
                                            Text(" ${item["visit_count"]}")
                                          ],
                                        )
                                      ],
                                    )

                                  ],
                                ),
                              ),);
                          },
                        ),
                      ),
                    ))

                  ],
                )

        ),
      );


  }
}
