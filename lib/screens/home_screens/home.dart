// ignore_for_file: prefer_const_constructors, unused_import, sized_box_for_whitespace, prefer_final_fields

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dogre/screens/appointment_nav/my_pet.dart';
import 'package:dogre/screens/home_screens/nav_screen/appointment.dart';
import 'package:dogre/screens/home_screens/nav_screen/chat.dart';
import 'package:dogre/screens/home_screens/nav_screen/home.dart';
import 'package:dogre/screens/home_screens/nav_screen/profile.dart';
import 'package:dogre/screens/maps/branch_maps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:stylish_bottom_bar/model/bar_items.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  var heart = false;
  int _selectedIndex = 0;
  static List<Widget> _widgetOption = <Widget>[
    HomeNav(),
    AppointmentNav(),
    Mypets(),
    ChatNav(),
    ProfileNav(),
  ];

  bool isFloatingActionButtonVisible() {
    return _selectedIndex == 0; // Show the FAB only on the 'Home' screen
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text("Happy Tails"),
        surfaceTintColor: Colors.white,
        titleSpacing: 3,
        elevation: 0,
        titleTextStyle: TextStyle(
            color: Color(0xFF1592E3),
            fontWeight: FontWeight.bold,
            fontSize: 22),
        backgroundColor: Color(0xFFFFFFFF),
        leading: Container(
          child: Image.asset(
            'assets/final_logo/app_icon.png',
          ),
        ),
      ),
      body: Center(
        child: _widgetOption.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: StylishBottomBar(
        option: AnimatedBarOptions(
            iconSize: 23,
            barAnimation: BarAnimation.fade,
            iconStyle: IconStyle.animated,
            padding: EdgeInsets.zero),
        /*option: BubbleBarOptions(
            barStyle: BubbleBarStyle.horizotnal,
            // barStyle: BubbleBarStyle.vertical,
            bubbleFillStyle: BubbleFillStyle.fill,
            // bubbleFillStyle: BubbleFillStyle.outlined,
            opacity: 0.3,
          ),*/

        items: [
          BottomBarItem(
            icon: Image.asset(
              'assets/final_logo/home_nav.png',
              height: 30,
            ),
            title: const Text('Home', style: TextStyle(fontSize: 12.3)),
            backgroundColor: Colors.blue,
            selectedIcon: const Icon(Icons.read_more),
          ),
          BottomBarItem(
            icon: Image.asset(
              'assets/final_logo/appointment_nav.png',
              height: 30,
            ),
            title: const Text(
              'Appointment',
              style: TextStyle(fontSize: 12.3),
            ),
            backgroundColor: Colors.blue,
          ),
          BottomBarItem(
            icon: Icon(
              Icons.pets,
              size: 35,
            ),
            title: const Text('Pets', style: TextStyle(fontSize: 12.3)),
            backgroundColor: Colors.purple.shade400,
          ),
          BottomBarItem(
            icon: Icon(
              LineAwesomeIcons.question_circle,
              size: 30,
            ),
            title: const Text("FAQs", style: TextStyle(fontSize: 12.3)),
            backgroundColor: Colors.blue,
          ),
          BottomBarItem(
            icon: Image.asset(
              'assets/final_logo/profile_nav.png',
              height: 30,
            ),
            title: const Text('Profile', style: TextStyle(fontSize: 12.3)),
            backgroundColor: Colors.blue,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
