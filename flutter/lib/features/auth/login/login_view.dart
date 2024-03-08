import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:VehiLoc/core/utils/colors.dart';
import 'package:VehiLoc/features/auth/widget/form_login.dart';
import 'package:VehiLoc/features/map/widget/bottom_bar.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
  final Logger logger = Logger(
    printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true),
  );

  late String version = '';
  late String buildNumber = '';

  @override
  void initState() {
    super.initState();
    _checkTokenAndRedirect();
    _usernameController.text = widget.usernameController?.text ?? '';
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  Future<void> _checkTokenAndRedirect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => BottomBar()),
            (Route<dynamic> route) => false,
        );
      LoginState.userSalt = prefs.getString("customerSalts")!;
    } else {
      _fetchAndCacheCustomerSalts();
      _requestLocationPermission();
    }
  }

  Future<void> _fetchAndCacheCustomerSalts() async {
    const String apiUrl = 'https://vehiloc.net/rest/customer_salts';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');

    if (username != null && password != null) {
      final String basicAuth =
          'Basic ' + base64Encode(utf8.encode('$username:$password'));

      try {
        // logger.i("test : ${basicAuth} ${Uri.parse(apiUrl)}");
        final http.Response response = await http.get(
          Uri.parse(apiUrl),
          headers: {'Authorization': basicAuth},
        );

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

  Future<void> _requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (!status.isGranted) {
      logger.e("permission success");
    }
  }


  Future<void> _login() async {
    setState(() {
      isLoading = true;
    });

    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

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
        await _requestLocationPermission();

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => BottomBar()),
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
                  controller: _usernameController,
                  text: 'Username',
                  textInputType: TextInputType.text,
                  obscure: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormLogin(
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
                      minimumSize: MaterialStateProperty.all(
                          Size(MediaQuery.of(context).size.width * 1.0, 50)),
                      backgroundColor:
                          MaterialStateProperty.all(GlobalColor.mainColor),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
