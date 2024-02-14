import 'package:dogre/screens/maps/maps_utils.dart';
import 'package:dogre/service/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:lottie/lottie.dart' as lootie;
import 'package:shimmer/shimmer.dart';
import 'dart:math' as math;

import '../../class/branch_data.dart';
import '../../components/my_button.dart';
import '../../main.dart';
import '../appointment_booking/choose_doctor.dart';

class MyMapPage extends StatefulWidget {
  @override
  _MyMapPageState createState() => _MyMapPageState();
}

class _MyMapPageState extends State<MyMapPage> {
  static const LatLng branch = LatLng(14.53204, 121.06818);
  Location location = Location();
  LatLng? currentLocation;
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String currentAddress = '';
  Set<Marker> markers = Set<Marker>();
  List? branchList;
  LatLng? selectedBranchLocation;
  BranchData? selectedBranchData;
  int selectedBranchIndex = -1;
  bool _isDisposed = false;
  bool isLoading = true;
  GoogleMapController? _googleMapController;
  BitmapDescriptor currentIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  @override
  void initState() {
    super.initState();
    addCustomIcon();
    customIconForUser();
    getLocationUpdates();
    branches();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> getLocationUpdates() async {
    if (!_isDisposed) {
      bool serviceEnabled;
      PermissionStatus permissionGranted;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      location.onLocationChanged.listen((LocationData currentLocationData) {
        if (!_isDisposed &&
            currentLocationData.latitude != null &&
            currentLocationData.longitude != null) {
          setState(() {
            currentLocation = LatLng(
                currentLocationData.latitude!, currentLocationData.longitude!);
            fetchAddress(currentLocation!);
          });
        }
      });
    }
  }

  Future<void> fetchAddress(LatLng location) async {
    try {
      List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        currentAddress = placemarks[0].name ?? 'Unknown Address';
      } else {
        currentAddress = 'Unknown Address';
      }

      // Update the info window with the current address
      updateInfoWindow();
    } catch (e) {
      currentAddress = 'Failed to fetch address';
      print('Failed to fetch address: $e');
    }
  }

  void updateInfoWindow() {
    if (currentLocation != null) {
      final currentLocationMarker = Marker(
        markerId: MarkerId("currentLocation"),
        position: currentLocation!,
        infoWindow: InfoWindow(
          title: currentAddress,
        ),
      );

      setState(() {
        markers.removeWhere(
            (marker) => marker.markerId.value == 'currentLocation');
        markers.add(currentLocationMarker);
      });
    }
  }

  Future<void> branches() async {
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

        // Insert the dummy branch at the beginning of the list
        branchList!.insert(0, dummyBranch);

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

  double calculateDistance(LatLng from, LatLng to) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    final double lat1 = math.pi / 180.0 * from.latitude;
    final double lon1 = math.pi / 180.0 * from.longitude;
    final double lat2 = math.pi / 180.0 * to.latitude;
    final double lon2 = math.pi / 180.0 * to.longitude;
    final double dlat = lat2 - lat1;
    final double dlon = lon2 - lon1;
    final double a = math.sin(dlat / 2) * math.sin(dlat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dlon / 2) *
            math.sin(dlon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final double distance = earthRadius * c; // Distance in kilometers
    return distance;
  }

  int compareBranchByDistance(branch1, branch2) {
    final branchLocation1 = LatLng(
      branch1['latitude'] as double,
      branch1['longitude'] as double,
    );

    final branchLocation2 = LatLng(
      branch2['latitude'] as double,
      branch2['longitude'] as double,
    );

    final distance1 = calculateDistance(currentLocation!, branchLocation1);
    final distance2 = calculateDistance(currentLocation!, branchLocation2);

    return distance1.compareTo(distance2);
  }

  Future<void> navigateToChooseDoctorScreen() async {
    // Show a loading indicator or delay as needed
    // For example, you can use a loading animation or delay here
    // Add your desired delay duration
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: lootie.LottieBuilder.asset(
              'assets/lottie/loading.json',
              height: 80,
              width: 80,
            ),
          );
        });

    if (selectedBranchData != null) {
      await Future.delayed(Duration(seconds: 1));
      Navigator.pop(context);
      Get.to(ChooseDoctor(branchData: selectedBranchData!));
    } else {
      Get.snackbar('error', '',
          backgroundColor: Colors.red.shade200,
          messageText: Text('Please select branch'),
          icon: Icon(Icons.error));
    }
  }

  void updateCameraPosition(LatLng location) {
    if (currentLocation != null && selectedBranchLocation != null) {
      final double distance =
          calculateDistance(currentLocation!, selectedBranchLocation!);
      final southwest = LatLng(
        math.min(currentLocation!.latitude, selectedBranchLocation!.latitude),
        math.min(currentLocation!.longitude, selectedBranchLocation!.longitude),
      );

      final northeast = LatLng(
        math.max(currentLocation!.latitude, selectedBranchLocation!.latitude),
        math.max(currentLocation!.longitude, selectedBranchLocation!.longitude),
      );

      final center = LatLng(
        (southwest.latitude + northeast.latitude) / 2,
        (southwest.longitude + northeast.longitude) / 2,
      );

      final updatedCameraPosition = CameraPosition(
        target: center,
        zoom: calculateZoomLevel(distance),
      );

      final bounds = CameraTargetBounds(
          LatLngBounds(southwest: southwest, northeast: northeast));

      _googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(updatedCameraPosition),
      );
    }
  }

  double calculateDistance2(LatLng location1, LatLng location2) {
    // Implement the distance calculation logic using Haversine formula or any other method.
    // You can find libraries or online resources for this calculation.
    // For simplicity, I'll assume a basic calculation here (not accurate for long distances).
    return math.sqrt(
      math.pow(location1.latitude - location2.latitude, 2) +
          math.pow(location1.longitude - location2.longitude, 2),
    );
  }

  double calculateZoomLevel(double distance) {
    // Adjust this function based on your requirements and testing.
    // This is a basic example, and you may need to fine-tune it for your specific use case.
    const double maxDistanceForMaxZoom =
        2000; // Adjust this distance as needed.
    const double maxZoom = 15.0; // Adjust this zoom level as needed.

    if (distance > maxDistanceForMaxZoom) {
      return maxZoom;
    } else {
      // Calculate the zoom level based on the distance.
      // This is just a simple example; you may need to adjust the formula.
      return maxZoom - (distance / maxDistanceForMaxZoom) * maxZoom;
    }
  }

  void customIconForUser() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), 'assets/final_logo/my_location.png')
        .then((icon) {
      setState(() {
        currentIcon = icon;
      });
    });
  }

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(), 'assets/final_logo/pet-shop.png')
        .then((icon) {
      setState(() {
        markerIcon = icon;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return SizedBox(
                height: constraints.maxHeight / 1.4,
                child: Stack(children: [
                  if (currentLocation == null)
                    Center(child: Text('Loading....'))
                  else
                    GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        _googleMapController = controller;
                      },
                      zoomControlsEnabled: true,
                      initialCameraPosition: CameraPosition(
                        target: currentLocation ?? selectedBranchLocation!,
                        zoom: 15.0,
                      ),
                      markers: {
                        // Marker for the current location
                        if (currentLocation != null)
                          Marker(
                            markerId: MarkerId('currentLocationMarker'),
                            position: currentLocation!,
                            infoWindow: InfoWindow(
                              title: 'Current Location',
                            ),
                            icon: currentIcon,
                          ),
                        // Markers for branches
                        ...branchList?.map((branch) {
                              final branchLocation = branch['branch_name'];
                              final branchId = branch['branch_id'].toString();
                              final lat = branch['latitude'] as double;
                              final long = branch['longitude'] as double;
                              return Marker(
                                icon: markerIcon,
                                markerId: MarkerId(branchId),
                                position: LatLng(lat, long),
                                infoWindow: InfoWindow(
                                  title: branchLocation,
                                ),
                              );
                            }) ??
                            [],
                      },
                    ),
                ]),
              );
            }),
            DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.3,
              snapSizes: [0.3, 1],
              snap: true,
              builder: (BuildContext context, scrollController) {
                return Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      if (branchList != null && branchList!.isNotEmpty)
                        _buildBranchList(scrollController)
                      else
                        _buildShimmerLoadingBranchList(),
                    ],
                  ),
                );
              },
            ),
            Container(
              child: Visibility(
                visible: selectedBranchData != null,
                child: Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 50,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10))),
                          backgroundColor: Colors.blue),
                      onPressed: () {
                        navigateToChooseDoctorScreen();
                      },
                      child: Text(
                        'Choose Branch',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoadingBranchList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: List.generate(2, (index) {
            return Column(
              children: List.generate(2, (index) {
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    color: Colors.white,
                  ),
                  title: Container(
                    height: 15,
                    color: Colors.white,
                  ),
                  subtitle: Container(
                    height: 15,
                    color: Colors.white,
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildBranchList(scrollController) => Column(
        children: [
          ListView.builder(
            controller: scrollController,
            shrinkWrap: true,
            itemCount: branchList?.length ?? -1,
            itemBuilder: (context, index) {
              final branch = branchList?[index];
              if (branch == null) return SizedBox.shrink();
              final id = branch['branch_id'];
              final branchName = branch['branch_name'];
              final isSelected = selectedBranchIndex == index;
              final branchLocation = LatLng(
                branch['latitude'] as double,
                branch['longitude'] as double,
              );

              double distance = 0.0;

              if (currentLocation != null) {
                distance = calculateDistance(currentLocation!, branchLocation);
                distance =
                    (distance * 1000).roundToDouble(); // Convert to meters
              }

              if (index == 0) {
                return Column(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Divider(
                        thickness: 5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Choose a Branch or swipe for more',
                      ),
                    ),
                  ],
                );
              }

              return Card(
                elevation: 0,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor:
                        isSelected ? Colors.blueGrey.shade50 : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedBranchLocation = branchLocation;
                      selectedBranchData = BranchData(
                        branchId: id,
                        branchLocation: branchName,
                      );
                      selectedBranchIndex = index;
                    });
                    updateCameraPosition(branchLocation);
                  },
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    selected: isSelected,
                    selectedColor: Colors.blue,
                    leading: Icon(
                      Icons.location_on,
                      color: Colors.red,
                    ),
                    title: Text(
                      branch['branch_name'],
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${branch['doctor_count'] ?? 0} available doctors',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          '$distance m',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
}
