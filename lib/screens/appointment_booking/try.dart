import 'package:dogre/class/branch_data.dart';
import 'package:dogre/class/doctor_data.dart';
import 'package:dogre/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookAppointment extends StatefulWidget {
  const BookAppointment(
      {super.key,
      required this.branchData,
      required this.doctorData,
      required this.formattedDate});

  final BranchData branchData;
  final DoctorData doctorData;
  final formattedDate;

  @override
  State<BookAppointment> createState() => _BookAppointmentState();
}

class _BookAppointmentState extends State<BookAppointment> {
  List? slot;

  String formatTimeToAMPM(String time) {
    final timeFormat = DateFormat('hh:mm a');
    final parsedTime = DateFormat('HH:mm').parse(time);
    return timeFormat.format(parsedTime);
  }

  Future<void> timeSlot() async {
    final doctorId = widget.doctorData.doctorId;
    final selectedDate = widget.doctorData.appointmentDate;
    final formattedDate = DateFormat.yMMMMd().format(selectedDate);
    final dayOfWeek = selectedDate.weekday;

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
          slot = availableTimeSlots;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Available Time Slots'),
        centerTitle: true,
        foregroundColor: Colors.blue,
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, // You can adjust the number of columns as needed
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 2.0, // Adjust the height of each grid item
        ),
        itemCount: slot?.length ?? 0,
        itemBuilder: (context, index) {
          final timeSlot = slot![index];
          return TextButton(
            style: TextButton.styleFrom(
              fixedSize: const Size(150, 50), // Adjust the size as needed
              side: BorderSide(color: Color(0xFF127ABD)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: () {
              // Handle time slot selection here
            },
            child: Center(
              child: Text(timeSlot),
            ),
          );
        },
      ),
    );
  }
}
