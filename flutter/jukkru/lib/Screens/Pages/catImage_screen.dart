import 'dart:io';

import 'package:jukkru/Camera/cameraSide_screen.dart';
import 'package:jukkru/DataBase/catImage_handler.dart';
import 'package:jukkru/DataBase/catPro_handler.dart';
import 'package:jukkru/DataBase/catTime_handler.dart';
import 'package:jukkru/Screens/Pages/catPro_Edit.dart';
import 'package:jukkru/model/catPro.dart';
import 'package:jukkru/model/catTime.dart';
import 'package:jukkru/model/imageNavidation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:image_picker/image_picker.dart';

import 'package:jukkru/model/image.dart';
import 'package:jukkru/model/utility.dart';
import 'package:intl/intl.dart';

class CatImageScreen extends StatefulWidget {
  final int idPro;
  final int idTime;
  const CatImageScreen({Key? key, required this.idPro, required this.idTime})
      : super(key: key);

  @override
  State<CatImageScreen> createState() => _CatImageScreenState();
}

class _CatImageScreenState extends State<CatImageScreen> {
  late Future<File> imageFile;
  late Image image;
  CatImageHelper? ImageHelper;
  CatTimeHelper? catTimeHelper;
  CatProHelper? catProHelper;
  late Future<CatProModel> catProData;
  late Future<CatTimeModel> catTimeData;
  late List<ImageModel> images;
  final ImagePicker _picker = ImagePicker();
  final formatDay = DateFormat('dd/MM/yyyy hh:mm a');
  ImageNavidation line = ImageNavidation();
  NoteDialog dialog = NoteDialog();

  @override
  void initState() {
    super.initState();
    images = [];
    ImageHelper = CatImageHelper();
    catTimeHelper = CatTimeHelper();
    catProHelper = CatProHelper();
    refreshImages();
  }

  refreshImages() {
    catProData = catProHelper!.getCatProWithID(widget.idPro);
    catTimeData = catTimeHelper!.getCatTimeWithCatTimeID(widget.idTime);
    ImageHelper!.getCatTimePhotos(widget.idTime).then((imgs) {
      setState(() {
        images.clear();
        images.addAll(imgs);
      });
    });
  }

  final picker = ImagePicker();
  // Implementing the image picker
  Future<void> pickImageFromGallery() async {
    final pickedImage =
        await picker.pickImage(source: ImageSource.gallery).then((imgFile) {
      final file = File(imgFile!.path);
      String imgString = Utility.base64String(file.readAsBytesSync());
      ImageModel photo = ImageModel(
          idPro: widget.idPro, idTime: widget.idTime, imagePath: imgString);
      ImageHelper!.save(photo);
      refreshImages();
    });
  }

  gridView() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        children: images.map((photo) {
          return InkWell(
              onTap: () {
                print("photo id: ${photo.id}");
                ImageHelper!.delete(photo);
                refreshImages();
              },
              child: Utility.imageFromBase64String(photo.imagePath));
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: catProData,
        builder: (context, AsyncSnapshot<CatProModel> catPro) {
          if (catPro.hasData) {
            return FutureBuilder(
                future: catTimeData,
                builder: (context, AsyncSnapshot<CatTimeModel> snapshot) {
                  if (snapshot.hasData) {
                    List<DataColumn> createColumns() {
                      return [
                        const DataColumn(
                            label:
                                Text('หัวข้อ', style: TextStyle(fontSize: 24))),
                        DataColumn(
                            label: Text('รายละเอียด'.toUpperCase(),
                                style: const TextStyle(fontSize: 24))),
                        const DataColumn(
                            label: Text('', style: TextStyle(fontSize: 24))),
                      ];
                    }

                    List<DataRow> createRows() {
                      return [
                        DataRow(cells: [
                          const DataCell(Text('ชื่อโค',
                              style: TextStyle(
                                fontSize: 24,
                              ))),
                          DataCell(SizedBox(
                            width: 96,
                            child: Text(catPro.data!.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                          )),
                          DataCell(IconButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        CatProFormEdit(catPro: catPro.data!)));
                              },
                              icon: const Icon(Icons.edit))),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('เพศ',
                              style: TextStyle(
                                fontSize: 24,
                              ))),
                          DataCell(Text(catPro.data!.gender,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold))),
                          DataCell(IconButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        CatProFormEdit(catPro: catPro.data!)));
                              },
                              icon: const Icon(Icons.edit))),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('สายพันธุ์',
                              style: TextStyle(
                                fontSize: 24,
                              ))),
                          DataCell(Text(catPro.data!.species,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold))),
                          DataCell(IconButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        CatProFormEdit(catPro: catPro.data!)));
                              },
                              icon: const Icon(Icons.edit))),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('รอบอก',
                              style: TextStyle(
                                fontSize: 24,
                              ))),
                          DataCell(Text(
                              snapshot.data!.heartGirth.toStringAsFixed(2),
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold))),
                          const DataCell(Text('')),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('ความยาวลำตัว',
                              style: TextStyle(
                                fontSize: 24,
                              ))),
                          DataCell(Text(
                              snapshot.data!.bodyLenght.toStringAsFixed(2),
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold))),
                          const DataCell(Text('')),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('น้ำหนัก\t(Kg)',
                              style: TextStyle(
                                fontSize: 24,
                              ))),
                          DataCell(Text(
                              snapshot.data!.weight.toStringAsFixed(2),
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold))),
                          const DataCell(Text('')),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text(
                            'วันที่',
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          )),
                          DataCell(SizedBox(
                            width: 108,
                            child: Text(
                                formatDay.format(DateTime.parse(snapshot.data!.date)),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                          )),
                          const DataCell(Text('')),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('ข้อความ',
                              style: TextStyle(
                                fontSize: 24,
                              ))),
                          DataCell(SizedBox(
                            width: 96,
                            child: Text(snapshot.data!.note,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold)),
                          )),
                          DataCell(IconButton(
                              onPressed: () {
                                bool newNote = true;

                                ((snapshot.data!.note == null) ||
                                        (snapshot.data!.note == ''))
                                    ? newNote = true
                                    : newNote = false;
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      dialog.buildDialog(
                                          context, snapshot.data!, newNote),
                                );
                              },
                              icon: const Icon(Icons.edit))),
                        ])
                      ];
                    }

                    DataTable createDataTable() {
                      return DataTable(
                          columns: createColumns(), rows: createRows());
                    }

                    return Scaffold(
                      appBar: AppBar(
                        centerTitle: true,
                        title: Text(catPro.data!.name,style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold)),
                        actions: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  refreshImages();
                                });
                              },
                              icon: const Icon(Icons.refresh))
                        ],
                      ),
                      body: Center(
                        child: ListView(
                          children: <Widget>[
                            // Flexible(
                            //  // show all image
                            //   child: gridView(),
                            // )
                            ImageSlideshow(
                              width: double.infinity,
                              height: 280,
                              initialPage: 0,
                              indicatorColor: Color(hex.hexColor("#FAA41B")),
                              indicatorBackgroundColor: Colors.grey,
                              children: [
                                ((snapshot.data!.imageSide == null) ||
                                        (snapshot.data!.imageSide == ''))
                                    ? RotatedBox(
                                        quarterTurns: 0,
                                        child: Image.asset(
                                          "assets/images/SideLeftNavigation2.png",
                                          // height: 120,
                                          // width: 180,
                                        ),
                                      )
                                    : RotatedBox(
                                        quarterTurns: -1,
                                        child: Utility.imageFromBase64String(
                                            snapshot.data!.imageSide),
                                      ),
                                ((snapshot.data!.imageRear == null) ||
                                        (snapshot.data!.imageRear == ''))
                                    ? RotatedBox(
                                        quarterTurns: 0,
                                        child: Image.asset(
                                          "assets/images/RearNavigation2.png",
                                          // height: 120,
                                          // width: 180,
                                        ),
                                      )
                                    : RotatedBox(
                                        quarterTurns: -1,
                                        child: Utility.imageFromBase64String(
                                            snapshot.data!.imageRear),
                                      ),
                                ((snapshot.data!.imageTop == null) ||
                                        (snapshot.data!.imageTop == ''))
                                    ? RotatedBox(
                                        quarterTurns: -1,
                                        child: Image.asset(
                                          "assets/images/TopLeftNavigation2.png",
                                          // height: 120,
                                          // width: 180,
                                        ),
                                      )
                                    : RotatedBox(
                                        quarterTurns: -1,
                                        child: Utility.imageFromBase64String(
                                            snapshot.data!.imageTop),
                                      ),
                              ],
                            ),
                            createDataTable(),
                          ],
                        ),
                      ),
                      // floatingActionButton: FloatingActionButton(
                      //   onPressed: () {
                      //     setState(() {
                      //       refreshImages();
                      //     });
                      //   },
                      //   child: Icon(Icons.refresh),
                      // ),
                    );
                  } else {
                    return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [CircularProgressIndicator()]);
                  }
                });
          } else {
            return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator()]);
          }
        });
  }
}

class NoteDialog {
  final txtNote = TextEditingController();

  Widget buildDialog(BuildContext context, CatTimeModel catTime, bool isNew) {
    CatTimeHelper catTimeHelper = CatTimeHelper();
    if (!isNew) {
      txtNote.text = catTime.note;
    }
    return AlertDialog(
        title: Text((isNew) ? 'เพิ่มข้อความ' : 'แก้ไขข้อความ'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        content: SingleChildScrollView(
          child: Column(children: <Widget>[
            TextField(
                controller: txtNote,
                decoration: const InputDecoration(hintText: 'Note')),
            const SizedBox(height: 8),
            ElevatedButton(
              child: const Text('บันทึก'),
              onPressed: () async {
                print(txtNote.text);
                await catTimeHelper.updateCatTime(CatTimeModel(
                    id: catTime.id,
                    idPro: catTime.idPro,
                    weight: catTime.weight,
                    bodyLenght: catTime.bodyLenght,
                    heartGirth: catTime.heartGirth,
                    hearLenghtSide: catTime.hearLenghtSide,
                    hearLenghtRear: catTime.hearLenghtRear,
                    hearLenghtTop: catTime.hearLenghtTop,
                    pixelReference: catTime.pixelReference,
                    distanceReference: catTime.distanceReference,
                    imageSide: catTime.imageSide,
                    imageRear: catTime.imageRear,
                    imageTop: catTime.imageTop,
                    date: catTime.date,
                    note: txtNote.text));

                Navigator.pop(context);
              },
            ),
          ]),
        ));
  }
}
