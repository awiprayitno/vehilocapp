import 'dart:async';
import 'dart:convert';

import 'package:VehiLoc/features/maintenance/widget/add_edit_fuel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../../core/utils/logger.dart';
import '../account/widget/redirect.dart';


class FuelView extends ConsumerStatefulWidget {
  FuelView({Key? key}) : super(key: key);

  @override
  ConsumerState<FuelView> createState() => _FuelViewState();
}

class _FuelViewState extends ConsumerState<FuelView> {


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
            margin: EdgeInsets.only(left: 10, top: 10),
            alignment: Alignment.topLeft,
            child: ElevatedButton(
              style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.green)
              ),
              onPressed: (){
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: AddEditFuel(),
                  withNavBar: false,
                  pageTransitionAnimation: PageTransitionAnimation.fade,
                );


              }, child: const Icon(Icons.add, color: Colors.white,)),)
          ],
      ),
    );
  }
}

