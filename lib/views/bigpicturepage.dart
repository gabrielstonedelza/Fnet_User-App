import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';

class BigPicturePage extends StatefulWidget {
  String pic;
  String name;
  BigPicturePage({Key? key, required this.pic, required this.name})
      : super(key: key);

  @override
  _BigPicturePageState createState() =>
      _BigPicturePageState(pic: this.pic, name: this.name);
}

class _BigPicturePageState extends State<BigPicturePage> {
  String pic;
  String name;
  _BigPicturePageState({required this.pic, required this.name});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Column(
          children: [
            Text(name, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: SafeArea(
          child: Scaffold(
              body: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Image.network(pic, fit: BoxFit.contain)))),
    );
  }
}
