import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:jukkru/convetHex.dart';

ConvertHex hex = ConvertHex();

class MenuOption extends StatefulWidget {
  final String title;
  const MenuOption(this.title, {Key? key}) : super(key: key);

  @override
  _MenuOptionState createState() => _MenuOptionState();
}

class _MenuOptionState extends State<MenuOption> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
        // เมื่อเลือกเมนูแล้วจะส่งไปทำงานที่หังก์ชัน onSelected
        onSelected: (item) => onSelected(context, item, widget.title),
        itemBuilder: (context) => [
              const PopupMenuItem<int>(
                  value: 0,
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text("Delete",style: TextStyle(fontSize: 24, color: Colors.black)),
                  )),
              const PopupMenuItem<int>(
                  value: 1,
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text("Edit",style: TextStyle(fontSize: 24, color: Colors.black)),
                  ))
            ]);
  }
}

void onSelected(BuildContext context, int item, String title) {
  switch (item) {
    case 0:
      showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("ลบโปรไฟล์ของ $title ",style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),
              content: Text(
                'คุณต้องการลบโปรไฟล์ของ $title ในวันที่ *02/01/2564* หรือไม่',
                style: const TextStyle(fontSize: 24, color: Colors.black),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'ไม่ใช่'),
                  child: const Text('ไม่ใช่',style: TextStyle(fontSize: 24),),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, 'ใช่'),
                  child: const Text('ใช่',style: TextStyle(fontSize: 24),),
                ),
              ],
            );
          });
      break;
    case 1:
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const EditOption()));
      break;
  }
}

class ProfileBox extends StatelessWidget {
  final CameraDescription camera;
  late int cattleNumber;
  late String cattleName;
  late String gender;
  late String specise;
  late String img;
  late double heartGirth;
  late double bodyLenght;
  late double weight;
  ProfileBox({Key? key, 
    required this.cattleNumber,
    required this.cattleName,
    required this.gender,
    required this.specise,
    required this.img,
    required this.camera
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      // แสดงภาพโค
      leading: Image.asset(img, height: 80, width: 110, fit: BoxFit.fill),
      // แสดงชื่อโค
      title: Text(cattleName,style: const TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
      // แสดงรายละเอียดต่างๆ
      subtitle: Text(
        'Cattle number: $cattleNumber \nGender : $gender \nSpecise : $specise',
        style: const TextStyle(fontSize: 18, color: Colors.black),
      ),
      trailing: MenuOption(cattleName),
      onTap: () {

        // Navigator.of(context).push(MaterialPageRoute(
        //     builder: (context) => CattleProfilPage(
        //           title: cattleName,
        //           camera: camera,
        //         )));
      },
    ));
  }
}

class DeleteOption extends StatelessWidget {
  const DeleteOption({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Delete"),
        backgroundColor: Color(hex.hexColor("#007BA4")),
      ),
      body: const Center(
        child: Text("Delete page"),
      ),
    );
  }
}

class EditOption extends StatelessWidget {
  const EditOption({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit"),
        backgroundColor: Color(hex.hexColor("#007BA4")),
      ),
      body: const Center(
        child: Text("Edit page"),
      ),
    );
  }
}
