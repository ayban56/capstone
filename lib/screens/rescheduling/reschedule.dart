import 'package:dogre/class/rescheduleData.dart';
import 'package:dogre/main.dart';
import 'package:dogre/screens/appointment_booking/time_slot.dart';
import 'package:dogre/screens/rescheduling/rescheduleTimeSlot.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

class RescheduleScreen extends StatefulWidget {
  const RescheduleScreen({
    super.key,
    required this.branchId,
    required this.appointmentId,
  });
  final appointmentId;
  final branchId;

  @override
  State<RescheduleScreen> createState() => _RescheduleScreenState();
}

class _RescheduleScreenState extends State<RescheduleScreen> {
  TextEditingController dateController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String availabilityText = '';
  String selectedDay = '';

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime canBook = DateTime.now().add(Duration(days: 5));
    final DateTime canBookLast = DateTime.now().add(Duration(days: 12));
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: canBook,
      firstDate: canBook, // Set the first selectable date to the current date
      lastDate: canBookLast,
    );

    if (picked != null && picked != selectedDate) {
      showDialog(
          context: context,
          builder: (context) {
            return Center(
              child: LottieBuilder.asset(
                'assets/lottie/loading.json',
                height: 80,
                width: 80,
              ),
            );
          });
      setState(() {
        selectedDate = picked;
        final formattedDate = DateFormat.yMMMMd().format(selectedDate);
        dateController.text = formattedDate;
        getDoctorsByDate(selectedDate);
        selectedDay = DateFormat.EEEE().format(selectedDate);
      });
    }
  }

  Future<void> getDoctorsByDate(DateTime selectedDate) async {
    final appointmentDate = selectedDate;
    final branchId = widget.branchId;
    final appointmentId = widget.appointmentId;

    final dayOfWeek = selectedDate.weekday - 0;

    final response = await supabase
        .from('doctor_schedule')
        .select('doctor_id')
        .eq('day_of_week', dayOfWeek)
        .eq('visibility', true)
        .execute();

    final availableDoctorIds = response.data
        .map((schedule) => schedule['doctor_id'] as String)
        .cast<String>()
        .toSet();

    final doctorsResponse = await supabase
        .from('users')
        .select('*')
        .eq('branch_id', branchId)
        .eq('user_type', 'doctor')
        .in_('id', availableDoctorIds.toList())
        .execute();

    try {
      final List<dynamic> data = doctorsResponse.data as List<dynamic>;

      if (data.isEmpty) {
        setState(() {
          doctorWidgets = [
            Center(
                heightFactor: 2,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/final_logo/8.png',
                      height: 150,
                      width: 150,
                    ),
                    Text(
                      'No doctor available',
                      style: TextStyle(fontSize: 20, color: Colors.black87),
                    ),
                    Text(
                      'Please select another date',
                      style: TextStyle(color: Colors.black54),
                    )
                  ],
                )),
          ];
          availabilityText = '';
        });
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
        setState(() {
          availabilityText = 'Available Doctor';
        });
        List<Widget> widgets = data.map((dynamic row) {
          if (row is Map<String, dynamic>) {
            final firstName = row['first_name'];
            final lastName = row['last_name'];
            final doctorName = '$firstName $lastName';
            final formatedName = doctorName.toString();
            final doctorEmail = row['email'];
            final doctorContactNumber = row['contact_number'];
            final doctorId = row['id'];

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: Colors.blue,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10)))),
                onPressed: () {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      final rescheduleData = RescheduleData(
                          doctorName: doctorName,
                          branchId: branchId,
                          rescheduleDate: selectedDate,
                          doctorId: doctorId,
                          appointmentId: appointmentId);

                      return AlertDialog(
                        contentPadding: EdgeInsets.zero,
                        backgroundColor: Colors.white,
                        content: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                              height: 350,
                              width: 500,
                              child: RescheduleTimeSlots(
                                rescheduleData: rescheduleData,
                              )),
                        ), // Display the TermsAndCondition widget in the dialog
                      );
                    },
                  );
                  /* final rescheduleData = RescheduleData(
                      doctorName: doctorName,
                      branchId: branchId,
                      rescheduleDate: selectedDate,
                      doctorId: doctorId,
                      appointmentId: appointmentId);
                  Get.to(RescheduleTimeSlots(rescheduleData: rescheduleData));
                  print('$appointmentId');*/
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 50,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Dr. $formatedName',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.black),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Email: $doctorEmail',
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Contact Number: $doctorContactNumber',
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Text('Invalid data');
          }
        }).toList();

        setState(() {
          doctorWidgets = widgets;
        });
      }
    } catch (e) {
      // Handle the error
      print(e);
    }
  }

  List<Widget> doctorWidgets = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Choose doctor',
          style: TextStyle(color: Colors.blue),
        ),
        centerTitle: true,
        foregroundColor: Colors.blue,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await getDoctorsByDate(selectedDate);
          },
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: ListView(
                children: [
                  Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Text(
                        'Preffered date',
                        style: TextStyle(color: Colors.grey.shade700),
                      )),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Center(
                      child: Column(
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                                side: BorderSide(color: Color(0xFF127ABD)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6))),
                            onPressed: () => _selectDate(context),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 7),
                                  child: Icon(
                                    Icons.calendar_month_outlined,
                                    color: Colors.blue,
                                    size: 35,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8),
                                            child: Text(
                                              dateController.text.isEmpty
                                                  ? 'Select Date'
                                                  : dateController.text,
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 17),
                                            ),
                                          ),
                                          Text(
                                            selectedDay,
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Visibility(
                                  visible: dateController.text.isNotEmpty,
                                  child: Text(
                                    'Change',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w300,
                                        decoration: TextDecoration.underline),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    child: Divider(
                      thickness: 2,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(availabilityText),
                  ),
                  Column(
                    children: doctorWidgets,
                  ),
                  if (dateController.text.isEmpty)
                    Center(
                      heightFactor: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/final_logo/8.png',
                            height: 150,
                            width: 150,
                          ),
                          Text(
                            'Please select a date',
                            style:
                                TextStyle(fontSize: 20, color: Colors.black87),
                          ),
                          IconButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Center(
                                          child:
                                              Text('Appointment instruction'));
                                    });
                              },
                              icon: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('How to book appointment'),
                                  SvgPicture.asset(
                                    'assets/svg/question_mark (2).svg',
                                    color: Colors.black54,
                                    height: 20,
                                  ),
                                ],
                              ))
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
