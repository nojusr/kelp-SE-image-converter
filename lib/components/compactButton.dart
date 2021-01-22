import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// a simple widget that creates a compact, desktop-oriented button
class CompactButton extends StatefulWidget {


  CompactButton({
    Key key,
    this.title,
    this.onClick,
    this.width,
  }): super(key: key);

  final String title;
  final VoidCallback onClick;
  final double width;


  @override
  CompactButtonState createState() => CompactButtonState();
}

class CompactButtonState extends State<CompactButton> {

  bool isHovering = false;
  bool isPressing = false;


  @override
  Widget build(BuildContext context) {

    Color bgColor;

    if (!isPressing) {
      if (isHovering) {
        bgColor = Colors.white.withOpacity(0.04);
      } else {
        bgColor = Colors.black.withOpacity(0.1);
      }
    } else {
      bgColor = Colors.white.withOpacity(0.1);
    }



    return MouseRegion(

      cursor: SystemMouseCursors.click,

      onEnter: (event) {
        setState(() {
          isHovering = true;
        });
      },

      onExit: (event) {
        setState(() {
          isHovering = false;
        });
      },

      child: GestureDetector(

        onTapDown:(event) {
          setState(() {
            isPressing = true;
          });
        },

        onTapCancel: () {
          setState(() {
            isPressing = false;
          });
        },

        onTapUp: (event) {
          setState(() {
            isPressing = false;
          });
          this.widget.onClick();
        },

        child: Container(
          height: 25,
          width: this.widget.width == null? 100 : this.widget.width,

          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(
              color: Theme.of(context).hintColor,
              width: 1,
            )
          ),
          child: Center(
            child: Text(
              this.widget.title,
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        ),
      ),


    );
  }
}