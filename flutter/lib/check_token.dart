import 'dart:convert';
import 'dart:io';

import 'package:VehiLoc/core/Api/api_service.dart';
import 'package:VehiLoc/core/utils/logger.dart';
import 'package:VehiLoc/features/auth/login/login_view.dart';
import 'package:VehiLoc/features/map/widget/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

import 'core/utils/user_provider.dart';

class CheckToken extends ConsumerStatefulWidget {
  const CheckToken({super.key});

  @override
  ConsumerState<CheckToken> createState() => _CheckTokenState();
}

class _CheckTokenState extends ConsumerState<CheckToken> {
  ApiService apiService = ApiService();
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
      //       //     // title: const Text(
      //       //     //     "Allow your location "
      //       //     // ),
      //       //     content: const Text("We will use your location to show vehicle positions relative to your current location and aid in easier vehicle searches. This information is only used while the application is open or in use"),
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
  
  Future<void> _checkTokenAndRedirect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    await _requestLocationPermission(context);

    if (token != null && token.isNotEmpty) {
      String? username = prefs.getString("username");
      String? password = prefs.getString("password");
      apiService.login(username!, password!).then((response) async {
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          // logger.i("response token");
          // logger.i(response.body);
          final String token = data['token'];

          ref.read(userProvider.notifier).state = jsonDecode(response.body);

          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('token', token);
          prefs.setString('username', username);
          prefs.setString('password', password);
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const BottomBar()),
                (Route<dynamic> route) => false,
          );
          LoginState.userSalt = prefs.getString("customerSalts")!;
        } else {
          logger.e('Failed to login. Status code: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid Username or Password.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      });
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginView()),
          (Route<dynamic> route) => false,
      );
    }
  }
  @override
  void initState() {
    super.initState();
    _checkTokenAndRedirect();
  }
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white, 
      body: Center(
        child: CircularProgressIndicator(), 
      ),
    );
  }
}