// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TermsAndCondition extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: Text(
                  'Terms and Condition',
                  style: TextStyle(
                      fontSize: 20, color: Colors.blue, fontFamily: 'Roboto'),
                ),
              ),
              Text(
                "This is a legal agreement that governs your use of the services of Happy Tails. By using this application, you, the user, agrees to these Terms and Conditions (this 'Agreement'). If you do not agree to this Agreement, you are not authorized to use the services of Happy Tails and should not use any of our services.\n"
                "This Agreement is between you and selected branch/branches of ASVC Veterinary Medical Clinic. Selected branch/branches of ASVC Veterinary Medical Clinic operates Happy Tails, a platform that will enable the user to connect with their licensed veterinarian by setting an appointment online and/or using the generated chatbot for common questions that can be answered through the application.\n"
                '\n'
                'By clicking the button, you understand that Happy Tails only provides and operates the platform that will allow the user to connect with the licensed veterinarian from the selected branch/branches of ASVC Veterinary Medical Clinic. Happy Tails is not engaged in any other platform/s of ASVC Veterinary Medical Clinic and does not provide any other medical profession aside from what selected branch/branches of ASVC Veterinary Medical Clinic can offer. Happy Tails does not recommend nor endorse any specific test, products, or opinions of other license veterinarian. \n',
                style: TextStyle(
                    fontSize: 14, color: Colors.black, letterSpacing: .5),
              ),
              Text(
                'Happy Tails IS NOT FOR ANY MEDICAL EMEGENCIES OR URGENT SITUATION. IF YOU HAVE AN EMERGENCY, PLEASE GO TO THE NEAREST VETERINARY MEDICAL CLINIC AND SEEK FOR AN IMMEDIATE ASSISTANCE FROM ANY MEDICAL EMERGENCY PERSONNEL.\n',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'This Agreement also applies to your use of Happy Tails’ mobile application (this “Application”) and to your registration for, and your use of Happy Tails services. You acknowledge that you have read, understand, and accept all terms and conditions in this Agreement and those that are contained in the Privacy Statement, which shall from an integral part of this Agreement.\n',
                style: TextStyle(
                    fontSize: 14, letterSpacing: .5, color: Colors.black),
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Roboto',
                      fontSize: 14,
                      letterSpacing: .5),
                  children: <TextSpan>[
                    TextSpan(
                      text: '1. Age and Capacity. ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'You represent and warrant that you are at least eighteen (18) years of age, and have the capacity to bind yourself contractually to this Agreement and to use Happy Tails. If you are under eighteen (18) years of age, or otherwise incapacitated to enter and agree to this Agreement, you may not register to use Happy Tails.',
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
                  children: <TextSpan>[
                    TextSpan(
                      text: '2.	Location. ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'The access to and use of Happy Tails is limited to natural persons located in the Philippines. By using Happy Tails, you agree and consent to our collection and use of your location data in accordance to our Privacy Statement and to this Agreement. Happy Tails will use your location to provide you the nearest registered branch/branches of ASVC Veterinary Medical Clinic to Happy Tails based on your location.',
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
                  children: <TextSpan>[
                    TextSpan(
                      text: '3.	Registration and Personal Information. ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'You must register to use Happy Tails. During registration and use of Happy Tails, you will be required to provide certain personal information, this includes your full name, email address, and contact number. It is your sole responsibility to update any changes to your Personal Details so that all your records to this application and to the clinic are up-to-date and accurate.',
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
                  children: <TextSpan>[
                    TextSpan(
                      text: '4.	Changes to the Terms of use. ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          'Happy Tails may change the provision of this Agreement at any time. You can review the most current version of the Agreement by going to your ',
                    ),
                    TextSpan(
                        text: 'Profile > Terms and Conditions.',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            'You are responsible for checking these terms and conditions periodically for any changes. '),
                  ],
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                'Data Privacy Policy',
                style: TextStyle(fontSize: 20, color: Colors.blue),
              ),
              SizedBox(
                height: 15,
              ),
              RichText(
                  text: TextSpan(
                      style:
                          TextStyle(color: Colors.black, fontFamily: 'Roboto'),
                      children: <TextSpan>[
                    TextSpan(
                        text:
                            'This Data Privacy Policy outlines the procedures and practices related to the collection, use, and protection of user data by the "Happy Tails" mobile application ("the App"). By using the App, you agree to the terms and conditions outlined in this policy.\n\n'),
                    TextSpan(
                        text:
                            'Happy Tails collects the following information:\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text:
                          'User Account Information: Name, Contact Number, and Email Address.\n\nLocation Data: GPS information for the purpose of identifying the nearest ASVC branch.\n\nPet Information: Details provided voluntarily by users for better customization of pet care guidance.\n\n',
                    ),
                    TextSpan(
                        text:
                            'The collected information above is used for the following purposes:\n\n',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text:
                            'Appointment Scheduling: User account information is used to facilitate the scheduling of appointments.\n\nLocation-Based Services: GPS data is utilized to identify and display the nearest ASVC branch.\n\nPersonalized Pet Care Guidance: Pet information is used to provide customized and relevant pet care advice through the chatbot.\n\n\nThe App employs industry-standard security measures to protect user data from unauthorized access, disclosure, alteration, and destruction. All data transmitted between the App and servers is encrypted using secure protocols. Regular security assessments and updates are conducted to address potential vulnerabilities.\n\nUser data is not shared with third parties without explicit consent, except as required by law or for the improvement of App services. Third-party services integrated into the App adhere to stringent data privacy and security standards. Users have control over the information they provide and can modify or delete their account data at any time. Users are informed and must consent to the collection and use of their data during the account creation process.\n\n'),
                    TextSpan(
                        text:
                            "The App is not intended for individuals under the age of 13. We do not knowingly collect personal information from children. Parents or legal guardians are encouraged to contact us if they believe their child's information has been collected without consent. This Privacy Policy is subject to periodic updates. Users will be notified of any changes, and continued use of the App implies acceptance of the revised policy.\n\n"),
                    TextSpan(
                        text:
                            'By using the "Happy Tails" mobile application, you acknowledge that you have read, understood, and agreed to the terms outlined in this Data Privacy Policy.\n\nFor inquiries regarding this Data Privacy Policy, please contact us at (0961) 758-7913.\n\nEffective Date as of November 05, 2023')
                  ])),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    onPressed: () {
                      navigator?.pop(context);
                    },
                    child: Text(
                      'I agree',
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
