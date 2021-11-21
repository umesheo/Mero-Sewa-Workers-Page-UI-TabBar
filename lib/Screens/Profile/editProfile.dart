import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merosewa_app/Authentication/Auto%20Login/api.dart';
import 'package:merosewa_app/Authentication/Social%20Login/Google/google_sign_in.dart';
import 'package:merosewa_app/Screens/Login/components/body.dart';
import 'package:merosewa_app/constants.dart';

//class to display the edit profile page
//and edit profile functioning
class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  //variables to store profile info fetched from database
  var name = "";
  String? uid = "";
  var email = "";
  String? photoURL = "";

  //variables for checking whether name and email is valid
  bool updateNameValid = true;
  bool updateEmailValid = true;

  //controllers to get the input text values
  TextEditingController nameController =
      TextEditingController(text: "loading name...");
  final emailController = TextEditingController(text: "loading email...");

  //fetching the current user's uid, email and creation time
  final userid = FirebaseAuth.instance.currentUser!.uid;
  final emails = FirebaseAuth.instance.currentUser!.email;
  final creationTime = FirebaseAuth.instance.currentUser!.metadata.creationTime;

  //defining a profile image varible to assign
  //either the default profile picture (if no display picture) or
  //profile picture of the user
  String? profileImage = "";

  //for progress indicator
  bool loading = false;

  //getting the current signed in user
  User? user = FirebaseAuth.instance.currentUser;

  FocusNode focusNode = new FocusNode();

  //creating an instance of AuthClass
  AuthClass authClass = AuthClass();

  @override
  void initState() {
    //instantly callthe functions when the profile page opens
    fetchData();
    displayImage();
    super.initState();
  }

  //display the profile picture of the user
  String displayImage() {
    //if the photoURL is null
    //i.e if the user has signed up using email
    //assign a default person picture to the pofileImage variable
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
    //reurning the profile image
    return profileImage!;
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

  //fetching the current user's data from database
  fetchData() async {
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

          //setting the database accessed values
          //to text field controllers to display
          nameController.text = name;
          emailController.text = email;
        });
      });
    }
  }

  //reset email function
  Future resetEmail(String newEmail) async {
    var message;

    user!
        .updateEmail(newEmail)
        .then(
          (value) => message = 'Success',
        )
        .catchError((onError) => message = 'error');
    return message;
  }

  //update profile of the user
  updateProfileData() async {
    //setting the initial loading state to false
    setState(() {
      loading = true;
    });
    try {
      //if the user has not made any changes in the data
      //display a snackbar
      if (email == emailController.text && name == nameController.text) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: Colors.grey,
              content: Text(
                "Failed to save. No changes in the user profile data",
                style: TextStyle(fontSize: 16.0, color: Colors.white),
              ),
              duration: Duration(milliseconds: 2000),
            ),
          );
      }
      //else if the database email is not equals to the user input email
      //then only reset the email
      //and send a verification email to the users email id
      else if (email != emailController.text) {
        //calling reset email function
        await resetEmail(emailController.text);

        await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .update({
          'name': capitalFirst(nameController.text),
          'email': emailController.text,
          //'photoURL': user!.photoURL,
          //'uid': user!.uid,
          //'signInWithGoogle': false
        });
        //reload the users data
        await user!.reload();
        await user!.sendEmailVerification();
        //signout from firebase
        await FirebaseAuth.instance.signOut();
        //sign out user from google
        await authClass.signOut();
        //wait until the token is deassigned from the user
        await Api.logoutUser();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: kPrimaryColor,
            content: Text(
              "Profile successfully updated. Please verify your new email to login",
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }

      //if the database email is equal to the user input email
      //i.e user has not requested to update the email
      //so only update the name in database
      //and fetch the data, then push the user to profile page
      else if (email == emailController.text) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .update({
          'name': capitalFirst(nameController.text),
          //'email': emailController.text,
          //'photoURL': user!.photoURL,
          //'uid': user!.uid,
          //'signInWithGoogle': false
        });

        //reload the user
        await user!.reload();
        //fetch the edited data from database
        await fetchData();

        //floating snack bar

        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              backgroundColor: kPrimaryColor,
              content: Text("Profile successfully updated",
                  style: TextStyle(fontSize: 16.0, color: Colors.white),
                  textAlign: TextAlign.center),
              shape: StadiumBorder(),
              behavior: SnackBarBehavior.floating,
              elevation: 0,
              padding: EdgeInsets.symmetric(vertical: 20),
              duration: Duration(milliseconds: 2000),
            ),
          );

        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print("Account already exists");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text(
              "Account already exists",
              style: TextStyle(fontSize: 16.0, color: Colors.white),
            ),
          ),
        );
      } else {
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
    } finally {
      //set the loading state to false
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  bool showPassword = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFFFFFFF),
          elevation: 0.3,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color:
                    Colors.black //Colors.greenAccent.shade400 //kPrimaryColor ,
                ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Form(
          key: _formKey,
          child: Container(
            padding: EdgeInsets.only(
                left: size.width * 0.05,
                top: size.width * 0.05,
                right: size.width * 0.05),
            child: ListView(
              children: [
                Text(
                  "Edit Profile",
                  style: GoogleFonts.varelaRound(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: size.height * 0.03,
                ),
                Container(
                    child: Column(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          //creating a container to display the user's profile image
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 4,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor),
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
                          //creating the edit button on the profile image
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
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
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
                    SizedBox(height: size.height * 0.05),
                    //creating name text field
                    Padding(
                      padding: const EdgeInsets.only(bottom: 35.0),
                      child: TextFormField(
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 3),
                          labelText: "Full Name",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        controller: nameController,
                        style: GoogleFonts.varelaRound(),
                        validator: (value) {
                          {
                            if (value == null || value.isEmpty) {
                              return 'Please enter upated name';
                            } else if (value.length < 3) {
                              return 'Please enter more than 3 characters';
                            }
                            return null;
                          }
                        },
                      ),
                    ),
                    //creating email text field
                    Padding(
                      padding: const EdgeInsets.only(bottom: 35.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(bottom: 3),
                          labelText: "Email",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        controller: emailController,
                        style: GoogleFonts.varelaRound(),
                        validator: (value) {
                          {
                            if (!value!.contains('@')) {
                              return 'Please enter a valid email: @ missing!';
                            }
                            return null;
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    //if not laoding
                    //display the cancel and save button
                    if (!loading)
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.00),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //creating cancel button
                            OutlinedButton(
                              style: ElevatedButton.styleFrom(
                                onPrimary: Colors.greenAccent.shade400,
                                //kPrimarySecondColor,
                                padding: EdgeInsets.symmetric(horizontal: 50),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                FocusScope.of(context).requestFocus(focusNode);

                                Navigator.of(context).pop();
                              },
                              child: Text("CANCEL",
                                  style: TextStyle(
                                      fontSize: 14,
                                      letterSpacing: 2.2,
                                      color: Colors.black)),
                            ),
                            //creating save button
                            ElevatedButton(
                              onPressed: () {
                                FocusScope.of(context).requestFocus(focusNode);
                                if (_formKey.currentState!.validate()) {
                                  updateProfileData();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                primary:
                                    kPrimarySecondColor, //Colors.greenAccent.shade400,
                                onPrimary: Colors
                                    .greenAccent.shade400, //kPrimaryColor,
                                elevation: 2,
                                side: BorderSide(color: Colors.white, width: 1),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 50,
                                ),

                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                "SAVE",
                                style: TextStyle(
                                    fontSize: 14,
                                    letterSpacing: 2.2,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    //else display circular progress indicator
                    if (loading)
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
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
