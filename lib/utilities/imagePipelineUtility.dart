import 'dart:typed_data';
import 'package:bitmap/bitmap.dart';
import 'package:flutter/material.dart';
import 'package:kelp_se_image_converter/utilities/settingTypes.dart';
import 'package:kelp_se_image_converter/utilities/resizeSync.dart';
import 'package:kelp_se_image_converter/utilities/bitmapDither.dart';

// a class that holds the various image/bitmap conversion steps needed
// for conversion
class ImagePipelineUtility {

  static const double bitSpacing = 255/7;

  static const int valuesPerPixel = 4; // how many values are used to represent a pixel in the Bitmap library


  // boilerplate function to apply dithering to an image.
  // see bitmapDither.dart for actual dithering code
  static Bitmap applyDithering(Bitmap input, String ditheringType) {

    Bitmap output;

    switch(ditheringType) {
      case "Floyd-Steinberg":
        output = BitmapDither.dither(input, DitheringType.FloydSteinberg);
        break;
      case "Ja-Ju-Ni":
        output = BitmapDither.dither(input, DitheringType.JaJuNi);
        break;
      case "Stucki":
        output = BitmapDither.dither(input, DitheringType.Stucki);
        break;
      case "Sierra-3":
        output = BitmapDither.dither(input, DitheringType.Sierra3);
        break;
      case "Sierra-2":
        output = BitmapDither.dither(input, DitheringType.Sierra2);
        break;
      case "Sierra Lite":
        output = BitmapDither.dither(input, DitheringType.SierraLite);
        break;
      default: // don't apply anything on default
        output = applyColorLimits(input);
        break;
    }

    return output;
  }

  // scales an image according the 'Surface type' dropdown menu.
  static Bitmap applyScaling({Bitmap input, String scalingOption, bool maintainAspect, Color bgColor, int cWidth, int cHeight}) {

    int optionIndex = settingTypes.surfaceTypeChoices.indexOf(scalingOption);
    Pair resPair = settingTypes.surfaceTypeResolutions[optionIndex];

    if (resPair.a == -1) {
      resPair = Pair(cWidth, cHeight);
    }

    Bitmap output;

    if (maintainAspect) { // scale the image while preserving the aspect ratio of the original image

      double aspectRatio = input.width/input.height;

      int outWidth = resPair.a; // desired width
      int outHeight = resPair.b; // desired height
      double outAspectRatio = outWidth/outHeight;

      // determine size of the scaled, but 'aspect-ratio-preserved' image
      int newHeight, newWidth;

      if (outAspectRatio > aspectRatio) {
        newWidth = (input.width*(outHeight/input.height)).round();
        newHeight = outHeight;
      } else {
        newWidth = outWidth;
        newHeight = (input.height*(outWidth/input.width)).round();
      }

      // determine drawing point for newly scaled image
      int topPos = ((outHeight-newHeight)/2).round();
      int leftPos = ((outWidth-newWidth)/2).round();

      // scale the image
      Bitmap scaled = resizeSync(input, newWidth, newHeight);

      // create a new image and paint it black
      output = Bitmap.blank(resPair.a, resPair.b);
      for (int i = 0; i < output.size; i+= 4) {
        output.content[i] = bgColor.red;
        output.content[i+1] = bgColor.green;
        output.content[i+2] = bgColor.blue;
        output.content[i+3] = bgColor.alpha;
      }

      // then, paint our scaled image on top of it
      for (int y = 0; y < scaled.height; y++) {
        int startingIndex = _getPixelIndex(output.width, output.height, leftPos, topPos+y);
        int scaledIndex = _getPixelIndex(scaled.width, scaled.height, 0, y);

        for (int x = 0; x < (scaled.width*4); x += 4) {
          output.content[startingIndex+x] = scaled.content[scaledIndex+x];
          output.content[startingIndex+x+1] = scaled.content[scaledIndex+x+1];
          output.content[startingIndex+x+2] = scaled.content[scaledIndex+x+2];
          output.content[startingIndex+x+3] = scaled.content[scaledIndex+x+3];

        }
      }
    } else { // if there's no aspect ratio sht to deal with, just use the provided Bitmap function to rescale
      output = resizeSync(input, resPair.a, resPair.b);
    }
    return output;
  }

  // function that deals with transparency in the main bitmap. SE doesn't allow for transparent images, with a few exceptions.
  // https://stackoverflow.com/questions/39542494/calculate-color-of-an-pixel-for-a-transparent-application-background-image
  // https://en.wikipedia.org/wiki/Alpha_compositing
  static Bitmap handleTransparency(Bitmap input, bool preserveTransparency, Color bgColor) {


    int r1, g1, b1, a1;
    int r2, g2, b2, a2;

    for (int i = 0; i < input.size; i += 4) {

      if (input.content[i+3] == 0) {
        input.content[i] = bgColor.red;
        input.content[i+1] = bgColor.green;
        input.content[i+2] = bgColor.blue;
        input.content[i+3] = bgColor.alpha;
        continue;
      }

      if (input.content[i+3] != 255) {


        r1 = input.content[i];
        g1 = input.content[i+1];
        b1 = input.content[i+2];
        a1 = input.content[i+3];

        // destination
        r2 = bgColor.red;
        g2 = bgColor.green;
        b2 = bgColor.blue;
        a2 = 1;

        input.content[i] =   ((r1 * (a1/255) + r2 * ((255-a1)/255))).round();// red channel output
        input.content[i+1] = ((g1 * (a1/255) + g2 * ((255-a1)/255))).round();// red channel output
        input.content[i+2] = ((b1 * (a1/255) + b2 * ((255-a1)/255))).round();// red channel output
        input.content[i+3] = 255; // alpha


        //print("i: ${i}");
        //print("rgba1: $r1 $g1 $b1 $a1 || rgba2 $r2 $g2 $b2 $a2");
        //print("afterCalc: ${input.content[i]} ${input.content[i+1]} ${input.content[i+2]} ${input.content[i+3]}");
      }

    }

    return input;
  }


  /*
    a Bitmap in the Bitmap library provides a width, height and
    a 'contents' array that follows this structure:
    [R G B A R G B A R G B A R G B A R G B ... R G B A ]

    this method provides a way to get the index to access the [R G B A] values
    for a single pixel with X and Y coordinates, using the width and height of the bitmap

    NOTE: this is copied from bitmapDither.dart
    I intend to make that file into a separate library, so i'm not going
    to bother putting the function below into a separate file
   */
  static int _getPixelIndex(int bmpWidth, int bmpHeight, int x, int y) {

    x.clamp(0, bmpWidth);
    y.clamp(0, bmpHeight);
    return (bmpWidth*valuesPerPixel)*y + valuesPerPixel*x;
  }


  // applies SE's color limits to an image.
  static Bitmap applyColorLimits(Bitmap input) {

    for (int i = 0; i < input.size; i+=4) {

      int r = input.content[i];
      int g = input.content[i+1];
      int b = input.content[i+2];

      input.content[i] = ((r / bitSpacing).ceil() << 5);
      input.content[i+1] = ((g / bitSpacing).ceil() << 5);
      input.content[i+2] = ((b/bitSpacing).ceil() << 5);
    }

    return input;
  }

  // converts an input color (as three integers) into a special unicode character
  // that SE's 'monospace' font recognizes as a colored pixel.
  // this used to be done while using String.fromCharCode, with the 'char' actually being an integer.
  static int ColorToChar(int r, int g, int b)
  {
    return (0xe100 + ((r / bitSpacing).ceil() << 6) + ((g / bitSpacing).ceil() << 3) + (b/bitSpacing).ceil());
  }

  // converts an input bitmap into a special multi-line string made out of characters that
  // SE's 'monospace' font interprets as colored pixels.
  static String bitmapToString(Bitmap input) {
    int w = input.width;
    int h = input.height;

    // stringBuffer is used for it's speed.
    StringBuffer intermediate = StringBuffer();

    for (int i = 0; i < input.size; i+=4) {

      int r = input.content[i];
      int g = input.content[i+1];
      int b = input.content[i+2];
      int a = input.content[i+3];

      if (a == 0) {
        intermediate.writeCharCode(0xe100);
      } else {
        intermediate.writeCharCode(ColorToChar(r, g, b));
      }

      if (i/4 % w == 0 && i != 0) {
        intermediate.write("\n");
      }
    }

    return intermediate.toString();
  }

}