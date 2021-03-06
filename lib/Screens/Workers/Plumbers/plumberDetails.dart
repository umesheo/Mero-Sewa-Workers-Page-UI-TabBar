import 'package:flutter/material.dart';
import 'package:merosewa_app/constants.dart';

//class to display the plumber details
class PlumberDetails extends StatefulWidget {
  //creating a constructor to receive worker's details from plumbersList page
  const PlumberDetails({
    Key? key,
    required this.category,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.photoURL,
  }) : super(key: key);

  final String category;
  final String name;
  final String address;
  final String phoneNumber;
  final String photoURL;

  //passing the worker's details to _PlumberDetailsState constructor
  @override
  _PlumberDetailsState createState() =>
      _PlumberDetailsState(category, name, address, phoneNumber, photoURL);
}

class _PlumberDetailsState extends State<PlumberDetails> {
  final String category;
  var currentFocus;
  final String name;
  final String address;
  final String phoneNumber;
  final String photoURL;

  //Accessing the worker's details from PlumberDetails constructor
  //and storing to uid variable
  _PlumberDetailsState(
      this.category, this.name, this.address, this.phoneNumber, this.photoURL);

  unfocus() {
    currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          unfocus();
        },
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFFFFFFFF),
              elevation: 0.3,
              title: Text(name, style: TextStyle(color: kBlackColor)),
            ),
            body: Center(
              child: Container(
                  child: Column(
                children: [
                  Text("$category"),
                  Text("$name"),
                  Text("$address"),
                  Text("$phoneNumber"),
                  Text("$photoURL"),
                ],
              )),
            )));
  }
}
