import 'package:flutter/material.dart';
import 'package:bitmap/bitmap.dart';

// class that is used as input for the main compute functions in main.dart
class BitmapComputeParameters {
  Bitmap mainBmp = Bitmap.blank(10, 10);
  String scalingOption = "";
  String ditheringOption = "";
  bool preserveAspect = false;
  bool preserveTransparency = false;
  Color backgroundColor = Colors.black;
  bool useCustomResolution = false;
  int customWidth = -1;
  int customHeight = -1;

  BitmapComputeParameters({
    this.mainBmp,
    this.scalingOption,
    this.ditheringOption,
    this.preserveAspect,
    this.preserveTransparency,
    this.backgroundColor,
    this.useCustomResolution,
    this.customWidth,
    this.customHeight,
  });
}