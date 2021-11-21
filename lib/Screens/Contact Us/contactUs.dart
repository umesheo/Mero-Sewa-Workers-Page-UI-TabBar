import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:merosewa_app/Screens/WebView/webView.dart';
import 'package:merosewa_app/constants.dart';
import 'package:merosewa_app/or_divider.dart';
import 'package:sign_button/sign_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

//class to display contact us page
class ContactUs extends StatefulWidget {
  const ContactUs({Key? key}) : super(key: key);

  @override
  _ContactUsState createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  var currentFocus;
  var phoneNumber = "+977-9843363933";
  var inquiryText = "Hello Trooper, I would like to place an inquiry.";
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        unfocus();
      },
      child: Scaffold(
          backgroundColor: Color(0xFFFFFFFF),
          appBar: AppBar(
            backgroundColor: Color(0xFFFFFFFF),
            elevation: 0.3,
            title: Text("Mero Sewa",
                style: TextStyle(
                    fontFamily: "Pacifico", color: Colors.black, fontSize: 25)),
          ),
          body: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: size.width * 0.10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //facebook icon
                          SignInButton.mini(
                              buttonType: ButtonType.facebook,
                              onPressed: () {
                                /*
                                //navigate to the respective page
                                //opening website within app
                                Navigator.of(context)
                                    .push(_createRoute(WebViewPage()));*/
                                //launching troopers facebook page
                                launch('fb://page/1828671380568191');
                              }),
                          //whatsapp icon
                          Container(
                            height: 42,
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
                                splashRadius: 22,
                                icon: FaIcon(
                                  FontAwesomeIcons.whatsapp,
                                  color: Color(0xFFFFFFFF),
                                ),
                                color: Colors.white,
                                onPressed: () {
                                  //launching troopers whatsapp with an pre-defined inquiry text
                                  launch(
                                      'whatsapp://send?phone=$phoneNumber&text=$inquiryText');
                                  //launch('sms:$phoneNumber?body=$inquiryText');
                                },
                              ),
                            ),
                          ),
                          //instagram icon
                          SignInButton.mini(
                              buttonType: ButtonType.instagram,
                              onPressed: () {
                                //launching troopers instagram page
                                launch(
                                    'https://www.instagram.com/troopersgroup/');
                              }),
                        ],
                      ),
                    ),
                    OrDivider(),
                    //phone icon
                    Container(
                      height: 42,
                      child: Ink(
                        decoration: ShapeDecoration(
                            color: Color(0xFF2196F3),
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
                          splashRadius: 22,
                          icon: FaIcon(
                            FontAwesomeIcons.phone,
                            color: Color(0xFFFFFFFF),
                          ),
                          color: Colors.white,
                          onPressed: () {
                            //lauching phone dial pad with troopers phone number
                            launch('tel:$phoneNumber');
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    //troopers IT Page link
                    Column(
                      children: [
                        Text(
                          'Version 1.0.0 \u00a9 Troopers Pvt. Ltd',
                          style: GoogleFonts.varelaRound(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        TextButton(
                          child: Text(
                            'Developed by Troopers IT Team',
                            style: GoogleFonts.varelaRound(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600),
                          ),
                          onPressed: () {
                            //launching Troopers It Page
                            launch('http://www.troopersgroup.com/It.html');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
