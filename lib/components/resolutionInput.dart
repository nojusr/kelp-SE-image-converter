import 'package:flutter/material.dart';
import 'package:kelp_se_image_converter/components/compactNumberField.dart';


class ResolutionInput extends StatefulWidget {

  ResolutionInput({
    this.widthTController,
    this.heightTController,
    this.onChangedWidth,
    this.onChangedHeight,

  });

  TextEditingController widthTController;
  TextEditingController heightTController;

  Function(String) onChangedWidth;
  Function(String) onChangedHeight;


  @override
  ResolutionInputState createState() => ResolutionInputState();
}

class ResolutionInputState extends State<ResolutionInput> {

  @override
  Widget build(BuildContext context) {


    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Width:"),
            CompactNumberField(
              fieldWidth: 70,
              controller: this.widget.widthTController,
              onChanged: this.widget.onChangedWidth,
            ),
          ],
        ),
        Container(
          width: 10,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Height:"),
            CompactNumberField(
              fieldWidth: 70,
              controller: this.widget.heightTController,
              onChanged: this.widget.onChangedHeight,
            ),
          ],
        ),
      ],
    );


  }
}