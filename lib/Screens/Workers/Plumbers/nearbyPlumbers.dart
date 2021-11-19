import 'package:flutter/material.dart';
import 'dart:io';
import 'package:merosewa_app/Screens/Workers/Plumbers/plumberDetails.dart';
import 'package:merosewa_app/Screens/Workers/data.dart';
import 'package:merosewa_app/constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';

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
  //Location currentLocation =  Location();
  @override
  void initState() {
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

      /*
      //getting the current position of the user
      //and setting it to currentPosition variable
      //first check if permission is given then only display data
      await _determinePermissions().then((Position position) {
        setState(() {
          currentPosition = position;
          location =
              "Lat: ${currentPosition!.latitude}, Long: ${currentPosition!.longitude}";
        });
      });
      */

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
      await fetchData();
    } finally {
      setState(() {
        loading = false;
      });
    }

    print(
        "Position: ---------------Longitude:${currentPosition!.longitude} && Latitude: ${currentPosition!.latitude}");
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
    getInternetConnection();
    //await getInternetConnection();

    //creating a database reference
    DatabaseReference referenceData = FirebaseDatabase.instance.reference();

    //getting the data from database were address is
    //equals to users current location
    await referenceData
        .child("Workers")
        .orderByChild("NearbyLocation") //remove order by child
        .equalTo(address) //and order by to display all workers
        .once()
        .then((DataSnapshot snapshot) {
      //clear the previous stored datalist
      dataList.clear();

      //getting the keys (index) and values from snapshot
      var keys = snapshot.value.keys;
      var values = snapshot.value;

      for (var key in keys) {
        //if category is plumber
        if (values[key]["Category"] == "Plumber") {
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
      //print("Snapshot Value${snapshot.value}");
      print(dataList[0].databaseAddress);
    });

    //return the data list
    return dataList;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
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
          //else is internet connection is available
          //address is not empty and loading is false
          //but nearby workers are not found
          else if (connection == true &&
              snapshot.hasError &&
              address != "" &&
              loading == false)
            return Center(
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
                                fontWeight: FontWeight.w300, fontSize: 18)),
                        SizedBox(height: size.height * 0.05),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Text(
                              "Please go to All Plumbers page to \n view the plumbers available in \n other locations ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w300, fontSize: 16)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          //else if internet connection is available
          //but location is disabled and loading is false
          //display location turned off
          else if (connection == true && !serviceEnabled && loading == false)

            //display a message
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      child: Column(
                    children: [
                      Text(
                        "Your location maybe turned off",
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
                            side: BorderSide(color: Colors.white, width: 1),
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
            );
          //else if location is enabled
          //and internet connection is also available
          //but for some reason the address is returned empty
          else if (connection == true &&
              serviceEnabled &&
              address == "" &&
              loading == false)
            return Center(
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
                        Text(
                            "Please check your Internet Connection \n and make sure to turn on the \n device location",
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
            ); /*
              else if (dataList.isEmpty && loading == false)
              return Text("No data foundsss");
              */
          //else is internet connection is not available
          else if (connection == false && loading == false)
            return Center(
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
                                fontWeight: FontWeight.w300, fontSize: 18)),
                        SizedBox(height: size.height * 0.05),
                      ],
                    ),
                  ),
                ],
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
                          name!,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 25,
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
                          Text(
                            address!,
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.normal),
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
                        Text(
                          category!,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w400),
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
