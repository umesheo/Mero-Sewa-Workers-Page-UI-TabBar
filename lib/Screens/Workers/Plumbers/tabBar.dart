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
  ScrollController scrollController = new ScrollController();
  bool top = true;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);

    scrollController = ScrollController(initialScrollOffset: 0.0);
  }

  void _scrollToTop() {
    //_scrollController.jumpTo(_scrollController.position.maxScrollExtent, );
    scrollController.animateTo(scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 700),
        curve: Curves.fastOutSlowIn); //Curves.fastLinearToSlowEaseIn);
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
                    padding: const EdgeInsets.only(left: 0),
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
                  elevation: 0.0,
                  //pinned: true,
                  //floating: true,
                  //snap: true,
                  forceElevated: innerBoxIsScrolled,
                ),
              ];
            },
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
                    ),
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: "Nearby"),
                      Tab(
                        text: "All",
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: controller,

                    //physics: NeverScrollableScrollPhysics(),
                    children: [NearbyPlumbersLists(), AllPlumbersList()],
                  ),
                ),
              ],
            )),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _scrollToTop();
        },
        child: Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              // circular shape
              shape: BoxShape.circle,

              gradient: LinearGradient(
                colors: [
                  kPrimaryColor,
                  kPrimarySecondColor,
                ],
              ),
            ),
            child: Icon(Icons.arrow_upward, color: Color(0xFFFFFFFF))),
      ),
    );
  }
}
