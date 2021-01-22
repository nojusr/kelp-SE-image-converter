import 'package:bitmap/bitmap.dart';
import 'package:bitmap/transformations.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:kelp_se_image_converter/components/checkerboardPattern.dart';
import 'package:kelp_se_image_converter/components/compactCheckbox.dart';
import 'package:kelp_se_image_converter/components/resolutionInput.dart';
import 'package:kelp_se_image_converter/utilities/imagePipelineUtility.dart';
import 'package:kelp_se_image_converter/utilities/settingTypes.dart';
import 'package:kelp_se_image_converter/utilities/bitmapComputeParameters.dart';
import 'package:kelp_se_image_converter/utilities/bitmapRotate.dart';

import 'package:kelp_se_image_converter/components/compactButton.dart';
import 'package:kelp_se_image_converter/components/compactDropDown.dart';
import 'package:kelp_se_image_converter/components/compactIconButton.dart';
import 'package:kelp_se_image_converter/components/compactTextField.dart';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'package:mime/mime.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'dart:async';

void main() {
  runApp(
      const ProviderScope(
          child: KelpImageConverter(),
      ),
  );
}

final inputBmpProvider = StateProvider<Bitmap>((ref) {
  return Bitmap.blank(500, 500);
});

final inputFilepathProvider = StateProvider<String>((ref) {
  return "";
});

final outputPreviewBmpProvider = StateProvider<Bitmap>((ref){
  return Bitmap.blank(500, 500);
});



class KelpImageConverter extends StatelessWidget {
  const KelpImageConverter({Key key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kelp\'s SE image to text converter ',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          bodyText1: TextStyle(
            fontSize: 12,
          ),
        ),

      ),
      home: KelpHomePage(),
    );
  }
}

class KelpHomePage extends StatefulWidget {
  KelpHomePage({Key key}) : super(key: key);

  @override
  KelpHomePageState createState() => KelpHomePageState();
}

class KelpHomePageState extends State<KelpHomePage> {


  TextEditingController fileInputFieldController = TextEditingController();
  TextEditingController resolutionWidthFieldController = TextEditingController();
  TextEditingController resolutionHeightFieldController = TextEditingController();

  // settings
  String currentSelectedSurfaceType = "(None)";
  String currentSelectedSurfaceName = "(None)";
  String currentSelectedDitheringType = "(None)";

  Color bgColor = Colors.black;

  bool maintainAspectRatio = false;
  bool preserveTransparency = false;

  // text output string
  String output = "";

  // internal use values
  bool showResolutionInput = false;
  int customWidth = 0;
  int customHeight = 0;


  // a compute function to run the image pipeline and
  // convert a given input image to text.
  static String runPipeLineCompute(BitmapComputeParameters input) {

    if (input.preserveTransparency) {

      input.backgroundColor = Colors.transparent;
    }

    Bitmap scaled = ImagePipelineUtility.applyScaling(
      input: input.mainBmp,
      scalingOption: input.scalingOption,
      maintainAspect: input.preserveAspect,
      bgColor: input.backgroundColor,
      cWidth: input.customWidth,
      cHeight: input.customHeight,
    );

    Bitmap dithered = ImagePipelineUtility.applyDithering(scaled, input.ditheringOption);
    Bitmap nonTransparent = ImagePipelineUtility.handleTransparency(dithered, input.preserveTransparency, input.backgroundColor);
    String convert = ImagePipelineUtility.bitmapToString(nonTransparent);
    return convert;
  }

  // a compute function to partially run the input image
  // to the pipeline and return a the final bitmap that would
  // be converted to text.
  static Bitmap runPipeLinePreview(BitmapComputeParameters input) {
    
    if (input.preserveTransparency) {
      input.backgroundColor = Colors.transparent;
    }

    Bitmap scaled = ImagePipelineUtility.applyScaling(
      input: input.mainBmp,
      scalingOption: input.scalingOption,
      maintainAspect: input.preserveAspect,
      bgColor: input.backgroundColor,
      cWidth: input.customWidth,
      cHeight: input.customHeight,
    );

    Bitmap dithered = ImagePipelineUtility.applyDithering(scaled, input.ditheringOption);
    Bitmap nonTransparent = ImagePipelineUtility.handleTransparency(dithered, input.preserveTransparency, input.backgroundColor);
    return nonTransparent;
  }

  // async function that computes a converted image preview for a given
  // input image
  void updatePreview(BuildContext context) async {
    Bitmap inputBmp = context.read(inputBmpProvider).state;
    Bitmap preview = await compute(runPipeLinePreview, BitmapComputeParameters(
      mainBmp: inputBmp,
      scalingOption: currentSelectedSurfaceType,
      ditheringOption: currentSelectedDitheringType,
      preserveAspect: maintainAspectRatio,
      preserveTransparency: preserveTransparency,
      customWidth: customWidth,
      customHeight: customHeight,
      backgroundColor: bgColor,
    ));
    context.read(outputPreviewBmpProvider).state = preview;
  }

  // verifies that a given input path does indeed contain a file,
  // and that said file is indeed an image, then updates the global
  // state with the new input image.
  Future<void> verifyAndSetInputFile(BuildContext context, String path) async {

    const List<String> allowedMimeTypes = [
      "image/png",
      "image/jpeg",
      "imgae/jpg",
    ];

    if (allowedMimeTypes.contains(lookupMimeType(path)) == false){
      return;
    }

    final File file = File(path);
    final FileImage fImg = FileImage(file);

    print(lookupMimeType(path));


    context.read(inputBmpProvider).state = await Bitmap.fromProvider(fImg);
    context.read(inputFilepathProvider).state = path;

    fileInputFieldController.value = fileInputFieldController.value.copyWith(
      text: path,
      selection: TextSelection(baseOffset: path.length, extentOffset: path.length),
      composing: TextRange.empty,
    );
  }


  @override
  void InitState () {
    super.initState();
    resolutionWidthFieldController.value = TextEditingValue(
      text: "178",
    );
    resolutionHeightFieldController.value = TextEditingValue(
      text: "178",
    );
  }

  @override
  void dispose() {

    resolutionWidthFieldController.dispose();
    resolutionHeightFieldController.dispose();
    fileInputFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final boldTextStyle = Theme.of(context).textTheme.bodyText1.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: Theme.of(context).textTheme.bodyText1.fontSize+0.5,
    );

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(5),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                 Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 5),

                      child: Text(
                        "Image Preview:",
                        style: boldTextStyle,
                      ),
                    ),

                    Container(
                      width: 400,
                      height: 400,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [

                          CheckerboardPattern(
                            height: 400,
                            width: 400,
                          ),

                          Consumer(builder: (context, watch, _){

                            Bitmap bmp = watch(inputBmpProvider).state;
                            Uint8List headedBitmap = bmp.buildHeaded();
                            return Image.memory(
                              headedBitmap,
                              fit: BoxFit.contain,
                              isAntiAlias: false,
                            );
                          }),
                        ],
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Row(

                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [

                          CompactIconButton(
                            width: 25,
                            child: Icon(Icons.rotate_left, size: 20),
                            onClick: () {
                              Bitmap bmpToEdit = context.read(inputBmpProvider).state;
                              Bitmap output = rotateCounterClockwise(bmpToEdit);
                              context.read(inputBmpProvider).state = output;
                              updatePreview(context);
                            },


                          ),
                          Container(width: 5,),
                          CompactIconButton(
                            width: 25,
                            child: Icon(Icons.rotate_right, size: 20),
                            onClick: () {
                              Bitmap bmpToEdit = context.read(inputBmpProvider).state;
                              Bitmap output = rotateClockwise(bmpToEdit);
                              context.read(inputBmpProvider).state = output;
                              updatePreview(context);
                            },
                          ),
                          Container(width: 5,),
                          CompactIconButton(
                            width: 25,
                            child: Icon(Icons.flip, size: 20),
                            onClick: () {
                              Bitmap bmpToEdit = context.read(inputBmpProvider).state;
                              Bitmap output = flipHorizontal(bmpToEdit);
                              context.read(inputBmpProvider).state = output;
                              updatePreview(context);
                            },
                          ),
                          Container(width: 5,),
                          CompactIconButton(
                            width: 25,
                            child: Transform.rotate(
                              angle: 3.1415/2,
                              child: Icon(Icons.flip, size: 20,),
                            ),
                            onClick: () {
                              Bitmap bmpToEdit = context.read(inputBmpProvider).state;
                              Bitmap output = flipVertical(bmpToEdit);
                              context.read(inputBmpProvider).state = output;
                              updatePreview(context);
                            },
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(vertical: 5),

                      child: Text(
                        "Converted image Preview:",
                        style: boldTextStyle,
                      ),
                    ),

                    Container(
                      width: 400,
                      height: 400,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [

                          CheckerboardPattern(
                            height: 400,
                            width: 400,
                          ),

                          Consumer(builder: (context, watch, _){

                            Bitmap bmp = watch(outputPreviewBmpProvider).state;
                            Uint8List headedBitmap = bmp.buildHeaded();
                            return Image.memory(
                              headedBitmap,
                              fit: BoxFit.contain,
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),

                Container(
                  padding: EdgeInsets.only(top: 5, left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Instructions:", style: boldTextStyle,),
                      Text(
                        "1) Browse for your desired image file.\n"
                        "2) Select surface type and name.\n"
                        "3) Select dithering option.\n"
                        "4) Click \"Convert\".\n"
                        "5) Copy and Paste the text to your in-game LCD panel\n"
                        "6) Set the \"Content\" to \"Text and Images\".\n"
                        "7) Set font size to 0.1, text padding to 0 and font to \"MONOSPACED\"",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),

                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CompactTextField(
                              hintText: "Image Path",
                              fieldWidth: 400,
                              controller: fileInputFieldController,
                              onSubmitted: (String input) async {
                                if (await File(input).exists()) {
                                  verifyAndSetInputFile(context, input);
                                  updatePreview(context);
                                }
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 5),
                              child: CompactButton(
                                width: 70,
                                title: "Browse",
                                onClick: () async{
                                  final FilePickerResult result = await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ["png", "jpg", "jpeg"]
                                  );

                                  if (result == null) {
                                    return;
                                  }

                                  await verifyAndSetInputFile(context, result.files.single.path);
                                  updatePreview(context);

                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Text("Surface Type:", style: boldTextStyle,),
                                ),

                                CompactDropDown(
                                  items: settingTypes.surfaceTypeChoices,
                                  value: currentSelectedSurfaceType,
                                  width: 180,
                                  onChanged: (String change) {
                                    setState(() {
                                      currentSelectedSurfaceType = change;
                                      if (change == "(Custom)") {
                                        showResolutionInput = true;
                                      } else {
                                        showResolutionInput = false;
                                      }
                                    });
                                    updatePreview(context);
                                  },
                                ),
                              ],
                            ),
                            Container(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Text("Dithering Mode:", style: boldTextStyle,),
                                ),

                                CompactDropDown(
                                  items: settingTypes.ditheringTypes,
                                  value: currentSelectedDitheringType,
                                  width: 180,
                                  onChanged: (String change) {
                                    setState(() {
                                      currentSelectedDitheringType = change;
                                    });
                                    updatePreview(context);
                                  },
                                ),
                              ],
                            ),
                            Container(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Padding(
                                  padding: EdgeInsets.only(bottom: 5),
                                  child: Text("Background Color:", style: boldTextStyle,),
                                ),


                                Row(
                                  children: [
                                    Container(
                                      width: 25,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Theme.of(context).hintColor,
                                          width: 1,
                                        ),
                                        color: bgColor,
                                      ),
                                    ),
                                    Container(width: 10,),
                                    CompactButton(
                                      title: "Change",
                                      width: 100,
                                      onClick: () {

                                        Color pickerColor = bgColor;

                                        showDialog(
                                          context: context,
                                          child: AlertDialog(

                                            content: SingleChildScrollView(
                                              child: ColorPicker(
                                                wheelWidth: 15,
                                                width: 30,
                                                height: 30,
                                                enableShadesSelection: false,
                                                color: pickerColor,
                                                onColorChanged: (Color c) {
                                                  pickerColor = c;
                                                },
                                                showMaterialName: false,
                                                showColorName: false,
                                                showColorCode: true,
                                                materialNameTextStyle: Theme.of(context).textTheme.caption,
                                                colorNameTextStyle: Theme.of(context).textTheme.caption,
                                                colorCodeTextStyle: Theme.of(context).textTheme.caption,
                                                pickersEnabled: const <ColorPickerType, bool>{
                                                  ColorPickerType.both: false,
                                                  ColorPickerType.primary: false,
                                                  ColorPickerType.accent: false,
                                                  ColorPickerType.bw: false,
                                                  ColorPickerType.custom: false,
                                                  ColorPickerType.wheel: true,
                                                },
                                              ),
                                            ),

                                            actions: <Widget>[
                                              FlatButton(
                                                child: const Text('Update'),
                                                onPressed: () {
                                                  setState(() {
                                                    bgColor = pickerColor;
                                                  });
                                                  updatePreview(context);
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),

                      showResolutionInput ?
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: ResolutionInput(
                          widthTController: resolutionWidthFieldController,
                          heightTController: resolutionHeightFieldController,
                          onChangedWidth: (value) {
                            customWidth = int.parse(value);
                            if (customWidth > 0 && customHeight > 0) {
                              updatePreview(context);
                            }
                          },
                          onChangedHeight: (value) {
                            customHeight = int.parse(value);
                            if (customWidth > 0 && customHeight > 0) {
                              updatePreview(context);
                            }
                          },
                        ),
                      ) : Container(),

                      Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            CompactCheckbox(
                              size: 15,
                              startingValue: false,
                              onClick: (value) {
                                setState(() {
                                  maintainAspectRatio = value;
                                });
                                updatePreview(context);
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 5, right: 10),
                              child: Text("Maintain Aspect Ratio"),
                            ),

                            CompactCheckbox(
                              size: 15,
                              startingValue: false,
                              onClick: (value) {
                                setState(() {
                                  preserveTransparency = value;
                                });
                                updatePreview(context);
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 5, right: 10),
                              child: Text("Preserve Transparency"),
                            ),

                          ],
                        ),
                      ),


                      Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 20),
                        child: CompactButton(
                          title: "Convert",
                          onClick: () async {
                            setState(() {
                              output = "";
                            });


                            Bitmap bmpToConvert = context.read(inputBmpProvider).state;

                            String converted = await compute(runPipeLineCompute, BitmapComputeParameters(
                              mainBmp: bmpToConvert,
                              scalingOption: currentSelectedSurfaceType,
                              ditheringOption: currentSelectedDitheringType,
                              preserveAspect: maintainAspectRatio,
                              preserveTransparency: preserveTransparency,
                              customHeight: customHeight,
                              customWidth: customWidth,
                              backgroundColor: bgColor,
                            ));
                            setState(() {
                              output = converted;
                            });


                          },
                        ),
                      ),

                      Text("Text output:", style: boldTextStyle,),

                      Padding(
                        padding: EdgeInsets.only(bottom: 5),
                        child: Text(
                          "(Should look like gibberish. Copy the text below into your LCD panel)",
                          style: Theme.of(context).textTheme.bodyText1
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            border: Border.all(
                              width: 1,
                              color: Theme.of(context).hintColor,
                            )
                        ),
                        height: 200,
                        width: 560,
                        child: SelectableText(output, maxLines: 1),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: CompactButton(
                          width: 150,
                          title: "Copy output to clipboard",
                          onClick: () {
                            Clipboard.setData(ClipboardData(text: output));
                          },
                        ),
                      ),


                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
