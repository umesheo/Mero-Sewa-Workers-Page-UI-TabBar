import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:merosewa_app/Authentication/Auto%20Login/api.dart';
import 'package:merosewa_app/Authentication/Auto%20Login/shared_pref_helper.dart';
import 'package:merosewa_app/Authentication/Social%20Login/Google/google_sign_in.dart';
import 'package:merosewa_app/Authentication/forgot_password.dart';
import 'package:merosewa_app/Screens/Signup/components/body.dart';
import 'package:merosewa_app/constants.dart';
import 'package:merosewa_app/or_divider.dart';
import 'package:sign_button/sign_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:merosewa_app/Screens/HomePage/bottomNaviationGateway.dart';

//class to display login screen
//and login user functioning
class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  static var name = "";
  static var email = "";
  var password = "";
  var photoURL = "";
  String? localStorageName = "";
  String? localStorageEmail = "";
  AuthClass authClass = AuthClass();
  bool connection = false;

  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoggingIn = false;
  var loading = false;
  bool _isKeyboardOpen = false;
  late AnimationController _controller;
  late Animation<double> _animation;
  final auth = FirebaseAuth.instance;
  User? user;
  Timer? timer;
  bool signInWithGoogle = false;
  static String? localUsername;
  static String? localEmail;

  @override
  void initState() {
    //getting the current user
    user = auth.currentUser;

    //for animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween(begin: 0.1, end: 1.0).animate(_controller);

    //listen if keyboard is opened or closed
    KeyboardVisibilityController().onChange.listen((isVisible) {
      setState(() {
        _isKeyboardOpen = isVisible;
      });
    });
    super.initState();
  }

  //Creating route to smoothly navigate to pages
  Route _createRoute(pages) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => pages,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = animation.drive(tween);
        //animation = CurvedAnimation(parent: animation, curve: Curves.bounceIn);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
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

  //login with email and password
  userLogin() async {
    //if user is trying to log in
    //set the isLoggingIn state to  true
    setState(() {
      isLoggingIn = true;
    });
    //todo: check if user has signed in wih google and then display error
    //The account already exists with a different credential.
    try {
      //sign in the user to firebase with email and password
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      user = auth.currentUser;
      //reload the user from time to time
      await user?.reload();

      //fetch the data from the database
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get()
          .then((ds) {
        setState(() {
          signInWithGoogle = ds.data()!['signInWithGoogle'];
          name = ds.data()!['name'];
          email = ds.data()!['email'];
          //photoURL = ds.data()!['photoURL'];
          print("Google: $signInWithGoogle");
        });
      });

      //if the email is verified
      //navigate to login screen
      if (user!.emailVerified) {
        //wait until the token is assigned and saved for auto login
        await Api.loginUser();

        //wait unitl the username and email is set to shared preferences
        await SharedPreferencesHelper().setUserName(name);
        await SharedPreferencesHelper().setEmail(email);

        //route to HomePage
        Navigator.of(context)
            .pushReplacement(_createRoute(BottomNavigationGateway()));
      }
      //else if the user email is not verified
      else if (!user!.emailVerified) {
        //send an email verification again
        await user!.sendEmailVerification();
        //and display a snack bar
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              //duration: const Duration(seconds: 1),
              backgroundColor: Colors.redAccent,
              content: Text(
                "Email not verified! A verification email has been sent again",
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
          );
      }
      //catch exception
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        //if (signInWithGoogle == true) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              //duration: const Duration(seconds: 1),
              backgroundColor: Colors.redAccent,
              content: Text(
                "User already exists with different credential. Try sign in with Google instead.",
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
          );
        //}
      }
      //if the user is not found
      else if (e.code == 'user-not-found') {
        print("Uer not found for that Email");
        //display a snack bar
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent,
              duration: Duration(milliseconds: 1500),
              content: Text(
                "No User found for that Email",
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
          );
        //else if the user enters wrong password
      } else if (e.code == 'wrong-password') {
        print("Incorrect Password");
        //display a snackbar
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: Colors.redAccent,
              duration: Duration(milliseconds: 1500),
              content: Text(
                "Incorrect password",
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
        isLoggingIn = false;
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
      //then set loading to false
      setState(() {
        loading = false;
      });
    } finally {}
  }

  FocusNode focusNode = new FocusNode();
  @override
  void dispose() {
    timer?.cancel();
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  var currentFocus;

  unfocus() {
    currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    _controller.forward();
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
                          top: size.height * 0.20,
                        )),
                      if (_isKeyboardOpen)
                        Padding(
                            padding: EdgeInsets.only(
                          top: size.height * 0.04,
                        )),
                      Image.asset(
                        "assets/images/Logo.png",
                        width: 100,
                        height: 100,
                      ),
                      Text(
                        'Mero Sewa',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Pacifico',
                          fontSize: 35,
                        ),
                      ),
                      if (!_isKeyboardOpen)
                        Padding(
                            padding: EdgeInsets.only(
                          bottom: size.height * 0.04,
                        )),
                      SizedBox(height: size.height * 0.01),
                      FadeTransition(
                          opacity: _animation,
                          child: Column(
                            children: [
                              //creating the email text field
                              Container(
                                height: 60,
                                margin: EdgeInsets.symmetric(vertical: 10),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
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
                                      color: Colors.redAccent,
                                      fontSize: 10,
                                    ),
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
                              //creating the password text field
                              Container(
                                height: 60,
                                margin: EdgeInsets.symmetric(vertical: 10),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                width: size.width * 0.8,
                                child: TextFormField(
                                  obscureText: true,
                                  autofocus: false,
                                  cursorColor: kPrimaryColor,
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    icon: Icon(Icons.lock,
                                        color: kPrimarySecondColor),
                                    border: InputBorder.none,
                                    /*
                                    //show password eye icon
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
                                    errorStyle: TextStyle(
                                        color: Colors.redAccent, fontSize: 10),
                                  ),
                                  controller: passwordController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please Enter Password';
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
                              SizedBox(height: size.height * 0.01),
                              //if the user is not loggin in i.e
                              //the login button is not pressed
                              //display the login button
                              if (!isLoggingIn)
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
                                          if (_formKey.currentState!
                                              .validate()) {
                                            setState(() {
                                              email = emailController.text;
                                              password =
                                                  passwordController.text;
                                            });
                                            userLogin();
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
                                      child: Text(
                                        "Log In",
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
                              //else if the user is loggin in i.e
                              //the login button is pressed
                              //display the circular progress indicator
                              if (isLoggingIn)
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          kPrimaryColor),
                                    ),
                                  ),
                                ),
                              //creating the forgotten password text button
                              Container(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ForgotPassword(),
                                        ),
                                      ),
                                    },
                                    child: Text(
                                      'Forgotten Password?',
                                      style: TextStyle(
                                          fontSize: 14.0, color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                              //or divider line
                              OrDivider(),
                              SizedBox(height: size.height * 0.008),
                              //if user has pressed the google login button
                              //display circular progress indicator
                              if (loading)
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          kPrimaryColor),
                                    ),
                                  ),
                                ),
                              //else display the google icon
                              if (!loading)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
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
                            ],
                          )),
                      if (!_isKeyboardOpen)
                        SizedBox(height: size.height * 0.100),
                      if (_isKeyboardOpen) SizedBox(height: size.height * 0.05),
                      //creating don't have an account text button
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
                                  "Don't have an Account? ",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                TextButton(
                                  onPressed: () => {
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, a, b) =>
                                              Signup(),
                                          transitionDuration:
                                              Duration(seconds: 0),
                                        ),
                                        (route) => false)
                                  },
                                  child: Text('Signup',
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
          ),
        ),
      ),
    );
  }
}
