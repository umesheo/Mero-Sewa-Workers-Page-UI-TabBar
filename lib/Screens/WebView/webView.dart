import 'package:flutter/material.dart';
import 'package:merosewa_app/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFFFFFFF),
          elevation: 0.3,
          title: Text("Mero Sewa",
              style: TextStyle(
                  fontFamily: "Pacifico", color: kBlackColor, fontSize: 25)),
        ),
        body: WebView(
          initialUrl: 'https://www.facebook.com/troopersgroup',
          javascriptMode: JavascriptMode.unrestricted,
        ));
  }
}
