import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dogre/screens/appointment_booking/choose_doctor.dart';
import 'package:dogre/screens/maps/branch_maps.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeNav extends StatelessWidget {
  const HomeNav({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController search = TextEditingController();

    triggerNotification() {
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: 10,
              channelKey: 'basic_channel',
              title: 'simple notification'));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/final_logo/home_pic.png',
                      width: 350,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 20),
                child: Row(
                  children: [
                    Text(
                      'How to use Happy Tails',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              GridView.count(
                padding: EdgeInsets.all(20),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2, // 2 columns
                children: [
                  // Add your grid items here
                  GestureDetector(
                    onTap: () {
                      _showOnlineAppointmentDialog(context);
                    },
                    child: GridTile(
                      child: Center(
                        child: Card(
                          borderOnForeground: false,
                          elevation: 2,
                          surfaceTintColor: Colors.white,
                          child: Center(
                            child: Column(
                              children: [
                                Image.asset(
                                    'assets/final_logo/online_appointment.png'),
                                Spacer(),
                                Text('Online Appointment'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Add another pet GridTile
                  GestureDetector(
                    onTap: () {
                      _showAddPetDialog(context);
                    },
                    child: GridTile(
                      child: Center(
                        child: Card(
                          elevation: 2,
                          surfaceTintColor: Colors.white,
                          child: Column(
                            children: [
                              Image.asset('assets/final_logo/add_pet.png'),
                              Spacer(),
                              Center(child: Text('Add another pet')),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Chatbot GridTile
                  GestureDetector(
                    onTap: () {
                      _showChatbotDialog(context);
                    },
                    child: GridTile(
                      child: Center(
                        child: Card(
                          elevation: 2,
                          surfaceTintColor: Colors.white,
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/final_logo/faqs.png',
                                height: 140,
                              ),
                              Spacer(),
                              Center(child: Text('FAQs')),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // User setting GridTile
                  GestureDetector(
                    onTap: () {
                      _showUserSettingDialog(context);
                    },
                    child: GridTile(
                      child: Center(
                        child: Card(
                          surfaceTintColor: Colors.white,
                          elevation: 2,
                          child: Center(
                            child: Column(
                              children: [
                                Image.asset(
                                    'assets/final_logo/user_setting.png'),
                                Spacer(),
                                Text('User setting'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOnlineAppointmentDialog(BuildContext context) {
    // Show the Online Appointment dialog here
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
              width: 200,
              height: 200,
              child: Center(child: Text('Online appointment'))),
        );
      },
    );
  }

  void _showAddPetDialog(BuildContext context) {
    // Show the Add another pet dialog here
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
              width: 200,
              height: 200,
              child: Center(child: Text('Add another pet'))),
        );
      },
    );
  }

  void _showChatbotDialog(BuildContext context) {
    // Show the Chatbot dialog here
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
              width: 200, height: 200, child: Center(child: Text('FAQs'))),
        );
      },
    );
  }

  void _showUserSettingDialog(BuildContext context) {
    // Show the User Setting dialog here
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
              width: 200,
              height: 200,
              child: Center(child: Text('User Setting'))),
        );
      },
    );
  }
}
