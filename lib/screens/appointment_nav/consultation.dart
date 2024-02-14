import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dogre/class/branch_data.dart';
import 'package:dogre/class/rescheduleData.dart';
import 'package:dogre/components/my_textfield.dart';
import 'package:dogre/main.dart';
import 'package:dogre/screens/appointment_booking/choose_doctor.dart';
import 'package:dogre/screens/appointment_history/appointment_history.dart';
import 'package:dogre/screens/appointment_nav/appointment_details.dart';
import 'package:dogre/screens/appointment_nav/cancel_appointment.dart';
import 'package:dogre/screens/rescheduling/reschedule.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class Consultation extends StatefulWidget {
  const Consultation({super.key});

  @override
  State<Consultation> createState() => _ConsultationState();
}

class _ConsultationState extends State<Consultation> {
  List? appointmentList;
  List? prosa;
  String dropdownValue = 'Latest first';

  @override
  void initState() {
    super.initState();
    bookedAppointments();
  }

  Future<void> bookedAppointments() async {
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('appointments')
        .select('*,  appointment_details(*)')
        .eq('user_id', userId)
        .order('is_booked', ascending: false)
        .execute();

    try {
      final now = DateTime.now();
      final yesterday = now.subtract(Duration(days: 1));
      final yesterdayStr = DateFormat('y-MM-d').format(yesterday);

      setState(() {
        appointmentList = response.data.toList();
      });

      for (var appointment in appointmentList!) {
        final dateStr = appointment['appointment_date'];
        final datestr2 = DateTime.parse(dateStr);
        final appointmentDate = DateFormat('y-MM-d').format(datestr2);

        if (appointmentDate == yesterdayStr) {
          final appointmentId = appointment['appointment_id'];
          updateAppointmentStatus(appointmentId, 'cancel');
        }
      }

      scheduleNotificationsForToday(appointmentList!);

      print(appointmentList);
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateAppointmentStatus(int appointmentId, String status) async {
    await supabase
        .from('appointments')
        .update({'status': status, 'is_booked': false})
        .eq('appointment_id', appointmentId)
        .eq('is_canceled', true)
        .execute();
  }

  void scheduleNotificationsForToday(List<dynamic> appointments) {
    final now = DateTime.now();
    final today = DateFormat('y-MM-d').format(now);
    for (var appointment in appointments) {
      final dateStr = appointment['appointment_date'];
      final datestr2 = DateTime.parse(dateStr);
      final appointmentDate = DateFormat('y-MM-d').format(datestr2);

      if (appointmentDate == today) {
        final appointmentId = appointment['appointment_id'];
        final doctorName = appointment['doctor_name'];

        scheduleNotification(appointmentId, doctorName);
      }
    }
  }

  void scheduleNotification(int appointmentId, String doctorName) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: appointmentId,
        channelKey: 'basic_channel',
        title: 'Appointment Reminder',
        body: 'You have an appointment with Dr. $doctorName today.',
      ),
      schedule: NotificationInterval(interval: 60),
    );
  }

  Future<void> sortAppointment(bool newestFirst) async {
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('appointments')
        .select('*,  appointment_details(*)')
        .eq('user_id', userId)
        .order('is_booked', ascending: false)
        .order('appointment_date', ascending: !newestFirst)
        .order('appointment_time', ascending: !newestFirst)
        .execute();

    try {
      setState(() {
        appointmentList = response.data.toList();
      });
    } catch (e) {
      print(e);
    }
  }

  triggerNotification() {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 10, channelKey: 'basic_channel', title: 'simple notification'));
  }

  Future<void> onFailedAppointments() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: appointmentList == null
          ? Center(
              child: LottieBuilder.asset(
                'assets/lottie/loading.json',
                height: 80,
                width: 80,
              ),
            )
          : appointmentList!.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/final_logo/online_appointment.png',
                        height: 200,
                        width: 200,
                      ),
                      Text('Your Appointments will display here'),
                      SizedBox(
                        height: 50,
                      )
                    ],
                  ),
                )
              : SafeArea(
                  child: RefreshIndicator(
                      displacement: 10,
                      edgeOffset: 1.1,
                      triggerMode: RefreshIndicatorTriggerMode.onEdge,
                      onRefresh: bookedAppointments,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 3, left: 3),
                        child: Column(
                          children: [
                            Container(
                              child: Row(
                                children: [
                                  Text(
                                    'Sort by: ',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black45),
                                  ),
                                  DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      elevation: 0,
                                      value: dropdownValue,
                                      icon: Icon(
                                        Icons.sort,
                                        size: 17,
                                      ),
                                      items: <String>[
                                        'Latest first',
                                        'Oldest first',
                                      ].map<DropdownMenuItem<String>>(
                                          (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black45),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          dropdownValue = newValue!;
                                          if (newValue == 'Latest first') {
                                            sortAppointment(
                                                false); // Sort newest first
                                          } else {
                                            sortAppointment(
                                                true); // Sort oldest first
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  Spacer(),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: false,
                                padding: EdgeInsets.zero,
                                itemCount: appointmentList?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final appointment = appointmentList![index];
                                  final dateStr =
                                      appointment['appointment_date'];
                                  final datestr2 = DateTime.parse(dateStr);
                                  final appointmentDate =
                                      DateFormat('MMMM d, y').format(datestr2);
                                  final appointmentMonth = DateFormat('MMM')
                                      .format(datestr2)
                                      .toUpperCase();
                                  final appointmentDay =
                                      DateFormat('d').format(datestr2);
                                  final timeStr =
                                      appointment['appointment_time'];
                                  final time = DateFormat('HH:mm:ss')
                                      .parse(timeStr); // Parse the time string
                                  final formattedTime =
                                      DateFormat('hh:mm a').format(time);
                                  final reasonForVisit =
                                      appointment['reason_for_visit'];
                                  final status = appointment['status']
                                      .toString()
                                      .capitalize;
                                  final appointmentId =
                                      appointment['appointment_id'];
                                  final branchName =
                                      appointment['branch_location'];
                                  final doctorName = appointment['doctor_name']
                                      .toString()
                                      .capitalize;
                                  final remarks = appointment['remarks']
                                          ?.toString()
                                          ?.capitalizeFirst ??
                                      'n/a';
                                  final details =
                                      appointment['appointment_details'];
                                  final petName = details['pet_name']
                                      .toString()
                                      .capitalizeFirst;
                                  final isBooked = appointment['is_booked'];
                                  final isCompleted =
                                      appointment['is_completed'];

                                  final referenceNumber =
                                      appointment['reference_number'];
                                  final ownerName =
                                      appointment['name'].toString().capitalize;
                                  final reason =
                                      appointment['reason_for_cancellation'];

                                  return GestureDetector(
                                    onTap: isBooked == false
                                        ? () {}
                                        : () {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return Center(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      child: Container(
                                                        height: 600,
                                                        width: 370,
                                                        child: AppointmentDetails(
                                                            appointmentId:
                                                                appointmentId),
                                                      ),
                                                    ),
                                                  );
                                                });
                                          },
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Column(
                                        children: [
                                          Card(
                                            elevation: 5,
                                            surfaceTintColor: Colors.white,
                                            child: Container(
                                              height: 175,
                                              padding: EdgeInsets.only(top: 23),
                                              child: Stack(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 70,
                                                        child: Column(
                                                          children: [
                                                            Text(
                                                              '$appointmentMonth',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.blue,
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            Text(
                                                              '$appointmentDay',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.blue,
                                                                fontSize: 40,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            '$branchName',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14),
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  RichText(
                                                                      text: TextSpan(
                                                                          style: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 12),
                                                                          children: <TextSpan>[
                                                                        TextSpan(
                                                                          text:
                                                                              'Doctor: ',
                                                                        ),
                                                                        TextSpan(
                                                                            text:
                                                                                'Dr. $doctorName',
                                                                            style:
                                                                                TextStyle(color: Colors.black)),
                                                                      ])),
                                                                  SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  RichText(
                                                                      text: TextSpan(
                                                                          style: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 12),
                                                                          children: <TextSpan>[
                                                                        TextSpan(
                                                                            text:
                                                                                'Reason for visit: '),
                                                                        TextSpan(
                                                                            text:
                                                                                '$reasonForVisit',
                                                                            style:
                                                                                TextStyle(color: Colors.black)),
                                                                      ])),
                                                                  SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  RichText(
                                                                      text: TextSpan(
                                                                          style: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 12),
                                                                          children: <TextSpan>[
                                                                        TextSpan(
                                                                            text:
                                                                                'Remarks: '),
                                                                        TextSpan(
                                                                            text:
                                                                                '$remarks',
                                                                            style:
                                                                                TextStyle(color: Colors.black))
                                                                      ])),
                                                                  SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                width: 15,
                                                              ),
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  RichText(
                                                                      text: TextSpan(
                                                                          style: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 12),
                                                                          children: <TextSpan>[
                                                                        TextSpan(
                                                                            text:
                                                                                'Pet: '),
                                                                        TextSpan(
                                                                            text:
                                                                                '$petName',
                                                                            style:
                                                                                TextStyle(color: Colors.black)),
                                                                      ])),
                                                                  SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  RichText(
                                                                      text: TextSpan(
                                                                          style: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 12),
                                                                          children: <TextSpan>[
                                                                        TextSpan(
                                                                          text:
                                                                              'Status: ',
                                                                        ),
                                                                        TextSpan(
                                                                            text: isCompleted == true
                                                                                ? 'Completed'
                                                                                : isBooked == true
                                                                                    ? 'In queue'
                                                                                    : 'Cancelled',
                                                                            style: TextStyle(
                                                                                color: isCompleted == true
                                                                                    ? Colors.green
                                                                                    : isBooked == true
                                                                                        ? Colors.blue
                                                                                        : Colors.red)),
                                                                      ])),
                                                                  SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  Text(
                                                                    'Ticket Number: ',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                  Text(
                                                                      '$referenceNumber',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight:
                                                                              FontWeight.bold)),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Positioned(
                                                    bottom: 0,
                                                    left: 0,
                                                    right: 0,
                                                    top: 113,
                                                    child: isBooked == false
                                                        ? Row(
                                                            children: [
                                                              Expanded(
                                                                  child: ElevatedButton(
                                                                      style: ElevatedButton.styleFrom(
                                                                          backgroundColor: Color(0xFFF6F6F6),
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.only(
                                                                                  bottomLeft: Radius.circular(
                                                                                    8,
                                                                                  ),
                                                                                  bottomRight: Radius.circular(8)))),
                                                                      onPressed: () {
                                                                        if (isCompleted ==
                                                                            false) {
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (context) {
                                                                                return Center(
                                                                                  child: Container(
                                                                                    height: 150,
                                                                                    width: 350,
                                                                                    child: Scaffold(
                                                                                      body: SafeArea(
                                                                                        child: Padding(
                                                                                          padding: const EdgeInsets.all(15),
                                                                                          child: Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Text(
                                                                                                'Cancellation Details',
                                                                                                style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                                                                                              ),
                                                                                              SizedBox(
                                                                                                height: 10,
                                                                                              ),
                                                                                              Text('Canceled by: $ownerName'),
                                                                                              SizedBox(
                                                                                                height: 5,
                                                                                              ),
                                                                                              Text('Reason: $reason')
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              });
                                                                        } else {
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (context) {
                                                                                return Center(
                                                                                  child: ClipRRect(
                                                                                    borderRadius: BorderRadius.circular(8),
                                                                                    child: Container(
                                                                                      height: 600,
                                                                                      width: 370,
                                                                                      child: AppointmentDetails(appointmentId: appointmentId),
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              });
                                                                        }
                                                                      },
                                                                      child: Text(
                                                                        isCompleted ==
                                                                                true
                                                                            ? 'APPOINTMENT COMPLETED'
                                                                            : 'APPOINTMENT CANCELLED',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.grey,
                                                                            fontSize: 12),
                                                                      )))
                                                            ],
                                                          )
                                                        : Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    TextButton(
                                                                        style: TextButton.styleFrom(
                                                                            backgroundColor:
                                                                                Color(0xFFF3F3F3),
                                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8)))),
                                                                        onPressed: () {
                                                                          showDialog(
                                                                              context: context,
                                                                              builder: (context) {
                                                                                return Center(
                                                                                  child: Container(
                                                                                      height: 380,
                                                                                      width: 350,
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.all(8.0),
                                                                                        child: ClipRRect(
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                          child: CancelAppointment(
                                                                                            appointmentId: appointmentId,
                                                                                          ),
                                                                                        ),
                                                                                      )),
                                                                                );
                                                                              });
                                                                        },
                                                                        child: Text(
                                                                          'CANCEL',
                                                                          style: TextStyle(
                                                                              color: Colors.black,
                                                                              fontSize: 12),
                                                                        )),
                                                              ),
                                                              Expanded(
                                                                  child: TextButton(
                                                                      style: TextButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(bottomRight: Radius.circular(8)))),
                                                                      onPressed: () {
                                                                        final branchId =
                                                                            appointment['branch_id'];
                                                                        Get.to(RescheduleScreen(
                                                                            branchId:
                                                                                branchId,
                                                                            appointmentId:
                                                                                appointmentId));
                                                                      },
                                                                      child: Text(
                                                                        'RESCHEDULE',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white),
                                                                      ))),
                                                            ],
                                                          ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ))),
    );
  }

  Future<void> cancelAppointment(int appointmentId) async {
    final response = await supabase
        .from('appointments')
        .update({'status': 'canceled', 'is_booked': false})
        .eq('appointment_id', appointmentId)
        .execute();

    try {
      bookedAppointments();
    } catch (e) {}
  }
}
