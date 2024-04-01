import 'dart:async';
import 'package:VehiLoc/features/auth/login/login_view.dart';
import 'package:flutter/material.dart';

class RedirectPage extends StatefulWidget {
  final String lastUsername;

 const RedirectPage({Key? key, required this.lastUsername}) : super(key: key);

  @override
  _RedirectPageState createState() => _RedirectPageState();
}

class _RedirectPageState extends State<RedirectPage> {
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.lastUsername;
    _redirectToLogin();
  }

  void _redirectToLogin() {
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginView(usernameController: _usernameController)),
        (Route<dynamic> route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

