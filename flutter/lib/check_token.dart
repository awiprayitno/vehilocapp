import 'package:VehiLoc/core/utils/logger.dart';
import 'package:VehiLoc/features/auth/login/login_view.dart';
import 'package:VehiLoc/features/map/widget/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class CheckToken extends StatefulWidget {
  const CheckToken({super.key});

  @override
  State<CheckToken> createState() => _CheckTokenState();
}

class _CheckTokenState extends State<CheckToken> {
  Future<void> _requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (!status.isGranted) {
      logger.e("permission success");
    }
  }
  
  Future<void> _checkTokenAndRedirect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    await _requestLocationPermission();

    if (token != null && token.isNotEmpty) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const BottomBar()),
          (Route<dynamic> route) => false,
      );
      LoginState.userSalt = prefs.getString("customerSalts")!;
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