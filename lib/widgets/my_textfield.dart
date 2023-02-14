import 'package:flutter/material.dart';

class My_TextField extends StatelessWidget {
  My_TextField(
      {required this.colorenabled,
      required this.colorfocused,
      required this.hint_text,
      required this.onChanged,
      required this.isprivate,
      required this.inputType});

  final Color colorenabled;
  final Color colorfocused;
  final String hint_text;
  final bool isprivate;
  final TextInputType inputType;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TextField(
      keyboardType: inputType,
      obscureText: isprivate,
      onChanged: (value) => onChanged,
      decoration: InputDecoration(
        hintText: hint_text,
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(13))),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorenabled, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(13))),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorfocused, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(13))),
      ),
    );
  }
}
