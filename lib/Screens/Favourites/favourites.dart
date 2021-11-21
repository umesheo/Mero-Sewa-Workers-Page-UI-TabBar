import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//class to display user's favourite workers
class Favourites extends StatefulWidget {
  Favourites({Key? key}) : super(key: key);

  @override
  _FavouritesState createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  var currentFocus;

  unfocus() {
    currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  List<Widget> _buildActions() => <Widget>[
        //App bar Search icon
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {},
          color: Colors.grey,
          tooltip: 'Search',
        ),
      ];

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
          title: Text("Mero Sewa",
              style: TextStyle(
                  fontFamily: "Pacifico", color: Colors.black, fontSize: 25)),
          actions: _buildActions(),
        ),
        body: Center(
          child: Container(
              child: Text(
            'Favourites',
            style: GoogleFonts.varelaRound(
                fontSize: 20, fontWeight: FontWeight.bold),
          )),
        ),
      ),
    );
  }
}
