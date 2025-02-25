import 'package:VehiLoc/features/account/widget/printer.dart';
import 'package:VehiLoc/features/vehicles/models/vehicle_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:VehiLoc/core/utils/colors.dart';
import 'package:VehiLoc/features/account/widget/button_logout.dart';
import 'package:VehiLoc/core/Api/websocket.dart';
import 'package:VehiLoc/features/account/widget/redirect.dart';

class AccountView extends ConsumerStatefulWidget {
  const AccountView({Key? key}) : super(key: key);

  @override
  _AccountViewState createState() => _AccountViewState();
}

class _AccountViewState extends ConsumerState<AccountView> {
  late String version = '';
  late String buildNumber = '';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            color: GlobalColor.textColor,
          ),
        ),
        backgroundColor: GlobalColor.mainColor,
      ),
      body: Stack(
        children: [
          Center(
            child: FutureBuilder<String>(
              future: _getUsername(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  String username = snapshot.data ?? '';

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_circle,
                        size: 100.0,
                        color: GlobalColor.mainColor,
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        username,
                        style: GoogleFonts.poppins(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      ButtonLogout(
                        onPressed: () async {
                          bool logoutConfirmed = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirmation"),
                                content: const Text("Are you sure?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      ref.read(selectedCustomerProvider.notifier).state.clear();
                                      SharedPreferences prefs = await SharedPreferences.getInstance();
                                      String username = prefs.getString('username') ?? '';
                                      Navigator.of(context).pop(true);
                                      prefs.setString('lastUsername', username);
                                    },
                                    child: const Text("Yes"),
                                  ),
                                ],
                              );
                            },
                          );

                          if (logoutConfirmed == true) {
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            prefs.remove('token');
                            prefs.remove('username');
                            prefs.remove('customerSalts');
                            WebSocketProvider.dispose();

                            String lastUsername = prefs.getString('lastUsername') ?? '';
                            PersistentNavBarNavigator.pushNewScreen(
                              context,
                              screen: RedirectPage(lastUsername: lastUsername),
                              withNavBar: false,
                              pageTransitionAnimation: PageTransitionAnimation.fade,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(Size(
                              MediaQuery.of(context).size.width * 0.3,
                              50,
                            )),
                            backgroundColor: MaterialStateProperty.all(
                                GlobalColor.mainColor),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            elevation: MaterialStateProperty.all(10),
                          ),
                          onPressed: (){
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: Printer2(),
                          withNavBar: false,
                          pageTransitionAnimation: PageTransitionAnimation.fade,
                        );
                      }, child: const Text("Setup Printer", style: TextStyle(
                        color: Colors.white
                      ),)),
                      Text(
                        'Version: $version+$buildNumber',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16.0,
                          color: GlobalColor.mainColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? '';
  }
}
