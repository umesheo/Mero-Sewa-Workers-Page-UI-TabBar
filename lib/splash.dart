import 'package:flutter/material.dart';
import 'package:merosewa_app/Authentication/Auto%20Login/shared_pref_helper.dart';
import 'package:merosewa_app/Screens/HomePage/bottomNaviationGateway.dart';
import 'package:merosewa_app/screens/Login/login_screen.dart';
import 'package:flutter/services.dart';
import 'package:merosewa_app/constants.dart';

//creating a splash page
class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  AnimationController? _animationController;
  AnimationController? _slideAnimationController;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _rotateAnimation;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    doLogin();
    super.initState();

    Future.delayed(const Duration(milliseconds: 1300), () {
      _slideAnimationController!.forward();
    });

    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    )..forward();

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 10),
      end: //Offset.infinite,
          const Offset(0, -3.72),
    ).animate(CurvedAnimation(
      parent: _slideAnimationController!,
      curve: Curves.linear,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.00,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.linear,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.25,
      end: 1.01990,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: const Interval(0.2, 1),
    ));
  }

  //Creating route to smoothly navigate to pages
  Route _createRoute(pages) {
    return PageRouteBuilder(
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

  void doLogin() async {
    Future.delayed(Duration(seconds: 3), () async {
      //get the auth token
      final token = await SharedPreferencesHelper().getAuthToken();
      //if token is present
      //i.e user has not logged out
      //take the user to home screen
      if (token != null && token.isNotEmpty) {
        //navigate to the respective page
        Navigator.of(context)
            .pushReplacement(_createRoute(BottomNavigationGateway()));
      }
      //if token is not present
      //i.e user has already logged out
      //take the user to login screen
      else {
        /*
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        */
        Navigator.of(context).pushReplacement(_createRoute(LoginScreen()));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _animationController!.dispose();
    _slideAnimationController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //system screen bottom customization
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(

        //setting the sceren bottom color to theme color
        systemNavigationBarColor: kPrimaryColor,
        //setting the screen bottom navigation button color to black
        systemNavigationBarIconBrightness: Brightness.dark));
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: RotationTransition(
                turns: _rotateAnimation!,
                child: ScaleTransition(
                  scale: _scaleAnimation!,
                  child: Image.asset(
                    "assets/images/LandBackground.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            SlideTransition(
              position: _slideAnimation!,
              child: Text(
                'Mero Sewa',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Pacifico',
                  fontSize: 35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
