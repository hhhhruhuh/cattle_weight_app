import 'dart:async';

import 'package:jukkru/Camera/cameraSide_screen.dart';
import 'package:jukkru/model/imageNavidation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'package:jukkru/Screens/Widgets/MainButton.dart';
import 'package:jukkru/convetHex.dart';
import 'package:jukkru/model/catTime.dart';

import 'DiscoveryDevice.dart';

// ConvertHex convert color code from web
ConvertHex hex = ConvertHex();
ImageNavidation line = ImageNavidation();

class BlueMainPage extends StatefulWidget {
  // final CameraDescription camera;
  final int idPro;
  final int idTime;
  final CatTimeModel catTime;

  const BlueMainPage({
    Key? key,
    required this.idPro,
    required this.idTime,
    required this.catTime,
  }) : super(key: key);

  @override
  _BlueMainPage createState() => _BlueMainPage();
}

class _BlueMainPage extends State<BlueMainPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Flutter Bluetooth Serial'),
      // ),
      body: _bluetoothState.isEnabled
          ? DiscoveryPage(
              start: true,
              idPro: widget.idPro,
              idTime: widget.idTime,
              catTime: widget.catTime
              // camera: widget.camera,
              )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  Container(
                      child: const Text(
                    "กรุณาเปิดบลูทูธ",
                    style: TextStyle(fontSize: 36),
                  )),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: MainButton(
              onSelected: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CameraSideScreen(
                          idPro: widget.idPro,
                          idTime: widget.idTime,
                          localFront: line.sideLeft,
                          localBack: line.sideRight,
                          catTime: widget.catTime,
                        )));
              },
              title: "ไม่เชื่อมต่ออุปกรณ์", pixelDistance: 10,),
        ),
      ),
    );
  }
}
