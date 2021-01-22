import 'package:flutter/material.dart';

// a simple widget that creates a compact, desktop-oriented text field.
class CompactTextField extends StatelessWidget {

  CompactTextField({
    this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.fieldWidth,
  });

  final double fieldWidth;
  final Function(String) onSubmitted;
  final Function(String) onChanged;
  final String hintText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      width: fieldWidth == null ? 250 : fieldWidth,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        cursorColor: Theme.of(context).textTheme.bodyText1.color,
        cursorWidth: 1,
        style: Theme.of(context).textTheme.bodyText1,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.black.withOpacity(0.2),
          hintText: hintText,
          contentPadding: EdgeInsets.only(top: 1.5, bottom: 1.5, left: 5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.zero),
          ),
        ),
      ),
    );


  }

}