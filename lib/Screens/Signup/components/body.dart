import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:merosewa_app/Authentication/Social%20Login/Google/google_sign_in.dart';
import 'package:merosewa_app/Authentication/verifyLogin.dart';
import 'package:merosewa_app/Screens/Login/components/body.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:merosewa_app/or_divider.dart';
import 'package:sign_button/sign_button.dart';
import 'package:merosewa_app/constants.dart';

//class to display signup page
//and signup user functioning
class Signup extends StatefulWidget {
  Signup({Key? key}) : super(key: key);

  @override
  SignupState createState() => SignupState();
}

class SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();

  var fullName = "";
  var email = "";
  var password = "";
  var confirmPassword = "";
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isSigningUp = false;
  bool _isKeyboardOpen = false;
  var loading = false;
  bool connection = false;
  //For google sign in
  AuthClass authClass = AuthClass();
  //Getting the current user
  User? user;
  String? photoURL = "";
  bool signInWithGoogle = false;

  @override
  void initState() {
    KeyboardVisibilityController().onChange.listen((isVisible) {
      setState(() {
        _isKeyboardOpen = isVisible;
      });
    });
    super.initState();
  }

  //checking the internet connection availability
  Future getInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          connection = true;
        });

        print(connection);
      }
    } on SocketException catch (_) {
      print('not connected');
      setState(() {
        connection = false;
      });

      print(connection);
    }
  }

  //capitalize first word of each. For eg: hello world to Hello World
  String capitalFirst(String location) {
    if (location.length <= 1) {
      return location.toUpperCase();
    }

    // Split string into multiple words
    final List<String> words = location.split(' ');

    // Capitalize first letter of each words
    final capitalizedWords = words.map((word) {
      if (word.trim().isNotEmpty) {
        final String firstLetter = word.trim().substring(0, 1).toUpperCase();
        final String remainingLetters = word.trim().substring(1);

        return '$firstLetter$remainingLetters';
      }
      return '';
    });

    // Join/Merge all words back to one String
    return capitalizedWords.join(' ');
  }

  //signing up the user
  registration() async {
    //if user is trying to log in
    //set the isLoggingIn state to  true
    setState(() {
      isSigningUp = true;
    });

    try {
      //if the password is equals to confirm password
      if (password == confirmPassword) {
        //wait until the user is created in firebase auth
        //and assign the email and password to userCredential variable
        UserCredential? userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        //storing the user's credential to user
        user = userCredential.user;
        //adding the current user's data to firestore database
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .set({
          'name': capitalFirst(fullNameController.text),
          'email': emailController.text,
          'photoURL': user!.photoURL,
          'uid': user!.uid,
          'signInWithGoogle': false
        });
        //displaying a snack bar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: kPrimaryColor,
            content: Text(
              "Registered successfully",
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ),
        );

        //Navigate to VerifyScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyScreen(),
          ),
        );
      } else {
        print("Password and Confirm Password doesn't match");
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: Duration(milliseconds: 1500),
              backgroundColor: Colors.redAccent,
              content: Text(
                "Password and Confirm Password doesn't match",
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
          );
      }
    }
    //catching firebase auth exceptions
    on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print("Password provided is too weak");
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text(
                "Password is too weak. Please provide atleast one number",
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
          );
      } else if (e.code == 'email-already-in-use') {
        print("Account already exists");
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: Duration(milliseconds: 1500),
              backgroundColor: Colors.redAccent,
              content: Text(
                "Account already exists",
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
          );
      } else {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: Duration(milliseconds: 1500),
              backgroundColor: Colors.redAccent,
              content: Text(
                "Something went wrong",
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
          );
      }
    }
    //if user is logged in
    //set the isLoggingIn state to false
     finally {
      setState(() {
        isSigningUp = false;
      });
    }
  }

  //login with google
  void _loginWithGoogle() async {
    //set loading to true
    setState(() {
      loading = true;
    });
    //calling the googleSignIn function of authClass
    try {
      //wait until the googleSignIn
      //method of authClass is fully executed
      await authClass.googleSignIn(context);
      //set loading to false
      setState(() {
        loading = false;
      });
    } finally {}
  }

  var currentFocus;

  unfocus() {
    currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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
            body: GestureDetector(
              child: Form(
                key: _formKey,
                child: Padding(
                  //padding: EdgeInsets.symmetric(horizontal: size.width * 0.1, vertical: size.height * 0.04),
                  padding: EdgeInsets.only(
                      right: size.width * 0.1,
                      left: size.width * 0.1,
                      top: size.height * 0.00),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (!_isKeyboardOpen)
                          Padding(
                              padding: EdgeInsets.only(
                            top: size.height * 0.10,
                          )),
                        if (_isKeyboardOpen)
                          Padding(
                              padding: EdgeInsets.only(
                            top: size.height * 0.04,
                          )),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //if keyboard not open
                            //display large social media button
                            if (!_isKeyboardOpen)
                              Container(
                                child: Column(
                                  children: [
                                    //if user has pressed the google login button
                                    //display circular progress indicator
                                    if (loading)
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            vertical: size.height * 0.035),
                                        child: Column(
                                          children: [
                                            Center(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(kPrimaryColor),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    //if the user has not pressed the google login button
                                    //display the google login button
                                    if (!loading)
                                      Container(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                                height: size.height * 0.02),
                                            SignInButton(
                                              buttonType: ButtonType.google,
                                              onPressed: () async {
                                                //wait until the internet connection avalability is checked
                                                await getInternetConnection();
                                                //if internet connection is available
                                                if (connection == true) {
                                                  _loginWithGoogle();
                                                }
                                                //else if internet connection is not available
                                                else if (connection == false) {
                                                  //display error
                                                  ScaffoldMessenger.of(context)
                                                    ..removeCurrentSnackBar()
                                                    ..showSnackBar(
                                                      SnackBar(
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    1500),
                                                        backgroundColor:
                                                            Colors.redAccent,
                                                        content: Text(
                                                          "No Internet Connectivity",
                                                          style: TextStyle(
                                                              fontSize: 16.0,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    );
                                                }
                                              },
                                              buttonSize: ButtonSize.large,
                                              width: size.width * 0.8,
                                              btnText: 'Continue with Google',
                                              btnTextColor: Colors.black,
                                              btnColor: Colors.white,
                                              padding: 15,
                                            ),
                                            SizedBox(
                                                height: size.height * 0.02),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            //if keyboard is open
                            //display small google button
                            if (_isKeyboardOpen)
                              Container(
                                margin:
                                    EdgeInsets.only(top: size.height * 0.02),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SignInButton.mini(
                                      buttonType: ButtonType.google,
                                      onPressed: () async {
                                        //wait until the internet connection avalability is checked
                                        await getInternetConnection();
                                        //if internet connection is available
                                        if (connection == true) {
                                          _loginWithGoogle();
                                        }
                                        //else if internet connection is not available
                                        else if (connection == false) {
                                          //display error
                                          ScaffoldMessenger.of(context)
                                            ..removeCurrentSnackBar()
                                            ..showSnackBar(
                                              SnackBar(
                                                duration: const Duration(
                                                    milliseconds: 1500),
                                                backgroundColor:
                                                    Colors.redAccent,
                                                content: Text(
                                                  "No Internet Connectivity",
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            );
                                        }
                                      },
                                      buttonSize: ButtonSize.large,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        if (!_isKeyboardOpen)
                          SizedBox(height: size.height * 0.03),
                        OrDivider(),
                        if (!_isKeyboardOpen)
                          SizedBox(height: size.height * 0.03),
                        //creating name text field
                        Container(
                          height: 60,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          width: size.width * 0.8,
                          child: TextFormField(
                            textCapitalization: TextCapitalization.words,
                            autofocus: false,
                            cursorColor: kPrimaryColor,
                            decoration: InputDecoration(
                              hintText: 'Name',
                              icon: Icon(Icons.person,
                                  color: kPrimarySecondColor),
                              border: InputBorder.none,
                              errorStyle: TextStyle(
                                  color: Colors.redAccent, fontSize: 10),
                            ),
                            controller: fullNameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter name';
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
                        //creating email text field
                        Container(
                          height: 60,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          width: size.width * 0.8,
                          child: TextFormField(
                            autofocus: false,
                            cursorColor: kPrimaryColor,
                            decoration: InputDecoration(
                              hintText: 'Email',
                              icon: Icon(Icons.person,
                                  color: kPrimarySecondColor),
                              border: InputBorder.none,
                              errorStyle: TextStyle(
                                  color: Colors.redAccent, fontSize: 10),
                            ),
                            controller: emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter email';
                              } else if (!value.contains('@')) {
                                return 'Please enter a valid email';
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
                        //creating password text field
                        Container(
                          height: 60,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          width: size.width * 0.8,
                          child: TextFormField(
                            obscureText: true,
                            autofocus: false,
                            cursorColor: kPrimaryColor,
                            decoration: InputDecoration(
                              hintText: 'Password',
                              icon:
                                  Icon(Icons.lock, color: kPrimarySecondColor),
                              /*
                          //creating eye button on the textfield
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.visibility,
                              ),
                              color: kPrimaryColor,
                              onPressed: () {
                                debugPrint("Pressed");
                              },
                            ),
                            */
                              border: InputBorder.none,
                              errorStyle: TextStyle(
                                  color: Colors.redAccent, fontSize: 10),
                            ),
                            controller: passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter password';
                              }
                              return null;
                            },
                          ),
                          decoration: BoxDecoration(
                            color: kPrimaryLightColor,
                            borderRadius: BorderRadius.circular(29),
                            //border: Border.all(color: Colors.black, width: 1.5),
                          ),
                        ),
                        //creating confrim password text field
                        Container(
                          height: 60,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          padding:
                              EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          width: size.width * 0.8,
                          child: TextFormField(
                            obscureText: true,
                            autofocus: false,
                            cursorColor: kPrimaryColor,
                            decoration: InputDecoration(
                              hintText: 'Re-type the password',
                              icon:
                                  Icon(Icons.lock, color: kPrimarySecondColor),
                              /*
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.visibility,
                          ),
                          color: kPrimaryColor,
                          onPressed: () {
                            debugPrint("Pressed");
                          },
                        ),
                        */
                              border: InputBorder.none,
                              errorStyle: TextStyle(
                                  color: Colors.redAccent, fontSize: 10),
                            ),
                            controller: confirmPasswordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter password';
                              }
                              return null;
                            },
                          ),
                          decoration: BoxDecoration(
                            color: kPrimaryLightColor,
                            borderRadius: BorderRadius.circular(29),
                          ),
                        ),
                        SizedBox(height: size.height * 0.01),
                        //if signing up is true
                        //i.e if the user has pressed the signup button
                        //display a circular progress indicator
                        if (isSigningUp)
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    kPrimaryColor),
                              ),
                            ),
                          ),
                        //if signing up is flase
                        //i.e if the user has not pressed the signup button
                        //display the signup button
                        if (!isSigningUp)
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
                                onPressed: () async {
                                  FocusScope.of(context)
                                      .requestFocus(focusNode);
                                  //wait until the internet connection avalability is checked
                                  await getInternetConnection();
                                  //if internet connection is available
                                  if (connection == true) {
                                    // Validate returns true if the form is valid, otherwise false.
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        fullName = fullNameController.text;
                                        email = emailController.text;
                                        password = passwordController.text;
                                        confirmPassword =
                                            confirmPasswordController.text;
                                      });
                                      registration();
                                    }
                                  }
                                  //else if internet connection is not available
                                  else if (connection == false) {
                                    //display error
                                    ScaffoldMessenger.of(context)
                                      ..removeCurrentSnackBar()
                                      ..showSnackBar(
                                        SnackBar(
                                          duration: const Duration(
                                              milliseconds: 1500),
                                          backgroundColor: Colors.redAccent,
                                          content: Text(
                                            "No Internet Connectivity",
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.white),
                                          ),
                                        ),
                                      );
                                  }
                                },
                                child: Text(
                                  "Sign Up",
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
                                    //primary: kPrimaryColor,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 20),
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ),
                        //if (!_isKeyboardOpen) SizedBox(height: size.height * 0.07),
                        //if (_isKeyboardOpen) SizedBox(height: size.height * 0.0120),
                        if (!_isKeyboardOpen)
                          SizedBox(height: size.height * 0.087),
                        if (_isKeyboardOpen)
                          SizedBox(height: size.height * 0.00),
                        //creating already have an account text button
                        Container(
                          width: size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: size.width,
                                height: 1,
                                color: Color(0xffA2A2A2),
                              ),
                              SizedBox(height: 0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account? ",
                                    style: TextStyle(color: Colors.grey),
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
                                    child: Text('Login',
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )),
      ),
    );
  }
}
