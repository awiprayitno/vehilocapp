import 'package:VehiLoc/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ButtonLogout extends StatelessWidget {
  const ButtonLogout({Key? key, required this.onPressed}) : super(key: key);

  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
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
      child: Text(
        'Log Out',
        style: GoogleFonts.poppins(
          textStyle: TextStyle(
            color: GlobalColor.textColor,
          ),
        ),
      ),
    );
  }
}
