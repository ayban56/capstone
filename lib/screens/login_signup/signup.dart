import 'package:dogre/main.dart';
import 'package:dogre/screens/login_signup/terms_and_condition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dogre/components/my_button.dart';
import 'package:dogre/components/my_checkbox.dart';
import 'package:dogre/components/my_textfield.dart';
import 'package:dogre/screens/login_signup/login.dart';
import 'package:dogre/service/snackbar_extention.dart';

class SignupScreen extends StatefulWidget {
  SignupScreen({Key? key});

  @override
  State<SignupScreen> createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen> {
  bool _isChecked = false;
  bool _isLoading = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  late TextEditingController emailController;
  late TextEditingController nameController;
  late TextEditingController passwordController;
  late TextEditingController contactController;
  late TextEditingController confirmPasswordController;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;

  GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    emailController = TextEditingController();
    nameController = TextEditingController();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    passwordController = TextEditingController();
    contactController = TextEditingController();
    confirmPasswordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    contactController.dispose();
    passwordController.dispose();

    confirmPasswordController.dispose();
    super.dispose();
  }

  void _signUp() async {
    if (_formKey.currentState?.validate() == true) {
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

        await supabase.auth.signUp(
          password: passwordController.text,
          email: emailController.text,
          data: {
            'first_name': firstNameController.text,
            'last_name': lastNameController.text,
            'contact_number': contactController.text,
            'role': 'customer',
          },
        );

        final name = nameController.text.trim();
        final contactNumber = contactController.text.trim();
        final userId = supabase.auth.currentUser!.id;

        setState(() {
          _isLoading = false;
        });

        navigateToLoginScreen();
      } on AuthException catch (e) {
        context.ShowSnackbar(message: e.message, backgroundColor: Colors.red);
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

  void navigateToLoginScreen() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create account'),
        centerTitle: true,
        foregroundColor: Colors.blue,
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
      ),
      backgroundColor: Color(0xFFFFFFFF),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/final_logo/app_icon.png',
                      height: 160,
                    ),
                  ],
                ),
                MyTextField(
                  controller: firstNameController,
                  obscureText: false,
                  prefixIcon: Icons.person_2_outlined,
                  labelText: 'First Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                  suffixIcon: null,
                ),
                const SizedBox(height: 10.0),
                MyTextField(
                  controller: lastNameController,
                  obscureText: false,
                  prefixIcon: Icons.person_2_outlined,
                  labelText: 'Last Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                  suffixIcon: null,
                ),
                const SizedBox(height: 10.0),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: TextFormField(
                    controller: contactController,
                    decoration: InputDecoration(
                        icon: Container(
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.blue),
                              borderRadius: BorderRadius.circular(8)),
                          width: 100,
                          height: 64,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/ph.png',
                                height: 40,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                '+63',
                                style: TextStyle(fontSize: 17),
                              )
                            ],
                          ),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(
                            color: Color(0xFF0070C0),
                          ),
                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Color(0xFF0070C0),
                        )),
                        focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Color(0xFF0070C0),
                        )),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Color(0xFF0070C0),
                        )),
                        labelText: '9XXXXXXX',
                        labelStyle: TextStyle(color: Colors.black)),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(height: 10.0),
                MyTextField(
                  controller: emailController,
                  obscureText: false,
                  prefixIcon: Icons.email_outlined,
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
                const SizedBox(height: 10.0),
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
                const SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    cursorColor: Colors.blue,
                    controller: confirmPasswordController,
                    obscureText: !isConfirmPasswordVisible,
                    style: TextStyle(color: Colors.blue),
                    decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            isConfirmPasswordVisible =
                                !isConfirmPasswordVisible;
                          });
                        },
                        child: Icon(
                          isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black54,
                        ),
                      ),
                      prefixIcon: Icon(Icons.lock),
                      labelText: 'Confirm Password',
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
                      if (value != passwordController.text) {
                        return 'Passwords must match*';
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 8),
                  child: CheckboxMenuButton(
                    value: _isChecked,
                    onChanged: (newValue) {
                      setState(() {
                        if (newValue == true) {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return Center(
                                  child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                    height: 450,
                                    width: 350,
                                    child: TermsAndCondition()),
                              ));
                            },
                          );
                        }
                      });
                      _isChecked = newValue!;
                    },
                    child: Row(
                      children: [
                        RichText(
                            text: TextSpan(
                                style: TextStyle(color: Colors.black),
                                children: <TextSpan>[
                              TextSpan(
                                text: 'I have read and agree to the ',
                                style: TextStyle(fontSize: 12),
                              ),
                              TextSpan(
                                  text:
                                      'Terms and Conditions \nand the Data Privacy Policy',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.blue))
                            ])),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      fixedSize: const Size(300, 50),
                      backgroundColor: Colors.blue,
                    ),
                    onPressed: () {
                      if (_isChecked == true) {
                        _signUp();
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Error'),
                              content: Text(
                                  'Please accept the Terms and Conditions.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: Text(
                      'Signup',
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
