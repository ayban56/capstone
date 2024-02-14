import 'package:dogre/main.dart';
import 'package:dogre/screens/appointment_nav/appointment_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AppointmentHistory extends StatefulWidget {
  const AppointmentHistory({super.key});

  @override
  State<AppointmentHistory> createState() => _AppointmentHistoryState();
}

class _AppointmentHistoryState extends State<AppointmentHistory> {
  List? appointmentList;
  String dropdownValue = 'Latest first';

  Future<void> historyAppointment() async {
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('appointments')
        .select('* , appointment_details(pet_name)')
        .eq('user_id', userId)
        .eq('is_booked', false)
        .order('appointment_date', ascending: true)
        .order('appointment_time', ascending: true)
        .execute();

    try {
      setState(() {
        appointmentList = response.data.toList();
      });
      print(appointmentList);
    } catch (e) {
      print(e);
    }
  }

  Future<Map<String, dynamic>?> fetchAppointmentDetails(
      int appointmentId) async {
    try {
      final response = await supabase
          .from('appointment_details')
          .select('*')
          .eq('appointment_id', appointmentId)
          .single()
          .execute();

      return response.data;
    } catch (e) {
      print(e);
    }
  }

  Future<void> sortAppointment(bool newestFirst) async {
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('appointments')
        .select('*')
        .eq('user_id', userId)
        .eq('is_booked', false)
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    historyAppointment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Text('History appointments'),
        centerTitle: true,
        foregroundColor: Colors.blue,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
          child: RefreshIndicator(
              displacement: 10,
              edgeOffset: 1.1,
              triggerMode: RefreshIndicatorTriggerMode.onEdge,
              onRefresh: historyAppointment,
              child: Padding(
                padding: const EdgeInsets.only(left: 3, right: 3),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Sort by: ',
                          style: TextStyle(fontSize: 14, color: Colors.black45),
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
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.black45),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                dropdownValue = newValue!;
                                if (newValue == 'Latest first') {
                                  sortAppointment(false); // Sort newest first
                                } else {
                                  sortAppointment(true); // Sort oldest first
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: appointmentList?.length ?? 0,
                        itemBuilder: (context, index) {
                          final appointment = appointmentList![index];
                          final dateStr = appointment['appointment_date'];
                          final datestr2 = DateTime.parse(dateStr);
                          final appointmentMonth =
                              DateFormat('MMM').format(datestr2);
                          final appointmentDay =
                              DateFormat('d').format(datestr2);
                          final timeStr = appointment['appointment_time'];
                          final time = DateFormat('HH:mm:ss')
                              .parse(timeStr); // Parse the time string
                          final formattedTime =
                              DateFormat('hh:mm a').format(time);
                          final reasonForVisit =
                              appointment['reason_for_visit'];
                          final status =
                              appointment['status'].toString().capitalize;
                          final appointmentId = appointment['appointment_id'];
                          final branchName = appointment['branch_location'];
                          final doctorName = appointment['doctor_name'];
                          final remarks = appointment['remarks'];
                          final petName = appointment['pet_name'];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Column(
                              children: [
                                Card(
                                  elevation: 5,
                                  surfaceTintColor: Colors.white,
                                  child: Container(
                                    height: 120,
                                    padding: EdgeInsets.only(top: 20),
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
                                                      color: Colors.blue,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    '$appointmentDay',
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 40,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '$branchName',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
                                                                  color: Colors
                                                                      .blue,
                                                                  fontSize: 12),
                                                              children: <TextSpan>[
                                                                TextSpan(
                                                                    text:
                                                                        'Time: '),
                                                                TextSpan(
                                                                    text:
                                                                        '$formattedTime',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black)),
                                                              ]),
                                                        ),
                                                        SizedBox(
                                                          height: 2,
                                                        ),
                                                        RichText(
                                                            text: TextSpan(
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue,
                                                                    fontSize:
                                                                        12),
                                                                children: <TextSpan>[
                                                              TextSpan(
                                                                  text:
                                                                      'Doctor: '),
                                                              TextSpan(
                                                                  text:
                                                                      'Dr. $doctorName',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black)),
                                                            ])),
                                                        SizedBox(
                                                          height: 2,
                                                        ),
                                                        RichText(
                                                            text: TextSpan(
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue,
                                                                    fontSize:
                                                                        12),
                                                                children: <TextSpan>[
                                                              TextSpan(
                                                                  text:
                                                                      'Reason for visit: '),
                                                              TextSpan(
                                                                  text:
                                                                      '$reasonForVisit',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black)),
                                                            ])),
                                                        SizedBox(
                                                          height: 2,
                                                        ),
                                                        RichText(
                                                            text: TextSpan(
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue,
                                                                    fontSize:
                                                                        12),
                                                                children: <TextSpan>[
                                                              TextSpan(
                                                                  text:
                                                                      'Remarks: '),
                                                              TextSpan(
                                                                  text:
                                                                      '$remarks',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black))
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
                                                                    color: Colors
                                                                        .blue,
                                                                    fontSize:
                                                                        12),
                                                                children: <TextSpan>[
                                                              TextSpan(
                                                                  text:
                                                                      'Pet: '),
                                                              TextSpan(
                                                                  text:
                                                                      '$petName',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black)),
                                                            ])),
                                                        SizedBox(
                                                          height: 2,
                                                        ),
                                                        RichText(
                                                            text: TextSpan(
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .blue,
                                                                    fontSize:
                                                                        12),
                                                                children: <TextSpan>[
                                                              TextSpan(
                                                                  text:
                                                                      'Status: '),
                                                              TextSpan(
                                                                  text:
                                                                      '$status',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black)),
                                                            ])),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ))),
    );
  }
}
