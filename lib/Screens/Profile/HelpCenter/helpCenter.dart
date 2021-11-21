import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merosewa_app/Screens/Profile/HelpCenter/faqs.dart';

import 'package:merosewa_app/constants.dart';

//class to display Help Center page
class HelpCenter extends StatefulWidget {
  const HelpCenter({Key? key}) : super(key: key);

  @override
  HelpCenterState createState() => HelpCenterState();
}

class HelpCenterState extends State<HelpCenter> {
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
            title: Text("Help Center", style: TextStyle(color: kBlackColor)),
          ),
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
            child: Column(
              children: [
                //creating FAQs list
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
                      Navigator.of(context).push(_createRoute(FAQs()));
                    },
                    child: Row(
                      children: [
                        Icon(Icons.ac_unit, color: kPrimarySecondColor),
                        SizedBox(width: 20),
                        Expanded(
                            child: Text("FAQs",
                                style: GoogleFonts.varelaRound(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ))),
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
          )),
    );
  }
}
