
import 'package:VehiLoc/features/maintenance/fuel_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:VehiLoc/core/utils/colors.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';


class FuelServiceView extends ConsumerStatefulWidget {
  const FuelServiceView({Key? key}) : super(key: key);

  @override
  _FuelServiceViewState createState() => _FuelServiceViewState();
}

class _FuelServiceViewState extends ConsumerState<FuelServiceView> with AutomaticKeepAliveClientMixin<FuelServiceView>{
  @override
  bool get wantKeepAlive => true;



  @override
  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Maintenance", style: TextStyle(
            color: Colors.white
          ),),
          backgroundColor: GlobalColor.mainColor,
        ),
        body: DefaultTabController(
            length: 2, // length of tabs
            initialIndex: 0,
            child: Column(children: <Widget>[
              const TabBar(
                labelColor: Colors.green,
                unselectedLabelColor: Colors.black,
                tabs: [
                  Tab(text: 'Fuel'),
                  Tab(text: 'Service'),
                ],
              ),
              Expanded(
                  child: TabBarView(children: <Widget>[
                    FuelView(),
                    Text("2")





                  ]))
            ]))
      ),
    );
  }
}
