import 'package:dogre/components/my_textfield.dart';
import 'package:dogre/main.dart';
import 'package:dogre/screens/appointment_nav/my_pet.dart';
import 'package:dogre/screens/home_screens/home.dart';
import 'package:dogre/screens/pets/pet_information.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../components/my_button.dart';

class AddPet extends StatefulWidget {
  const AddPet({super.key});

  @override
  State<AddPet> createState() => _AddPetState();
}

class _AddPetState extends State<AddPet> {
  String? petGender;
  List? petList;
  TextEditingController petNameController = TextEditingController();
  TextEditingController breedController = TextEditingController();
  TextEditingController specieController = TextEditingController();
  TextEditingController birtDateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController concernController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String specie = 'dog';
  final List<String> items = [
    'Dog',
    'Cat',
  ];
  String? selectedValue;

  Future<void> birthdate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final dayOfWeek = selectedDate.weekday;
    final DateTime lowerDate =
        DateTime(currentDate.year - 100, currentDate.month, currentDate.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: lowerDate, // Set the first selectable date to the current date
      lastDate: currentDate,
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        final formattedDate = DateFormat.yMMMMd().format(selectedDate);
        birtDateController.text = formattedDate;
      });
    }
  }

  Future<void> addPet() async {
    final petName = petNameController.text.toString();
    final breed = breedController.text.toString();
    final specie = selectedValue.toString().toLowerCase();
    final birthdate = birtDateController.text.toString();
    final description = descriptionController.text.toString();
    final userId = supabase.auth.currentUser!.id;
    final firsstName = supabase.auth.currentUser!.userMetadata!['first_name'];
    final lastName = supabase.auth.currentUser!.userMetadata!['last_name'];
    final ownerName = '$firsstName $lastName';

    try {
      final response = await supabase.from('pets').upsert([
        {
          'user_id': userId,
          'owner_name': ownerName,
          'pet_name': petName,
          'pet_breed': breed,
          'pet_specie': specie,
          'pet_gender': petGender,
          'birthdate': birthdate,
          'description': description,
        }
      ]).execute();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Your pet added successfuly.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator?.pop(context);
                  gotoHome();
                },
                child: Text('Continue'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Handle any exceptions here
      print(e);
    }
  }

  void gotoHome() {
    Get.offAll(HomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Add Pet'),
        foregroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            MyTextField(
              controller: petNameController,
              obscureText: false,
              prefixIcon: Icons.pets,
              labelText: 'Pet Name',
              suffixIcon: null,
            ),
            SizedBox(
              height: 15,
            ),
            MyTextField(
              controller: breedController,
              obscureText: false,
              prefixIcon: Icons.pets,
              labelText: 'Breed',
              suffixIcon: null,
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.pets,
                      color: Colors.blue,
                    ),
                    labelText: 'Species',
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.blue),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.blue))),
                value: selectedValue,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.blue,
                ),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Colors.blue, fontSize: 16),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedValue = newValue;
                  });
                },
                items: items.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(color: Colors.blue),
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: GestureDetector(
                onTap: () => birthdate(context),
                child: TextField(
                  controller: birtDateController,
                  enabled: false,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 17,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Birthdate',
                    labelStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(
                      Icons.calendar_month,
                      color: Colors.blue,
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              child: Column(
                children: [
                  RadioListTile(
                    title: Text(
                      "Male",
                      style: TextStyle(color: Colors.black),
                    ),
                    value: "male",
                    groupValue: petGender,
                    fillColor:
                        MaterialStateColor.resolveWith((states) => Colors.blue),
                    onChanged: (value) {
                      setState(() {
                        petGender = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text(
                      "Female",
                      style: TextStyle(color: Colors.black),
                    ),
                    value: "female",
                    groupValue: petGender,
                    fillColor:
                        MaterialStateColor.resolveWith((states) => Colors.blue),
                    onChanged: (value) {
                      setState(() {
                        petGender = value.toString();
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                  maxLines: 3,
                  controller: descriptionController,
                  decoration: InputDecoration(
                    floatingLabelAlignment: FloatingLabelAlignment.start,
                    alignLabelWithHint: true,
                    labelText: 'Description (Sepecial Markings)',
                    labelStyle: TextStyle(color: Colors.black),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(
                        color: Color(0xFF0070C0),
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                      color: Color(0xFF0070C0),
                    )),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 10),
              child: MyButton(
                onPressed: () {
                  addPet();
                },
                color: Colors.blue,
                textStyle: TextStyle(color: Colors.white),
                btn_name: 'Add Pet',
              ),
            )
          ],
        ),
      )),
    );
  }
}
