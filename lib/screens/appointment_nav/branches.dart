import 'package:dogre/class/branch_data.dart';
import 'package:dogre/components/my_button.dart';
import 'package:dogre/main.dart';
import 'package:dogre/screens/appointment_booking/book_appointment.dart';
import 'package:dogre/screens/appointment_booking/choose_doctor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class FindADoctor extends StatefulWidget {
  const FindADoctor({super.key});

  @override
  State<FindADoctor> createState() => _FindADoctorState();
}

class _FindADoctorState extends State<FindADoctor> {
  String? _currentAddress = "Address will be displayed here";
  bool isLoading = true;
  TextEditingController search = TextEditingController();

  List? branchList;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    branches();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _getPosition();
      final latitude = position.latitude;
      final longitude = position.longitude;

      await getAddress(latitude, longitude);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error getting location: $e");
      setState(() {
        isLoading = false;
        _currentAddress = "Error getting location";
      });
    }
  }

  Future<Position> _getPosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.deniedForever) {
        throw Exception("Location permission denied forever");
      }
    } else if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission denied forever");
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> getAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placeMarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placeMarks.isNotEmpty) {
        Placemark placemark = placeMarks[0];

        setState(() {
          _currentAddress =
              ' ${placemark.street},${placemark.administrativeArea}, ${placemark.locality}, ${placemark.country}';
        });
      } else {
        setState(() {
          _currentAddress = "Address not found";
        });
      }
    } catch (e) {
      print("Error getting address: $e");
      setState(() {
        _currentAddress = "Error getting address";
      });
    }
  }

  void branches() async {
    final response = await supabase.from('branches').select('*').execute();

    final dummyBranch = {
      'branch_id': 0,
      'branch_location': 'Select a Branch', // You can customize this text
      'latitude': 0.0, // Provide a default latitude
      'longitude': 0.0, // Provide a default longitude
      'doctor_count': 0,
    };

    try {
      setState(() async {
        branchList = response.data.toList();
        isLoading = false;

        for (var branchData in branchList!) {
          final branchId = branchData['branch_id'];
          final doctorsResponse = await supabase
              .from('users')
              .select('*')
              .eq('user_type', 'doctor')
              .eq('branch_id', branchId)
              .execute();
          final doctorCount = doctorsResponse.data.length;
          branchData['doctor_count'] = doctorCount;
        }
      });
      print(branchList);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Row(
              children: [
                TextButton.icon(
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });

                    try {
                      final position = await _getPosition();
                      final latitude = position.latitude;
                      final longitude = position.longitude;

                      getAddress(latitude, longitude);
                    } catch (e) {
                      print("Error getting location: $e");
                    } finally {
                      setState(() {
                        isLoading =
                            false; // Hide loading indicator after fetching location.
                      });
                    }
                  },
                  icon: const Icon(Icons.location_pin),
                  label: Text(
                    _currentAddress ?? "",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 20),
              child: Text(
                'ASVC branch near you',
                style: TextStyle(fontSize: 17, color: Colors.grey.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
