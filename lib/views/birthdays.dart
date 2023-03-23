import 'dart:convert';
import 'package:age_calculator/age_calculator.dart';
import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../sendsms.dart';

class Birthdays extends StatefulWidget {
  const Birthdays({Key? key}) : super(key: key);

  @override
  _BirthdaysState createState() => _BirthdaysState();
}

class _BirthdaysState extends State<Birthdays> {
  late List allCustomers = [];
  bool isLoading = true;
  late var items;
  late List hasBirthDayInFive = [];
  late List hasBirthDayToday = [];
  late List todaysBirthdayPhones = [];
  bool hasbdinfive = false;
  bool hasbdintoday = false;
  // late DateDuration duration;
  late String username = "";
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  final SendSmsController sendSms = SendSmsController();

  Future<void> fetchCustomers(String token) async {
    const url = "https://fnetghana.xyz/user_customers/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $token"
    });

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allCustomers = json.decode(jsonData);
      for (var i in allCustomers) {
        DateDuration duration;
        DateTime birthday = DateTime.parse(i['date_of_birth']);
        duration = AgeCalculator.timeToNextBirthday(birthday);
        if (duration.months == 0 && duration.days == 5) {
          setState(() {
            hasBirthDayInFive.add(i['name']);
            hasbdinfive = true;
          });
        }
        if (duration.months == 0 && duration.days == 0) {
          setState(() {
            hasbdintoday = true;
            hasBirthDayToday.add(i['name']);
            todaysBirthdayPhones.add(i['phone']);
          });
        }
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (storage.read("username") != null) {
      setState(() {
        username = storage.read("username");
      });
    }

    if (storage.read("usertoken") != null) {
      setState(() {
        hasToken = true;
        uToken = storage.read("usertoken");
      });
    }
    fetchCustomers(uToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Birthdays"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              fetchCustomers(uToken);
            },
          )
        ],
      ),
      body: SafeArea(
          child: isLoading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Center(
                        child: CircularProgressIndicator(
                      color: primaryColor,
                      strokeWidth: 5,
                    )),
                  ],
                )
              : hasbdinfive
                  ? ListView.builder(
                      itemCount: hasBirthDayInFive != null
                          ? hasBirthDayInFive.length
                          : 0,
                      itemBuilder: (context, i) {
                        return Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8),
                              child: Card(
                                color: secondaryColor,
                                elevation: 12,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                // shadowColor: Colors.pink,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 18.0, bottom: 18),
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                        backgroundColor: primaryColor,
                                        foregroundColor: Colors.white,
                                        child: Icon(Icons.person)),
                                    trailing: Image.asset(
                                      "assets/images/cake.png",
                                      width: 30,
                                      height: 30,
                                    ),
                                    title: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15.0),
                                      child: Row(
                                        children: [
                                          const Text(
                                            "Name: ",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                          Text(
                                            hasBirthDayInFive[i],
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: const [
                                            Text(
                                              "Birthday is coming up in five days",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        );
                      })
                  : hasbdintoday
                      ? ListView.builder(
                          itemCount: hasBirthDayToday != null
                              ? hasBirthDayToday.length
                              : 0,
                          itemBuilder: (context, i) {
                            return Column(
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8),
                                  child: Card(
                                    elevation: 12,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    // shadowColor: Colors.pink,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 18.0, bottom: 18),
                                      child: ListTile(
                                        leading: const CircleAvatar(
                                            backgroundColor: primaryColor,
                                            foregroundColor: Colors.white,
                                            child: Icon(Icons.person)),
                                        trailing: Image.asset(
                                          "assets/images/cake.png",
                                          width: 30,
                                          height: 30,
                                        ),
                                        title: Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 15.0),
                                          child: Row(
                                            children: [
                                              const Text("Name: "),
                                              Text(
                                                hasBirthDayToday[i],
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: const [
                                                Text(
                                                  "Birthday is today",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            );
                          })
                      : const Center(
                          child: Text("No birthdays available"),
                        )),
    );
  }
}
