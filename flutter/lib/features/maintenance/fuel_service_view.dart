
import 'package:VehiLoc/core/utils/user_provider.dart';
import 'package:VehiLoc/features/maintenance/fuel_view.dart';
import 'package:VehiLoc/features/maintenance/service_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:VehiLoc/core/utils/colors.dart';


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
    List<Widget> tabBar = [];
    List<Widget> tabBarView = [];
    final userModels = ref.watch(userProvider.notifier).state;

    if(userModels["roles"]["can_fuels_view"]){
      tabBar.add(const Tab(text: 'Fuel'));
      tabBarView.add(FuelView());
    }

    if(userModels["roles"]["can_services_view"]){
      tabBar.add(const Tab(text: 'Service'));
      tabBarView.add(ServiceView());
    }

    super.build(context);
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Maintenance", style: TextStyle(
            color: Colors.white
          ),),
          backgroundColor: GlobalColor.mainColor,
        ),
        body: tabBar.isEmpty
            ? const Center(
          child: Text("Anda tidak memiliki akses melihat data Maintenance"),
        )
            :DefaultTabController(
            length: tabBar.length , // length of tabs
            initialIndex: 0,
            child: Column(children: <Widget>[
             TabBar(
                labelColor: Colors.green,
                unselectedLabelColor: Colors.black,
                tabs: tabBar
              ),
              Expanded(
                  child: TabBarView(children: tabBarView))
            ]))
      ),
    );
  }
}
