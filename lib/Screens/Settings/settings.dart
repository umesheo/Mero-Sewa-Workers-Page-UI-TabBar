import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:merosewa_app/Screens/Settings/feedback.dart';
import 'package:merosewa_app/constants.dart';
import 'package:sign_button/sign_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

//class to display settings page
class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  var currentFocus;

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
        //animation =
        //CurvedAnimation(parent: animation, curve: Curves.easeInBack);
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
          ),
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
            child: Column(
              children: [
                //creating about mero sewa list
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
                      Navigator.of(context).push(_createRoute(null));
                      /*
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfilePage()),
                      );
                      */
                    },
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: kPrimarySecondColor),
                        SizedBox(width: 20),
                        Expanded(child: Text("About Mero Sewa")),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: kPrimaryColor,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                //creating feedback list
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
                      Navigator.of(context).push(_createRoute(FeedBack()));
                    },
                    child: Row(
                      children: [
                        Icon(Icons.message_outlined,
                            color: kPrimarySecondColor),
                        SizedBox(width: 20),
                        Expanded(child: Text("Feedback")),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: kPrimaryColor,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                //creating terms & conditions list
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
                      Navigator.of(context).push(_createRoute(null));
                    },
                    child: Row(
                      children: [
                        Icon(Icons.language, color: kPrimarySecondColor),
                        SizedBox(width: 20),
                        Expanded(child: Text("Terms & Conditions")),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: kPrimaryColor,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                //creating privacy policy list
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
                      Navigator.of(context).push(_createRoute(null));
                    },
                    child: Row(
                      children: [
                        Icon(Icons.work_outline, color: kPrimarySecondColor),
                        SizedBox(width: 20),
                        Expanded(child: Text("Privacy Policy")),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: kPrimaryColor,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                /*
                //creating contact buttons
                Container(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //facebook icon
                          SignInButton.mini(
                              buttonType: ButtonType.facebook,
                              onPressed: () {}),
                          //instagram icon
                          SignInButton.mini(
                              buttonType: ButtonType.instagram,
                              onPressed: () {}),
                          SizedBox(width: 25),
                          Container(
                            height: 42,
                            width: 42,
                            child: Ink(
                              decoration: ShapeDecoration(
                                  color: Colors.green,
                                  shape: CircleBorder(),
                                  shadows: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.9),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: Offset(0, 2),
                                    ),
                                  ]),
                              child: IconButton(
                                splashRadius: 20,
                                icon: FaIcon(
                                  FontAwesomeIcons.whatsapp,
                                  color: Color(0xFFFFFFFF),
                                ),
                                color: Colors.white,
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                */
              ],
            ),
          )),
    );
  }
}
