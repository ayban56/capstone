import 'package:dogre/components/my_button.dart';
import 'package:dogre/main.dart';
import 'package:dogre/screens/pets/add_pet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';

class Mypets extends StatefulWidget {
  const Mypets({super.key});

  @override
  State<Mypets> createState() => _MypetsState();
}

class _MypetsState extends State<Mypets> {
  List? petList;
  bool isLoading = true;
  String dropdownValue = 'Species'; // Selected sorting method

  // Add the selected sorting method
  String selectedSortingMethod = 'Species';

  Future<void> pets() async {
    final userId = supabase.auth.currentUser!.id;
    final response =
        await supabase.from('pets').select('*').eq('user_id', userId).execute();

    try {
      setState(() {
        petList = response.data.toList();
        isLoading = false;
      });
      print(petList);
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pets();
  }

  bool petIsDog(Map<String, dynamic>? pet) {
    if (pet != null) {
      final petType = pet['pet_specie']
          as String?; // Replace 'pet_type' with the actual field that indicates pet type
      return petType ==
          'dog'; // Assuming 'dog' indicates a dog, adjust based on your data.
    }
    return false; // Return false by default if the pet is null or pet type is not 'dog'.
  }

  void _sortPetList(String sortingMethod) {
    petList?.sort((a, b) {
      if (sortingMethod == 'Species') {
        return a['pet_specie'].toString().compareTo(b['pet_specie'].toString());
      } else {
        return a['pet_name'].toString().compareTo(b['pet_name'].toString());
      }
    });
  }

  Future<void> deletePet(int petId) async {
    try {
      final petDeleted =
          await supabase.from('pets').delete().eq('pet_id', petId).execute();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return petList == null
        ? _buildShimmerLoading()
        : petList!.isEmpty
            ? Center(
                child: Center(
                    child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/final_logo/add_pet.png',
                    height: 200,
                    width: 200,
                  ),
                  Text('Pets will display here'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () {
                            Get.to(AddPet());
                          },
                          icon: Row(
                            children: [
                              Text('Add Pet'),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(LineAwesomeIcons.plus_circle),
                            ],
                          )),
                    ],
                  )
                ],
              )))
            : Scaffold(
                backgroundColor: Colors.white,
                body: SafeArea(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 10),
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
                                  'Species',
                                  'Name',
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
                                    selectedSortingMethod = newValue!;
                                    // Sort the pet list based on the selected sorting method
                                    _sortPetList(selectedSortingMethod);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      isLoading
                          ? _buildShimmerLoading() // Show shimmer loading while data is loading
                          : _buildPetList(), // Show pet list when data is available
                      Spacer(),
                      Center(
                        child: MyButton(
                          btn_name: 'Add Pet',
                          onPressed: () {
                            Get.to(AddPet());
                          },
                          color: Colors.blue,
                          textStyle: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(5, (index) {
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
      ),
    );
  }

  Widget _buildPetList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: petList?.length ?? 0,
      itemBuilder: (context, index) {
        final pet = petList?[index];
        if (pet == null) return SizedBox.shrink();
        final petId = pet['pet_id'];
        final petName = pet['pet_name'].toString().capitalize;
        final gender = pet['pet_gender'].toString().capitalize;
        final species = pet['pet_specie'].toString().capitalizeFirst;
        final breed = pet['pet_breed'].toString().capitalizeFirst;
        final description = pet['description'].toString().capitalizeFirst;

        final rawBirthdate = pet['birthdate'] as String?;
        final formattedBirthdate = rawBirthdate != null
            ? DateFormat.yMMMMd().format(DateTime.parse(rawBirthdate))
            : 'Unknown Birthdate';

        void deleteDialog() {
          showDialog(
              context: context,
              builder: (context) {
                return Center(
                  child: Container(
                    height: 300,
                    width: 300,
                    child: Scaffold(
                      backgroundColor: Colors.white,
                      body: Column(
                        children: [
                          TextButton(
                              onPressed: () {
                                deletePet(petId);
                              },
                              child: Text('Confirm'))
                        ],
                      ),
                    ),
                  ),
                );
              });
        }

        void _showPetDetails() {
          showDialog(
            context: context,
            builder: (context) {
              return Center(
                child: Container(
                  height: 500,
                  width: 375,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Scaffold(
                      appBar: AppBar(
                        title: Text('Pet Details'),
                        centerTitle: true,
                        automaticallyImplyLeading: false,
                        foregroundColor: Colors.blue,
                      ),
                      backgroundColor: Colors.white,
                      body: Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pet Name',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              '$petName',
                              style: TextStyle(fontSize: 19),
                            ),
                            Divider(),
                            Text(
                              'Birthdate',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              '$formattedBirthdate',
                              style: TextStyle(fontSize: 19),
                            ),
                            Divider(),
                            Text(
                              'Gender',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              '$gender',
                              style: TextStyle(fontSize: 19),
                            ),
                            Divider(),
                            Text(
                              'Breed',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              '$breed',
                              style: TextStyle(fontSize: 19),
                            ),
                            Divider(),
                            Text(
                              'Species',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              '$species',
                              style: TextStyle(fontSize: 19),
                            ),
                            Divider(),
                            Text(
                              'Description',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              '${description!.isNotEmpty ? description : 'n/a'}',
                              style: TextStyle(fontSize: 19),
                            ),
                            Divider(),
                            Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                    style: TextButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        fixedSize: Size(100, 10),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8))),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Close',
                                      style: TextStyle(color: Colors.white),
                                    )),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Card(
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: petIsDog(pet)
                      ? Container(
                          width: 40,
                          child: Image.asset('assets/final_logo/dog.png'))
                      : Container(
                          width: 40,
                          child: Image.asset('assets/final_logo/cat.png')),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pet Name',
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        '$petName',
                        style: TextStyle(color: Colors.black, fontSize: 19),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                      onPressed: () {
                        deleteDialog();
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      )),
                  onTap: () {
                    _showPetDetails();
                  },
                  contentPadding: EdgeInsets.only(left: 20, bottom: 5),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
