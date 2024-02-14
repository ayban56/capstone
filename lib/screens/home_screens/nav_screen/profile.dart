import 'dart:io';

import 'package:dogre/components/my_button.dart';
import 'package:dogre/main.dart';
import 'package:dogre/screens/login_signup/forgot_password.dart';
import 'package:dogre/screens/login_signup/login.dart';
import 'package:dogre/screens/maps/try_map.dart';
import 'package:dogre/screens/try/try.dart';
import 'package:dogre/service/snackbar_extention.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../login_signup/terms_and_condition.dart';

class ProfileNav extends StatefulWidget {
  const ProfileNav({Key? key});

  @override
  State<ProfileNav> createState() => _ProfileNavState();
}

var _loading = true;

class _ProfileNavState extends State<ProfileNav> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isEditing = false;
  List<dynamic>? profiles;
  String? _avatarUrl;

  Future<void> signOut() async {
    try {
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
      await supabase.auth.signOut();
    } catch (e) {
      context.ShowSnackbar(message: e.toString(), backgroundColor: Colors.red);
      Navigator.pop(context);
    } finally {
      if (mounted) {
        Get.offAll(LoginScreen());
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    profileData();
  }

  void profileData() async {
    final userId = supabase.auth.currentUser!.id;

    final profile =
        await supabase.from('users').select('*').eq('id', userId).execute();
    try {
      setState(() {
        profiles = profile.data;
        print('$profiles');
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text('Profile'),
        centerTitle: true,
        foregroundColor: Colors.blue,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                  // Initialize the text controllers with current profile data
                  if (_isEditing && profiles != null && profiles!.isNotEmpty) {
                    _firstNameController.text = profiles![0]['first_name'];
                    _lastNameController.text = profiles![0]['last_name'];
                    _contactNumberController.text =
                        profiles![0]['contact_number'];
                    _emailController.text = profiles![0]['email'];
                  }
                });
              },
              icon: Row(
                children: [
                  _isEditing
                      ? Text(
                          'Cancel',
                          style: TextStyle(color: Colors.blue),
                        )
                      : Row(
                          children: [
                            Icon(
                              LineAwesomeIcons.edit,
                              semanticLabel: 'edit',
                            ),
                            Text(
                              'Edit',
                              style: TextStyle(color: Colors.blue),
                            )
                          ],
                        ),
                ],
              ))
        ],
      ),
      body: _isEditing
          ? _buildEditForm()
          : profiles != null
              ? Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: profiles!.map<Widget>((profile) {
                      final firstName =
                          profile['first_name'].toString().capitalize;
                      final lastName =
                          profile['last_name'].toString().capitalize;
                      final fullName = '$firstName $lastName';
                      final phone = profile['contact_number'];
                      final contactNumber = '+63$phone';
                      final email = profile['email'];
                      final avatarUrl = profile['avatar_url'];

                      return Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 150,
                              height: 150,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: avatarUrl != null
                                    ? Image.network(
                                        avatarUrl,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/images/logo.png',
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'First name',
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                      Text(
                                        '$firstName',
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        'Last name',
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                      Text(
                                        '$lastName',
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        'Contact number',
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                      Text(
                                        '$contactNumber',
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      Text(
                                        'email',
                                        style: TextStyle(color: Colors.black54),
                                      ),
                                      Text(
                                        '$email',
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Container(
                                        child: Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return ForgotPassword();
                                                    });
                                              },
                                              child: Text('Change Password',
                                                  style: TextStyle(
                                                      fontSize: 22,
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.w400)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Center(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Container(
                                                      height: 450,
                                                      width: 330,
                                                      child:
                                                          TermsAndCondition()),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Text(
                                          'Terms and Conditions',
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.blue,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: Colors.blue),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            signOut();
                                          },
                                          icon: Container(
                                            width: 100,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.logout,
                                                  color: Colors.black45,
                                                ),
                                                Text(
                                                  'Logout',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.black54),
                                                )
                                              ],
                                            ),
                                          ))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                )
              : Center(
                  child: LottieBuilder.asset(
                    'assets/lottie/loading.json',
                    height: 80,
                    width: 80,
                  ), // Show a loading indicator
                ),
    );
  }

  Widget _buildEditForm() {
    final avatarUrl = profiles![0]['avatar_url'];
    String? _imageUrl;
    final userId = supabase.auth.currentUser!.id;
    final String pathName = '/$userId/profile';
    var imageUrl = supabase.storage.from('users avatar').getPublicUrl(pathName);

    Future<void> updateProfile() async {
      final userId = await supabase.auth.currentUser!.id;
      try {
        Future.delayed(Duration(seconds: 5));
        final update = supabase
            .from('users')
            .update({
              'first_name': _firstNameController.text,
              'last_name': _lastNameController.text,
              'contact_number': _contactNumberController.text,
              'email': _emailController.text,
              'avatar_url': imageUrl,
            })
            .eq('id', userId)
            .execute();
      } catch (e) {}
    }

    void _update() async {
      Future.delayed(Duration(seconds: 5));
      final UserResponse res = await supabase.auth
          .updateUser(UserAttributes(email: _emailController.text, data: {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'contact_number': _contactNumberController.text,
      }));
      final User? updateUser = res.user;
    }

    return SingleChildScrollView(
      child: Form(
        child: Padding(
          padding: const EdgeInsets.only(right: 15, left: 15),
          child: Column(
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (image == null) {
                    return;
                  }
                  final imageBytes = await image.path;
                  final avatarFile = File(imageBytes);
                  final userId = supabase.auth.currentUser!.id;
                  final String pathName = '/$userId/profile';

                  // Upload the image
                  final String path =
                      await supabase.storage.from('users avatar').upload(
                            pathName,
                            avatarFile,
                            fileOptions: const FileOptions(
                              cacheControl: '3600',
                              upsert: true,
                            ),
                          );

                  // Fetch the updated image URL
                  final updatedImageUrl = supabase.storage
                      .from('users avatar')
                      .getPublicUrl(pathName);

                  // Update the state to reflect the changes
                  setState(() {
                    imageUrl = updatedImageUrl;
                  });
                },
                child: Text(
                  'Upload a Photo',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.characters,
                controller: _firstNameController,
                decoration: InputDecoration(
                    labelText: 'First Name',
                    labelStyle: TextStyle(color: Colors.blue),
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: .5, color: Colors.blue)),
                    enabledBorder:
                        OutlineInputBorder(borderSide: BorderSide(width: .5)),
                    fillColor: Colors.white),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.characters,
                controller: _lastNameController,
                decoration: InputDecoration(
                    labelText: 'Last Name',
                    filled: true,
                    labelStyle: TextStyle(color: Colors.blue),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: .5, color: Colors.blue)),
                    enabledBorder:
                        OutlineInputBorder(borderSide: BorderSide(width: .5)),
                    fillColor: Colors.white),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.phone,
                controller: _contactNumberController,
                decoration: InputDecoration(
                    labelText: 'Contact Number',
                    labelStyle: TextStyle(color: Colors.blue),
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: .5, color: Colors.blue)),
                    enabledBorder:
                        OutlineInputBorder(borderSide: BorderSide(width: .5)),
                    fillColor: Colors.white),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
                textInputAction: TextInputAction.next,
                controller: _emailController,
                decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.blue),
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: .5, color: Colors.blue)),
                    enabledBorder:
                        OutlineInputBorder(borderSide: BorderSide(width: .5)),
                    fillColor: Colors.white),
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    fixedSize: Size(200, 50)),
                onPressed: () {
                  setState(() {
                    _update();
                    updateProfile();
                    _isEditing = false;
                  });
                },
                child: Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
