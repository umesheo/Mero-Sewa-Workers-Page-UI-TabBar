import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:merosewa_app/Screens/Workers/Plumbers/allPlumbers.dart';
import 'package:merosewa_app/Screens/Workers/Plumbers/nearbyPlumbers.dart';
import 'package:merosewa_app/constants.dart';

class TabBarPage extends StatefulWidget {
  const TabBarPage({Key? key}) : super(key: key);

  @override
  _TabBarPageState createState() => _TabBarPageState();
}

class _TabBarPageState extends State<TabBarPage>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  late ScrollController scrollController;
  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
    scrollController = ScrollController(initialScrollOffset: 0.0);
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
            controller: scrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                new SliverAppBar(
                  title: Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                                child: Text("Plumbers",
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
                      ],
                    ),
                  ),
                  backgroundColor: Color(0xFFFFFFFF),

                  toolbarHeight: 100,
                  /*
                  collapsedHeight:
                      80, //height:100 to display back button when collapsed //height:80 to hide back button when collapsed
                  expandedHeight: 180,
                  */
                  elevation: 0.3,
                  //pinned: true,
                  floating: true,
                  //snap: true,
                  forceElevated: innerBoxIsScrolled,
                ),
              ];
            },
            /*
          child: AppBar(
            backgroundColor: Color(0xFFFFFFFF),
            elevation: 0.3,
            //title: Text("Plumbers", style: TextStyle(color: kBlackColor)),
            bottom: TabBar(
              controller: controller,
              //isScrollable: true,
              padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              labelColor: Colors.black,
              indicator: BoxDecoration(
                  gradient:
                      LinearGradient(colors: [Colors.cyan, Colors.greenAccent]),
                  borderRadius: BorderRadius.circular(40),
                  color: Colors.redAccent),
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: "Nearby"),
                Tab(
                  text: "All",
                )
              ],
            ),
          ),
          */

            body: Column(
              children: [
                Container(
                  color: Color(0xFFFFFFFF),
                  child: TabBar(
                    controller: controller,
                    //isScrollable: true,
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      top: 10,
                    ),
                    labelColor: Colors.black,

                    indicator: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Colors.cyan, Colors.greenAccent]),
                        borderRadius: BorderRadius.circular(40),
                        color: Colors.redAccent),
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: "Nearby"),
                      Tab(
                        text: "All",
                      )
                    ],
                  ),
                ),
                /*
                Padding(
                  padding: const EdgeInsets.only(top: 0, right: 0, left: 0),
                  child: Container(
                    height: 60,
                    margin: EdgeInsets.symmetric(vertical: 10),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    width: size.width * 0.8,
                    child: TextFormField(
                      obscureText: true,
                      autofocus: false,
                      cursorColor: kPrimaryColor,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        icon: Icon(Icons.lock, color: kPrimarySecondColor),
                        border: InputBorder.none,
                        /*
                                    //show password eye icon
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        Icons.visibility,
                                      ),
                                      color: kPrimaryColor,
                                      onPressed: () {
                                        debugPrint("Pressed");
                                      },
                                    ),
                                    */
                        errorStyle:
                            TextStyle(color: Colors.redAccent, fontSize: 10),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please Enter Password';
                        }
                        return null;
                      },
                    ),
                    decoration: BoxDecoration(
                      color: kPrimaryLightColor,
                      borderRadius: BorderRadius.circular(29),
                      //border: Border.all(color: Colors.black, width: 1.5),
                    ),
                  ),
                ),
                */
                Expanded(
                  child: TabBarView(
                    controller: controller,
                    children: [NearbyPlumbersLists(), AllPlumbersList()],
                  ),
                ),
              ],
            )),
      ),
      /*
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.refresh, size: 32),
        onPressed: () {},
      ),
      */
    );
  }
}
