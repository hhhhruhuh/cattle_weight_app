
import 'dart:math';

import 'package:jukkru/Screens/Widgets/MainButton.dart';
import 'package:jukkru/Screens/Widgets/PaintPoint.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:jukkru/Screens/Widgets/PaintLine.dart';
import 'package:jukkru/Screens/Widgets/position.dart';
import 'package:jukkru/Screens/Widgets/preview.dart';

Positions pos = Positions();

class LineAndPosition extends StatefulWidget {
  final String imgPath;
  final String fileName;
  final VoidCallback onSelected;
  const LineAndPosition({Key? key, required this.imgPath, required this.fileName, required this.onSelected}) : super(key: key);

  @override
  LineAndPositionState createState() => LineAndPositionState();
}

class LineAndPositionState extends State<LineAndPosition> {
  List<double> positionsX = [];
  List<double> positionsY = [];
  double pixelDistance = 0;
  int index = 0;

  void onTapDown(BuildContext context, TapDownDetails details) {
    print('${details.globalPosition}');
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(details.globalPosition);

    setState(() {
      index++;
      positionsX.add(localOffset.dx);
      positionsY.add(localOffset.dy);
      // Distance calculation
      positionsX.length % 2 == 0
          ? pixelDistance = sqrt(((positionsX[index] - positionsX[index - 1]) *
                  (positionsX[index] - positionsX[index - 1])) +
              ((positionsY[index] - positionsY[index - 1]) *
                  (positionsY[index] - positionsY[index - 1])))
          : pixelDistance = pixelDistance;

      // print("Pixel Distance = ${pixelDistance}");
      pos.setPixelDistance(pixelDistance);
      print("POS  = ${pos.getPixelDistance()}");
    });
  }

  @override
  void initState() {
    super.initState();
    positionsX.add(100);
    positionsY.add(100);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) => onTapDown(context, details),
      child: Stack(fit: StackFit.loose, children: <Widget>[
        // Hack to expand stack to fill all the space. There must be a better
        // way to do it.
        // new Container(color: Colors.white),
        RotatedBox(
          quarterTurns: 1,
          child: PreviewScreen(
            imgPath: widget.imgPath,
            fileName: widget.fileName,
          ),
        ),
        //// Show position (x2,y2)
        // new Positioned(
        //   child: new Text(
        //       '(${positionsX[index].toInt()} , ${positionsY[index].toInt()})'),
        //   left: positionsX[index],
        //   top: positionsY[index],
        // ),
        //// Show position (x1,y1)
        // positionsX.length % 2 == 0
        //     ? new Positioned(
        //         child: new Text(
        //             '(${positionsX[index - 1].toInt()} , ${positionsY[index - 1].toInt()})'),
        //         left: positionsX[index - 1],
        //         top: positionsY[index - 1],
        //       )
        //     : Container(),
        // // Distance calculation
        // positionsX.length % 2 == 0
        //     ? Text(
        //         "${sqrt(((positionsX[index] - positionsX[index - 1]) * (positionsX[index] - positionsX[index - 1])) + ((positionsY[index] - positionsY[index - 1]) * (positionsY[index] - positionsY[index - 1])))}")
        //     : Container(),
        PathCircle(
          x1: positionsX[index],
          y1: positionsY[index],
        ),
        positionsX.length % 2 == 0
            ? PathCircle(
                x1: positionsX[index - 1],
                y1: positionsY[index - 1],
              )
            : Container(),
        positionsX.length % 2 == 0
            ? PathExample(
                x1: positionsX[index - 1],
                y1: positionsY[index - 1],
                x2: positionsX[index],
                y2: positionsY[index],
              )
            : Container(),

        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            MainButton(
                onSelected: () {
                  widget.onSelected();
                },
                title: "บันทึก", pixelDistance: 10,),
          ]),
        ),
      ]),
    );
  }
}
