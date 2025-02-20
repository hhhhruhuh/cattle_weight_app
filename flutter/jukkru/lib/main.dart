
import 'package:camera/camera.dart';

import 'package:jukkru/Screens/Pages/catPro_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'convetHex.dart';


ConvertHex hex = ConvertHex();

List<CameraDescription> cameras = [];

void main() async {

  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error in fetching the cameras: $e');
  }

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(Phoenix(child: const MyApp()));
}

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // กำหนด font เริ่มต้น
          fontFamily: 'TH-Niramit-AS',

          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: 
        // ExportSQLtoCSV(title:"Export sql table to csv")
        const CatProScreen()
        
        );
  }
}
