import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CompactCheckbox extends StatefulWidget {

  CompactCheckbox({
    Key key,
    this.onClick,
    this.size,
    this.startingValue,
  }): super(key: key);

  Function(bool) onClick;
  bool startingValue;
  double size;

  @override
  CompactCheckboxState createState() => CompactCheckboxState();
}

class CompactCheckboxState extends State<CompactCheckbox> {



  bool isHovering = false;
  bool isPressing = false;
  bool value;

  @override
  void initState() {
    value = this.widget.startingValue == null ? false : this.widget.startingValue;
    super.initState();
  }


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
            value = !value;
          });
          this.widget.onClick(value);
        },

        child: Container(
          height: this.widget.size,
          width: this.widget.size,

          decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(
                color: Theme.of(context).hintColor,
                width: 1,
              )
          ),
          child: Center(
            child: value == true
                ? Transform.scale(scale: 0.65, alignment: Alignment.topLeft, origin: Offset(-4.5, -5), child: Icon(Icons.check),)   //Icons.check)
                : Container()
          ),
        ),
      ),


    );
  }
}