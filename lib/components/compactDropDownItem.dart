import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// sub-widget used in compactDropDown
class CompactDropdownItem extends StatefulWidget {


  CompactDropdownItem({
    Key key,
    this.value,
    this.onClick,
    this.width,
  }): super(key: key);

  final String value;
  final VoidCallback onClick;
  final double width;


  @override
  CompactDropdownItemState createState() => CompactDropdownItemState();
}

class CompactDropdownItemState extends State<CompactDropdownItem> {

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

          color: Theme.of(context).scaffoldBackgroundColor,

          child: Container(


            decoration: BoxDecoration(
                color: bgColor,
                border: Border.symmetric(
                  vertical: BorderSide(
                    color: Theme.of(context).hintColor,
                    width: 1,
                  ),

                )
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text(
                  this.widget.value,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),


            ),
          ),



        ),
      ),

    );
  }
}