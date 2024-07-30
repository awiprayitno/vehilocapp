
import 'package:VehiLoc/core/Api/api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FuelCard extends StatefulWidget{
  const FuelCard({super.key});

  @override
  State<FuelCard> createState() => _FuelCardState();
}

class _FuelCardState extends State<FuelCard> {
  ApiService apiService = ApiService();
  @override
  Widget build(BuildContext context) {
    return SizedBox(child: ElevatedButton(onPressed: (){
      apiService.getFuelData(page: 1, perPage: 1, vehicleIds: 0);
    }, child: Text("check"),),);
  }

}