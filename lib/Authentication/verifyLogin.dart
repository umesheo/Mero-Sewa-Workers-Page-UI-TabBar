import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:merosewa_app/Authentication/profile.dart';
import 'package:merosewa_app/Screens/Login/login_screen.dart';

//verify login screen
class VerifyScreen extends StatefulWidget {
  const VerifyScreen({Key? key}) : super(key: key);

  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final auth = FirebaseAuth.instance;
  User? user;
  Timer? timer;

  ProfileState userProfile = ProfileState();

  //execute when the app loads
  @override
  void initState() {
    //getting the current user
    user = auth.currentUser;
    //sending an email verification
    user!.sendEmailVerification();

    //setting a timer continiuously repeats the process
    //on the set duration and calls the verify email method
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      verifyEmail();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  //verifying the user's email
  Future<void> verifyEmail() async {
    //getting the current user
    user = auth.currentUser;
    //reload the user from time to time
    await user?.reload();
    //if the email is verified
    //navigate to login screen
    if (user!.emailVerified) {
      //cancel the timer
      timer?.cancel();
      //send the verification email to the user
      await user!.sendEmailVerification();
      //Navigate to the login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
      //Display a snack bar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.greenAccent,
          content: Text(
            "Email is verified. Please login to continue",
            style: TextStyle(fontSize: 16.0, color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        body: Padding(
            padding: EdgeInsets.only(
                right: size.width * 0.1,
                left: size.width * 0.1,
                top: size.height * 0.00),
            child: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "We're excited to have you get started",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Pacifico',
                      fontWeight: FontWeight.w300,
                      fontSize: 18),
                ),
                SizedBox(height: size.height * 0.05),
                Image.asset(
                  "assets/images/gmail.png",
                  height: size.height * 0.15,
                ),
                SizedBox(height: size.height * 0.05),
                Text(
                  "An email has been sent to ${user?.email} \n\n Please verify to proceed",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 18),
                ),
                SizedBox(height: size.height * 0.05),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receieve an email? ",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () async {
                        await user!.sendEmailVerification();
                        print('Verification Email has been sent');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.orangeAccent,
                            content: Text(
                              'Verification Email has been sent',
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.black),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Verify now',
                        style: TextStyle(fontSize: 14.0, color: Colors.black),
                      ),
                    )
                  ],
                ),
              ],
            ))));
  }
}
