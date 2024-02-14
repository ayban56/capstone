import 'package:dogre/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:lottie/lottie.dart';

class AppointmentDetails extends StatefulWidget {
  const AppointmentDetails({super.key, required this.appointmentId});
  final appointmentId;

  @override
  State<AppointmentDetails> createState() => _AppointmentDetailsState();
}

class _AppointmentDetailsState extends State<AppointmentDetails> {
  List<dynamic>? appointmentDetailsList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchAppointmentDetails();
  }

  Future<void> fetchAppointmentDetails() async {
    final appoinmentId = widget.appointmentId;
    final details = await supabase
        .from('appointments')
        .select('*,  appointment_details(*)')
        .eq('appointment_id', appoinmentId)
        .execute();

    try {
      setState(() {
        appointmentDetailsList = details.data;
        print('$appointmentDetailsList');
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return appointmentDetailsList == null
        ? Center(
            child: LottieBuilder.asset(
              'assets/lottie/loading.json',
              height: 100,
              width: 100,
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text('Appointment Details'),
              centerTitle: true,
              automaticallyImplyLeading: false,
              actions: [
                Stack(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(LineAwesomeIcons.times))
                  ],
                )
              ],
            ),
            body: SafeArea(
                child: Center(
              child: Column(
                  children: appointmentDetailsList!.map<Widget>((appointment) {
                final dateStr = appointment['appointment_date'];
                final datestr2 = DateTime.parse(dateStr);
                final appointmentDate =
                    DateFormat('MMMM d, y').format(datestr2);
                final ownerName = appointment['name'].toString().capitalize;
                final tryName = appointment['branch_location'];
                final referenceNumber = appointment['reference_number'];
                final timeStr = appointment['appointment_time'];
                final time = DateFormat('HH:mm:ss')
                    .parse(timeStr); // Parse the time string
                final formattedTime = DateFormat('hh:mm a').format(time);
                final tipospame = formattedTime.contains('AM');
                final details = appointment['appointment_details'];
                final petName = details['pet_name'].toString().capitalizeFirst;
                final doctorName = appointment['doctor_name'];
                final reasonForVisit = appointment['reason_for_visit'];
                final remark = appointment['remarks'];

                String lopsa = '';

                if (tipospame) {
                  lopsa = 'Morning';
                } else {
                  lopsa = 'Afternoon';
                }

                final splitted = tryName.split(' ');
                final branch = splitted[0];
                final location = splitted[5];
                final woah = tryName.contains('City');
                var location2 = '';

                if (woah == true) {
                  location2 = splitted[6];
                }

                final branchName = '$branch $location $location2';

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Branch'),
                                Text(
                                  '$branchName',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Appointment Date'),
                                Text(
                                  '$appointmentDate',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Time'),
                                Text(
                                  '$lopsa',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Doctor'),
                                Text(
                                  '$doctorName',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Pet Name'),
                                Text(
                                  '$petName',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Reason for visit'),
                                Text(
                                  '$reasonForVisit',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Divider(),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Remark'),
                                Text(
                                  '$remark',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Divider(),
                        Spacer(),
                        Text('Ticket Number'),
                        Text(
                          '$referenceNumber',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20,
                        )
                      ],
                    ),
                  ),
                );
              }).toList()),
            )),
          );
  }
}
