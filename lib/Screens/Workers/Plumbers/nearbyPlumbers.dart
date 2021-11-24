import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:merosewa_app/Screens/Workers/Plumbers/plumberDetails.dart';
import 'package:merosewa_app/Screens/Workers/data.dart';
import 'package:merosewa_app/constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

//class to display plumber lists
class NearbyPlumbersLists extends StatefulWidget {
  const NearbyPlumbersLists({
    Key? key,
  }) : super(key: key);

  @override
  _NearbyPlumbersListState createState() => _NearbyPlumbersListState();
}

class _NearbyPlumbersListState extends State<NearbyPlumbersLists> {
  Position? currentPosition;
  bool loading = true;
  //to store latitude and longitude
  String location = "";
  //to store the data of the provided index of the desired location lists
  List<Placemark>? placemark;
  //to store the text location to string format
  String address = "";

  List<Data> dataList = [];
  bool dataExists = false;

  bool serviceEnabled = false;
  late LocationPermission permission;

  late Geolocator geoLocator;
  bool permissionError = false;
  bool connection = false;
  //search text field folded
  bool _searchFolded = true;
  //search field is empty
  bool searching = false;
  //assign search textfield value
  var searchText = "";

  //Location currentLocation =  Location();
  @override
  void initState() {
    //instantly close the keyboard once the page is loaded
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    asyncMethods();

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

  void asyncMethods() async {
    //get the current position of user
    await getPosition();
    //check for location permissions
    await _determinePermissions();
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
/*
  void locationPosition() async {
    Position positions = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    LatLng latLatPosition = LatLng(positions.latitude, positions.longitude);
    String addressGoogle =
        await AssistantMethods.searchCoordinateAddress(positions);
    print("Address from Google API: $addressGoogle");
  }
  */

  //get the current position of user
  //in address format
  Future<void> getPosition() async {
    try {
      //getting the users current position based on accuracy
      await Geolocator.getCurrentPosition().then((Position position) {
        //setting the current position of
        //the user to current position variable
        currentPosition = position;
        //listening for changes
        Geolocator.getPositionStream(
          desiredAccuracy: LocationAccuracy.high,
        ) //distanceFilter: 4)
            .listen((Position position) {
          //updated location of the current location
          currentPosition = position;
          //storing latitude and longitude to location variable
          //for testing only
          location =
              "Lat: ${currentPosition!.latitude}, Long: ${currentPosition!.longitude}";
        });
      });

      //getting the address from latitude and longitude
      //by passing the latitude and longitude to the constructor of placemarkFromCoordinates(latitude, longitude)
      //and storing to placemark variable
      placemark = await placemarkFromCoordinates(
        currentPosition!.latitude,
        currentPosition!.longitude,
      );
      //print(placemark);

      //fetchin the data of the first part from the
      //placemaker's list of location data
      Placemark place = placemark![1];

      //getting the specific location of the user
      //and storing to address variable
      setState(() {
        address = "${place.subLocality}";
      });

      //print(address);
      fetchData();
    } finally {
      setState(() {
        loading = false;
      });
    }

    //print(
    //  "Position: ---------------Longitude:${currentPosition!.longitude} && Latitude: ${currentPosition!.latitude}");
  }

  /// Determine whether the location services and permissions are enabled
  Future _determinePermissions() async {
    setState(() {
      loading = true;
    });
    try {
      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();

      //if location service is not enable
      if (!serviceEnabled) {
        //await Geolocator.openLocationSettings();
        return Future.error('Location services are disabled.');
      } else {
        //ask the user to grant access to their location
        permission = await Geolocator.checkPermission();
        //if permission is denied
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            // Permissions are denied, next time you could try
            // requesting permissions again (this is also where
            // Android's shouldShowRequestPermissionRationale
            // returned true and display an explanatory UI
            return Future.error('Location permissions are denied');
          }
        }

        if (permission == LocationPermission.deniedForever) {
          // Permissions are denied forever, handle appropriately.
          return Future.error(
              'Location permissions are permanently denied, we cannot request permissions.');
        }
        //if location permission is accepted
        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever) {
          return getPosition();
        }
      }
    } finally {}
  }

  //fetching workers from users current location
  //and according to the category
  Future fetchData() async {
    //if the user is not searching
    //return nearby plumbers data
    if (searching == false) {
      getInternetConnection();
      //await getInternetConnection();

      //creating a database reference
      DatabaseReference referenceData = FirebaseDatabase.instance.reference();

      //getting the data from database were address is
      //equals to users current location
      await referenceData
          .child("Workers")
          .orderByChild("NearbyLocation") //remove order by child
          //and order by to display all workers
          .once()
          .then((DataSnapshot snapshot) {
        //clear the previous stored datalist
        dataList.clear();

        //getting the keys (index) and values from snapshot
        var keys = snapshot.value.keys;
        var values = snapshot.value;

        for (var key in keys) {
          //since firebase database is case sensitive
          //and geocoder only returns data first word capital. For eg. Kusunti
          //compare the database nearbylocation to address
          //and return the data even if the location is saved on small case in database (kusunti)
          if (values[key]["NearbyLocation"] == address ||
              values[key]["NearbyLocation"] == smallFirst(address)) {
            //if category is plumber
            if (values[key]["Category"] == "Plumber" ||
                values[key]["Category"] == "plumber") {
              //fetch all data of the plumbers from database
              //who are nearby the current location of the user
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
        }
        //print("Snapshot Value${snapshot.value}");
        print(dataList[0].databaseAddress);
      });

      //return the data list
      return dataList;
    }
    //else if the user is searching
    //only return the searched data
    //from defined category
    else if (searching == true) {
      DatabaseReference searchRef =
          FirebaseDatabase.instance.reference().child("Workers");
      searchRef.once().then((DataSnapshot snapShot) {
        dataList.clear();
        var keys = snapShot.value.keys;
        var values = snapShot.value;

        for (var key in keys) {
          Data data = new Data(
              capitalFirst(values[key]["Category"]),
              capitalFirst(values[key]["Name"]),
              capitalFirst(values[key]["Address"]),
              capitalFirst(values[key]["PhoneNumber"]),
              values[key]["URL"]);
          //since firebase database is case sensitive
          //and geocoder only returns data first word capital. For eg. Kusunti
          //compare the database nearbylocation to address
          //and return the data even if the location is saved on small case in database (kusunti)
          if (values[key]["NearbyLocation"] == address ||
              values[key]["NearbyLocation"] == smallFirst(address)) {
            //if category is plumber
            if (values[key]["Category"] == "Plumber" ||
                values[key]["Category"] == "plumber") {
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
        }
      });
      return dataList;
    }
  }

  //capitalize first word of each. For eg: hello world to Hello World
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
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        unfocus();
      },
      child: Scaffold(
        body: Container(
          child: FutureBuilder(
            future: fetchData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData && loading == false)
                return ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: dataList.length,
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
              //else is internet connection is available
              //address is not empty and loading is false
              //but nearby workers are not found
              else if (connection == true &&
                  snapshot.hasError &&
                  address != "" &&
                  loading == false)
                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //if address is not empty
                        //but no plumber was found nearby the location
                        Container(
                          child: Column(
                            children: [
                              Text(
                                "No plumbers found nearby",
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
                                  "We're sorry to inform you that \n  no plumbers were found nearby \n $address",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 18)),
                              SizedBox(height: size.height * 0.05),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                    "Please go to All Plumbers page to \n view the plumbers available in \n other locations ",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 16)),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              //else if internet connection is available
              //but location is disabled and loading is false
              //display location turned off
              else if (connection == true &&
                  !serviceEnabled &&
                  loading == false)

                //display a message
                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            child: Column(
                          children: [
                            Text(
                              "Your location might be turned off",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Pacifico',
                                  fontWeight: FontWeight.w300,
                                  fontSize: 20),
                            ),
                            SizedBox(height: size.height * 0.03),
                            Lottie.asset(
                              'assets/location.json',
                              width: size.width * 0.80,
                              height: size.height * 0.20,
                            ),

                            SizedBox(height: size.height * 0.03),
                            Text(
                                "We require you to turn your device \n location on to view the plumbers nearby",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w300, fontSize: 18)),

                            SizedBox(height: size.height * 0.05),
                            //Display a try again button
                            //until the user turns on the location
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: ElevatedButton(
                                onPressed: () async {
                                  await getInternetConnection();
                                  if (connection == true) {
                                    _determinePermissions();
                                    //get the current position of user
                                    getPosition();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Color(
                                      0xFFF44336), //Colors.greenAccent.shade400,
                                  //kPrimaryColor,
                                  elevation: 2,
                                  side:
                                      BorderSide(color: Colors.white, width: 1),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 30,
                                  ),

                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(
                                  "TRY AGAIN",
                                  style: TextStyle(
                                      fontSize: 14,
                                      letterSpacing: 2.2,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                  ),
                );
              //else if location is enabled
              //and internet connection is also available
              //but for some reason the address is returned empty
              else if (connection == true &&
                  serviceEnabled &&
                  address == "" &&
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
                              Text("Could not fetch the current location",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 18)),
                              Text(
                                  "Please check your Internet Connection \n and make sure to turn on the \n device location",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 18)),
                              Text(
                                  "Or please ensure that you have a strong \n wifi network access",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 16)),
                              SizedBox(height: size.height * 0.05),
                              //Display a reload button
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await getInternetConnection();

                                    if (connection == true) {
                                      //check the location permissions
                                      _determinePermissions();
                                      //get the current position of user
                                      getPosition();
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
                                  "Please turn on your wifi or mobile data \n to view nearby plumbers",
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
