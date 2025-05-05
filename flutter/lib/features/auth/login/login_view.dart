import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:VehiLoc/core/utils/colors.dart';
import 'package:VehiLoc/features/auth/widget/form_login.dart';
import 'package:VehiLoc/features/map/widget/bottom_bar.dart';
import 'package:VehiLoc/core/utils/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:VehiLoc/core/model/response_image_promo.dart';

class LoginView extends StatefulWidget {
  final TextEditingController? usernameController; 

  const LoginView({Key? key, this.usernameController}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}


class LoginState {
  static String userSalt = "";
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

  late String version = '';
  late String buildNumber = '';
  Carousel? carousel;

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.usernameController?.text ?? '';
    _initPackageInfo();
    fetchCarouselData();
  }

  Future<void> _initPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  Future<void> fetchCarouselData() async {
    const String apiUrl = 'https://vehiloc.net/rest/promo_pictures';
  
    try {
      final http.Response response = await http.get(Uri.parse(apiUrl));
  
      if (response.statusCode == 200 && mounted) { 
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          carousel = Carousel.fromJson(responseData);
        });
      } else {
        throw Exception('Failed to load carousel data');
      }
    } catch (error) {
      logger.e('Error fetching carousel data: $error');
    }
  }

  Future<void> _fetchAndCacheCustomerSalts() async {
    const String apiUrl = 'https://vehiloc.net/rest/customer_salts';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');

    if (username != null && password != null) {
      final String basicAuth =
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';

      try {
        // logger.i("test : ${basicAuth} ${Uri.parse(apiUrl)}");
        final http.Response response = await http.get(
          Uri.parse(apiUrl),
          headers: {'Authorization': basicAuth},
        );

        logger.i("response CustomerSalts");
        logger.i(response.body);
        if (response.statusCode == 200) {
          prefs.setString('customerSalts', response.body);
          LoginState.userSalt = response.body;
          logger.i('Customer Salts = ${response.body}');
        } else {
          logger.e(
              'Failed to fetch customer salts. Status code: ${response.statusCode}');
        }
      } catch (error) {
        logger.e('Error: $error');
      }
    }
  }

  Future<void> _requestLocationPermission(BuildContext context) async {
    await Permission.location.serviceStatus.isEnabled.then((value) async {
      logger.i("permission");
      logger.wtf(value);
      // if(value == true){
      //   await Permission.location.isGranted.then((va) async {
      //     if(!va){
      //       await Permission.location.request();
      //       // await showDialog(
      //       //     barrierDismissible: false,
      //       //     context: context, builder: (BuildContext c){
      //       //   return AlertDialog(
      //       //     // title: const Text(hf
      //       //     //     "Allow your location "
      //       //     // ),
      //       //     content: const Text("We'll use your location to show vehicle positions relative to your current location and aid in easier vehicle searches"),
      //       //     actions: [
      //       //       // ElevatedButton(onPressed: (){
      //       //       //   exit(0);
      //       //       // }, child: const Text("Cancel")),
      //       //       ElevatedButton(onPressed: ()async {
      //       //         Navigator.pop(context);
      //       //         await Permission.location.request();
      //       //         // if (!status.isGranted) {
      //       //         //   exit(0);
      //       //         // }
      //       //       }, child: const Text("Continue")),
      //       //     ],
      //       //   );
      //       // });
      //       // await Permission.location.isPermanentlyDenied.then((v) async {
      //       //   logger.i("location Permanent disable");
      //       //   logger.wtf(v);
      //       //   if(v){
      //       //
      //       //     await showDialog(
      //       //         barrierDismissible: false,
      //       //         context: context, builder: (BuildContext c){
      //       //       return AlertDialog(
      //       //
      //       //         title: const Text(
      //       //             "Alert"
      //       //         ),
      //       //         content: Container(
      //       //           child: const Text("Silahkan buka pengaturan untuk memberikan akses lokasi ke Vehiloc"),
      //       //         ),
      //       //         actions: [
      //       //           ElevatedButton(onPressed: (){
      //       //             Geolocator.openLocationSettings().then((value) {
      //       //               exit(0);
      //       //             });
      //       //
      //       //
      //       //           }, child: const Text("Ok")),
      //       //         ],
      //       //       );
      //       //     });
      //       //   }else{
      //       //
      //       //   }
      //       // });
      //
      //     }
      //
      //   });
      // }else{
      //   await showDialog(
      //       barrierDismissible: false,
      //       context: context, builder: (BuildContext c){
      //     return AlertDialog(
      //
      //       title: const Text(
      //           "Alert"
      //       ),
      //       content: const Text("Silahkan menyalakan lokasi untuk mengakses Vehiloc"),
      //       actions: [
      //         ElevatedButton(onPressed: (){
      //           Geolocator.openLocationSettings().then((value) {
      //             exit(0);
      //           });
      //
      //
      //         }, child: const Text("Ok")),
      //       ],
      //     );
      //   });
      // }
    });

  }


  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });

    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    final String basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    const String apiUrl = 'https://vehiloc.net/rest/token';

    try {
      final http.Response response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': basicAuth},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        logger.i(response.body);
        final String token = data['token'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);
        prefs.setString('username', username);
        prefs.setString('password', password);

        await _fetchAndCacheCustomerSalts();
        await _requestLocationPermission(context);

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const BottomBar()),
            (Route<dynamic> route) => false,
        );
      } else {
        logger.e('Failed to login. Status code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid Username or Password.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (error) {
      logger.e('Error: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width > 600;
    final bool isIpad = MediaQuery.of(context).size.width > 900;
    final double carouselHeight = isIpad ? MediaQuery.of(context).size.height * 0.8 : isTablet ? MediaQuery.of(context).size.height * 0.4  : MediaQuery.of(context).size.height * 0.2;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/logo/vehiloc-logo-text.png',
                    width: 200,
                    height: 200,
                  )
                ),
                // Center(
                //   child: 
                //     Text(
                //       'VehiLoc',
                //       style: GoogleFonts.poppins(
                //         color: GlobalColor.mainColor,
                //         fontSize: 35,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                // ),

                 TextFormLogin(
                   text: "Username",
                    controller: _usernameController,
                   obscure: false,
                   clearButton: true,
                  ),


                const SizedBox(
                  height: 10,
                ),
                TextFormLogin(
                  clearButton: false,
                  controller: _passwordController,
                  text: 'Password',
                  textInputType: TextInputType.text,
                  obscure: true,
                ),
                const SizedBox(
                  height: 15,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _login,
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(MediaQuery.of(context).size.width * 1.0, 50)),
                      backgroundColor: MaterialStateProperty.all(GlobalColor.mainColor),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      )),
                      elevation: MaterialStateProperty.all(10),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            'Login',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Version: $version+$buildNumber',
                        style: GoogleFonts.poppins(
                          color: GlobalColor.mainColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'vehiloc.net',
                        style: GoogleFonts.poppins(
                          color: GlobalColor.mainColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                CarouselSlider(
                  options: CarouselOptions(
                    height: carouselHeight,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    viewportFraction: 0.8,
                    enlargeCenterPage: true
                  ),
                  items: carousel?.data?.map((String imageUrl) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10.0), 
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0), 
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList() ?? [],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
