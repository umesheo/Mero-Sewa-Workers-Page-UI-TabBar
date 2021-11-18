import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:merosewa_app/Authentication/Auto%20Login/api.dart';
import 'package:merosewa_app/Authentication/Social%20Login/Google/google_sign_in.dart';
import 'package:merosewa_app/Screens/Login/components/body.dart';
import 'package:merosewa_app/constants.dart';

//class to change password of the users
//todo: password is not being changed if the user signs in from google
class ChangePassword extends StatefulWidget {
  ChangePassword({Key? key}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  var newPassword = "";
  var confirmPassword = "";
  // Create text controllers and use it to retrieve the current value
  // of the TextFields.
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  FocusNode focusNode = new FocusNode();
  AuthClass authClass = AuthClass();
  var currentFocus;
  bool isLoading = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    confirmPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  final currentUser = FirebaseAuth.instance.currentUser;
  changePassword() async {
    //set the loading indicator to true
    setState(() {
      isLoading = true;
    });
    try {
      //if new password and confirm password matches
      if (newPassword == confirmPassword) {
        //wait until the current user's password is updated
        await currentUser!.updatePassword(newPassword);
        //sign out the user
        await FirebaseAuth.instance.signOut();
        //sign out user from google
        await authClass.signOut();
        //wait until the token is deassigned from the user
        await Api.logoutUser();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
        //display a snackbar message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: kPrimaryColor,
            content: Text(
              "Password successfully updated. Please login again",
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ),
        );
      }
      //else print error
      else {
        print("Password and Confirm Password doesn't match");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "Password and Confirm Password doesn't match",
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ),
        );
      }
    }
    //print error if the password is weak
    on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print("Password provided is too weak");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "Password is too weak. Please provide atleast one number",
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ),
        );
      }
    }
    //finally set the loading indicator to false
     finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  unfocus() {
    currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFFFFFFF),
          elevation: 0.3,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: kBlackColor),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: ListView(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  child: TextFormField(
                    obscureText: true,
                    cursorColor: kPrimaryColor,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: kPrimaryColor, width: 1.0),
                      ),
                      border: OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: kPrimarySecondColor, width: 1.0),
                      ),
                      labelText: 'New Password',
                      floatingLabelStyle:
                          (TextStyle(color: kPrimarySecondColor, fontSize: 20)),
                      hintText: 'Enter New Password',
                      labelStyle: TextStyle(
                        fontSize: 15.0,
                      ),
                      errorStyle:
                          TextStyle(color: Colors.redAccent, fontSize: 15),
                    ),
                    controller: newPasswordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Password';
                      }
                      return null;
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  child: TextFormField(
                    obscureText: true,
                    cursorColor: kPrimaryColor,
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: kPrimaryColor, width: 1.0),
                      ),
                      border: OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: kPrimarySecondColor, width: 1.0),
                      ),
                      labelText: 'Confirm Password',
                      floatingLabelStyle:
                          (TextStyle(color: kPrimarySecondColor, fontSize: 20)),
                      hintText: 'Enter New Password',
                      labelStyle: TextStyle(fontSize: 15.0),
                      errorStyle:
                          TextStyle(color: Colors.redAccent, fontSize: 15),
                    ),
                    controller: confirmPasswordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please Enter Password';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 32),
                //if not loading i.e if the user has not pressed the change password button
                //display the send password button
                if (!isLoading)
                  ElevatedButton(
                    onPressed: () {
                      FocusScope.of(context).requestFocus(focusNode);
                      // Validate returns true if the form is valid, otherwise false.
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          newPassword = newPasswordController.text;
                          confirmPassword = confirmPasswordController.text;
                        });
                        changePassword();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      primary:
                          kPrimarySecondColor, //Colors.greenAccent.shade400,
                      onPrimary: Colors.greenAccent.shade400, //kPrimaryColor,
                      elevation: 2,
                      side: BorderSide(color: Colors.white, width: 1),
                      padding: EdgeInsets.symmetric(
                        horizontal: 50,
                      ),

                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      "Change Password",
                      style: TextStyle(
                          fontSize: 17,
                          letterSpacing: 2.2,
                          color: Colors.white),
                    ),
                  ),
                //if loading i.e if the user has pressed the change password button
                //display the circular progess indicator
                if (isLoading)
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(kPrimaryColor),
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
