import 'package:flutter/material.dart';
import 'package:merosewa_app/Screens/Workers/Plumbers/plumberDetails.dart';
import 'package:merosewa_app/Screens/Workers/data.dart';
import 'package:merosewa_app/constants.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

//class to display plumber lists
class AllPlumbersList extends StatefulWidget {
  const AllPlumbersList({
    Key? key,
  }) : super(key: key);

  @override
  _AllPlumbersListState createState() => _AllPlumbersListState();
}

class _AllPlumbersListState extends State<AllPlumbersList> {
  bool loading = true;
  String address = "";
  List<Data> dataList = [];
  bool connection = false;

  @override
  void initState() {
    loadAllData();

    //fetchData();
    super.initState();
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

  //getting the internet connection
  Future getInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          connection = true;
        });

        //timer?.cancel();
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

  loadAllData() async {
    setState(() {
      loading = true;
    });
    try {
      await getInternetConnection();
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future fetchAllData() async {
    getInternetConnection();
    //creating a database reference
    DatabaseReference referenceData = FirebaseDatabase.instance.reference();

    //getting the data from database were address is
    //equals to users current location
    await referenceData.child("Workers").once().then((DataSnapshot snapshot) {
      //clear the previous stored datalist
      dataList.clear();

      //getting the keys (index) and values from snapshot
      var keys = snapshot.value.keys;
      var values = snapshot.value;

      for (var key in keys) {
        //if category is plumber
        if (values[key]["Category"] == "Plumber" ||
            values[key]["Category"] == "plumber") {
          //fetch all data of the plumbers from database

          //and add to Data class constructor
          Data data = new Data(
              values[key]["Category"],
              values[key]["Name"],
              values[key]["Address"],
              values[key]["PhoneNumber"],
              values[key]["URL"]);
          //then add the value to the data list
          dataList.add(data);
        }
      }
      //print("Snapshot Value${snapshot.value}");
      print(dataList[0].databaseAddress);
    });
    //return the data list
    return dataList;
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        body: Container(
      child: FutureBuilder(
        future: fetchAllData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData && loading == false)
            return ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: dataList.length,
                itemBuilder: (_, index) {
                  return GestureDetector(
                      onTap: () {
                        //navigate to Plumber Details page with the all data
                        Navigator.of(context).push(_createRoute(PlumberDetails(
                            category: dataList[index].databaseCategory!,
                            name: dataList[index].databaseName!,
                            address: dataList[index].databaseAddress!,
                            phoneNumber: dataList[index].phoneNumber!,
                            photoURL: dataList[index].photoURL!)));
                      },
                      //displaying the data in card lists
                      //include the details required in the lisitng page
                      child: cardUI(
                          dataList[index].databaseName,
                          dataList[index].databaseAddress,
                          dataList[index].databaseCategory,
                          dataList[index].phoneNumber,
                          dataList[index].photoURL));
                });
          //else if snapshot has unknown error
          //and internet connection is also available
          //but for some reason the address is returned empty
          else if (snapshot.hasError && connection == true && loading == false)
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Column(
                        children: [
                          Text(
                            "Something went wrong",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Pacifico',
                                fontWeight: FontWeight.w300,
                                fontSize: 20),
                          ),
                          SizedBox(height: size.height * 0.03),
                          Image.asset(
                            "assets/images/gmail.png",
                            height: size.height * 0.15,
                          ),
                          SizedBox(height: size.height * 0.03),
                          Text("An unknown error has occured",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w300, fontSize: 18)),
                          SizedBox(height: size.height * 0.05),
                          //Display a reload button
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: ElevatedButton(
                              onPressed: () async {
                                await getInternetConnection();

                                if (connection == true) {
                                  loadAllData();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Color(
                                    0xFFF44336), //Colors.greenAccent.shade400,
                                //kPrimaryColor,
                                elevation: 2,
                                side: BorderSide(color: Colors.white, width: 1),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 30,
                                ),

                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                "RELOAD",
                                style: TextStyle(
                                    fontSize: 14,
                                    letterSpacing: 2.2,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          //else is internet connection is not available
          else if (connection == false && loading == false)
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Column(
                        children: [
                          Text(
                            "No Internet Connectivity",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Pacifico',
                                fontWeight: FontWeight.w300,
                                fontSize: 20),
                          ),
                          SizedBox(height: size.height * 0.03),
                          Lottie.asset(
                            'assets/norecordsfound.json',
                            width: size.width * 0.80,
                            height: size.height * 0.20,
                          ),
                          SizedBox(height: size.height * 0.03),
                          Text(
                              "Please turn on your wifi or mobile data \n to view all plumbers",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w300, fontSize: 18)),
                          SizedBox(height: size.height * 0.05),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          /*
                    else if (dataList.isEmpty && loading == false)
                    return Text("No data foundsss");
                    */
          else
            return Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                ),
              ),
            );
        },
      ),
    ));
  }

  //card list design
  Widget cardUI(String? name, String? address, String? category,
      String? phoneNumber, String? photoURL) {
    return Container(
      margin: EdgeInsets.only(right: 20, left: 20, top: 20),
      decoration: BoxDecoration(
        border: Border.all(width: 0, color: Color(0xFFFFFFFF)),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.grey)],
        color: Color(0xFFFFFFFF),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 10, left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Colors.cyan,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          //display capital first letter of each word
                          capitalFirst(name!),
                          style: GoogleFonts.varelaRound(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.2,
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_pin,
                            color: Colors.cyan,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            capitalFirst(address!),
                            style: GoogleFonts.varelaRound(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.category,
                          color: Colors.cyan,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          capitalFirst(category!),
                          style: GoogleFonts.varelaRound(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.cyan,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        )),
                    child: Icon(Icons.info, size: 20),
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: Container(
              transform: Matrix4.translationValues(20.0, 25.0, 0.0),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.cyan,
                child: ClipOval(
                  child: Image.network(
                    photoURL!,
                    width: MediaQuery.of(context).size.width / 5.9,
                    height: MediaQuery.of(context).size.height / 5.8,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
