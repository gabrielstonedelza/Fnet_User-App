import 'package:flutter/material.dart';

Widget myCard(String title,String started,String now){
  return Padding(
    padding: const EdgeInsets.all(12.0),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListTile(
          title: Text(title),
          subtitle: Column(
            children: [
              Row(
                children: [
                  const Text("Started with: "),
                  Text(started),
                ],
              ),
              Row(
                children: [
                  const Text("Now: "),
                  Text(now),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}