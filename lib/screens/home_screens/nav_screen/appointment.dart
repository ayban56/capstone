// ignore_for_file: prefer_const_constructors

import 'package:dogre/screens/appointment_nav/consultation.dart';
import 'package:dogre/screens/appointment_nav/branches.dart';
import 'package:dogre/screens/appointment_nav/my_pet.dart';
import 'package:dogre/screens/maps/branch_maps.dart';
import 'package:flutter/material.dart';

class AppointmentNav extends StatefulWidget {
  const AppointmentNav({super.key});

  @override
  State<AppointmentNav> createState() => _AppointmentNavState();
}

class _AppointmentNavState extends State<AppointmentNav> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: DefaultTabController(
          length: 3,
          child: Scaffold(
            body: Material(
              color: Colors.white,
              child: Column(
                children: [
                  TabBar(
                    indicatorColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    dividerColor: Colors.white,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Color(0xFF1592E3),
                    tabs: [
                      Tab(
                        text: 'Branches',
                      ),
                      Tab(
                        text: 'Appointments',
                      ),
                    ],
                  ),
                  Expanded(
                      child: TabBarView(
                          physics: NeverScrollableScrollPhysics(),
                          children: [MyMapPage(), Consultation()]))
                ],
              ),
            ),
          ),
        ));
  }
}
