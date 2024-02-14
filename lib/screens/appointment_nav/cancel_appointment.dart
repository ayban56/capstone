import 'package:dogre/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:lottie/lottie.dart';

class CancelAppointment extends StatefulWidget {
  const CancelAppointment({super.key, required this.appointmentId});
  final int appointmentId;

  @override
  State<CancelAppointment> createState() => _CancelAppointmentState();
}

class _CancelAppointmentState extends State<CancelAppointment> {
  List<dynamic>? appointmentDetails;
  String dropdownValue = 'Change of mind';

  void fetchAppointmentDetails() async {
    final response = await supabase
        .from('appointments')
        .select('* , appointment_details(*)')
        .eq('appointment_id', widget.appointmentId)
        .execute();

    setState(() {
      appointmentDetails = response.data;
      print(appointmentDetails);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchAppointmentDetails();
  }

  @override
  Widget build(BuildContext context) {
    return appointmentDetails == null
        ? Center(
            child: LottieBuilder.asset(
              'assets/lottie/loading.json',
              height: 80,
              width: 80,
            ),
          )
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                'Cancel Appointment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(LineAwesomeIcons.times),
                ),
              ],
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                      children: appointmentDetails!.map<Widget>((appointment) {
                    final dateStr = appointment['appointment_date'];
                    final datestr2 = DateTime.parse(dateStr);
                    final appointmentDate =
                        DateFormat('MMMM d, y').format(datestr2);
                    final appointmentTime = appointment['appointment_time'];
                    final remarks = appointment['remarks'];
                    final timeStr = appointment['appointment_time'];
                    final time = DateFormat('HH:mm:ss')
                        .parse(timeStr); // Parse the time string
                    final formattedTime = DateFormat('hh:mm a').format(time);
                    final details = appointment['appointment_details'];
                    final petName = details['pet_name'];

                    return Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Appointment Details',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                  children: <TextSpan>[
                                TextSpan(text: 'Date: '),
                                TextSpan(
                                    text: '$appointmentDate',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal))
                              ])),
                          SizedBox(
                            height: 5,
                          ),
                          RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                  children: <TextSpan>[
                                TextSpan(text: 'Time: '),
                                TextSpan(
                                    text: '$formattedTime',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal))
                              ])),
                          SizedBox(
                            height: 5,
                          ),
                          RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                  children: <TextSpan>[
                                TextSpan(text: 'Pet: '),
                                TextSpan(
                                    text: '$petName',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal))
                              ])),
                          SizedBox(
                            height: 5,
                          ),
                          RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                  children: <TextSpan>[
                                TextSpan(text: 'Remarks: '),
                                TextSpan(
                                    text: '$remarks',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal))
                              ])),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                'Reason for Cancelation',
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '*',
                                style: TextStyle(color: Colors.red),
                              )
                            ],
                          ),
                          Container(
                            height: 50,
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                contentPadding:
                                    EdgeInsets.only(left: 20, right: 17),
                                filled: true,
                                fillColor: Colors.white,
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: .5, color: Colors.black)),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: .5, color: Colors.black)),
                              ),
                              elevation: 0,
                              value: dropdownValue,
                              icon: Icon(
                                Icons.arrow_drop_down_outlined,
                                size: 20,
                              ),
                              items: <String>[
                                'Change of mind',
                                'Others',
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
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList()),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    top: 270,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: Color(0xFFF2F2F2),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(8)))),
                              onPressed: () {},
                              child: Text(
                                'BACK',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 12),
                              )),
                        ),
                        Expanded(
                            child: TextButton(
                                style: TextButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(8)))),
                                onPressed: () {
                                  final appointmentId = widget.appointmentId;
                                  cancelAppointment(appointmentId);
                                  Future.delayed(Duration(seconds: 5));
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'CANCEL APPOINTMENT',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Future<void> cancelAppointment(int appointmentId) async {
    final response = await supabase
        .from('appointments')
        .update({
          'status': 'canceled',
          'is_booked': false,
          'reason_for_cancellation': dropdownValue
        })
        .eq('appointment_id', appointmentId)
        .execute();

    try {
      fetchAppointmentDetails();
    } catch (e) {}
  }
}
