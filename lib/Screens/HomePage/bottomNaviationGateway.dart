import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merosewa_app/Screens/Contact%20Us/contactUs.dart';
import 'package:merosewa_app/Screens/Settings/settings.dart';
import 'package:merosewa_app/constants.dart';
import 'package:merosewa_app/Screens/Favourites/favourites.dart';
import 'package:merosewa_app/Screens/HomePage/homeScreen.dart';
import 'package:merosewa_app/Screens/Profile/profile.dart';
import 'package:flutter/services.dart';

//class which acts as a naviation gateway to
//bottom navigation bar icons (pages)
class BottomNavigationGateway extends StatefulWidget {
  @override
  BottomNavigationGatewayState createState() => BottomNavigationGatewayState();
}

class BottomNavigationGatewayState extends State<BottomNavigationGateway> {
  int selectedOptionIndex = 0;

  //calling the pages to view from bottom navigation
  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    Favourites(),
    ProfilePage(),
    Settings(),
    ContactUs()
  ];

  @override
  Widget build(BuildContext context) {
    //system status bar and screen bottom customization
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        //setting the status bar and status bar icon brightness to black
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark,
        //setting the status bar color to white
        statusBarColor: Color(0xFFFFFFFF),
        //setting the sceren bottom color to theme color
        systemNavigationBarColor: kPrimaryColor,
        //setting the screen bottom navigation button color to black
        systemNavigationBarIconBrightness: Brightness.dark));
    return Scaffold(
      /*
      //Use this app bar for a common app bar text and icons for all pages
      //else if different pages have different icons, use the app bar independently
      //in all of the pages
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.3,
        title: Text("Mero Sewa",
            style: TextStyle(
                fontFamily: "Pacifico", color: Colors.black, fontSize: 25)),
        /*
        Menu Icon: If needed in future
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.gripLines),
          onPressed: () {},
          color: Colors.grey,
          tooltip: 'Menu',
        ),
        */
        actions: _buildActions(),
      ),
      */
      body: _widgetOptions.elementAt(selectedOptionIndex),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  //Display Multiple icons on the right side of the screen
  List<Widget> _buildActions() => <Widget>[
        //App bar Search and cart icon
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {},
          color: Colors.grey,
          tooltip: 'Search',
        ),
        /*
        IconButton(
          icon: Icon(
            FontAwesomeIcons.shoppingBasket,
            size: 20,
          ),
          onPressed: () {},
          color: Colors.grey,
          tooltip: 'Cart',
        )
        */
      ];

  //bulding bottok navigation bar icons and texts
  Widget _buildBottomNavigationBar() {
    List<String> bottomNavigationBarOptions = [
      'Home',
      'Favorites',
      'Profile',
      'Settings',
      'Contact'
    ];

    List<IconData> bottomNavigationBarIcons = [
      Icons.home_outlined,
      Icons.favorite_border,
      Icons.person_outline,
      Icons.settings_outlined,
      Icons.call_outlined
    ];

    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: 10),
      //bottom navigation bar container style
      decoration: BoxDecoration(
          color: kPrimarySecondColor,
          //bottom navigation bar border style
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          )),
      child: Row(
        children: List.generate(bottomNavigationBarOptions.length, (index) {
          if (index == selectedOptionIndex) {
            return Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedOptionIndex = index;
                  });
                },
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    //bottom navigation bar active icons container border style
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        //bottom navigation bar active icons color
                        Icon(
                          bottomNavigationBarIcons[index],
                          color: kPrimaryColor,
                        ),
                        SizedBox(width: 3),
                        //bottom navigation bar icon labels
                        Text(
                          bottomNavigationBarOptions[index],
                          style: GoogleFonts.varelaRound(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedOptionIndex = index;
                });
              },
              //bottom navigation bar inactive icon color
              child: Icon(
                bottomNavigationBarIcons[index],
                color: Colors.white,
              ),
            ),
          );
        }),
      ),
    );
  }
}
