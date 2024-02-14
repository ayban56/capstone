import 'package:dogre/class/branch_data.dart';
import 'package:dogre/class/doctor_data.dart';
import 'package:dogre/class/pet_data.dart';
import 'package:dogre/main.dart';
import 'package:dogre/screens/home_screens/home.dart';
import 'package:dogre/service/snackbar_extention.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import the intl package

class ConfirmBooking extends StatefulWidget {
  const ConfirmBooking({
    super.key,
    required this.branchData,
    required this.doctorData,
    required this.petData,
    required this.appointmentTime,
    required this.concern,
    required this.remarks,
    required this.referenceNumber,
  });

  final BranchData branchData;
  final DoctorData doctorData;
  final PetData petData;
  final appointmentTime;
  final concern;
  final remarks;
  final referenceNumber;
  @override
  State<ConfirmBooking> createState() => _ConfirmBookingState();
}

class _ConfirmBookingState extends State<ConfirmBooking> {
  bool isConfirming = false;
  final dateFormat = DateFormat('MMMM d, y');

  Future<void> insertAppointment() async {
    final firstName = supabase.auth.currentUser?.userMetadata?['first_name'];
    final lastName = supabase.auth.currentUser?.userMetadata?['last_name'];
    final String fullName = '$firstName $lastName';
    final pureNumber =
        supabase.auth.currentUser?.userMetadata?['contact_number'];
    final contactNumber = '+63$pureNumber';
    final branchId = widget.branchData.branchId;
    final branchLocation = widget.branchData.branchLocation;
    final doctorId = widget.doctorData.doctorId;
    final appointmentDate =
        dateFormat.format(widget.doctorData.appointmentDate);
    String userId = supabase.auth.currentUser!.id;
    final appointmentTime = widget.appointmentTime;
    final doctorName = widget.doctorData.doctorName;
    final reasonForVisit = widget.concern;
    final remarks = widget.remarks;
    final petName = widget.petData.petName;
    final referenceNumber = widget.referenceNumber;

    setState(() {
      isConfirming = true;
    });

    await Future.delayed(Duration(seconds: 2));

    try {
      final response = await supabase.from('appointments').upsert([
        {
          'user_id': userId,
          'doctor_id': doctorId,
          'appointment_date': appointmentDate,
          'appointment_time': appointmentTime,
          'branch_id': branchId,
          'branch_location': branchLocation,
          'name': fullName,
          'contact_number': contactNumber,
          'doctor_name': doctorName,
          'reason_for_visit': reasonForVisit,
          'remarks': remarks,
          'reference_number': referenceNumber,
        }
      ]).execute();

      final responseAppointmentId = await supabase
          .from('appointments')
          .select('appointment_id')
          .eq('user_id', userId)
          .eq('branch_id', branchId)
          .order('appointment_id', ascending: false)
          .limit(1)
          .execute();

      final appointmentId =
          responseAppointmentId.data?[0]['appointment_id'] as int?;

      print('$appointmentId');

      setState(() {
        isConfirming = false;
      });

      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return Center(
              child: Container(
                height: 350,
                width: 320,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
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
                          Text('Your ticket number:'),
                          Text(
                            '$referenceNumber',
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
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
              ),
            );
          });
      await insertAppointmentDetails(appointmentId);
      print('galing');
    } on AuthException catch (e) {
      context.ShowSnackbar(message: e.toString(), backgroundColor: Colors.red);
      setState(() {
        isConfirming = false;
      });
    } catch (e) {
      context.ShowSnackbar(message: e.toString(), backgroundColor: Colors.red);
      setState(() {
        isConfirming = false;
      });
    }
  }

  Future<void> insertAppointmentDetails(int? appointmentId) async {
    if (appointmentId != null) {
      final petName = widget.petData.petName;
      final breed = widget.petData.petBreed;
      final specie = widget.petData.petSpecie;
      final birhdate = dateFormat.format(widget.petData.birthDate);
      final description = widget.petData.description;

      final petGender = widget.petData.petGender;
      final firstName = supabase.auth.currentUser?.userMetadata?['first_name'];
      final lastName = supabase.auth.currentUser?.userMetadata?['last_name'];
      final String fullName = '$firstName $lastName';
      final contactNumber =
          supabase.auth.currentUser?.userMetadata?['contact_number'];

      try {
        final response = await supabase.from('appointment_details').upsert([
          {
            'appointment_id': appointmentId,
            'pet_name': petName,
            'breed': breed,
            'species': specie,
            'gender': petGender,
            'birthdate': birhdate,
            'description': description,
            'owner_name': fullName,
            'contact_number': contactNumber,
          }
        ]).execute();

        print('Pet details inserted successfully.');
      } catch (e) {
        print('Error inserting pet details: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create a DateFormat object for formatting the date
    final dateFormat = DateFormat('MMMM d, y');
    final tryName = widget.branchData.branchLocation;
    final description = widget.petData.description.capitalize;
    final splitted = tryName.split(' ');
    final branch = splitted[0];
    final location = splitted[5];
    final woah = tryName.contains('City');
    var location2 = '';

    if (woah == true) {
      location2 = splitted[6];
    }

    final branchName = '$branch $location $location2';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Text(
          'Confirm Appointment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.blue,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 20),
                  child: Text(
                    'Please check the appointment details',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text('Branch: '),
                      Text('$branchName'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text('Appointment Date: '),
                      Text(
                          dateFormat.format(widget.doctorData.appointmentDate)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text('Doctor Name: '),
                      Text(widget.doctorData.doctorName),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text('Pet: '),
                      Text(widget.petData.petName),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text('Pet Description: '),
                      Text('$description'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text('Reason for Visit: '),
                      Text(widget.concern),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextButton(
                    style: TextButton.styleFrom(
                        fixedSize: Size(250, 20),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(width: .5, color: Colors.blue),
                            borderRadius: BorderRadius.circular(5))),
                    onPressed: isConfirming ? null : () => insertAppointment(),
                    child: isConfirming
                        ? LottieBuilder.asset(
                            'assets/lottie/loading.json',
                            width: 80,
                            height: 80,
                          )
                        : Text(
                            'Confirm Appointment',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
