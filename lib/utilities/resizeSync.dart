import 'package:bitmap/bitmap.dart';
import 'package:bitmap/transformations.dart';
import 'dart:typed_data';

// a synchronous bitmap resize function. Direct copy of resize() found in
// package:bitmap/transformations.dart, only with the async keyword taken out.
// used in the compute functions and those don't properly support asynchronous functions yet
Bitmap resizeSync(Bitmap bitmap, int resizeWidth, int resizeHeight) {
  final width = bitmap.width;
  final height = bitmap.height;

  final int newBitmapSize = (resizeWidth * resizeHeight) * bitmapPixelLength;

  final Bitmap resized = Bitmap.fromHeadless(
    resizeWidth,
    resizeHeight,
    Uint8List(newBitmapSize),
  );

  resizeCore(
    bitmap.content,
    resized.content,
    width,
    height,
    resizeWidth,
    resizeHeight,
  );

  return resized;
}
