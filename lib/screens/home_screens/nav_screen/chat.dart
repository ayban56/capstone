// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatNav extends StatefulWidget {
  const ChatNav({super.key});

  @override
  State<ChatNav> createState() => _ChatNavState();
}

class _ChatNavState extends State<ChatNav> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 8, right: 8, top: 10),
              child: SizedBox(
                width: 800,
                child: Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          'Frequently Asked Questions',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Divider(
                        thickness: 1,
                        color: Colors.black38,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What is ASVC Veterinary Clinic?',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              '\u2022 ASVC Veterinary Clinic is a pet service provider that offers veterinary care, grooming, boarding, and products for animals. ASVC stands for Animal Surgery and Vaccinating Clinic',
                            ),
                            Divider(),
                            Text(
                              'What are the operating hours of ASVC Veterinary Clinic?',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                                '\u2022 ASVC Veterinary Clinic is open from 8 am to 6 pm every day, Monday to Sunday. They also accept emergency cases'),
                            Divider(),
                            Text(
                              'What are the services offered by ASVC Veterinary Clinic?',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                                '\u2022 ASVC Veterinary Clinic offers a variety of services for your pets, such as:'),
                            Text(
                                '- Vaccination \n- Deworming\n- Spaying and neutering\n- Dental care\n- Surgery\n- Laboratory tests\n- X-ray\n- Ultrasound\n- Grooming'),
                            Divider(),
                            Text(
                              'How much do the services cost at ASVC Veterinary Clinic?',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                                '\u2022 The prices of the services vary depending on the type and size of the animal, the condition and needs of the pet, and the availability of the service. You can inquire about the specific rates by calling the clinic or visiting their Facebook page. You can also check their posts for any promotions or discounts they may offer from time to time')
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
