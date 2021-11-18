import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//delete the page later
class Profile extends StatefulWidget {
  final User? user;
  Profile({Key? key, this.user}) : super(key: key);

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final email = FirebaseAuth.instance.currentUser!.email;
  final creationTime = FirebaseAuth.instance.currentUser!.metadata.creationTime;

  User? user = FirebaseAuth.instance.currentUser;
  User? googleUser;

  @override
  void initState() {
    googleUser = widget.user;
    super.initState();
  }

  //user verification
  verifyEmail() async {
    if (user != null && !user!.emailVerified) {
      await user!.sendEmailVerification();
      print('Verification Email has been sent');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            'Verification Email has been sent',
            style: TextStyle(fontSize: 18.0, color: Colors.black),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        children: [
          user!.photoURL != null
              ? ClipOval(
                  child: Material(
                    child: Image.network(
                      user!.photoURL!,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                )
              : ClipOval(
                  child: Material(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Icon(
                        Icons.person,
                        size: 60,
                      ),
                    ),
                  ),
                ),
          Text(
            "Name: ${user!.displayName}",
            style: TextStyle(fontSize: 18.0),
          ),
          Text(
            'User ID: $uid',
            style: TextStyle(fontSize: 18.0),
          ),
          Column(
            children: [
              Text(
                'Email: $email',
                style: TextStyle(fontSize: 18.0),
              ),
              user!.emailVerified
                  ? Text(
                      'verified',
                      style: TextStyle(fontSize: 18.0, color: Colors.blueGrey),
                    )
                  : TextButton(
                      onPressed: () => {verifyEmail()},
                      child: Text('Verify Email'))
            ],
          ),
          Text(
            'Created: $creationTime',
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
  }
}
