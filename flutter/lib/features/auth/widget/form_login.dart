import "package:VehiLoc/core/utils/colors.dart";
import "package:flutter/material.dart";

class TextFormLogin extends StatefulWidget {
  const TextFormLogin({
    Key? key,
    required this.controller,
    required this.text,
    this.textInputType,
    required this.obscure,
    required this.clearButton,
  }) : super(key: key);

  final TextEditingController controller;
  final String text;
  final TextInputType? textInputType;
  final bool obscure;
  final bool clearButton;

  @override
  _TextFormLoginState createState() => _TextFormLoginState();
}

class _TextFormLoginState extends State<TextFormLogin> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      padding: const EdgeInsets.only(top: 3, left: 15),
      decoration: BoxDecoration(
        color: GlobalColor.textColor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 7,
          )
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        autofillHints: const [AutofillHints.username],
        keyboardType: widget.textInputType,
        obscureText: widget.obscure && _obscureText,
        decoration: InputDecoration(
          hintText: widget.text,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(0),
          hintStyle: const TextStyle(
            height: 3,
          ),
          suffixIcon: widget.obscure
              ? IconButton(
                  icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : widget.clearButton
              ? IconButton(
            icon: const Icon(Icons.cancel, size: 20,),
            onPressed: () {
              widget.controller.clear();
            },
          ):
              null,
        ),
      ),
    );
  }
}
