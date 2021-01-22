import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// a simple widget that creates a compact, desktop-oriented button
class CompactIconButton extends StatefulWidget {


  CompactIconButton({
    Key key,
    this.child,
    this.onClick,
    this.width,
  }): super(key: key);

  final Widget child;
  final VoidCallback onClick;
  final double width;


  @override
  CompactIconButtonState createState() => CompactIconButtonState();
}

class CompactIconButtonState extends State<CompactIconButton> {

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
            child: this.widget.child,
          ),
        ),
      ),


    );
  }
}