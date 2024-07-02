

import 'package:jukkru/DataBase/catTime_handler.dart';
import 'package:jukkru/Screens/Pages/ProfilePage.dart';
import 'package:jukkru/model/calculation.dart';
import 'package:jukkru/model/catTime.dart';
import 'package:jukkru/model/imageNavidation.dart';
import 'package:flutter/material.dart';

import 'package:jukkru/Screens/Widgets/MainButton.dart';
import 'package:jukkru/convetHex.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

ConvertHex hex = ConvertHex();
CattleCalculation calculate = CattleCalculation();
ImageNavidation line = ImageNavidation();

class BlueSaveNextCamera extends StatefulWidget {
  final int? catTimeID;
  final BluetoothDevice? server;
  final bool? blueConnection;
  const BlueSaveNextCamera(
      {Key? key, this.catTimeID, this.server, this.blueConnection})
      : super(key: key);

  @override
  _BlueSaveNextCameraState createState() => _BlueSaveNextCameraState();
}

class _BlueSaveNextCameraState extends State<BlueSaveNextCamera> {
  late CatTimeHelper catTimeHelper;
  late Future<CatTimeModel> catTimeData;

  Future loadData() async {
    catTimeData = catTimeHelper.getCatTimeWithCatTimeID(widget.catTimeID!);
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
          centerTitle: true,
          title: const Text("คำนวณ",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              )),
          backgroundColor: Color(hex.hexColor("#007BA4")),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: FutureBuilder(
              future: catTimeData,
              builder: (context, AsyncSnapshot<CatTimeModel> snapshot) {
                if (snapshot.hasData) {
                  double hg = calculate.calHeartGirth(
                      snapshot.data!.hearLenghtRear,
                      snapshot.data!.hearLenghtSide);

                  return Center(
                    child: ListView(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PhysicalModel(
                              color: Colors.teal,
                              elevation: 8,
                              shadowColor: Colors.grey,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                  height: 240,
                                  width: 360,
                                  color: Colors.white,
                                  child: Center(
                                      child: ListTile(
                                    title: RotatedBox(
                                      quarterTurns: -1,
                                      child: Image.asset(
                                        "assets/images/SideLeftNavigation3.png",
                                        height: 120,
                                        width: 180,
                                      ),
                                    ),
                                    subtitle: Text(
                                      "รอบอก: ${hg.toStringAsFixed(3)} ซม.",
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )))),
                          const SizedBox(
                            height: 16,
                          ),
                          PhysicalModel(
                            color: Colors.teal,
                            elevation: 8,
                            shadowColor: Colors.grey,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                                height: 240,
                                width: 360,
                                color: Colors.white,
                                child: Center(
                                    child: ListTile(
                                  title: RotatedBox(
                                    quarterTurns: -1,
                                    child: Image.asset(
                                      "assets/images/SideLeftNavigation4.png",
                                      height: 120,
                                      width: 180,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "ความยาวลำตัว: ${snapshot.data!.bodyLenght.toStringAsFixed(3)} ซม.",
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ))),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                MainButton(
                                    onSelected: () async {
                                      double weight = calculate.calWeight(
                                          snapshot.data!.bodyLenght, hg);

                                      print("Cattle Weight: $weight Kg.");

                                      await catTimeHelper.updateCatTime(
                                          CatTimeModel(
                                              id: snapshot.data!.id,
                                              idPro: snapshot.data!.idPro,
                                              weight: weight,
                                              bodyLenght:
                                                  snapshot.data!.bodyLenght,
                                              heartGirth: hg,
                                              hearLenghtSide:
                                                  snapshot.data!.hearLenghtSide,
                                              hearLenghtRear:
                                                  snapshot.data!.hearLenghtRear,
                                              hearLenghtTop:
                                                  snapshot.data!.hearLenghtTop,
                                              pixelReference:
                                                  snapshot.data!.pixelReference,
                                              distanceReference: snapshot
                                                  .data!.distanceReference,
                                              imageSide:
                                                  snapshot.data!.imageSide,
                                              imageRear:
                                                  snapshot.data!.imageRear,
                                              imageTop: snapshot.data!.imageTop,
                                              date: DateTime.now()
                                                  .toIso8601String(),
                                              note: snapshot.data!.note));
                                      // Navigator.pushAndRemoveUntil จะไม่สามารถย้อนกลับมายัง Screen เดิมได้
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CattleProfilPage(
                                                    catProID:
                                                        snapshot.data!.idPro,
                                                  )),
                                          (route) => false);
                                    },
                                    title: "คำนวณน้ำหนัก", pixelDistance: 10,),
                                const SizedBox(
                                  height: 10,
                                ),
                                // MainButton(
                                //     onSelected: () {
                                //       Navigator.of(context).push(
                                //           MaterialPageRoute(
                                //               builder: (context) =>
                                //                   BlueAndCameraTop(
                                //                     idPro: snapshot.data.idPro,
                                //                     idTime: snapshot.data.id,
                                //                     catTime: snapshot.data,
                                //                     server: widget.server,
                                //                   )));
                                //     },
                                //     title: "ถ่ายภาพกระดูกสันหลังโค"),
                              ])
                        ]),
                  );
                } else {
                  return Container();
                }
              }),
        ));
  }
}
