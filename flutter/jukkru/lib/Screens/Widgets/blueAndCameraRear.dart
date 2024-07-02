import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'package:jukkru/BlueCamera/BlueCameraRear_screen.dart';
import 'package:jukkru/Bluetooth/BlueMassgae.dart';


import 'package:jukkru/convetHex.dart';
import 'package:jukkru/model/catTime.dart';
import 'package:jukkru/model/imageNavidation.dart';

// refferent
// https://morioh.com/p/1f083bb5e877
// https://camposha.info/flutter/flutter-bluetooth-solutions/

// Messege Management
BleMessage BM = BleMessage();
// ConvertHex convert color code from web
ConvertHex hex = ConvertHex();

var connection; //BluetoothConnection

bool isConnecting = true;
bool isDisconnecting = false;

class BlueAndCameraRear extends StatefulWidget {
  final BluetoothDevice server;
  final int idPro;
  final int idTime;
  final CatTimeModel catTime;
  // final CameraDescription camera;

  const BlueAndCameraRear({
    Key? key,
    required this.server,
    required this.idPro,
    required this.idTime,
    required this.catTime,
  }) : super(key: key);

  @override
  _BlueAndCameraRear createState() => _BlueAndCameraRear();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _BlueAndCameraRear extends State<BlueAndCameraRear> {
  static const clientID = 0;
  // var connection; //BluetoothConnection

  List<_Message> messages = [];
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      TextEditingController();
  final ScrollController listScrollController = ScrollController();

  // bool isConnecting = true;
  // bool isDisconnecting = false;

  String formatedTime(int secTime) {
    String getParsedTime(String time) {
      if (time.length <= 1) return "0$time";
      return time;
    }

    int min = secTime ~/ 60;
    int sec = secTime % 60;

    String parsedTime =
        "${getParsedTime(min.toString())} : ${getParsedTime(sec.toString())}";

    return parsedTime;
  }

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((connection) {
      print('Connected to the device');
      connection = connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input!.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected()) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Row> list = messages.map((message) {
      return Row(
        mainAxisAlignment: message.whom == clientID
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(12.0),
            margin: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            width: 222.0,
            decoration: BoxDecoration(
                color:
                    message.whom == clientID ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(7.0)),
            child: Text(
                (text) {
                  return text == '/shrug' ? '¯\\_(ツ)_/¯' : text;
                }(message.text.trim()),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ถ่ายภาพด้านข้างโค',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        actions: [
          Row(
            children: [
              isConnected()
                  ? IconButton(
                      onPressed: () {
                        _disconnect();
                      },
                      icon: const Icon(Icons.bluetooth_connected),
                      color: Colors.white)
                  : IconButton(
                      onPressed: () {
                        _connect();
                      },
                      icon: const Icon(Icons.bluetooth_disabled),
                      color: Colors.white),
              IconButton(
                  onPressed: () {
                    Phoenix.rebirth(context);
                  },
                  icon: const Icon(Icons.home)),
            ],
          )
        ],
        backgroundColor: Color(hex.hexColor("#007BA4")),
      ),
      body: Stack(children: [
        BlueParamitor(
          server: widget.server,
          idPro: widget.idPro,
          idTime: widget.idTime,
          catTime: widget.catTime,
          heightValue: BM.getHeight(),
          blueConnection: isConnected(),
        )
      ]),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    for (var byte in data) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    }
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
        // Class  BleMessage = BM
        BM.setMessage(dataString.substring(0, index));
        // BM.printMessage();
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.isNotEmpty) {
      try {
        connection.output.add(utf8.encode("$text\r\n"));
        await connection.output.allSent;

        setState(() {
          messages.add(_Message(clientID, text));
        });

        Future.delayed(const Duration(milliseconds: 333)).then((_) {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 333),
              curve: Curves.easeOut);
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }

  // Method to show  bluetooth connection status
  bool isConnected() {
    return connection != null && connection.isConnected;
  }

  // Method to connect bluetooth
  void _connect() async {
    await BluetoothConnection.toAddress(widget.server.address)
        .then((connection) {
      print('Connected to the device');
      connection = connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input!.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  // Method to disconnect bluetooth
  void _disconnect() async {
    await connection.close();
    // show('Device disconnected');
    if (connection.isConnected) {
      setState(() {
        isDisconnecting = true;
        isConnecting = false;
      });
    }
  }
}

class BlueParamitor extends StatefulWidget {
  // final CameraDescription camera;
  final BluetoothDevice server;
  final bool blueConnection;
    final int idPro;
  final int idTime;
  final CatTimeModel catTime;
  final double heightValue;
  const BlueParamitor({
    Key? key,
    required this.server,
    required this.blueConnection,
    required this.idPro,
    required this.idTime,
    required this.catTime,
    required this.heightValue,
  }) : super(key: key);

  @override
  _BlueParamitorState createState() => _BlueParamitorState();
}

class _BlueParamitorState extends State<BlueParamitor> {
  ImageNavidation line = ImageNavidation();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: <Widget>[
          BlueCameraRearScreen(
              idPro: widget.idPro,
              idTime: widget.idTime,
              server: widget.server,
              blueConnection: widget.blueConnection,
              localFront: line.rearRight,
              localBack: line.rearRight,
              catTime: widget.catTime,
              heightValue: widget.heightValue,),
          ShowBlueParamitor(
            blueConnection: widget.blueConnection,
          )
        ],
      ),
    );
  }
}

class ShowBlueParamitor extends StatefulWidget {
  final bool blueConnection;
  const ShowBlueParamitor({Key? key, required this.blueConnection})
      : super(key: key);

  @override
  _ShowBlueParamitorState createState() => _ShowBlueParamitorState();
}

class _ShowBlueParamitorState extends State<ShowBlueParamitor> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 10, 20, 5),
      child: widget.blueConnection
          ? RotationTransition(
              turns: const AlwaysStoppedAnimation(90 / 360),
              child: Opacity(
                opacity: 0.6,
                child: Container(
                  // margin:EdgeInsets.only(left: 30, top: 0, right: 30, bottom: 50),
                  height: 150,
                  width: 120,
                  decoration: BoxDecoration(
                    border: ((BM.distance > 200 && BM.distance < 400) &&
                            (BM.axisY >= 80 && BM.axisY <= 90) &&
                            (BM.axisZ >= 180 && BM.axisZ <= 190))
                        ? Border.all(
                            color: Colors
                                .green, //                   <--- border color
                            width: 5.0,
                          )
                        : Border.all(
                            color: Colors
                                .red, //                   <--- border color
                            width: 5.0,
                          ),
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "Height = ${BM.getHeight()}\nDistance = ${BM.distance}\nAxisX = ${BM.axisY}\nAxisY = ${BM.axisY}\nAxisZ = ${BM.axisZ}",
                      style:
                          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            )
          : FittedBox(
              child: Container(
                margin: const EdgeInsets.all(16.0),
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
    );
  }
}
