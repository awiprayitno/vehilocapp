import 'package:VehiLoc/check_token.dart';
import 'package:VehiLoc/features/maintenance/widget/add_edit_fuel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  //runApp(const App());
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    
    return MaterialApp(
      //home: CheckToken(),
      initialRoute: "/",
      routes: {
        '/': (context) => const CheckToken(),

      },
    );
  }
}
