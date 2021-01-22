import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// widget that generates a checkerboard pattern
// that is commonly used to convey transparency
class CheckerboardPattern extends StatelessWidget {

  final double width;
  final double height;

  CheckerboardPattern({
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: this.width,
      height: this.height,

      decoration: BoxDecoration(),
      clipBehavior: Clip.hardEdge,

      child: CustomPaint(
        willChange: false,
        painter: CheckerboardPainter(
          bgColor: Colors.white,
          checkerColor: Color(0xFFDCDCDC),
          checkerSize: 20,
        ),
      ),

    );

  }
}

class CheckerboardPainter extends CustomPainter {

  Color checkerColor;
  Color bgColor;
  double checkerSize;

  CheckerboardPainter({
    this.bgColor,
    this.checkerColor,
    this.checkerSize,
  });


  @override
  void paint(Canvas canvas, Size size) {

    // determine square count
    int checkerCountX = (size.width/checkerSize).ceil();
    int checkerCountY = (size.height/checkerSize).ceil();

    canvas.drawColor(bgColor, BlendMode.srcOver); // draw bg

    Paint checkerPaint = Paint();
    checkerPaint.color = this.checkerColor;
    checkerPaint.style = PaintingStyle.fill;


    for (int i = 0; i < checkerCountX; i++) {
      for (int j = 0; j < checkerCountY; j++) {

        double drawPosX = (checkerSize/2)+(checkerSize*i);
        double drawPosY = (checkerSize/2)+(checkerSize*j);

        Rect drawRect = Rect.fromCenter(
          center: Offset(drawPosX, drawPosY),
          height: checkerSize,
          width: checkerSize,
        );

        if (j%2 == 0) {
          if ((i+1)%2 == 0) {
            canvas.drawRect(drawRect, checkerPaint);
          }

        } else {
          if (i % 2 == 0) {
            canvas.drawRect(drawRect, checkerPaint);
          }
        }
      }
    }

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
