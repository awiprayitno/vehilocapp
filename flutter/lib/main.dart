import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:VehiLoc/features/auth/login/login_view.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    
    return const MaterialApp(
      home: LoginView(),
    );
  }
}
