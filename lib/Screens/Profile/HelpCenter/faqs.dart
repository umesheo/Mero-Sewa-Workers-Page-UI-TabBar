import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:merosewa_app/constants.dart';
import 'package:google_fonts/google_fonts.dart';

//class to display FAQs page
class FAQs extends StatefulWidget {
  const FAQs({Key? key}) : super(key: key);

  @override
  FAQsState createState() => FAQsState();
}

class FAQsState extends State<FAQs> {
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
          backgroundColor: Color(0xFFFFFFFF),
          appBar: AppBar(
            backgroundColor: Color(0xFFFFFFFF),
            elevation: 0.3,
            title: Text("FAQs", style: TextStyle(color: kBlackColor)),
          ),
          body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
            child: Column(
              children: [
                buildCard(
                    "How do I hire workers?",
                    "You will hire workers by simply selecting the desired workers card in the home screen."
                        "You will then be displayed the list of nearby workers and can choose from any of the workers you want to hire."
                        "After you have selected a worker, you get directed to the selected worker's details page where you can tap on the call button to hire the worker."),
                buildCard("To which locations are the workers available?",
                    "Currently, the workers are available inside Kathmandu and Lalitpur valley")
              ],
            ),
          )),
    );
  }

  Widget buildCard(String title, String description) {
    Size size = MediaQuery.of(context).size;
    return Card(
        //
        child: Padding(
      //padding for contents of the list
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: ExpandablePanel(
          //padding for list bottom
          header: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(title,
                style: GoogleFonts.varelaRound(
                    fontSize: 19,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500)),
          ),
          collapsed: Text(""),
          expanded: Text(
            description,
            style: GoogleFonts.varelaRound(
                fontSize: 16, color: Colors.grey.shade500),
          )),
    ));
  }
}
