import 'package:VehiLoc/features/maintenance/fuel_service_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:VehiLoc/features/map/map_screen.dart';
import 'package:VehiLoc/features/account/account_view.dart';
import 'package:VehiLoc/core/utils/colors.dart';
import 'package:VehiLoc/core/utils/logger.dart';
import 'package:VehiLoc/features/vehicles/vehicles_view.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class BottomBar extends StatefulWidget {
  final double? lat;
  final double? lon;

  const BottomBar({Key? key, this.lat, this.lon}) : super(key: key);
  static int currentIndex = 1;
  static Function? globalSetState;

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  late PersistentTabController _controller = PersistentTabController();

  late List<Widget> _navScreens;

  @override
  void initState() {
    BottomBar.currentIndex = 1;
    super.initState();
    _controller = PersistentTabController(initialIndex: 1);
    var mapScreen = MapScreen(lat: widget.lat, lon: widget.lon);

    _navScreens = [
      mapScreen,
      const VehicleView(),
      const FuelServiceView(),
      const AccountView(),
    ];

    BottomBar.globalSetState = (double? lat, double? lon) {
      setState(() {
        BottomBar.currentIndex = 0;
        _controller.index = 0;
        MapScreen.globalSetState?.call(lat, lon);
      });
    };
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    logger.d("index");
    logger.i(BottomBar.currentIndex);
    return [
      PersistentBottomNavBarItem(
        icon: ColorFiltered(
          colorFilter: ColorFilter.mode(
            BottomBar.currentIndex == 0 ? GlobalColor.buttonColor : GlobalColor.textColor,
            BlendMode.srcIn,
          ),
          child: SvgPicture.asset(
            'assets/icons/map-icon.svg',
          ),
        ),
        title: 'Map',
        activeColorPrimary: GlobalColor.textColor,
        activeColorSecondary: GlobalColor.buttonColor,
        inactiveColorPrimary: GlobalColor.buttonColor,
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: BottomBar.currentIndex == 0 ? GlobalColor.textColor : GlobalColor.textColor,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: ColorFiltered(
          colorFilter: ColorFilter.mode(
            BottomBar.currentIndex == 1 ? GlobalColor.buttonColor : GlobalColor.textColor,
            BlendMode.srcIn,
          ),
          child: SvgPicture.asset(
            'assets/icons/car-icon.svg',
          ),
        ),
        title: 'Vehicles',
        activeColorPrimary: GlobalColor.textColor,
        activeColorSecondary: GlobalColor.buttonColor,
        inactiveColorPrimary: GlobalColor.buttonColor,
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: BottomBar.currentIndex == 1 ? GlobalColor.textColor : GlobalColor.textColor,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: ColorFiltered(
          colorFilter: ColorFilter.mode(
            BottomBar.currentIndex == 2 ? GlobalColor.buttonColor : GlobalColor.textColor,
            BlendMode.srcIn,
          ),
          child: const FaIcon(FontAwesomeIcons.screwdriverWrench, size: 18,),
        ),
        title: 'Maintenance',
        activeColorPrimary: GlobalColor.textColor,
        activeColorSecondary: GlobalColor.buttonColor,
        inactiveColorPrimary: GlobalColor.buttonColor,
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: BottomBar.currentIndex == 2 ? GlobalColor.textColor : GlobalColor.textColor,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: ColorFiltered(
          colorFilter: ColorFilter.mode(
            BottomBar.currentIndex == 3 ? GlobalColor.buttonColor : GlobalColor.textColor,
            BlendMode.srcIn,
          ),
          child: SvgPicture.asset(
            'assets/icons/profile-icon.svg',
          ),
        ),
        title: 'Profile',
        activeColorPrimary: GlobalColor.textColor,
        activeColorSecondary: GlobalColor.buttonColor,
        inactiveColorPrimary: GlobalColor.buttonColor,
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: BottomBar.currentIndex == 3 ? GlobalColor.textColor : GlobalColor.textColor,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _navScreens,
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: GlobalColor.mainColor,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      hideNavigationBarWhenKeyboardShows: true,
      popAllScreensOnTapOfSelectedTab: true,
      navBarStyle: NavBarStyle.style10,
      onItemSelected: (index) {
        setState(() {
          BottomBar.currentIndex = index;
        });
      },
    );
  }
}
