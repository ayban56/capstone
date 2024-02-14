import 'package:dogre/class/branch_data.dart';
import 'package:dogre/class/doctor_data.dart';
import 'package:dogre/class/time_slot.dart';
import 'package:dogre/main.dart';
import 'package:dogre/screens/appointment_booking/book_appointment.dart';
import 'package:dogre/screens/appointment_booking/time_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:lottie/lottie.dart';

class ChooseDoctor extends StatefulWidget {
  const ChooseDoctor({
    super.key,
    required this.branchData,
  });
  final BranchData branchData;

  @override
  State<ChooseDoctor> createState() => _ChooseDoctorState();
}

class _ChooseDoctorState extends State<ChooseDoctor> {
  TextEditingController dateController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String availabilityText = '';
  String selectedDay = '';
  bool isLoading = true;
  List? doctorList;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime canBook = DateTime.now().add(Duration(days: 5));
    final DateTime canBookLast = DateTime.now().add(Duration(days: 12));
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: canBook,
      firstDate: canBook,
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
    final branchId = widget.branchData.branchId;
    final branchLocation = widget.branchData.branchLocation;

    final appointmentDate = selectedDate;

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
        .select('*, doctor_schedule(*)')
        .eq('branch_id', branchId)
        .eq('user_type', 'doctor')
        .in_('id', availableDoctorIds.toList())
        .execute();

    Navigator.pop(context);

    try {
      setState(() {
        doctorList = doctorsResponse.data.toList();
      });
      print(doctorList);
    } catch (e) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Text(
                        'Preferred date',
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
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w300,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.black54),
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
                    child: Text(
                      availabilityText,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: doctorList?.length ?? 0,
                        itemBuilder: (context, index) {
                          final doctor = doctorList?[index];
                          final doctorEmail = doctor['email'];
                          final firstName = doctor['first_name'];
                          final lastName = doctor['last_name'];
                          final doctorName = '$firstName $lastName';
                          final formatedName = doctorName.toString().capitalize;
                          final doctorContactNumber = doctor['contact_number'];
                          final doctorId = doctor['id'];
                          final avatarUrl = doctor['avatar_url'];
                          final schedules =
                              doctor['doctor_schedule'] as List<dynamic>;

                          return ListTile(
                            onTap: () {
                              final appointmentDate = selectedDate;
                              final formattedDate = DateFormat('yyyy-MM-dd')
                                  .format(appointmentDate);

                              final branchData = BranchData(
                                branchId: widget.branchData.branchId,
                                branchLocation:
                                    widget.branchData.branchLocation,
                              );
                              final doctorData = DoctorData(
                                doctorId: doctorId,
                                doctorEmail: doctorEmail,
                                appointmentDate: appointmentDate,
                                doctorName: doctorName,
                              );

                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => TimeSlot(
                                    branchData: branchData,
                                    doctorData: doctorData,
                                    formattedDate: formattedDate),
                              ));
                            },
                            contentPadding: EdgeInsets.all(8.0),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                height: 70,
                                width: 70,
                                child: Image.network(
                                  avatarUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(
                              'Dr. $formatedName',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.black),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email: $doctorEmail',
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  'Contact Number: $doctorContactNumber',
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          );
                        }),
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
