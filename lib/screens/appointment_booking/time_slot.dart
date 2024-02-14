// ignore_for_file: prefer_const_constructors

import 'dart:math';

import 'package:dogre/class/branch_data.dart';
import 'package:dogre/class/doctor_data.dart';
import 'package:dogre/class/pet_data.dart';
import 'package:dogre/main.dart';
import 'package:dogre/screens/appointment_booking/book_appointment.dart';
import 'package:dogre/screens/appointment_booking/confirm_booking.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase/supabase.dart';

class TimeSlot extends StatefulWidget {
  const TimeSlot({
    Key? key,
    required this.branchData,
    required this.doctorData,
    required this.formattedDate,
  });

  final BranchData branchData;
  final DoctorData doctorData;
  final formattedDate;

  @override
  State<TimeSlot> createState() => _TimeSlotState();
}

class _TimeSlotState extends State<TimeSlot> {
  List<String> timeSlots = [];
  List? petList;
  int selectedTimeSlotIndex = -1;
  int selectedPetIndex = -1;
  bool isLoading = true;
  int morningSlotsCount = 0;
  int afternoonSlotsCount = 0;
  bool showMorningSlots = true;
  String morningEndTime = '11:30 AM';
  String afternoonStartTime = '1:00 PM';
  String startTime = '';
  String endTime = '';
  String referenceNumber = '';

  TextEditingController concernController = TextEditingController();
  TextEditingController remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    fetchTimeSlots();
    pets();
  }

  Future<void> pets() async {
    final userId = supabase.auth.currentUser!.id;
    final response =
        await supabase.from('pets').select('*').eq('user_id', userId).execute();

    try {
      setState(() {
        petList = response.data.toList();
      });
      print(petList);

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          isLoading = false;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  String formatTimeToAMPM(String time) {
    final timeFormat = DateFormat('hh:mm a');
    final parsedTime = DateFormat('HH:mm').parse(time);
    return timeFormat.format(parsedTime);
  }

  Future<void> fetchTimeSlots() async {
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
      startTime = workingHours['start_time'] as String;
      endTime = workingHours['end_time'] as String;

      final bookedAppointmentsResponse = await supabase
          .from('appointments')
          .select('appointment_time')
          .eq('is_booked', true)
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

  String calculateMiddleTime(String startTime, String endTime) {
    final morningEndTime = '11:30:00';
    final afternoonStartTime = '12:30:00';

    final startDateTime = DateFormat('HH:mm:ss').parse(startTime);
    final endDateTime = DateFormat('HH:mm:ss').parse(endTime);
    final middleTime = startDateTime.add(
      Duration(
          milliseconds:
              (endDateTime.difference(startDateTime).inMilliseconds / 2)
                  .round()),
    );

    if (middleTime.isAfter(DateFormat('HH:mm:ss').parse(morningEndTime)) &&
        middleTime.isBefore(DateFormat('HH:mm:ss').parse(afternoonStartTime))) {
      // If the middle time falls within the excluded range, adjust it
      final adjustedTime = DateFormat('HH:mm:ss').parse(afternoonStartTime);
      return DateFormat('HH:mm:ss').format(adjustedTime);
    }

    return DateFormat('HH:mm:ss').format(middleTime);
  }

  void selectTimeSlot(int index) {
    setState(() {
      selectedTimeSlotIndex = index;
    });
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

      if (!isTimeSlotBooked(formattedTime, bookedTimeSlots) &&
          !isExcludedTimeSlot(formattedTime)) {
        availableTimeSlots.add(formattedTime);
        if (isMorningSlot(formattedTime)) {
          morningSlotsCount++;
        } else {
          afternoonSlotsCount++;
        }
      }
      currentTime = currentTime.add(slotDuration);
    }

    return availableTimeSlots;
  }

  bool isExcludedTimeSlot(String timeSlot) {
    // Parse the time string to DateTime
    final time = DateFormat('hh:mm a').parse(timeSlot);

    // Check if the time is between 12:00 PM and 1:00 PM
    return time.isAfter(DateTime(time.year, time.month, time.day, 10, 0, 0)) &&
        time.isBefore(DateTime(time.year, time.month, time.day, 13, 0, 0));
  }

  bool isTimeSlotBooked(String timeSlot, List<String> bookedTimeSlots) {
    print('Checking if $timeSlot is booked.');

    return bookedTimeSlots.contains(timeSlot);
  }

  Future<void> reviewAppointments() async {
    final concern = concernController.text.capitalize.toString();
    final remarks = remarksController.text;

    if (selectedTimeSlotIndex == -1 || selectedPetIndex == -1) {
      Get.snackbar('error', '',
          backgroundColor: Colors.red.shade200,
          messageText: Text('Pets and time are required'),
          icon: Icon(Icons.error));
      return;
    }

    if (concern.isEmpty) {
      Get.snackbar('error', '',
          backgroundColor: Colors.red.shade200,
          messageText: Text('Concern field is required'),
          icon: Icon(Icons.error));
      return;
    }

    final selectedPet = petList![selectedPetIndex];
    final birthDateStr = selectedPet['birthdate'];
    final birthDate = DateFormat('yyyy-MM-dd').parse(birthDateStr);
    final petName = selectedPet['pet_name'];
    final petBreed = selectedPet['pet_breed'];
    final description = selectedPet['description'];
    final petGender = selectedPet['pet_gender'];
    final petSpecie = selectedPet['pet_specie'];
    final branchId = widget.branchData.branchId;
    final branchLocation = widget.branchData.branchLocation;
    final doctorId = widget.doctorData.doctorId;
    final doctorEmail = widget.doctorData.doctorEmail;
    final appointmentDate = widget.doctorData.appointmentDate;
    final selectedTime = timeSlots[selectedTimeSlotIndex];
    final appointmentTime = selectedTime;
    final formattedDate = widget.formattedDate;
    final doctorName = widget.doctorData.doctorName;
    final branchData = BranchData(
      branchId: branchId,
      branchLocation: branchLocation,
    );
    final doctorData = DoctorData(
      doctorId: doctorId,
      doctorEmail: doctorEmail,
      appointmentDate: appointmentDate,
      doctorName: doctorName,
    );
    final petData = PetData(
      petName: petName,
      petBreed: petBreed,
      birthDate: birthDate,
      description: description,
      petGender: petGender,
      petSpecie: petSpecie,
    );

    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 500,
                width: 350,
                child: ConfirmBooking(
                  branchData: branchData,
                  doctorData: doctorData,
                  petData: petData,
                  appointmentTime: appointmentTime,
                  concern: concern,
                  remarks: remarks,
                  referenceNumber: referenceNumber,
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Set appointment'),
          centerTitle: true,
          foregroundColor: Colors.blue,
        ),
        body: Center(
            child: Center(
          child: LottieBuilder.asset(
            'assets/lottie/loading.json',
            height: 80,
            width: 80,
          ),
        ) // You can customize the loading indicator
            ),
      );
    }
    if (timeSlots.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'No Available Time Slots',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          foregroundColor: Colors.blue,
        ),
        body: Center(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No available time slots',
              style: TextStyle(fontSize: 20),
            ),
          ],
        )),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Appointment Details',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
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
                    DateFormat('MMMM d, y').format(
                      DateFormat('y-M-d').parse(widget.formattedDate),
                    ),
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      showMorningSlots = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                            width: 1,
                            color:
                                showMorningSlots ? Colors.blue : Colors.white)),
                  ),
                  child: Text(
                    'Morning (${formatTimeToAMPM(startTime)} - ${formatTimeToAMPM(morningEndTime)})',
                    style: TextStyle(
                        color: showMorningSlots ? Colors.blue : Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      showMorningSlots = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            width: 1,
                            color: !showMorningSlots
                                ? Colors.blue
                                : Colors.white)),
                  ),
                  child: Text(
                    'Afternoon (${formatTimeToAMPM(afternoonStartTime)} - ${formatTimeToAMPM(endTime)})',
                    style: TextStyle(
                        color: !showMorningSlots ? Colors.blue : Colors.black),
                  ),
                ),
              ],
            ),
            Container(
              height: 150,
              margin: EdgeInsets.only(bottom: 10),
              child: showMorningSlots
                  ? _buildSlotList(timeSlots.where(isMorningSlot).toList())
                  : _buildSlotList(timeSlots.where(isAfternoonSlot).toList()),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    'Select a Pet', // Add your text here
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  hintText: 'Select a Pet',
                  border: OutlineInputBorder(),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                ),
                items: petList?.asMap().entries.map((entry) {
                  final index = entry.key;
                  final pet = entry.value as Map<String, dynamic>;
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text(pet['pet_name'] as String),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedPetIndex = newValue!;
                  });
                },
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    'Reason for visit', // Add your text here
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Concern is required*'; // Validation error message
                  }
                  return null; // No validation error
                },
                maxLines: 1,
                controller: concernController,
                decoration: InputDecoration(
                  focusColor: Colors.blue,
                  alignLabelWithHint: true,
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    'Remarks (optional)', // Add your text here
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                maxLines: 3,
                controller: remarksController,
                decoration: InputDecoration(
                  focusColor: Colors.blue,
                  alignLabelWithHint: true,
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextButton(
              onPressed: () {
                reviewAppointments();
                print('$selectedTimeSlotIndex');
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

  Widget _buildSlotList(List<String> slots) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final timeSlot = slots[index];
        final isSelected = selectedTimeSlotIndex == index;

        int slotNumber = index + 1;

        final number = generateReferenceNumber();

        referenceNumber = number;

        return Visibility(
          visible: showMorningSlots
              ? isMorningSlot(timeSlot)
              : isAfternoonSlot(timeSlot),
          child: Column(
            children: [
              Container(
                height: 150,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    surfaceTintColor: Colors.white,
                    elevation: 5,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        side: BorderSide(
                          color: isSelected ? Colors.blue : Colors.grey,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: () {
                        selectTimeSlot(index);
                        print(timeSlot);
                        print(referenceNumber);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Slot $slotNumber',
                            style: TextStyle(
                              fontSize: 15,
                              color: isSelected ? Colors.blue : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String generateReferenceNumber() {
    Random random = Random();
    return random.nextInt(1000000).toString(); // Adjust the range as needed
  }

  bool isMorningSlot(String timeSlot) {
    // Parse the time string to DateTime
    final time = DateFormat('hh:mm a').parse(timeSlot);

    // Check if the time is before 12:00 PM
    return time.isBefore(DateTime(time.year, time.month, time.day, 12, 0, 0));
  }

  bool isAfternoonSlot(String timeSlot) {
    // Parse the time string to DateTime
    final time = DateFormat('hh:mm a').parse(timeSlot);

    // Check if the time is after or equal to 12:00 PM
    return time.isAfter(DateTime(time.year, time.month, time.day, 12, 0, 0)) ||
        time.isAtSameMomentAs(
            DateTime(time.year, time.month, time.day, 12, 0, 0));
  }
}
