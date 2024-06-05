import 'package:VehiLoc/core/utils/colors.dart';
import 'package:flutter/material.dart';

circularLoading(BuildContext context){
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(child: AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,

          child: Center(
            child:
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        color: GlobalColor.mainColor,
                        strokeWidth: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ), onWillPop: ()async{
        return false;
      });
    },

  );
}