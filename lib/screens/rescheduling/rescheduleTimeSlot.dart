// ignore_for_file: use_build_context_synchronously

import 'package:dogre/class/branch_data.dart';
import 'package:dogre/class/doctor_data.dart';
import 'package:dogre/class/rescheduleData.dart';
import 'package:dogre/main.dart';
import 'package:dogre/screens/appointment_booking/book_appointment.dart';
import 'package:dogre/screens/appointment_nav/consultation.dart';
import 'package:dogre/screens/home_screens/home.dart';
import 'package:dogre/screens/home_screens/nav_screen/appointment.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase/supabase.dart';

class RescheduleTimeSlots extends StatefulWidget {
  const RescheduleTimeSlots({
    Key? key,
    required this.rescheduleData,
  });
  final RescheduleData rescheduleData;

  @override
  State<RescheduleTimeSlots> createState() => _TimeSlotState();
}

class _TimeSlotState extends State<RescheduleTimeSlots> {
  List<String> timeSlots = [];
  List? petList;
  int selectedTimeSlotIndex = -1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    fetchTimeSlots();
  }

  String formatTimeToAMPM(String time) {
    final timeFormat = DateFormat('hh:mm a');
    final parsedTime = DateFormat('HH:mm').parse(time);
    return timeFormat.format(parsedTime);
  }

  Future<void> fetchTimeSlots() async {
    final doctorId = widget.rescheduleData.doctorId;
    final selectedDate = widget.rescheduleData.rescheduleDate;
    final dayOfWeek = selectedDate.weekday;
    final formattedDate = DateFormat.yMMMMd().format(selectedDate);

    // Fetch the doctor's working hours for the selected day from Supabase
    final workingHoursResponse = await supabase
        .from('doctor_schedule')
        .select('start_time, end_time')
        .eq('doctor_id', doctorId)
        .eq('day_of_week', dayOfWeek)
        .execute();

    if (workingHoursResponse.status == 200 &&
        workingHoursResponse.data != null &&
        workingHoursResponse.data.isNotEmpty) {
      final workingHours = workingHoursResponse.data[0];
      final startTime = workingHours['start_time'] as String;
      final endTime = workingHours['end_time'] as String;

      // Fetch booked appointments for the selected doctor on the selected date from Supabase
      final bookedAppointmentsResponse = await supabase
          .from('appointments')
          .select('appointment_time')
          .eq('doctor_id', doctorId)
          .eq('appointment_date', formattedDate)
          .execute();

      if (bookedAppointmentsResponse.status == 200 &&
          bookedAppointmentsResponse.data != null) {
        final bookedTimeSlots = (bookedAppointmentsResponse.data
                as List<dynamic>)
            .map((row) => formatTimeToAMPM(row['appointment_time'].toString()))
            .toList();

        final availableTimeSlots =
            calculateAvailableTimeSlots(startTime, endTime, bookedTimeSlots);

        setState(() {
          timeSlots = availableTimeSlots;
        });

        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            isLoading = false;
          });
        });
      } else {
        print('Error fetching booked appointments');
      }
    } else {
      print('Error fetching working hours');
    }
  }

  List<String> calculateAvailableTimeSlots(
      String startTime, String endTime, List<String> bookedTimeSlots) {
    final availableTimeSlots = <String>[];

    // Convert start and end time to DateTime
    final startTimeDT = DateFormat('HH:mm:ss').parse(startTime);
    final endTimeDT = DateFormat('HH:mm:ss').parse(endTime);

    final displayFormat = DateFormat('hh:mm a');

    final slotDuration = const Duration(hours: 1);
    var currentTime = startTimeDT;

    while (currentTime.isBefore(endTimeDT)) {
      final formattedTime = displayFormat.format(currentTime);

      // Debug prints
      print('Formatted Time: $formattedTime');
      print('Booked Time Slots: $bookedTimeSlots');

      // Check if the formattedTime is not in the list of booked time slots
      if (!isTimeSlotBooked(formattedTime, bookedTimeSlots)) {
        availableTimeSlots.add(formattedTime);
      }
      currentTime = currentTime.add(slotDuration);
    }

    return availableTimeSlots;
  }

  bool isTimeSlotBooked(String timeSlot, List<String> bookedTimeSlots) {
    // Debug print
    print('Checking if $timeSlot is booked.');

    // Check if the time slot exists in the list of booked time slots
    return bookedTimeSlots.contains(timeSlot);
  }

  Future<void> _resched() async {
    final appointmentDate = widget.rescheduleData.rescheduleDate;
    final doctorId = widget.rescheduleData.doctorId;
    final formattedDate = DateFormat.yMMMMd().format(appointmentDate);
    final doctorName = widget.rescheduleData.doctorName;
    final selectedTime = timeSlots[selectedTimeSlotIndex];
    final appointmentTime = selectedTime;

    final appointmentId = widget.rescheduleData.appointmentId;
    final response = await supabase
        .from('appointments')
        .update({
          'appointment_date': formattedDate,
          'appointment_time': appointmentTime,
          'doctor_name': doctorName,
          'doctor_id': doctorId,
        })
        .eq('appointment_id', appointmentId)
        .execute();

    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: Container(
              height: 350,
              width: 320,
              child: Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/final_logo/success.png',
                        width: 150,
                      ),
                      Text(
                        'Your appointment is confirmed',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(color: Colors.black),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Please be reminded to come at least ',
                              ),
                              TextSpan(
                                text: '5 minutes ',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text:
                                    'early before your scheduled time otherwise any latecomer will be considered as Walk-in!\n Thank you.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Get.offAll(HomeScreen());
                          },
                          child: Text(
                            'Close',
                            style: TextStyle(color: Colors.blue),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  void _showRescheduleDialog() {
    final appointmentDate = widget.rescheduleData.rescheduleDate;
    final formattedDate = DateFormat.yMMMMd().format(appointmentDate);
    final doctorName = widget.rescheduleData.doctorName;
    final selectedTime = timeSlots[selectedTimeSlotIndex];
    final appointmentTime = selectedTime;

    print('$selectedTimeSlotIndex');

    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 300,
              width: 300,
              child: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: AppBar(
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  title: Text(
                    'Rescheule details',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                backgroundColor: Colors.white,
                body: SafeArea(
                    child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Doctor name',
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                      Text(
                        '$doctorName',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Reschedule Date',
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                      Text(
                        '$formattedDate',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Reschedule time',
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                      Text(
                        '$appointmentTime',
                        style: TextStyle(fontSize: 18),
                      ),
                      Spacer(),
                      Center(
                        child: Container(
                          width: 300,
                          child: Row(
                            children: [
                              TextButton(
                                  style: TextButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      fixedSize: Size(120, 20)),
                                  onPressed: () {
                                    _resched();
                                  },
                                  child: Text(
                                    'Confirm',
                                    style: TextStyle(color: Colors.white),
                                  )),
                              Spacer(),
                              TextButton(
                                  style: TextButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      fixedSize: Size(120, 20)),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.blue),
                                  )),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )),
              ),
            ),
          ),
        );
      },
    );
  }

  void selectTimeSlot(int index) {
    setState(() {
      selectedTimeSlotIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final rescheduleDate = widget.rescheduleData.rescheduleDate as DateTime;

    final formattedDate = DateFormat('MMMM d, y').format(rescheduleDate);

    if (isLoading) {
      return Scaffold(
        body: Center(
            child: Center(
          child: LottieBuilder.asset(
            'assets/lottie/loading.json',
            height: 80,
            width: 80,
          ),
        )),
      );
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 80,
        toolbarHeight: 40,
        leading: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Row(
              children: [
                Text(
                  'Cancel',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                  textAlign: TextAlign.start,
                ),
              ],
            )),
        foregroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        physics: RangeMaintainingScrollPhysics(),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '$formattedDate',
                    style: TextStyle(color: Colors.blue, fontSize: 20),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    'Select a Time Slot', // Add your text here
                  ),
                ),
              ],
            ),
            Container(
              height: 150,
              margin: EdgeInsets.only(bottom: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal, // Horizontal scroll
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  final timeSlot = timeSlots[index];
                  final isSelected = selectedTimeSlotIndex == index;
                  return Column(
                    children: [
                      Container(
                        height: 150,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              side: BorderSide(
                                color:
                                    isSelected ? Colors.blue : Colors.black54,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: () {
                              selectTimeSlot(index);
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  timeSlot,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextButton(
              onPressed: () {
                final selectedTime = timeSlots[selectedTimeSlotIndex];
                final appointmentTime = selectedTime;
                print('$selectedTimeSlotIndex');
                _showRescheduleDialog();
              },
              style: TextButton.styleFrom(
                fixedSize: Size(250, 20),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: .5, color: Colors.blue),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Text(
                'Review Details',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
