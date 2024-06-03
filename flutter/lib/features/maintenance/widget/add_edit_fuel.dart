
import 'package:VehiLoc/core/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AddEditFuel extends ConsumerStatefulWidget {
  //final arguments;
  const AddEditFuel({Key? key}) : super(key: key);
  @override
  ConsumerState<AddEditFuel> createState() => _AddEditFuelState();
}

class _AddEditFuelState extends ConsumerState<AddEditFuel> {

  @override
  void initState() {
    super.initState();
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white
        ),
        title: Text("Add/Edit Fuel", style: TextStyle(
          color: Colors.white
        ),),
        backgroundColor: GlobalColor.mainColor,
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                isDense: true,
                labelText: "Vehicle",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: GlobalColor.mainColor, width: 1),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            TextField(
              decoration: InputDecoration(
                isDense: true,
                labelText: "Vehicle",
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: GlobalColor.mainColor, width: 1),
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            RadioMenuButton(value: true, groupValue: true, onChanged: (v){}, child: Text(
              "Solar"
            ))
          ],
        ),
      ),
    );
  }
}