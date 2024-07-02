
import 'package:flutter/material.dart';
import 'package:jukkru/convetHex.dart';
import 'package:jukkru/Screens/Widgets/CattleBox.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

// class ที่ใช้ในการแปลงค่าสีจากภายนอกมาใช้ใน flutter
ConvertHex hex = ConvertHex();

class CattlePreview extends StatelessWidget {
  // final CameraDescription camera;
  final String cattleNumber;
  final String cattleName;
  final String gender;
  final String specise;
  final String img1;
  final String img2;
  final String img3;
  final double heartGirth;
  final double bodyLenght;
  final double weight;

  const CattlePreview(
      this.cattleNumber,
      this.cattleName,
      this.gender,
      this.specise,
      this.img1,
      this.img2,
      this.img3,
      this.heartGirth,
      this.bodyLenght,
      this.weight, {Key? key}
      ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          cattleName,
          style: const TextStyle(
            fontFamily: "boogaloo",
            fontSize: 24,
          ),
        ),
        backgroundColor: Color(hex.hexColor("#007BA4")),
        actions: [
          IconButton(
              onPressed: () {
                Phoenix.rebirth(context);
              },
              icon: const Icon(Icons.home))
        ],
      ),
      body: ListView(children: [
        // นำภาพมาแสดงผล
        ImageSlideshow(
          width: double.infinity,
          height: 200,
          initialPage: 0,
          indicatorColor: Color(hex.hexColor("#FAA41B")),
          indicatorBackgroundColor: Colors.grey,
          children: [
            Image.asset(img1, fit: BoxFit.cover),
            Image.asset(img2, fit: BoxFit.cover),
            Image.asset(img3, fit: BoxFit.cover)
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        Container(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Text(cattleName,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Container(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
            children: [
              Expanded(
                  child: Text(
                      "Cattle number: $cattleNumber \t\t\t\tBody width : $bodyLenght \nSpecise : $specise \t\t\tHeart girth : $heartGirth \nGender : $gender \t\t\t\t\t\t\t\tWeight : $weight",
                      style: const TextStyle(fontSize: 24, color: Colors.black))),
            ],
          ),
        )),
        const SizedBox(
          height: 40,
        ),
        // ปุ่มแก้ไข
        SizedBox(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                        height: 60,
                        width: 80,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const EditOption()));
                            },
                            child: Text(
                              "แก้ไข",
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Color(hex.hexColor("ffffff"))),
                            ),
                            // color: Color(hex.hexColor("#FAA41B")),
                            // // สีปุ่มเมื่อกด
                            // splashColor: Color(hex.hexColor("#FFC909")),
                            // // กำหนดรูปร่างของปุ่ม
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: new BorderRadius.circular(20.0),
                            //   // side: BorderSide(color: Colors.black),
                            // ),
                          ),
                        )),
                  ),
                  // ปุ่มลบ
                  Expanded(
                    child: SizedBox(
                        height: 50,
                        width: 80,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog<String>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("ลบข้อมูลของ $cattleName ",
                                          style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold)),
                                      content: Text(
                                          'คุณต้องการลบข้อมูลของ $cattleName ในวันที่ *02/01/2564* หรือไม่',
                                          style: const TextStyle(
                                              fontSize: 24,
                                              color: Colors.black)),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'ไม่ใช่'),
                                          child: const Text('ไม่ใช่',
                                              style: TextStyle(fontSize: 24)),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'ใช่'),
                                          child: const Text('ใช่',
                                              style: TextStyle(fontSize: 24)),
                                        ),
                                      ],
                                    );
                                  });
                            },
                            child: Text(
                              "ลบ",
                              style: TextStyle(
                                  fontSize: 24,
                                  color: Color(hex.hexColor("ffffff"))),
                            ),
                            // color: Color(hex.hexColor("#FAA41B")),
                            // // สีปุ่มเมื่อกด
                            // splashColor: Color(hex.hexColor("#FFC909")),
                            // // กำหนดรูปร่างของปุ่ม
                            // shape: RoundedRectangleBorder(
                            //   borderRadius: new BorderRadius.circular(20.0),
                            //   // side: BorderSide(color: Colors.black),
                            // ),
                          ),
                        )),
                  ),
                ],
              ),
            )),
        const SizedBox(
          height: 15,
        ),
        // ปุ่มบันทึกหน้าจอ
        SizedBox(
            height: 50,
            width: 160,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: ElevatedButton(
                onPressed: () {
                  print("บันทึกหน้าจอ");
                },
                child: Text(
                  "บันทึกหน้าจอ",
                  style: TextStyle(
                      fontSize: 24, color: Color(hex.hexColor("ffffff"))),
                ),
                // color: Color(hex.hexColor("#FAA41B")),
                // // สีปุ่มเมื่อกด
                // splashColor: Color(hex.hexColor("#FFC909")),
                // // กำหนดรูปร่างของปุ่ม
                // shape: RoundedRectangleBorder(
                //   borderRadius: new BorderRadius.circular(20.0),
                //   // side: BorderSide(color: Colors.black),
                // ),
              ),
            )),
        const SizedBox(
          height: 15,
        ),
        // ปุ่มบันทึกหน้าจอ
        SizedBox(
            height: 50,
            width: 160,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: ElevatedButton(
                onPressed: () {
                  // print("หน้าหลัก");
                  // Navigator.pushAndRemoveUntil(
                  //     context,
                  //     MaterialPageRoute(builder: (context) =>CattleHistory(camera: camera,)),
                  //     (route) => false);
                },
                child: Text(
                  "หน้าหลัก",
                  style: TextStyle(
                      fontSize: 24, color: Color(hex.hexColor("ffffff"))),
                ),
                // color: Color(hex.hexColor("#FAA41B")),
                // // สีปุ่มเมื่อกด
                // splashColor: Color(hex.hexColor("#FFC909")),
                // // กำหนดรูปร่างของปุ่ม
                // shape: RoundedRectangleBorder(
                //   borderRadius: new BorderRadius.circular(20.0),
                //   // side: BorderSide(color: Colors.black),
                // ),
              ),
            )),
      ]),
    );
  }
}
