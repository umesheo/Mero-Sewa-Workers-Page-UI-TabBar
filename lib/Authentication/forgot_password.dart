import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:merosewa_app/Screens/HomePage/bottomNaviationGateway.dart';
import 'package:merosewa_app/Screens/Login/components/body.dart';
import 'package:merosewa_app/Screens/Login/login_screen.dart';
import 'package:merosewa_app/Screens/Signup/components/body.dart';
import 'package:merosewa_app/constants.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io';

//class to change the password using users email
class ForgotPassword extends StatefulWidget {
  ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();

  var email = "";
  var loading = false;

  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final emailController = TextEditingController();
  bool _isKeyboardOpen = false;
  bool connection = false;

  @override
  void initState() {
    KeyboardVisibilityController().onChange.listen((isVisible) {
      setState(() {
        _isKeyboardOpen = isVisible;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.

    emailController.dispose();
    super.dispose();
  }

  //checking the internet connection
  Future getInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      //if internet connection is available
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        //call the reset password function
        resetPassword();

        print(connection);
      }
    }
    //else no internet connection
    on SocketException catch (_) {
      //display an error
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            //duration: const Duration(seconds: 1),
            backgroundColor: Colors.redAccent,
            duration: Duration(milliseconds: 1500),
            content: Text(
              "No Internet Connectivity",
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ),
        );

      print(connection);
    }
  }

  //resetting the users password
  resetPassword() async {
    //set loading to true
    setState(() {
      loading = true;
    });
    try {
      //sending the email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      //navigating to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
      //displaying a success message
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: kPrimaryColor,
            content: Text(
              "Password reset email has been sent",
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ),
        );
    }
    //catching exceptions
    on FirebaseAuthException catch (e) {
      //if the user with the email is not found
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        //display no user found error
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: Duration(milliseconds: 1500),
              backgroundColor: Colors.redAccent,
              content: Text(
                'No user found for that email',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          );
      }
    }
    //set loading to false
     finally {
      setState(() {
        loading = false;
      });
    }
  }

  var currentFocus;

  unfocus() {
    currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  FocusNode focusNode = new FocusNode();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
        onTap: () {
          unfocus();
        },
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/LandBackground.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.1, vertical: size.height * 0.05),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (_isKeyboardOpen) SizedBox(height: size.height * 0.17),
                      if (!_isKeyboardOpen)
                        SvgPicture.asset(
                          "assets/icons/login.svg",
                          height: size.height * 0.35,
                        ),
                      if (_isKeyboardOpen)
                        Text(
                          'Reset Password',
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'Pacifico',
                            fontSize: 35,
                          ),
                        ),
                      SizedBox(height: size.height * 0.05),
                      Container(
                        height: 60,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        width: size.width * 0.8,
                        child: TextFormField(
                          autofocus: false,
                          cursorColor: kPrimaryColor,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            icon:
                                Icon(Icons.person, color: kPrimarySecondColor),
                            border: InputBorder.none,
                            errorStyle: TextStyle(
                                color: Colors.redAccent, fontSize: 10),
                          ),
                          controller: emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please Enter Email';
                            } else if (!value.contains('@')) {
                              return 'Please Enter Valid Email';
                            }
                            return null;
                          },
                        ),
                        decoration: BoxDecoration(
                          color: kPrimaryLightColor,
                          borderRadius: BorderRadius.circular(29),
                          //border: Border.all(color: Colors.black, width: 1),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        width: size.width * 0.8,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (loading == false)
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(29.0),
                                  gradient: LinearGradient(colors: [
                                    kPrimaryColor,
                                    kPrimarySecondColor,
                                  ]),
                                ),
                                margin: EdgeInsets.symmetric(vertical: 10),
                                width: size.width * 0.8,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(29),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      FocusScope.of(context)
                                          .requestFocus(focusNode);
                                      // Validate returns true if the form is valid, otherwise false.
                                      if (_formKey.currentState!.validate()) {
                                        setState(() {
                                          email = emailController.text;
                                        });

                                        getInternetConnection();
                                      }
                                    },
                                    child: Text(
                                      "Reset Password",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        letterSpacing: 2.2,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.transparent,
                                        onSurface: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 40, vertical: 20),
                                        textStyle: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ),
                              ),
                            SizedBox(height: size.height * 0.03),
                            if (loading == true)
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 22),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        kPrimaryColor),
                                  ),
                                ),
                              ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an Account? ",
                                    style: TextStyle(
                                        color: Colors.grey, height: 0),
                                  ),
                                  TextButton(
                                    onPressed: () => {
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, a, b) =>
                                                Login(),
                                            transitionDuration:
                                                Duration(seconds: 0),
                                          ),
                                          (route) => false)
                                    },
                                    child: Text(
                                      'Login',
                                      style: TextStyle(
                                          color: Colors.black, height: 0),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't have an Account? ",
                                    style: TextStyle(
                                        color: Colors.grey, height: -1),
                                  ),
                                  TextButton(
                                      onPressed: () => {
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder:
                                                      (context, a, b) =>
                                                          Signup(),
                                                  transitionDuration:
                                                      Duration(seconds: 0),
                                                ),
                                                (route) => false)
                                          },
                                      child: Text(
                                        'Signup',
                                        style: TextStyle(
                                            color: Colors.black, height: -1),
                                      ))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
