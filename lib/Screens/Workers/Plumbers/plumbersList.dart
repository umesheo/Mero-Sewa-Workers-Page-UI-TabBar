import 'package:flutter/material.dart';

import 'package:merosewa_app/Screens/Workers/Plumbers/plumberDetails.dart';
import 'package:merosewa_app/Screens/Workers/data.dart';
import 'package:merosewa_app/constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';

//class to display plumber lists
class PlumbersList extends StatefulWidget {
  const PlumbersList({Key? key}) : super(key: key);

  @override
  _PlumbersListState createState() => _PlumbersListState();
}

class _PlumbersListState extends State<PlumbersList>
    with TickerProviderStateMixin {
  TabController? _controller;
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

  int _currentTabIndex = 0;

  late Geolocator geoLocator;
  bool permissionError = false;
  //Location currentLocation =  Location();

  @override
  void initState() {
    //check for location permissions
    _determinePermissions();
    //get the current position of user
    getPosition();
    //locationPosition();

    //fetchData();
    super.initState();
    _controller = TabController(vsync: this, length: 2);
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
  _determinePermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

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
  fetchData() async {
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
    TabController _controller = TabController(vsync: this, length: 2);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFFFFFFF),
          elevation: 0.3,
          title: Text("Plumbers", style: TextStyle(color: kBlackColor)),
        ),
        body: Stack(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Row(
                  children: [
                    Container(
                        child: Text("Looking For",
                            style: TextStyle(
                                fontFamily: "Finger Paint",
                                color: kBlackColor,
                                fontSize: 23,
                                fontWeight: FontWeight.bold))),
                    SizedBox(width: 0),
                    Lottie.asset(
                      'assets/plumbers.json',
                      width: 150,
                      height: 80,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.1),
              child: Container(
                child: TabBar(
                  controller: _controller,
                  isScrollable: true,
                  padding: EdgeInsets.only(left: 20, right: 20),
                  labelColor: Colors.black,
                  indicator: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Colors.cyan, Colors.greenAccent]),
                      borderRadius: BorderRadius.circular(40),
                      color: Colors.redAccent),
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(text: "NearBy"),
                    Tab(
                      text: "All",
                    )
                  ],
                ),
              ),
            ),
            Container(
              child: TabBarView(
                controller: _controller,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 150.0),
                    child: Container(
                      child: FutureBuilder(
                        future: fetchData(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData && loading == false)
                            return ListView.builder(
                                physics: BouncingScrollPhysics(),
                                itemCount: dataList.length,
                                itemBuilder: (_, index) {
                                  return GestureDetector(
                                      onTap: () {
                                        //navigate to Plumber Details page with the all data
                                        Navigator.of(context).push(_createRoute(
                                            PlumberDetails(
                                                category: dataList[index]
                                                    .databaseCategory!,
                                                name: dataList[index]
                                                    .databaseName!,
                                                address: dataList[index]
                                                    .databaseAddress!,
                                                phoneNumber: dataList[index]
                                                    .phoneNumber!,
                                                photoURL: dataList[index]
                                                    .photoURL!)));
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
                          else if (snapshot.hasError && loading == false)
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //if address is empty
                                  //i.e if the location permission is denied
                                  //or location is off
                                  address == ""
                                      ?
                                      //display a message
                                      Container(
                                          child: Column(
                                          children: [
                                            Text(
                                              "Your location is turned off",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontFamily: 'Pacifico',
                                                  fontWeight: FontWeight.w300,
                                                  fontSize: 20),
                                            ),
                                            SizedBox(
                                                height: size.height * 0.03),
                                            Lottie.asset(
                                              'assets/location.json',
                                              width: size.width * 0.80,
                                              height: size.height * 0.20,
                                            ),

                                            SizedBox(
                                                height: size.height * 0.03),
                                            Text(
                                                "We require you to turn your location on \n to view the plumbers nearby",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize: 18)),
                                            SizedBox(
                                                height: size.height * 0.05),
                                            //Display a try again button
                                            //until the user turns on the location
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  _determinePermissions();
                                                  //get the current position of user
                                                  getPosition();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  primary: Color(
                                                      0xFFF44336), //Colors.greenAccent.shade400,
                                                  //kPrimaryColor,
                                                  elevation: 2,
                                                  side: BorderSide(
                                                      color: Colors.white,
                                                      width: 1),
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 30,
                                                  ),

                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
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
                                        ))
                                      //else if location is on and no workers is found nearby the location
                                      : Container(
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
                                              SizedBox(
                                                  height: size.height * 0.03),
                                              Lottie.asset(
                                                'assets/norecordsfound.json',
                                                width: size.width * 0.80,
                                                height: size.height * 0.20,
                                              ),
                                              SizedBox(
                                                  height: size.height * 0.03),
                                              Text(
                                                  "We're sorry to inform you that \n  no plumbers were found nearby \n $address",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      fontSize: 18)),
                                              SizedBox(
                                                  height: size.height * 0.05),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Text(
                                                    "Please go to All Plumbers page to \n view all the plumbers available in \n other locations ",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 16)),
                                              ),
                                            ],
                                          ),
                                        )
                                  /*
                      Text(
                          "Longitude:${currentPosition!.longitude} Latitude: ${currentPosition!.latitude}")*/
                                  //print entire location data
                                  //Text(placemark.toString())
                                ],
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      kPrimaryColor),
                                ),
                              ),
                            );
                        },
                      ),
                    ),
                  ),
                  AllWorker()
                ],
              ),
            ),
          ],
        ));
  }

  //card list design
  Widget cardUI(String? name, String? address, String? category,
      String? phoneNumber, String? photoURL) {
    return Container(
      margin: EdgeInsets.only(right: 20, left: 20, top: 25),
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

class AllWorker extends StatefulWidget {
  AllWorker({Key? key}) : super(key: key);

  @override
  _AllWorkerState createState() => _AllWorkerState();
}

class _AllWorkerState extends State<AllWorker> {
  List<Data> dataList = [];
  bool dataExists = false;
  @override
  void initState() {
    //check for location permissions

    //locationPosition();
    fetchDataAll();
    //fetchData();
    super.initState();
  }

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

  fetchDataAll() async {
    //creating a database reference
    DatabaseReference referenceData = FirebaseDatabase.instance.reference();

    //getting the data from database were address is
    //equals to users current location
    await referenceData
        .child("Workers")
        //and order by to display all workers
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
    return Padding(
      padding: const EdgeInsets.only(top: 150.0),
      child: Container(
        child: FutureBuilder(
          future: fetchDataAll(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData)
              return ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: dataList.length,
                  itemBuilder: (_, index) {
                    return GestureDetector(
                        onTap: () {
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
            else if (snapshot.hasError)
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //if address is empty
                    //i.e if the location permission is denied
                    //or location is off

                    //display a message

                    //else if location is on and no workers is found nearby the location
                    Container(
                      child: Column(
                        children: [
                          Text(
                            "No plumbers found.",
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
                              "We're sorry to inform you that \n at this moment we don't have any plumbers.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.w300, fontSize: 18)),
                          SizedBox(height: size.height * 0.05),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Text("Please visit after a while. ",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.w300, fontSize: 16)),
                          ),
                        ],
                      ),
                    )
                    /*
                      Text(
                          "Longitude:${currentPosition!.longitude} Latitude: ${currentPosition!.latitude}")*/
                    //print entire location data
                    //Text(placemark.toString())
                  ],
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
    );
  }

  Widget cardUI(String? name, String? address, String? category,
      String? phoneNumber, String? photoURL) {
    return Container(
      margin: EdgeInsets.only(right: 20, left: 20, top: 25),
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
