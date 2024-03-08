import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:VehiLoc/features/map/map_screen.dart';
import 'package:VehiLoc/features/account/account_view.dart';
import 'package:VehiLoc/core/utils/colors.dart';
import 'package:VehiLoc/features/vehicles/vehicles_view.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

class BottomBar extends StatefulWidget {
  final double? lat;
  final double? lon;

  BottomBar({this.lat, this.lon});

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int currentIndex = 0;

  late PersistentTabController _controller = PersistentTabController();

  late List<Widget> _navScreens;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: currentIndex);
    _navScreens = [
      MapScreen(lat: widget.lat, lon: widget.lon),
      const VehicleView(),
      const AccountView(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(
          'assets/icons/map-icon.svg',
          color: currentIndex == 0
              ? GlobalColor.buttonColor
              : GlobalColor.textColor,
        ),
        title: 'Map',
        activeColorPrimary: GlobalColor.textColor,
        activeColorSecondary: GlobalColor.buttonColor,
        inactiveColorPrimary: GlobalColor.buttonColor,
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: currentIndex == 0 ? GlobalColor.textColor : GlobalColor.textColor,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(
          'assets/icons/car-icon.svg',
          color: currentIndex == 1
              ? GlobalColor.buttonColor
              : GlobalColor.textColor,
        ),
        title: 'Vehicles',
        activeColorPrimary: GlobalColor.textColor,
        activeColorSecondary: GlobalColor.buttonColor,
        inactiveColorPrimary: GlobalColor.buttonColor,
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: currentIndex == 1 ? GlobalColor.textColor : GlobalColor.textColor,
        ),
      ),
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(
          'assets/icons/profile-icon.svg',
          color: currentIndex == 2
              ? GlobalColor.buttonColor
              : GlobalColor.textColor,
        ),
        title: 'Profile',
        activeColorPrimary: GlobalColor.textColor,
        activeColorSecondary: GlobalColor.buttonColor,
        inactiveColorPrimary: GlobalColor.buttonColor,
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: currentIndex == 2 ? GlobalColor.textColor : GlobalColor.textColor,
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
          currentIndex = index;
        });
      },
    );
  }
}
