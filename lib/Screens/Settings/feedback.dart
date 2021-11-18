import 'dart:convert';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:merosewa_app/Authentication/Auto%20Login/shared_pref_helper.dart';
import 'package:merosewa_app/constants.dart';
import 'package:merosewa_app/Screens/Login/components/body.dart';

class FeedBack extends StatefulWidget {
  FeedBack({Key? key}) : super(key: key);

  @override
  FeedbackState createState() => FeedbackState();
}

class FeedbackState extends State<FeedBack> {
  final controllerTo = TextEditingController();
  final controllerSubject = TextEditingController();
  final controllerMessage = TextEditingController();
  final controllerEmail = TextEditingController();
  FocusNode focusNode = new FocusNode();

  late String name = "";
  late String email = "";
  late String message = "";
  late String subject = "";
  late String? username = "";
  late String? emails = "";
  bool isLoading = false;
  var currentFocus;
  bool connection = false;

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  fetchData() async {
    username = await SharedPreferencesHelper().getUsername();
    emails = await SharedPreferencesHelper().getEmail();
  }

  Future getInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          connection = true;
        });

        print(connection);
      }
    } on SocketException catch (_) {
      print('not connected');
      setState(() {
        connection = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          //duration: const Duration(seconds: 1),
          backgroundColor: Colors.redAccent,
          content: Text(
            "No Internet Connectivity",
            style: TextStyle(fontSize: 16.0, color: Colors.white),
          ),
        ),
      );

      print(connection);
    }
  }

  Future sendEmail({
    required String? name,
    required String? email,
    required String subject,
    required String message,
  }) async {
    setState(() {
      isLoading = true;
    });
    final serviceId = 'service_mk9fgrv';
    final templateId = 'template_lpw6zh9';
    final userId = 'user_nwrjR5ijiULgq2cHto0Uy';
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http
        .post(url,
            headers: {
              'origin': 'http://localhost',
              'Content-Type': 'application/json'
            },
            body: json.encode({
              'service_id': serviceId,
              'template_id': templateId,
              'user_id': userId,
              'template_params': {
                'user_name': username,
                'user_email': emails,
                'user_subject': subject,
                'user_message': message
              }
            }))
        .then((value) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: kPrimaryColor,
            content: Text("Thank you for your valuable feedback",
                style: TextStyle(fontSize: 16.0, color: Colors.white),
                textAlign: TextAlign.center),
            shape: StadiumBorder(),
            behavior: SnackBarBehavior.floating,
            elevation: 0,
            padding: EdgeInsets.symmetric(vertical: 20),
            duration: Duration(milliseconds: 2000),
          ),
        );

      Navigator.of(context).pop();

      setState(() {
        isLoading = false;
      });
    });

    print(response.body);
    print("Name $name");
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
            title: Text("Feedback", style: TextStyle(color: kBlackColor)),
            leading: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Colors
                      .black //Colors.greenAccent.shade400 //kPrimaryColor ,
                  ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  //buildTextField(title: 'To', controller: controllerTo),
                  //const SizedBox(height: 16),
                  //buildTextField(title: 'Email', controller: controllerEmail),
                  //const SizedBox(height: 16),
                  //buildTextField(title: 'Subject', controller: controllerSubject),
                  //const SizedBox(height: 16),
                  buildTextField(
                      //title: 'Please write your feedback...',
                      placeHolder: 'Please write your feedback...',
                      controller: controllerMessage,
                      maxLines: 6),
                  const SizedBox(height: 32),

                  if (!isLoading)
                    ElevatedButton(
                      onPressed: () async {
                        FocusScope.of(context).requestFocus(focusNode);

                        setState(() {
                          message = controllerMessage.text;
                        });
                        try {
                          final result =
                              await InternetAddress.lookup('example.com');
                          if (result.isNotEmpty &&
                              result[0].rawAddress.isNotEmpty) {
                            setState(() {
                              connection = true;
                            });
                            if (controllerMessage.text.isEmpty) {
                              ScaffoldMessenger.of(context)
                                ..removeCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.redAccent,
                                    content: Text(
                                        "The field cannot be left empty!!",
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.white),
                                        textAlign: TextAlign.center),
                                    shape: StadiumBorder(),
                                    behavior: SnackBarBehavior.floating,
                                    elevation: 0,
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                  ),
                                );
                            } else {
                              sendEmail(
                                  name: username,
                                  email: emails,
                                  subject: 'User Feedback',
                                  message: message);

                              print("ayo hai yo$username");
                              print("ayo hai yo$emails");
                              print(subject);
                            }
                            print(connection);
                          }
                        } on SocketException catch (_) {
                          print('not connected');
                          setState(() {
                            connection = false;
                          });

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

                          print(connection);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        primary:
                            kPrimarySecondColor, //Colors.greenAccent.shade400,
                        onPrimary: Colors.greenAccent.shade400, //kPrimaryColor,
                        elevation: 2,
                        side: BorderSide(color: Colors.white, width: 1),
                        padding: EdgeInsets.symmetric(
                          horizontal: 50,
                        ),

                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        "Send",
                        style: TextStyle(
                            fontSize: 17,
                            letterSpacing: 2.2,
                            color: Colors.white),
                      ),
                    ),
                  if (isLoading)
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(kPrimaryColor),
                        ),
                      ),
                    ),
                ],
              ))),
    );
  }

  Widget buildTextField({
    //required String title,
    required String placeHolder,
    required TextEditingController controller,
    int maxLines = 1,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*
          Text(
           // title,
            //style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          */
          SizedBox(height: 5),
          TextField(
            controller: controller,
            maxLines: maxLines,
            cursorColor: kPrimaryColor,
            decoration: InputDecoration(
                enabledBorder: const OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: kPrimaryColor, width: 1.0),
                ),
                border: OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: kPrimarySecondColor, width: 1.0),
                ),
                hintText: placeHolder,
                hintStyle: TextStyle(
                  fontSize: 15,
                )),
          )
        ],
      );
}
