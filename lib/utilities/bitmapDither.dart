import 'dart:math';

import 'package:bitmap/bitmap.dart';
import 'package:kelp_se_image_converter/utilities/bitmapDitherKernels.dart';
import 'dart:ui';

enum DitheringType {
  FloydSteinberg,
  JaJuNi,
  Stucki,
  Sierra3,
  Sierra2,
  SierraLite
}



class BitmapDither {

  static int colorDepth = 7;
  static double bitSpacing = 255/colorDepth;


  static Bitmap dither(Bitmap input, DitheringType type) {
    switch(type) {
      case DitheringType.FloydSteinberg:
        return _ditherAlongKernel(input, BitmapDitheringKernels.floydSteinbergKernel);
        break;
      case DitheringType.JaJuNi:
        return _ditherAlongKernel(input, BitmapDitheringKernels.jaJuNiKernel);
        break;
      case DitheringType.Stucki:
        return _ditherAlongKernel(input, BitmapDitheringKernels.stuckiKernel);
        break;
      case DitheringType.Sierra3:
        return _ditherAlongKernel(input, BitmapDitheringKernels.sierraThreeKernel);
        break;
      case DitheringType.Sierra2:
        return _ditherAlongKernel(input, BitmapDitheringKernels.sierraTwoKernel);
        break;
      case DitheringType.SierraLite:
        return _ditherAlongKernel(input, BitmapDitheringKernels.sierraLiteKernel);
        break;
      default:
        return input;

    }
  }

  static Bitmap _ditherAlongKernel(Bitmap input, List<List<int>> kernel) {

    int kernelDivisor = kernel[0][0];

    int kernelStartpointY = kernel.indexWhere((element){
      if (element.contains(0)) {
        return true;
      }
      return false;
    });


    int kernelStartpointX = kernel[kernelStartpointY].indexWhere((element){
      if (element == 0) {
        return true;
      }
      return false;
    });

    for (int h = 0; h < input.height-1; h++) {
      for (int w = 0; w < input.width-1; w++) {
        int pixelPoint = _getPixelIndex(input.width, input.height, w, h);

        int oldR, oldG, oldB;
        oldR = input.content[pixelPoint];
        oldG = input.content[pixelPoint+1];
        oldB = input.content[pixelPoint+2];

        Color oldPixel = Color.fromARGB(255, oldR, oldG, oldB);
        Color newPixel = _getClosestColor(oldPixel);

        input.content[pixelPoint] = newPixel.red;
        input.content[pixelPoint+1] = newPixel.green;
        input.content[pixelPoint+2] = newPixel.blue;

        int errR, errG, errB;
        errR = oldR - newPixel.red;
        errG = oldG - newPixel.green;
        errB = oldB - newPixel.blue;

        int tmpPixelPoint = 0;
        int factor = 0;


        for (int i = 1; i < kernel.length; i++) {
          for (int j = 0; j < kernel[1].length; j++) {

            factor = kernel[i][j];

            if (factor == -1 || factor == 0) {
              continue;
            }

            // get relative coordinates from i and j, relative to kernelstartpointY and kernelstartpointX
            int relativeY = i - kernelStartpointY;
            int relativeX = j - kernelStartpointX;

            //Rprint("factoring ${factor}/${kernelDivisor} at ${w+relativeX} ${h+relativeY} || kernelLen: ${kernel[1].length}x${kernel.length}");

            if (w+relativeX > input.width || h+relativeY > input.height) {
              continue;
            }

            tmpPixelPoint = _getPixelIndex(input.width, input.height, w+relativeX, h+relativeY);

            if (tmpPixelPoint+2 >= input.size) {
              continue;
            }

            input.content[tmpPixelPoint] = _applyDitherCalc(factor, kernelDivisor, errR, input.content[tmpPixelPoint]);
            input.content[tmpPixelPoint+1] = _applyDitherCalc(factor, kernelDivisor, errG, input.content[tmpPixelPoint+1]);
            input.content[tmpPixelPoint+2] = _applyDitherCalc(factor, kernelDivisor, errB, input.content[tmpPixelPoint+2]);
          }
        }
      }
    }

    return input;
  }

  static int _applyDitherCalc(int fac, int divisor, int err, int oldVal) {
    return (oldVal + (err * fac/divisor).round()).clamp(0, 255);
  }

  /*
    a [Bitmap] in the Bitmap library provides a width, height and
    a 'contents' array that follows this structure:
    [R G B A R G B A R G B A R G B A R G B ... R G B A ]

    this method provides a way to get the index to access the [R G B A] values
    for a single pixel with X and Y coordinates, using the width and height of the bitmap
   */
  static int _getPixelIndex(int bmpWidth, int bmpHeight, int x, int y) {
    x.clamp(0, bmpWidth);
    y.clamp(0, bmpHeight);

    int pixelDataLen = 4; // how many separate integers are used to represent a single pixel

    return (bmpWidth*pixelDataLen)*y + pixelDataLen*x;
  }

  // gets the closest color for quantization
  static Color _getClosestColor(Color pixelColor) {
    int R, G, B;

    R = ((pixelColor.red.toDouble()~/bitSpacing) * bitSpacing).toInt();
    G = ((pixelColor.green.toDouble()~/bitSpacing) * bitSpacing).toInt();
    B = ((pixelColor.blue.toDouble()~/bitSpacing) * bitSpacing).toInt();

    return Color.fromARGB(pixelColor.alpha, R, G, B);
  }
}