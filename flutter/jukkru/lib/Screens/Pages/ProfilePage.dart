import 'package:jukkru/DataBase/catPro_handler.dart';
import 'package:jukkru/Screens/Pages/catTime_screen.dart';
import 'package:jukkru/model/catPro.dart';
import 'package:flutter/material.dart';

import 'package:jukkru/convetHex.dart';

import 'ChartPage.dart';

ConvertHex hex = ConvertHex();

class CattleProfilPage extends StatefulWidget {
  const CattleProfilPage({
    Key? key,
    required this.catProID,
  }) : super(key: key);

  final int catProID;

  @override
  _CattleProfilPageState createState() => _CattleProfilPageState();
}

class _CattleProfilPageState extends State<CattleProfilPage> {
  CatProHelper? catProHelper;

  late Future<CatProModel> catProData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    catProHelper = CatProHelper();

    loadData();
    // NotesModel(title: "User00",age: 22,description: "Default user",email: "User@exemple.com");
  }

  loadData() async {
    catProData = catProHelper!.getCatProWithID(widget.catProID);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: catProData,
        builder: (context, AsyncSnapshot<CatProModel> catPro) {
          if (catPro.hasData) {
            return DefaultTabController(
              ///จำนวนเมนู
              length: 2,
              child: Scaffold(
                backgroundColor: Color(hex.hexColor('#FFC909')),

                ///กำหนดให้แต่ละ tapBar แสดงอะไร
                body: TabBarView(
                  children: [
                    // หน้าแอปที่ต้องการให้ทำงานเมื่อกดเมนู
                    CatTimeScreen(
                      catProID: widget.catProID,
                    ),
                    ChartCattle(
                        title: catPro.data!.name, catProID: catPro.data!.id!),
                  ],
                ),
                bottomNavigationBar: const TabBar(
                  tabs: [
                    // ตั้งค่าเมนูภายใน  TapBar View
                    Tab(
                        icon: Icon(
                      Icons.list,
                      size: 48,
                    )),
                    Tab(
                      icon: Icon(
                        Icons.bar_chart_rounded,
                        size: 48,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
