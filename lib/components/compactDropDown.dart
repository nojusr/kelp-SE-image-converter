import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kelp_se_image_converter/components/compactDropDownItem.dart';

// a simple widget that creates a compact, desktop-oriented dropdown menu
class CompactDropDown extends StatefulWidget {

  CompactDropDown({
    Key key,
    this.items,
    this.onChanged,
    this.value,
    this.width,
  }): super(key: key);

  List<String> items = List<String>();
  final String value;
  final Function(String) onChanged;
  final double width;

  @override
  CompactDropDownState createState() => CompactDropDownState();
}

class CompactDropDownState extends State<CompactDropDown> {

  bool isHovering = false;
  bool isPressing = false;


  bool isMenuOpen = false;

  OverlayEntry dropMenuOverlay;

  OverlayEntry createDropOverlayEntry (TapUpDetails d, BuildContext bc) {
    RenderBox renderBox = context.findRenderObject();

    var offset = renderBox.localToGlobal(Offset.zero);

    double menuHeight = (25*this.widget.items.length).toDouble();
    double screenHeight = MediaQuery.of(bc).size.height;
    bool renderUpwards = false; // renders items downwards otherwise

    if ((offset.dy+25+menuHeight) > screenHeight ) {
      renderUpwards = true;
    }


    List<CompactDropdownItem> listItems = this.widget.items.map((value){
      return CompactDropdownItem(
        value: value,
        width: this.widget.width,
        onClick: () {
          dropMenuOverlay.remove();
          this.widget.onChanged(value);
          isMenuOpen = false;
        },
      );
    }).toList();

    if (renderUpwards) {
      listItems = listItems.reversed.toList();
    }

    return OverlayEntry(
      opaque: false,
      builder: (context) {

        return Stack(
          fit: StackFit.passthrough,
          children: [
            Container(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTapDown: (deets) {
                  dropMenuOverlay.remove();
                  isMenuOpen = false;
                },
              ),
            ),

            Positioned(
              left: offset.dx,
              top: renderUpwards? offset.dy-menuHeight-1 : offset.dy+25,
              child:Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: !renderUpwards? BorderSide(
                      width: 1,
                      color: Theme.of(bc).hintColor,
                    ):BorderSide(
                        width: 0,
                        color: Colors.transparent
                    ),

                    top: renderUpwards? BorderSide(
                      width: 1,
                      color: Theme.of(bc).hintColor,
                    ):BorderSide(
                      width: 0,
                      color: Colors.transparent
                    ),
                  ),
                ),
                child: Column(
                  children: listItems,
                ),
              ),
            ),
          ],
        );
      },

    );
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
        setState(() {isHovering = true;});
      },

      onExit: (event) {
        setState(() {isHovering = false;});
      },

      child: GestureDetector(

        onTapDown:(event) {
          setState(() {isPressing = true;});
        },

        onTapCancel: () {
          setState(() {isPressing = false;});
        },

        onTapUp: (event) {
          setState(() {isPressing = false;});

          if (isMenuOpen == false) {
            dropMenuOverlay = createDropOverlayEntry(event, context);
            Overlay.of(context).insert(dropMenuOverlay);
            isMenuOpen = true;
          } else {
            dropMenuOverlay.remove();
            isMenuOpen = false;
          }
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

          padding: EdgeInsets.symmetric(horizontal: 5),

          child: Row(
            children: [
              Expanded(
                child: Text(
                  this.widget.value,
                  style: Theme.of(context).textTheme.bodyText1,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                ),
              ),

              Icon(
                Icons.arrow_drop_down,
              ),
            ]
          ),
        ),

      ),


    );
  }
}