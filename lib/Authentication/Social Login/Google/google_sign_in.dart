import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:merosewa_app/Authentication/Auto%20Login/api.dart';
import 'package:merosewa_app/Authentication/Auto%20Login/shared_pref_helper.dart';
import 'package:merosewa_app/Screens/HomePage/bottomNaviationGateway.dart';

//class for singing in the user using google authentication
class AuthClass {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  User? currentUser = FirebaseAuth.instance.currentUser;
  late String? uid;
  var name = "";
  var email = "";
  var photoURL = "";
  bool signInWithGoogle = true;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      //'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

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

  Future<User?> googleSignIn(BuildContext context) async {
    try {
      //authnticating the users using google sign in
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      //getting the id and access token and storing to credential v
      AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      //getting the current user
      user = userCredential.user;
      //Getting the current user's uid
      uid = user?.uid;
      //getting the uid under the users
      final snapShot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      //if the uid under users collection does not exist i.e if the user is a new user
      if (!snapShot.exists) {
        //add the google users data to firestore
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .set({
          'name': user!.displayName,
          'email': user!.email,
          'photoURL': user!.photoURL,
          'signInWithGoogle': true,
          'uid': user!.uid,
        }).then((signedInUser) async {
          print("Success");
        });

        //wait until the access token is assigned
        await Api.loginUser();

        //fetch the current signed in users data from database
        //and assign in to the respective variables
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get()
            .then((ds) {
          signInWithGoogle = ds.data()!['signInWithGoogle'];
          name = ds.data()!['name'];
          email = ds.data()!['email'];
          photoURL = ds.data()!['photoURL'];
          print("Google: $signInWithGoogle");
          print("Name: $name");
          print("Email: $email");
        });

        //set the name and email accessed from database to
        //a local storage
        await SharedPreferencesHelper().setUserName(name);
        await SharedPreferencesHelper().setEmail(email);

        //Navigate to the respective page
        Navigator.of(context)
            .pushReplacement(_createRoute(BottomNavigationGateway()));
      }
      //else if the uid under users collection do exist, check if it is a email or google user
      else {
        //wait until the access token is assigned
        await Api.loginUser();

        //fetch the currenntly signed in users data from firestore database
        //and assign to the resepctive variables
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get()
            .then((ds) {
          signInWithGoogle = ds.data()!['signInWithGoogle'];
          name = ds.data()!['name'];
          email = ds.data()!['email'];
          //photoURL = ds.data()!['photoURL'];
          print("Google: $signInWithGoogle");
          print("Name: $name");
          print("Email: $email");
        });

        ///set the name and email accessed from database to
        //a local storage
        await SharedPreferencesHelper().setUserName(name);
        await SharedPreferencesHelper().setEmail(email);
        //wait SharedPreferencesHelper().setPhotoURL(photoURL);

        /*
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BottomNavigationGateway(),
          ),
        );
        */
        //Navigate to the respective page
        Navigator.of(context)
            .pushReplacement(_createRoute(BottomNavigationGateway()));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              'The account already exists with a different credential.',
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ),
        );
      } else if (e.code == 'invalid-credential') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              'Error occurred while accessing credentials. Try again.',
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ),
        );
      }
    } catch (e) {
      print(e.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Something went wrong",
            style: TextStyle(fontSize: 16.0, color: Colors.white),
          ),
        ),
      );
    }
    return user;
  }

  //signout the user
  Future<void> signOut({BuildContext? context}) async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      final snackBar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context!).showSnackBar(snackBar);
    }
  }
}
