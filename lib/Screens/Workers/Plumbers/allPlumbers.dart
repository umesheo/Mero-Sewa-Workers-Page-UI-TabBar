import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  //search text field folded
  bool _searchFolded = true;
  //search field is empty
  bool searching = false;
  //assign search textfield value
  var searchText = "";

  @override
  void initState() {
    //instantly close the keyboard once the page is loaded
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.initState();

    //_scrollController = ScrollController(initialScrollOffset: 0.0);
    loadAllData();
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
        //print(connection);
      }
    } on SocketException catch (_) {
      print('not connected');
      setState(() {
        connection = false;
      });

      //print(connection);
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
    //if the user is not searching
    //return all plumbers data
    if (searching == false) {
      getInternetConnection();
      //creating a database reference
      DatabaseReference referenceData = FirebaseDatabase.instance.reference();

      //getting the data from database were address is
      //equals to users current location
      await referenceData
          .child("Workers")
          .orderByChild("NearbyLocation")
          .once()
          .then((DataSnapshot snapshot) {
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
    //else if the user is searching
    //only return the searched data
    else if (searching == true) {
      DatabaseReference searchRef =
          FirebaseDatabase.instance.reference().child("Workers");
      searchRef.once().then((DataSnapshot snapShot) {
        dataList.clear();
        var keys = snapShot.value.keys;
        var values = snapShot.value;

        for (var key in keys) {
          //if category is plumber
          if (values[key]["Category"] == "Plumber" ||
              values[key]["Category"] == "plumber") {
            Data data = new Data(
                capitalFirst(values[key]["Category"]),
                capitalFirst(values[key]["Name"]),
                capitalFirst(values[key]["Address"]),
                capitalFirst(values[key]["PhoneNumber"]),
                values[key]["URL"]);
            //since the values are exactly compared and is case sensitive
            //so if the the first letter of databaseAddress is capital and the first letter of search textfield is also capital the condition becomes true
            //and if the first letter of search text field is in small then convert the first letter to capital case, now the condition becomes true
            if (data.databaseAddress!.contains(searchText) ||
                data.databaseAddress!.contains(capitalFirst(searchText)) ||
                data.databaseName!.contains(searchText) ||
                data.databaseName!.contains(capitalFirst(searchText))) {
              dataList.add(data);
            }
          }
          Timer(Duration(seconds: 1), () {
            setState(() {});
          });
        }
      });
      return dataList;
    }
  }

  //capitalize first letter of each word.
  //For eg: hello world to Hello World
  String capitalFirst(String text) {
    if (text.length <= 1) {
      return text.toUpperCase();
    }

    // Split string into multiple words
    final List<String> words = text.split(' ');

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

  //lower case the first word of each. For eg: Hello World to hello world
  String smallFirst(String text) {
    if (text.length <= 1) {
      return text.toLowerCase();
    }

    // Split string into multiple words
    final List<String> words = text.split(' ');

    // Capitalize first letter of each words
    final capitalizedWords = words.map((word) {
      if (word.trim().isNotEmpty) {
        final String firstLetter = word.trim().substring(0, 1).toLowerCase();
        final String remainingLetters = word.trim().substring(1);

        return '$firstLetter$remainingLetters';
      }
      return '';
    });

    // Join/Merge all words back to one String
    return capitalizedWords.join(' ');
  }

  var currentFocus;

  unfocus() {
    currentFocus = FocusScope.of(context);
    //once the search field
    setState(() {
      searchText = "";
    });
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
      setState(() {
        _searchFolded = true;
      });
    }
  }

  FocusNode focusNode = new FocusNode();

  @override
  void dispose() {
    //_scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        unfocus();
      },
      child: Scaffold(
        body: Container(
          height: size.height,
          child: FutureBuilder(
            future: fetchAllData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData && loading == false)
                return ListView.builder(
                    //controller: _scrollController,
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: dataList.length,
                    //reverse: true,
                    itemBuilder: (_, index) {
                      return GestureDetector(
                          onTap: () {
                            unfocus();
                            //navigate to Plumber Details page with the all data
                            Navigator.of(context).push(_createRoute(
                                PlumberDetails(
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
              else if (snapshot.hasError &&
                  connection == true &&
                  loading == false)
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
                                      fontWeight: FontWeight.w300,
                                      fontSize: 18)),
                              SizedBox(height: size.height * 0.05),
                              //Display a reload button
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await getInternetConnection();

                                    if (connection == true) {
                                      loadAllData();
                                      fetchAllData();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: Color(
                                        0xFFF44336), //Colors.greenAccent.shade400,
                                    //kPrimaryColor,
                                    elevation: 2,
                                    side: BorderSide(
                                        color: Colors.white, width: 1),
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
                                      fontWeight: FontWeight.w300,
                                      fontSize: 18)),
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
        ),
        //setting the search button position
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        //creating an animated search button
        floatingActionButton: AnimatedContainer(
          duration: Duration(milliseconds: 250),
          height: 60,
          //setting the width of the search button
          width: _searchFolded ? 56 : size.width * 0.80,
          decoration: _searchFolded
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: kElevationToShadow[6],
                  // circular shape
                  gradient: LinearGradient(
                    colors: [
                      kPrimaryColor,
                      kPrimarySecondColor,
                    ],
                  ))
              : BoxDecoration(
                  boxShadow: kElevationToShadow[6],
                  borderRadius: BorderRadius.circular(32),
                  color: Colors.white),

          child: Row(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(
                    0), //const EdgeInsets.only(left: 16.0, top: 8, bottom: 8),
                child: Container(
                    //color: Colors.transparent,
                    padding: EdgeInsets.only(left: 20),
                    child: !_searchFolded
                        ? TextField(
                            style: GoogleFonts.varelaRound(
                                color: kPrimarySecondColor),
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              hintText: 'Search for Name or Location',
                              hintStyle: GoogleFonts.varelaRound(
                                  color: kPrimarySecondColor),
                              border: InputBorder.none,
                            ),
                            //checking for textfield changes
                            onChanged: (text) {
                              //if search textfield text is not empty
                              if (text != "") {
                                //set searching equals to true
                                //and set the textfield text to seachText variable
                                setState(() {
                                  searching = true;
                                  searchText = text;
                                });
                              }
                              //else if search text field is empty
                              else {
                                //set searching equals to false

                                setState(() {
                                  searching = false;
                                });
                              }
                              //print("------searching-------$searching");
                            },
                          )
                        : null),
              )),
              AnimatedContainer(
                duration: Duration(milliseconds: 400),
                child: Material(
                  //hiding the auto grey splash
                  type: MaterialType.transparency,
                  child: InkWell(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(_searchFolded ? 32 : 0),
                        topRight: Radius.circular(32),
                        bottomLeft: Radius.circular(_searchFolded ? 32 : 0),
                        bottomRight: Radius.circular(32),
                      ),
                      child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: _searchFolded
                              ? Icon(
                                  Icons.search,
                                  color: Color(0xFFFFFFFF),
                                )
                              : Icon(
                                  Icons.close,
                                  color: kBlackColor,
                                )),
                      //search button on tap
                      onTap: () async {
                        FocusScope.of(context).requestFocus(focusNode);
                        await getInternetConnection();
                        if (connection == true) {
                          setState(() {
                            _searchFolded = !_searchFolded;
                          });
                          //if the user closes the search text field
                          //se the searchText to empty
                          //so that all of the data can be displayed again
                          if (_searchFolded) {
                            setState(() {
                              searchText = "";
                            });
                          }
                        } else {
                          print("No internet");
                          //display error
                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                duration: const Duration(milliseconds: 1500),
                                backgroundColor: Colors.redAccent,
                                content: Text("No Internet Connectivity",
                                    style: TextStyle(
                                        fontSize: 16.0, color: Colors.white),
                                    textAlign: TextAlign.center),
                                shape: StadiumBorder(),
                                behavior: SnackBarBehavior.floating,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(vertical: 20),
                              ),
                            );
                        }
                      }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
