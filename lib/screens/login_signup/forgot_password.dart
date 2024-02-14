import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pinput/pinput.dart';
import '../../components/my_textfield.dart';
import '../../main.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final tokenController = TextEditingController();
  bool resetingPassword = false;
  bool _isSendingMail = false;
  bool _isChangingPassword = true;
  GlobalKey<FormState> _formKey = GlobalKey();

  void _forgotPassword() async {
    final isValid = _formKey.currentState?.validate();
    final email = emailController.text.toString();

    final isEmailExist = supabase
        .from('users')
        .select('*')
        .eq('user_type', 'customer')
        .eq('email', emailController.toString())
        .limit(1)
        .maybeSingle();

    if (email.isEmpty) {
      Get.snackbar('error', '',
          backgroundColor: Colors.red.shade200,
          messageText: Text('Please enter your email'),
          icon: Icon(Icons.error));
      return;
    }

    try {
      if (isValidEmail(email)) {
        setState(() {
          resetingPassword = true;
          _isChangingPassword = false;
        });
        final response =
            supabase.auth.resetPasswordForEmail(emailController.text);
      } else {
        Get.snackbar('', 'Enter valid email',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            titleText: Text(
              'Login failed',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 15),
            ));
      }
    } on AuthException catch (e) {
      setState(() {
        resetingPassword = false;
      });
      Get.snackbar('', e.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          titleText: Text(
            'Login failed',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),
          ));
    } catch (e) {
      print(e);
      Get.snackbar('none', 'none');
      return;
    }
  }

  bool isValidEmail(String email) {
    final emailPattern = r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)*(\.[a-z]{2,7})$';
    final regExp = RegExp(emailPattern);
    return regExp.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          title: Text(
            'Reset Password',
            style: TextStyle(
              fontSize: 19,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          foregroundColor: Colors.blue,
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(LineAwesomeIcons.angle_left)),
        ),
        backgroundColor: Colors.white,
        body: resetingPassword
            ? _buildPinInput()
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/assets/images/logo.png',
                        height: 160,
                      ),
                    ],
                  ),
                  Text(
                    'Enter your email for verificarion',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  MyTextField(
                    controller: emailController,
                    obscureText: false,
                    prefixIcon: Icons.email,
                    labelText: 'email',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required*';
                      }

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
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.blue,
                              fixedSize: Size(150, 40),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          onPressed: () {
                            _forgotPassword();
                          },
                          child: Column(
                            children: [
                              _isSendingMail
                                  ? CircularProgressIndicator()
                                  : Text(
                                      'Send mail',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ],
                          )),
                      SizedBox(
                        width: 20,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Spacer(),
                ],
              ));
  }

  Widget _buildPinInput() {
    void _recoverViaOtp() async {
      final recoveryOtp = tokenController.text.toString();
      if (recoveryOtp.isEmpty) {
        Get.snackbar('error', '',
            backgroundColor: Colors.red.shade200,
            messageText: Text('Please enter the code'),
            icon: Icon(Icons.error));
        return;
      }
      try {
        final recovery = await supabase.auth.verifyOTP(
            token: tokenController.text,
            type: OtpType.recovery,
            email: emailController.text);
        setState(() {
          _isChangingPassword = true;
        });
      } catch (e) {
        return;
      }
    }

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    return _isChangingPassword
        ? _buildResetingPassword()
        : Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/assets/images/logo.png',
                      height: 160,
                    ),
                  ],
                ),
                Text(
                  'Enter the six digits code',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Pinput(
                    length: 6,
                    defaultPinTheme: defaultPinTheme,
                    controller: tokenController,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextButton(
                    style: TextButton.styleFrom(
                        fixedSize: Size(150, 40),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      _recoverViaOtp();
                    },
                    child: Text(
                      'Continue',
                      style: TextStyle(color: Colors.white),
                    )),
                TextButton(
                    style: TextButton.styleFrom(
                      fixedSize: Size(150, 40),
                    ),
                    onPressed: () {
                      setState(() {
                        resetingPassword = false;
                      });
                    },
                    child: Text(
                      'Back',
                      style: TextStyle(color: Colors.blue),
                    ))
              ],
            ),
          );
  }

  Widget _buildResetingPassword() {
    void _savePassword() async {
      try {
        await supabase.auth.updateUser(
            UserAttributes(password: confirmPasswordController.text));
        Get.snackbar('', 'Password Successfuly Changed',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            titleText: Text(
              'Login failed',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 15),
            ));
        Navigator.pop(context);
      } on AuthException catch (e) {
        Get.snackbar('', e.message,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            titleText: Text(
              'Error',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 15),
            ));
      } catch (e) {
        Get.snackbar('', e.toString(),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            titleText: Text(
              'Error',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 15),
            ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Spacer(),
        MyTextField(
          controller: passwordController,
          obscureText: true,
          prefixIcon: Icons.lock_outline,
          labelText: 'Password',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required*';
            }
            return null;
          },
          suffixIcon: null,
        ),
        const SizedBox(height: 10.0),
        MyTextField(
          controller: confirmPasswordController,
          obscureText: false,
          prefixIcon: Icons.lock_outlined,
          labelText: 'Confirm password',
          validator: (value) {
            if (value != passwordController.text) {
              return 'Passwords must match*';
            }
            return null;
          },
          suffixIcon: null,
        ),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () {
                  _savePassword();
                },
                child: Text(
                  'Save password',
                  style: TextStyle(color: Colors.white),
                )),
            SizedBox(
              width: 20,
            ),
            TextButton(
                onPressed: () {
                  setState(() {
                    _isChangingPassword = false;
                  });
                },
                child: Text('Back')),
          ],
        ),
        SizedBox(
          height: 20,
        ),
        Spacer(),
      ],
    );
  }
}
