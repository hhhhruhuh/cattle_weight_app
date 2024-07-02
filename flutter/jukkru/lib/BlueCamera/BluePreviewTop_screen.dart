import 'dart:io';

import 'package:jukkru/BlueCamera/BlueCapturesTop_screen.dart';
import 'package:jukkru/Screens/Pages/BlueAndCameraSolution/BluePictureTWTop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:jukkru/DataBase/catImage_handler.dart';
import 'package:jukkru/DataBase/catTime_handler.dart';
import 'package:jukkru/model/catTime.dart';
import 'package:jukkru/model/image.dart';
import 'package:jukkru/model/utility.dart';


class BluePreviewTopScreen extends StatefulWidget {
  final int idPro;
  final int idTime;
  final File imageFile;
  final List<File> fileList;
  final CatTimeModel catTime;
  final BluetoothDevice server;
  final bool blueConnection;
  // final double heightValue;
  const BluePreviewTopScreen({
    Key? key,
    required this.idPro,
    required this.idTime,
    required this.imageFile,
    required this.fileList,
    required this.catTime,
    required this.server,
    required this.blueConnection,
    // required this.heightValue,
  }) : super(key: key);

  @override
  State<BluePreviewTopScreen> createState() => _BluePreviewTopScreenState();
}

class _BluePreviewTopScreenState extends State<BluePreviewTopScreen> {
  CatImageHelper ImageHelper = CatImageHelper();
  CatTimeHelper? catTimeHelper;
  late List<ImageModel> images;
  late Future<CatTimeModel> catTimeData;

  @override
  void initState() {
    // TODO: implement initState
    ImageHelper = CatImageHelper();
    catTimeHelper = CatTimeHelper();
    refreshImages();
    loadData();
    super.initState();
  }

  refreshImages() {
    ImageHelper.getCatTimePhotos(widget.idTime).then((imgs) {
      setState(() {
        images.clear();
        images.addAll(imgs);
      });
    });
  }

  loadData() async {
    catTimeData = catTimeHelper!.getCatTimeWithCatTimeID(widget.catTime.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preview"), actions: [
        FutureBuilder(
            future: catTimeData,
            builder: (context, AsyncSnapshot<CatTimeModel> snapshot) {
              if (snapshot.hasData) {
                return Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => BlueCapturesTopScreen(
                                idPro: widget.idPro,
                                idTime: widget.idTime,
                                imageFileList: widget.fileList,
                                catTime: snapshot.data!,
                                server: widget.server,
                                blueConnection: widget.blueConnection,

                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.photo)),
                    IconButton(
                        onPressed: () async {
                          final file = widget.imageFile;
                          String imgString =
                              Utility.base64String(file.readAsBytesSync());
                          ImageModel photo = ImageModel(
                              idPro: widget.idPro,
                              idTime: widget.idTime,
                              imagePath: imgString);

                          await ImageHelper.save(photo);

                          // print("imgString : $imgString");
                          await catTimeHelper!.updateCatTime(CatTimeModel(
                              id: snapshot.data!.id,
                              idPro: snapshot.data!.idPro,
                              weight: snapshot.data!.weight,
                              bodyLenght: snapshot.data!.bodyLenght,
                              heartGirth: snapshot.data!.heartGirth,
                              hearLenghtSide: snapshot.data!.hearLenghtSide,
                              hearLenghtRear: snapshot.data!.hearLenghtRear,
                              hearLenghtTop: snapshot.data!.hearLenghtTop,
                              pixelReference: snapshot.data!.pixelReference,
                              distanceReference:
                                  snapshot.data!.hearLenghtRear,
                              imageSide: snapshot.data!.imageSide,
                              imageRear: snapshot.data!.imageRear,
                              imageTop: imgString,
                              date: DateTime.now().toIso8601String(),
                              note: snapshot.data!.note));

                          setState(() {
                            refreshImages();
                          });

                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => BluePictureTWTop(
                                    imageFile: file,
                                    fileName: file.path,
                                    catTime: snapshot.data!,
                                    server: widget.server,
                                    blueConnection: widget.blueConnection,
                                  )));

                          // Navigator.of(context).pushAndRemoveUntil(
                          //     MaterialPageRoute(builder: (context) => CatTimeScreen(catProId: widget.idPro,)),
                          //     (Route<dynamic> route) => false);

                          // Navigator.pop(context);
                        },
                        icon: const Icon(Icons.save))
                  ],
                );
              } else {
                return Container();
              }
            })
      ]),
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: TextButton(
          //     onPressed: () {},
          //     child: Text('Go to all captures'),
          //     style: TextButton.styleFrom(
          //       primary: Colors.black,
          //       backgroundColor: Colors.white,
          //     ),
          //   ),
          // ),
          Expanded(
            child: Image.file(widget.imageFile),
          ),
        ],
      ),
    );
  }
}
