// ignore_for_file: use_build_context_synchronously

import 'package:dogre/components/my_button.dart';
import 'package:dogre/components/my_checkbox.dart';
import 'package:dogre/components/my_textfield.dart';
import 'package:dogre/main.dart';
import 'package:dogre/screens/home/home.dart';
import 'package:dogre/screens/home_screens/home.dart';
import 'package:dogre/screens/login_signup/forgot_password.dart';
import 'package:dogre/screens/login_signup/signup.dart';
import 'package:dogre/screens/pets/add_pet.dart';
import 'package:dogre/service/snackbar_extention.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool isPasswordVisible = false;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid != null && isValid) {
      setState(() {
        _isLoading = true;
      });

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

        final response = await supabase.auth.signInWithPassword(
          password: passwordController.text,
          email: emailController.text,
        );

        if (response.user != null) {
          final userId = response.user!.id;

          final userTypeResponse = await supabase
              .from('users')
              .select('user_type')
              .eq('id', userId)
              .execute();

          if (userTypeResponse.data.isNotEmpty) {
            final userType = userTypeResponse.data[0]['user_type'] as String;

            if (userType == 'customer') {
              final petsResponse = await supabase
                  .from('pets')
                  .select('pet_id')
                  .eq('user_id', userId)
                  .execute();

              if (petsResponse.data.isNotEmpty) {
                _navigateToHome();
              } else {
                showDialog(
                    context: context,
                    builder: (context) {
                      final name = supabase.auth.currentUser!.id;
                      return AddPet();
                    });
              }
            } else if (userType == 'doctor') {
              final signout = supabase.auth.signOut();
              Get.snackbar('', 'Invalid login credentials',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  titleText: Text(
                    'Login failed',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 15),
                  ));
              Navigator.pop(context);
            }
          } else {
            // Handle the case where user_type information is not available
          }
        } else {
          context.ShowSnackbar(
              message: 'Login failed', backgroundColor: Colors.red);
        }

        setState(() {
          _isLoading = false;
        });
      } on AuthException catch (e) {
        //context.ShowSnackbar(message: e.message, backgroundColor: Colors.red);
        Get.snackbar('', e.message,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            titleText: Text(
              'Login failed',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 15),
            ));
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
      } catch (e) {
        context.ShowSnackbar(
            message: e.toString(), backgroundColor: Colors.red);
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
      }
    }
  }

  void _navigateToHome() {
    Get.offAll(HomeScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFFFFFFFF),
      body: SafeArea(
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/final_logo/1.png',
                        height: 300,
                      )
                    ],
                  ),
                  MyTextField(
                    controller: emailController,
                    obscureText: false,
                    prefixIcon: Icons.email,
                    labelText: 'Email',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required*';
                      }
                      final emailPattern =
                          r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)*(\.[a-z]{2,7})$';
                      final regExp = RegExp(emailPattern);
                      if (!regExp.hasMatch(value)) {
                        return 'Enter a valid email address';
                      }

                      return null;
                    },
                    suffixIcon: null,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextFormField(
                      cursorColor: Colors.blue,
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      style: TextStyle(color: Colors.blue),
                      decoration: InputDecoration(
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                          child: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.black54,
                          ),
                        ),
                        prefixIcon: Icon(Icons.lock),
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.black),
                        prefixIconColor: Colors.blue,
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Color(0xFF0070C0),
                        )),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Color(0xFF0070C0),
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Color(0xFF0070C0),
                        )),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Color(0xFF0070C0),
                        )),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required*';
                        }
                        return null;
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(right: 8, left: 8),
                    child: Row(
                      children: [
                        Spacer(),
                        TextButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Scaffold(
                                      body: ForgotPassword(),
                                    );
                                  });
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.blue),
                            ))
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  FilledButton(
                      style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          fixedSize: const Size(300, 50),
                          backgroundColor: Colors.blue),
                      onPressed: _isLoading ? null : _signIn,
                      child: Text('SIGN IN')),

                  const SizedBox(
                    height: 10,
                  ),

                  const Spacer(),

                  Container(
                    padding: EdgeInsets.only(right: 8, left: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8, left: 8),
                          child: Text('OR'),
                        ),
                        Expanded(child: Divider())
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 30,
                  ),
                  //create account button
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MyButton(
                      btn_name: 'Create new account',
                      color: const Color(0xFFFFFFFF),
                      side: const BorderSide(color: Color(0xFF127ABD)),
                      textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF127ABD)),
                      onPressed: () {
                        Get.to(SignupScreen());
                      },
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'by ASVC Veterinary Medical Clinic',
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 11),
                            ),
                            Image.asset(
                              'assets/final_logo/3.png',
                              height: 50,
                              width: 150,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ))),
    );
  }
}
