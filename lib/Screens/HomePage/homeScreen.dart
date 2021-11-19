import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merosewa_app/Screens/HomePage/categories_tile.dart';
import 'package:merosewa_app/Screens/HomePage/workers_tile.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:merosewa_app/Screens/Profile/profile.dart';
import 'package:merosewa_app/Screens/Workers/Plumbers/tabBar.dart';
import 'package:merosewa_app/constants.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lottie/lottie.dart';

//class to display home screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  int _dataLength = 1;
  bool isLoading = false;
  bool connection = false;
  Timer? timer;
  var currentFocus;

  @override
  void initState() {
    //getting the internet connection in every 1 second

    getInternetConnection();

    //getting the slider images from db
    //as soon as the application loads
    getSliderImageFromDb();

    super.initState();
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

  //fetching the slider images from database
  Future getSliderImageFromDb() async {
    await getInternetConnection();
    var _fireStore = FirebaseFirestore.instance;
    //setting the initial loading state to true
    setState(() {
      isLoading = true;
    });

    //fetching ad slider images from database
    Future.delayed(const Duration(seconds: 2), () {});

    QuerySnapshot snapshot = await _fireStore.collection('adSlider').get();

    if (mounted) {
      setState(() {
        //setting the data length to the total number of database documents
        _dataLength = snapshot.docs.length;
      });
    }

    //setting the loading to false
    //after images has been fetched
    setState(() {
      isLoading = false;
    });

    //returning the fetched images
    return snapshot.docs;
  }

  //app bar top right search icon
  List<Widget> _buildActions() => <Widget>[
        //App bar Search and cart icon
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {},
          color: Colors.grey,
          tooltip: 'Search',
        ),
      ];

  unfocus() {
    currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
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
        /*
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
        */
        return Align(
          child: SizeTransition(sizeFactor: animation, child: child),
        );
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
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
        appBar: AppBar(
          backgroundColor: Color(0xFFFFFFFF),
          elevation: 0.3,
          title: Row(
            children: [
              Image.asset(
                'assets/images/Logo.png',
                width: 50,
                height: 50,
              ),
              SizedBox(width: 0),
              Text("ero Sewa",
                  style: TextStyle(
                      fontFamily: "Pacifico",
                      color: kBlackColor,
                      fontSize: 25)),
            ],
          ),
          /*
          Menu Icon: If needed in future
          leading: IconButton(
            icon: Icon(FontAwesomeIcons.gripLines),
            onPressed: () {},
            color: Colors.grey,
            tooltip: 'Menu',
          ),
          */
          //app bar top right icon
          actions: _buildActions(),
        ),
        body: SingleChildScrollView(
          child: Container(
            //Colors.grey.shade100,
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 0, bottom: 20),
                  //color: Colors.grey.shade300, //Color(0xffffffff),
                  child: Column(
                    children: [
                      //if the data exists
                      if (_dataLength != 0)
                        FutureBuilder(
                          //calling the getSliderImageFromDb function
                          future: getSliderImageFromDb(),
                          builder: (context, AsyncSnapshot snapShot) {
                            //if the snapshot data is not null
                            //and the internet connectivity is available
                            if (snapShot.data != null && connection == true)
                              //return the images
                              return Container(
                                child: CarouselSlider.builder(
                                    itemCount: snapShot.data!.length,
                                    itemBuilder:
                                        (BuildContext context, int index, int) {
                                      //getting the image from snapshot and storing the images in a Map format
                                      DocumentSnapshot sliderImage =
                                          snapShot.data[index];
                                      Map getImage = sliderImage.data() as Map;
                                      //decorating the slider images
                                      return Container(
                                        margin: EdgeInsets.only(top: 20),
                                        padding: EdgeInsets.only(
                                          top: 20,
                                        ),
                                        //decoration for slider images top color
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: Offset(0,
                                                  0), // changes position of shadow
                                            ),
                                          ],
                                          color: kPrimaryColor,
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(20),
                                            bottomLeft: Radius.circular(20),
                                          ),
                                        ),
                                        //displaying the image
                                        child: ClipRRect(
                                          //borderRadius:
                                          //BorderRadius.circular(8),
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Image.network(
                                              getImage['image'],
                                              fit: BoxFit.fill,
                                              width: double.infinity,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    //designing the image height, ratio and updating the index
                                    //to the current index
                                    options: CarouselOptions(
                                        //viewportFraction: 1, //uncomment for full screen
                                        initialPage: 0,
                                        autoPlay: true,
                                        aspectRatio: 2.0,
                                        height: 190,
                                        enlargeCenterPage: true,
                                        onPageChanged:
                                            (int i, carouselPageChangedReason) {
                                          setState(() {
                                            _index = i;
                                          });
                                        })),
                              );

                            //by default returning the shimmer loading effect
                            return Shimmer.fromColors(
                                child: Container(
                                    height: 190,
                                    width: MediaQuery.of(context).size.width,
                                    color: Colors.grey.shade300),
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100);
                          },
                        ),
                      SizedBox(height: 10),
                      //displaying and styling the image dots indicator
                      if (_dataLength != 0)
                        DotsIndicator(
                          dotsCount: _dataLength,
                          position: _index.toDouble(),
                          decorator: DotsDecorator(
                              size: const Size.square(5.0),
                              activeSize: const Size(18.0, 5.0),
                              activeShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                              activeColor: Theme.of(context).primaryColor),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 0),
                //_buildCategories(),
                _buildWorkersCard()
              ],
            ),
          ),
        ),
      ),
    );
  }

  //categories section
  //future update: recommended workers section
  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Categories',
                  style: GoogleFonts.varelaRound(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _ExploreAllButton(
                  onTap: () {},
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          //to display the categories card
          _buildCategoriesList()
        ],
      ),
    );
  }

  //creating categories list
  //future: recommended workers list
  Widget _buildCategoriesList() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        //calling and assigning values to the CategoriesTile constructor
        //main design of categories card: CategoriesTile class
        CategoriesTile(
          assetPath: 'assets/images/bread.png',
          color: Color(0xffFCE8A8),
          title: 'Title',
        ),
        CategoriesTile(
          assetPath: 'assets/images/apple.png',
          color: Color(0xffDFECF8),
          title: 'Title',
        ),
        CategoriesTile(
          assetPath: 'assets/images/vegetable.png',
          color: Color(0xffE2F3C2),
          title: 'Title',
        ),
        CategoriesTile(
          assetPath: 'assets/images/milk.png',
          color: Color(0xffFFDBC5),
          title: 'Title',
        ),
      ],
    );
  }

  //hire workers section

  Widget _buildWorkersCard() {
    Size size = MediaQuery.of(context).size;
    return Container(
      child: Padding(
        //padding: const EdgeInsets.all(15.0),
        padding: EdgeInsets.only(top: 0, bottom: 20, right: 15, left: 15),
        child: Container(
          //color: kPrimaryColor,
          /*
          decoration: BoxDecoration(
            /*
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
            */
            color: kPrimaryColor,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
          ),
          */
          //Color(0xffffffff), //Colors.grey.shade100,  //Color(0xffffffff),
          child: Padding(
            padding: const EdgeInsets.only(
              top: 0,
              //bottom: 20,
              //right: 20,
              //left: 20,
              //right: 15,
              //left: 15,
              right: 10, left: 10,
            ),
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 100,
                    width: 400,
                    decoration: BoxDecoration(
                      color: Colors.cyan[300],
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 8.0,
                        left: 15,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Text("Indroducing",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 14)),
                                    Text("Mero Sewa",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text("Find your workers easily now!",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Lottie.asset(
                                  'assets/searching.json',
                                  width: 150,
                                  height: 90,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Hire Workers',
                          style: GoogleFonts.varelaRound(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        /*
                        //Explore all button
                        _ExploreAllButton(
                          onTap: () {},
                        ),
                        */
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //calling and assigning values to the WorkersTile constructor
                              //main design of categories card: WorkersTile class
                              GestureDetector(
                                child: Container(
                                  height: 130,
                                  //width: 160,
                                  width: 105,
                                  child: WorkersTile(
                                    assetPath: 'assets/images/Plumber.png',
                                    color:
                                        Color(0xffDFECF8), //Color(0xffffffff),
                                    //price: 'Some Text',
                                    title: 'Plumbers',
                                  ),
                                ),
                                onTap: () async {
                                  //check internet connection
                                  await getInternetConnection();
                                  //if internet connection is available
                                  if (connection == true) {
                                    Navigator.of(context)
                                        .push(_createRoute(TabBarPage()));
                                  }
                                  //else if internet connection is not available
                                  else if (connection == false) {
                                    //display error
                                    ScaffoldMessenger.of(context)
                                      ..removeCurrentSnackBar()
                                      ..showSnackBar(
                                        SnackBar(
                                          duration: const Duration(
                                              milliseconds: 1500),
                                          backgroundColor: Colors.redAccent,
                                          content: Text(
                                              "No Internet Connectivity",
                                              style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors.white),
                                              textAlign: TextAlign.center),
                                          shape: StadiumBorder(),
                                          behavior: SnackBarBehavior.floating,
                                          elevation: 0,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 20),
                                        ),
                                      );
                                  }
                                },
                              ),

                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  height: 130,
                                  //width: 160,
                                  width: 105,
                                  child: WorkersTile(
                                    color:
                                        Color(0xffDFECF8), // Color(0xffffffff),
                                    assetPath: 'assets/images/electrician.png',
                                    title: 'Electricians',
                                    //price: 'Some Text',
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  height: 130,
                                  //width: 160,
                                  width: 105,
                                  child: WorkersTile(
                                    color:
                                        Color(0xffDFECF8), //Color(0xffffffff),
                                    assetPath: 'assets/images/mechanic.png',
                                    title: 'Mechanics',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  height: 130,
                                  //width: 160,
                                  width: 105,
                                  child: WorkersTile(
                                    color:
                                        Color(0xffDFECF8), // Color(0xffffffff),
                                    assetPath: 'assets/images/painter.png',
                                    title: 'Painters',
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  height: 130,
                                  //width: 160,
                                  width: 105,
                                  child: WorkersTile(
                                    color:
                                        Color(0xffDFECF8), // Color(0xffffffff),
                                    assetPath: 'assets/images/carpenter.png',
                                    title: 'Carpenter',
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  height: 130,
                                  //width: 160,
                                  width: 105,
                                  child: WorkersTile(
                                    color:
                                        Color(0xffDFECF8), //Color(0xffffffff),
                                    assetPath: 'assets/images/cleaner.png',

                                    title: 'Cleaners',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                  //to display the workers card
                  // _buildWorkersCardList()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //creating workers card list
  //original workers card list
  Widget _buildWorkersCardList() {
    List workersList = [
      //calling and assigning values to the TopProductTile constructor
      //main design of categories card: WorkersTile class
      GestureDetector(
        child: WorkersTile(
          assetPath: 'assets/images/Plumber.png',
          color: Color(0xffDFECF8),
          //price: 'Some Text',
          title: 'Plumbers',
        ),
        onTap: () {
          Navigator.of(context).push(_createRoute(ProfilePage()));
        },
      ),

      WorkersTile(
        color: Color(0xffF4DEF8),
        assetPath: 'assets/images/electrician.png',
        title: 'Electrician',
        //price: 'Some Text',
      ),
      WorkersTile(
        color: Color(0xffFFF2C5),
        assetPath: 'assets/images/mechanic.png',
        title: 'Mechanic',
        //price: 'Some Text',
      ),
    ];

    return Column(
      children: <Widget>[
        Container(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => workersList[index],
            separatorBuilder: (context, index) => SizedBox(width: 20),
            itemCount: workersList.length,
          ),
        )
      ],
    );
  }
}

//Explore all button
class _ExploreAllButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ExploreAllButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: this.onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color(0xffE0E6EE),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10)),
        ),
        child: Text(
          'Explore All',
          style: GoogleFonts.varelaRound(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700]),
        ),
      ),
    );
  }
}
