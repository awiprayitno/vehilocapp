import 'dart:async';
import 'dart:convert';

import 'package:VehiLoc/core/utils/loading_widget.dart';
import 'package:VehiLoc/features/maintenance/widget/add_edit_fuel.dart';
import 'package:VehiLoc/features/maintenance/widget/add_edit_service.dart';
import 'package:VehiLoc/features/maintenance/widget/fuel_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

import '../../core/Api/api_service.dart';
import '../../core/model/response_vehicles.dart';
import '../../core/utils/logger.dart';
import '../account/widget/redirect.dart';


class ServiceView extends ConsumerStatefulWidget {
  ServiceView({Key? key}) : super(key: key);

  @override
  ConsumerState<ServiceView> createState() => _ServiceViewState();
}

class _ServiceViewState extends ConsumerState<ServiceView> {
  final PagingController<int, dynamic> _pagingController =
  PagingController(firstPageKey: 0);
  //late List<Widget> children;
  final int _pageSize = 20;

  final ApiService apiService = ApiService();
  List<DropdownMenuItem> listVehicle = [];
  int? selectedVehicle;
  bool isLoad = true;
  RefreshController _refreshController = RefreshController();

  Future<void> _fetchPage(int pageKey) async {
    try {
      var newItems =

      await apiService.getServiceData(
          page: pageKey + 1,
          perPage: _pageSize,
          vehicleIds: selectedVehicle!);
      //
      // await getRequest.getCustomers(
      //   teamToken: companyModels["team_token"],
      //   token: userModels["token"],
      //   page: pageKey,
      //   perPage: _pageSize,
      //   q: searchText.text,
      // );




      var items = jsonDecode(newItems);




      logger.d(items);


      final isLastPage = items["data"].length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(items["data"]);
      } else {
        pageKey = pageKey + 1;
        _pagingController.appendPage(items["data"], pageKey);
      }
    } catch (error) {
      logger.e("error");
      logger.e(error);
      _pagingController.error = error;
    }
  }

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

  Future<List<Vehicle>> fetchAllData() async {
    try {
      final List<Vehicle> vehicles = await apiService.fetchVehicles();
      final List<Vehicle> validVehicles = vehicles.where((vehicle) => vehicle.lat != 0.0 && vehicle.lon != 0.0 && vehicle.vehicleId != null).toList();
      return validVehicles;
    } catch (e) {
      logger.e("Error fetching data: $e");
      return [];
    }
  }


  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      fetchAllData().then((value){
        for(Vehicle vehicle in value){
          listVehicle.add(
              DropdownMenuItem(value: vehicle.vehicleId.toString(),
                child: Text(vehicle.name.toString()),));
        }
        selectedVehicle = value[0].vehicleId;
        logger.d("selected");
        logger.i(value[0].name);
        logger.i(selectedVehicle);
        setState(() {
          isLoad = false;
        });


      });
    });

  }




  @override
  Widget build(BuildContext context) {
    if(isLoad){
      return const Center(
        child: CircularProgressIndicator(),
      );
    }else{

      return Container(
        margin: const EdgeInsets.all(5),
        child: Column(
          children: [
            Expanded(
                flex: 1,
                child:
                Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    child: DropdownButton(
                        value: selectedVehicle.toString(),
                        isExpanded: true,
                        items: listVehicle, onChanged: (item){
                      logger.i(item);
                      setState(() {
                        selectedVehicle = int.parse(item);
                        _refreshController.requestRefresh();
                      });

                    }))),
            Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.only(left: 10, top: 10),
                  alignment: Alignment.topLeft,
                  child: ElevatedButton(
                      style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(Colors.green)
                      ),
                      onPressed: (){
                        Map data = {};
                        circularLoading(context);
                        fetchAllData().then((value){
                          data["vehicles"] = value;
                          Navigator.of(context, rootNavigator: true).pop();
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: AddEditService(data),
                            withNavBar: false,
                            pageTransitionAnimation: PageTransitionAnimation.fade,
                          );


                        });


                      }, child: const Icon(Icons.add, color: Colors.white,)),)),
            Expanded(
                flex: 9,
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: false,
                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    onLoading: _onLoading,
                    child: PagedListView<int, dynamic>(
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
                          return Card(child: ListTile(
                            title: Text("${item["title"]} (${item["km"]}Km) ${DateFormat("dd-MMMM-yyyy").format(DateTime.fromMillisecondsSinceEpoch(item["dt"] * 1000).toLocal())}"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${item["workshop"]} (${item["days"]} days)"),
                                Text("Next Service Date ${DateFormat("dd-MMMM-yyyy").format(DateTime.fromMillisecondsSinceEpoch(item["dt"] * 1000).toLocal())}"),
                                Text("Next Service Km ${item["next_service_km"]}"),
                                Text("Sparepart : ${item["sparepart_cost"]}"),
                                Text("Service : ${item["service_cost"]}"),
                                Text("Total : ${item["total_cost"]}"),
                                Text("${item["description"]}"),

                              ],),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: (){
                                Map data = {};
                                circularLoading(context);
                                fetchAllData().then((value){
                                  data["vehicles"] = value;
                                  data["item"] = item;
                                  data["item"]["vehicle_id"] = selectedVehicle;
                                  logger.i("values");
                                  logger.d(data);
                                  Navigator.of(context, rootNavigator: true).pop();
                                  PersistentNavBarNavigator.pushNewScreen(
                                    context,
                                    screen: AddEditService(data),
                                    withNavBar: false,
                                    pageTransitionAnimation: PageTransitionAnimation.fade,
                                  );


                                });
                              },
                            ),
                          ),);
                        },
                      ),
                    ),
                  ),)
            )

          ],
        ),
      );
    }

  }
}

