import 'package:flutter/material.dart';

class TimeUp extends StatefulWidget {
  const TimeUp({Key? key}) : super(key: key);

  @override
  _TimeUpState createState() => _TimeUpState();
}

class _TimeUpState extends State<TimeUp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: const [
            Text("App session closed for the day,",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
            Text("Please try again in the morning"),
          ],
        ),
      ),
    );
  }
}
