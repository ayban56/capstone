import 'package:dogre/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:dogre/components/my_textfield.dart';
import 'package:dogre/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../components/my_button.dart';

class SignupAddPets extends StatefulWidget {
  const SignupAddPets({super.key});

  @override
  State<SignupAddPets> createState() => _SignupAddPetsState();
}

class _SignupAddPetsState extends State<SignupAddPets> {
  String? petGender;
  List? petList;
  TextEditingController petNameController = TextEditingController();
  TextEditingController breedController = TextEditingController();
  TextEditingController specieController = TextEditingController();
  TextEditingController birtDateController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController concernController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  Future<void> birthdate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final dayOfWeek = selectedDate.weekday;
    final DateTime lowerDate =
        DateTime(currentDate.year - 100, currentDate.month, currentDate.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: lowerDate, // Set the first selectable date to the current date
      lastDate: DateTime(2101),
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
    final specie = specieController.text.toString();
    final birthdate = birtDateController.text.toString();
    final description = descriptionController.text.toString();
    final userId = supabase.auth.currentUser!.id;

    try {
      final response = await supabase.from('pets').upsert([
        {
          'user_id': userId,
          'pet_name': petName,
          'pet_breed': breed,
          'pet_specie': specie,
          'pet_gender': petGender,
          'birthdate': birthdate,
          'description': description,
        }
      ]).execute();
    } catch (e) {
      // Handle any exceptions here
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Add pet'),
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
              labelText: 'Pet name',
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
            MyTextField(
              controller: specieController,
              obscureText: false,
              prefixIcon: Icons.pets,
              labelText: 'Specie',
              suffixIcon: null,
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 15),
                  child: TextButton(
                    onPressed: () => birthdate(context),
                    child: Text(
                      birtDateController.text.isEmpty
                          ? 'Birthdate'
                          : birtDateController.text,
                      style: TextStyle(color: Colors.blue, fontSize: 17),
                    ),
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      fixedSize: const Size(350, 50),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              child: Column(
                children: [
                  RadioListTile(
                    title: Text("Male"),
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
                    title: Text("Female"),
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
                    labelText: 'Description (Sepecial Markings)',
                    labelStyle: TextStyle(color: Colors.blue),
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
                  Get.offAll(Home());
                  addPet();
                },
                color: Colors.blue,
                textStyle: TextStyle(color: Colors.white),
                btn_name: 'Add pet',
              ),
            )
          ],
        ),
      )),
    );
  }
}
