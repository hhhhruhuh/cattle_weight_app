

import 'dart:io';

import 'package:jukkru/Screens/Pages/GallorySolutions/PictureHgTop.dart';
import 'package:jukkru/model/calculation.dart';
import 'package:flutter/material.dart';

import 'package:jukkru/DataBase/catTime_handler.dart';
import 'package:jukkru/Screens/Widgets/MainButton.dart';
import 'package:jukkru/Screens/Widgets/PaintLine.dart';
import 'package:jukkru/Screens/Widgets/PaintPoint.dart';
import 'package:jukkru/Screens/Widgets/position.dart';
import 'package:jukkru/Screens/Widgets/preview.dart';
import 'package:jukkru/convetHex.dart';
import 'package:jukkru/model/catTime.dart';

ConvertHex hex = ConvertHex();
Positions pos = Positions();
CattleCalculation calculate = CattleCalculation();

class GalloryTWTop extends StatefulWidget {
  final File? imageFile;
  final String? fileName;
  final CatTimeModel? catTime;
  const GalloryTWTop({
    Key? key,
    this.imageFile,
    this.fileName,
    this.catTime,
  }) : super(key: key);

  @override
  _GalloryTWTopState createState() => _GalloryTWTopState();
}

class _GalloryTWTopState extends State<GalloryTWTop> {
  bool showState = false;
  final TextEditingController _textFieldController = TextEditingController();
  CatTimeHelper ?catTimeHelper;
  Future<CatTimeModel> ?catTimeData;

  loadData() async {
    catTimeData = catTimeHelper?.getCatTimeWithCatTimeID(widget.catTime!.id!);
  }

  @override
  void initState() {
    super.initState();
    catTimeHelper = CatTimeHelper();

    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("[1/2] กรุณาระบุความกว้างกระดูกก้นกบของโค",
                style: TextStyle(
                    fontSize: 24,
                    color: Color(hex.hexColor("ffffff")),
                    fontWeight: FontWeight.bold)),
            backgroundColor: Color(hex.hexColor("#007BA4"))),
        body: FutureBuilder(
            future: catTimeData,
            builder: (context, AsyncSnapshot<CatTimeModel> snapshot) {
              if (snapshot.hasData) {
                return Stack(
                  children: [
                    KLaPGalloryTWTop(
                        imgPath: widget.imageFile!.path,
                        fileName: widget.fileName!),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              MainButton(
                                  onSelected: () async {
                                    // print("POS: ${pos.getPixelDistance().toStringAsFixed(4)}\tHear Lenght Rear: ${snapshot.data.hearLenghtRear.toStringAsFixed(4)}");

                                    await catTimeHelper?.updateCatTime(
                                        CatTimeModel(
                                            id: snapshot.data!.id,
                                            idPro: snapshot.data!.idPro,
                                            weight: snapshot.data!.weight,
                                            bodyLenght:
                                                snapshot.data!.bodyLenght,
                                            heartGirth:
                                                snapshot.data!.heartGirth,
                                            hearLenghtSide:
                                                snapshot.data!.hearLenghtSide,
                                            hearLenghtRear:
                                                snapshot.data!.hearLenghtRear,
                                            hearLenghtTop:
                                                snapshot.data!.hearLenghtTop,
                                            pixelReference:
                                                pos.getPixelDistance(),
                                            distanceReference:
                                                snapshot.data!.hearLenghtRear,
                                            imageSide: snapshot.data!.imageSide,
                                            imageRear: snapshot.data!.imageRear,
                                            imageTop: snapshot.data!.imageTop,
                                            date: DateTime.now()
                                                .toIso8601String(),
                                            note: snapshot.data!.note));

                                    loadData();
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => GalloryHGTop(
                                                imgPath: widget.imageFile!.path,
                                                fileName: widget.fileName,
                                                catTimeID: snapshot.data!.id)));
                                  },
                                  title: "บันทึก", pixelDistance: 10,),
                            ]),
                      ),
                    ),
                    showState
                        ? Container()
                        : AlertDialog(
                            // backgroundColor: Colors.black,
                            title: const Text("ระบุความกว้างกระดูกก้นกบของโค",
                                style: TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.bold)),
                            content: Image.asset(
                                "assets/images/TopLeftNavigation3.png"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  setState(() => showState = !showState);
                                },
                                // => Navigator.pop(context, 'ตกลง'),
                                child: const Text('ตกลง',
                                    style: TextStyle(fontSize: 24)),
                              ),
                            ],
                          ),
                  ],
                );
              } else {
                return Center(child: Container(child: const Text("กรุณาเปลี่ยนรูปด้านบนโค",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),));
              }
            }));
  }
}

class KLaPGalloryTWTop extends StatefulWidget {
  final String? imgPath;
  final String? fileName;
  final VoidCallback? onSelected;
  const KLaPGalloryTWTop({Key? key, this.imgPath, this.fileName, this.onSelected}) : super(key: key);

  @override
  KLaPGalloryTWTopState createState() => KLaPGalloryTWTopState();
}

class KLaPGalloryTWTopState extends State<KLaPGalloryTWTop> {
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
          ? pixelDistance = calculate.pixelDistance(positionsX[index - 1],
              positionsY[index - 1], positionsX[index], positionsY[index])
          // pixelDistance = sqrt(((positionsX[index] - positionsX[index - 1]) *
          //         (positionsX[index] - positionsX[index - 1])) +
          //     ((positionsY[index] - positionsY[index - 1]) *
          //         (positionsY[index] - positionsY[index - 1])))
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
            imgPath: widget.imgPath!,
            fileName: widget.fileName!,
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

        // Padding(
        //   padding: EdgeInsets.all(20),
        //   child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        //     MainButton(
        //         onSelected: () {
        //           widget.onSelected();
        //         },
        //         title: "บันทึก"),
        //   ]),
        // ),
      ]),
    );
  }
}
