import 'dart:async';
import 'dart:convert';

import 'package:VehiLoc/core/utils/loading_widget.dart';
import 'package:VehiLoc/features/maintenance/widget/add_edit_fuel.dart';
import 'package:VehiLoc/features/maintenance/widget/add_edit_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

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
  final ApiService apiService = ApiService();

  Future<List<Vehicle>> fetchAllData() async {
    try {
      final List<Vehicle> vehicles = await apiService.fetchVehicles();
      final List<Vehicle> validVehicles = vehicles.where((vehicle) => vehicle.lat != 0.0 && vehicle.lon != 0.0).toList();
      return validVehicles;
    } catch (e) {
      logger.e("Error fetching data: $e");
      return [];
    }
  }


  @override
  void initState() {

    super.initState();

  }




  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 10, top: 10),
            alignment: Alignment.topLeft,
            child: ElevatedButton(
                style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.green)
                ),
                onPressed: (){
                  circularLoading(context);
                  fetchAllData().then((value){
                    Navigator.of(context, rootNavigator: true).pop();
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: AddEditService(value),
                      withNavBar: false,
                      pageTransitionAnimation: PageTransitionAnimation.fade,
                    );


                  });


                }, child: const Icon(Icons.add, color: Colors.white,)),)
        ],
      ),
    );
  }
}

