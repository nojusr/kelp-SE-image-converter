import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// a simple widget that creates a compact, desktop-oriented text field.
class CompactNumberField extends StatelessWidget {

  CompactNumberField({
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
        keyboardType: TextInputType.number,
        cursorColor: Theme.of(context).textTheme.bodyText1.color,
        cursorWidth: 1,
        style: Theme.of(context).textTheme.bodyText1,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
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