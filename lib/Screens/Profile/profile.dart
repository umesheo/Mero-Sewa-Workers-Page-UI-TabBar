import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:merosewa_app/Authentication/Auto%20Login/api.dart';
import 'package:merosewa_app/Authentication/Auto%20Login/shared_pref_helper.dart';
import 'package:merosewa_app/Authentication/Social%20Login/Google/google_sign_in.dart';
import 'package:merosewa_app/Authentication/change_password.dart';
import 'package:merosewa_app/Screens/Login/components/body.dart';
import 'package:merosewa_app/Screens/Profile/editProfile.dart';
import 'package:merosewa_app/Screens/Profile/HelpCenter/helpCenter.dart';
import 'package:merosewa_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//class to display profile page
class ProfilePage extends StatefulWidget {
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  //db access
  String? name = "";
  String? email = "";
  String? photoURL = "";
  String? profileImage = "";
  User? user = FirebaseAuth.instance.currentUser;
  AuthClass authClass = AuthClass();
  //shared preferences access
  String? username = "";
  String? emails = "";
  String? photoURLS = "";
  var getPhoto = "";
  Timer? timer;
  var currentFocus;
  bool loading = false;
  bool connection = false;

  @override
  void initState() {
    //continuously check for the updates in the database
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      fetchData();
    });
    displayImage();
    super.initState();
  }

  //display the profile picture of the user
  String displayImage() {
    //if the photoURL is null
    //i.e if the user has signed up using email
    //assign a person picture to the pofileImage variable
    if (photoURL == null) {
      setState(() {
        profileImage =
            "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg";
      });
    }
    //else if the photoURL is not null
    //i.e if the user is a google user
    //assign the user's picture to profile image variable
    else {
      setState(() {
        profileImage = photoURL;
      });
    }
    //print(profileImage);
    return profileImage!;
  }

  //fetching the current user's data
  fetchData() async {
    username = await SharedPreferencesHelper().getUsername();
    emails = await SharedPreferencesHelper().getEmail();

    final firebaseUser = user;

    //if the current user is not null
    if (firebaseUser != null) {
      //wait until the user's data is fetched
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get()
          .then((ds) {
        setState(() {
          name = ds.data()!['name'];
          email = ds.data()!['email'];
          photoURL = ds.data()!['photoURL'];
        });
      });
    }
  }

  //Creating route to smoothly navigate to pages
  Route _createRoute(pages) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 300),
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

  unfocus() {
    currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
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

  //logout function
  void logOut() async {
    //setting the initial loading state to true
    setState(() {
      loading = true;
    });
    print("Tap");
    try {
      //sign out user from firebase
      await FirebaseAuth.instance.signOut();
      //sign out user from google
      await authClass.signOut();
      //wait until the token is deassigned from the user
      await Api.logoutUser();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => Login(),
          ),
          (route) => false);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text("Something went wrong",
                style: TextStyle(fontSize: 16.0, color: Colors.white),
                textAlign: TextAlign.center),
            shape: StadiumBorder(),
            behavior: SnackBarBehavior.floating,
            elevation: 0,
            padding: EdgeInsets.symmetric(vertical: 20),
            duration: Duration(milliseconds: 2000),
          ),
        );
    } finally {
      //setting the loading state to false
      setState(() {
        loading = false;
      });
    }
  }

  //app bar logout icon
  List<Widget> _buildActions() => <Widget>[
        //if the user has not pressed the logout button
        //display the logout button
        if (!loading)
          //App bar Search icon
          IconButton(
            icon: Icon(Icons.logout_outlined),
            onPressed: () async {
              //wait until the internet connection avalability is checked
              await getInternetConnection();
              //if internet connection is available
              if (connection == true) {
                logOut();
              }
              //else if internet connection is not available
              else if (connection == false) {
                //display error
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      duration: const Duration(milliseconds: 1500),
                      backgroundColor: Colors.redAccent,
                      content: Text("No Internet Connectivity",
                          style: TextStyle(fontSize: 16.0, color: Colors.white),
                          textAlign: TextAlign.center),
                      shape: StadiumBorder(),
                      behavior: SnackBarBehavior.floating,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 20),
                    ),
                  );
              }
            },
            color: Colors.grey,
            tooltip: 'Search',
          ),
        //else display a circular progress indicator
        if (loading)
          Container(
            margin: EdgeInsets.symmetric(
              vertical: 20,
            ),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
              ),
            ),
          ),
      ];

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Color(0xFFFFFFFF),
            elevation: 0.3,
            title: Text("Mero Sewa",
                style: TextStyle(
                    fontFamily: "Pacifico", color: Colors.black, fontSize: 25)),
            actions: _buildActions()),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              SizedBox(
                height: 115,
                width: 115,
                child: Stack(
                  children: [
                    //container for profile image
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 4,
                              color: Theme.of(context).scaffoldBackgroundColor),
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.1),
                                offset: Offset(0, 10))
                          ],
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(displayImage()))),
                    ),
                    //creating the edit buttons
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 4,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            color: kPrimaryColor, //Colors
                            //.greenAccent.shade400, ,
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        )),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.02),
              //Displaying the user's name
              Text('$name', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: size.height * 0.01),
              //Displaying the user's email
              Text(
                '$email',
                style: TextStyle(fontWeight: FontWeight.w100),
              ),
              SizedBox(height: size.height * 0.04),
              //Edit Profile
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                    padding: EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    backgroundColor: Color(0xFFF5F6F9),
                  ),
                  onPressed: () async {
                    //wait until the internet connection avalability is checked
                    await getInternetConnection();
                    //if internet connection is available
                    if (connection == true) {
                      //navigate to the respective page
                      Navigator.of(context)
                          .push(_createRoute(EditProfilePage()));
                    }
                    //else if internet connection is not available
                    else if (connection == false) {
                      //display error
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            duration: const Duration(milliseconds: 1500),
                            backgroundColor: Colors.redAccent,
                            content: Text("No Internet Connectivity",
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.white),
                                textAlign: TextAlign.center),
                            shape: StadiumBorder(),
                            behavior: SnackBarBehavior.floating,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 20),
                          ),
                        );
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.person, color: kPrimarySecondColor),
                      SizedBox(width: 20),
                      Expanded(child: Text("Edit Profile")),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: kPrimaryColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              //Change Password
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                    padding: EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    backgroundColor: Color(0xFFF5F6F9),
                  ),
                  onPressed: () async {
                    //wait until the internet connection availability is checked
                    await getInternetConnection();
                    //if internet connection is available
                    if (connection == true) {
                      //navigate to the respective page
                      Navigator.of(context)
                          .push(_createRoute(ChangePassword()));
                    }
                    //else if internet connection is not available
                    else if (connection == false) {
                      //display error
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            duration: const Duration(milliseconds: 1500),
                            backgroundColor: Colors.redAccent,
                            content: Text("No Internet Connectivity",
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.white),
                                textAlign: TextAlign.center),
                            shape: StadiumBorder(),
                            behavior: SnackBarBehavior.floating,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 20),
                          ),
                        );
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.password, color: kPrimarySecondColor),
                      SizedBox(width: 20),
                      Expanded(child: Text("Change Password")),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: kPrimaryColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              //Help Center
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.black,
                    padding: EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    backgroundColor: Color(0xFFF5F6F9),
                  ),
                  onPressed: () {
                    //navigate to the respective page
                    Navigator.of(context).push(_createRoute(HelpCenter()));
                  },
                  child: Row(
                    children: [
                      Icon(Icons.help, color: kPrimarySecondColor),
                      SizedBox(width: 20),
                      Expanded(child: Text("Help Center")),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: kPrimaryColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
