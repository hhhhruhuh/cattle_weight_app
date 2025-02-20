
// Create a Form widget.
import 'package:jukkru/DataBase/catPro_handler.dart';

import 'package:jukkru/DataBase/catTime_handler.dart';

import 'package:flutter/material.dart';

import 'package:jukkru/model/catPro.dart';

class CatProFormCreate extends StatefulWidget {
  const CatProFormCreate({
    Key? key,
  }) : super(key: key);

  @override
  CatProFormCreateState createState() {
    return CatProFormCreateState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class CatProFormCreateState extends State<CatProFormCreate> {
  CatProHelper? catProHelper;
  CatTimeHelper? catTimeHelper;
  final _formKey = GlobalKey<FormState>();
  String _selectedGender = 'male';
  late String cattleName;
  bool gender = false;
  String species = 'Species';
  late Future<List<CatProModel>> notesList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    catProHelper = CatProHelper();
    catTimeHelper = CatTimeHelper();
    loadData();
  }

  loadData() async {
    notesList = catProHelper!.getCatProList();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("เพิ่มโค",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("ชื่อโค",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 16,
              ),
              TextFormField(
                style: const TextStyle(fontSize: 24),
                decoration: InputDecoration(
                  focusColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.blue, width: 1.0),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  fillColor: Colors.grey,

                  // labelText: "${cattleName}",
                ),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาระบุชื่อ';
                  } else {
                    cattleName = value;
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 16,
              ),
              const Text("เพศ",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ListTile(
                leading: Radio<String>(
                  value: 'male',
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                      gender = false;
                    });
                  },
                ),
                title: const Text('Male',style: TextStyle(fontSize: 18)),
              ),
              ListTile(
                leading: Radio<String>(
                  value: 'female',
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                      gender = true;
                    });
                  },
                ),
                title: const Text('Female',style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(
                height: 16,
              ),
              const Text("สายพันธุ์",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                width: 360,
                height: 64,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  )),
                  value: species,
                  items: <String>['Species', 'Brahman', 'Angus', 'Charolais']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(fontSize: 18),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      species = newValue!;
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 44, vertical: 16),
                              textStyle: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('ยกเลิก'),
                        ),
                        const SizedBox(
                          width: 18,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 44, vertical: 16),
                              textStyle: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // ScaffoldMessenger.of(context).showSnackBar(
                              //   const SnackBar(
                              //       content: Text('Processing Data')),
                              // );
                              // print(
                              //     "Name: $cattleName \tGender: $_selectedGender\tSpecies: $species");

                              CatProModel cattlePro = CatProModel(
                                  name: cattleName,
                                  gender: _selectedGender,
                                  species: species);

                              await catProHelper!.insert(cattlePro);
                              loadData();

                              Navigator.pop(context);
                            }
                          },
                          child: const Text('บันทึก'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
