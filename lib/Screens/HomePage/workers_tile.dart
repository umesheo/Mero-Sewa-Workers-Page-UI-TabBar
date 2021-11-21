import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//class to design the workers card
class WorkersTile extends StatelessWidget {
  final Color color;
  final String title;
  final String assetPath;
  //final String price;

  const WorkersTile({
    Key? key,
    required this.color,
    required this.title,
    required this.assetPath,
    //required this.price
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: this.color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      //height: 200,
      //width: 150,
      child: Center(
        child: Stack(
          children: <Widget>[
            Container(
              //padding: EdgeInsets.only(left: 20),
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    this.assetPath,
                    height: 80,
                    width: 80,
                  ),
                  Text(
                    this.title,
                    style: GoogleFonts.varelaRound(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  /*
                  Text(
                    this.price,
                    style: GoogleFonts.varelaRound(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey),
                  ),
                  */
                ],
              ),
            ),
            Positioned(
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(20))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    //Plus and minus buttons on the card
                    /*
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Icon(Icons.add),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Icon(Icons.remove),
                      
                    )
                    */
                  ],
                ),
              ),
            ),
            /*
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Icon(
                  Icons.favorite_border,
                ),
              ),
            )
            */
          ],
        ),
      ),
    );
  }
}
