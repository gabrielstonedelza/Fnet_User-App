import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../static/app_colors.dart';

class UserBankPaymentDetails extends StatefulWidget {
  final id;
  UserBankPaymentDetails({Key? key, required this.id}) : super(key: key);

  @override
  State<UserBankPaymentDetails> createState() =>
      _UserBankPaymentDetailsState(id: this.id);
}

class _UserBankPaymentDetailsState extends State<UserBankPaymentDetails> {
  final id;
  _UserBankPaymentDetailsState({required this.id});
  late List allUserPayments = [];
  bool isLoading = true;
  late var items;
  late List amounts = [];
  late List paymentDates = [];
  double sum = 0.0;
  late String uToken = "";
  final storage = GetStorage();
  late String username = "";

  //
  late String tellerName = "";
  late String detailTellerNumber = "";
  late String detailAmount = "";
  late String detail200 = "";
  late String detail100 = "";
  late String detail50 = "";
  late String detail20 = "";
  late String detail10 = "";
  late String detail5 = "";
  late String detail2 = "";
  late String detail1 = "";
  late String agentName = "";
  late String detailDate = "";
  late String detailTime = "";

  late int d200 = 0;
  late int d100 = 0;
  late int d50 = 0;
  late int d20 = 0;
  late int d10 = 0;
  late int d5 = 0;
  late int d2 = 0;
  late int d1 = 0;

  fetchData() async {
    final paymentUrl = "https://fnetghana.xyz/bank_payment_detail/$id/";
    final myLink = Uri.parse(paymentUrl);
    http.Response response = await http.get(
      myLink,
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Token $uToken"
      },
    );
    if (response.statusCode == 200) {
      final codeUnits = response.body;
      var jsonData = jsonDecode(codeUnits);
      setState(() {
        tellerName = jsonData['teller_name'];
        detailTellerNumber = jsonData['teller_phone'];
        detailAmount = jsonData['amount'];
        detail200 = jsonData['d_200'].toString();
        detail100 = jsonData['d_100'].toString();
        detail50 = jsonData['d_50'].toString();
        detail20 = jsonData['d_20'].toString();
        detail10 = jsonData['d_10'].toString();
        detail5 = jsonData['d_5'].toString();
        detail2 = jsonData['d_2'].toString();
        detail1 = jsonData['d_1'].toString();
        detailDate = jsonData['date_added'];
        detailTime = jsonData['time_added'];

        d200 = int.parse(detail200) * 200;
        d100 = int.parse(detail100) * 100;
        d50 = int.parse(detail50) * 50;
        d20 = int.parse(detail20) * 20;
        d10 = int.parse(detail10) * 10;
        d5 = int.parse(detail5) * 5;
        d2 = int.parse(detail2) * 2;
        d1 = int.parse(detail1) * 1;
      });
    } else {
      if (kDebugMode) {
        print(response.body);
      }
    }
    setState(() {
      isLoading = false;
      paymentDates = paymentDates;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (storage.read("usertoken") != null) {
      setState(() {
        uToken = storage.read("usertoken");
      });
    }
    if (storage.read("username") != null) {
      setState(() {
        username = storage.read("username");
      });
    }
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Payment Detail"),
          backgroundColor: primaryColor,
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  color: primaryColor,
                ),
              )
            : ListView(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 12,
                      color: secondaryColor,
                      child: ListTile(
                        title: Row(
                          children: [
                            const Text(
                              "Teller ➡️ ",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            Text(
                              "${tellerName.capitalize}",
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                const Text(
                                  "Teller's Phone ➡️ ",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Text(
                                  detailTellerNumber,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                const Text(
                                  "Amount ➡️ ",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Text(
                                  detailAmount,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            detail200 != "0" ? Row(
                              children: [
                                const Text(
                                  "GHS 200 Notes ➡️ ",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Text(
                                  "$detail200 ($d200)",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ) : Container(),
                            const SizedBox(
                              height: 10,
                            ),
                            detail100 != "0" ?   Row(
                              children: [
                                const Text(
                                  "GHS 100 Notes ➡️ ",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Text(
                                  "$detail100 ($d100)",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ) : Container(),
                            const SizedBox(
                              height: 10,
                            ),
                            detail50 != "0" ?    Row(
                              children: [
                                const Text(
                                  "GHS 50 Notes ➡️ ",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Text(
                                  "$detail50 ($d50)",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ) : Container(),
                            const SizedBox(
                              height: 10,
                            ),
                            detail20 != "0" ?  Row(
                              children: [
                                const Text(
                                  "GHS 20 Notes ➡️ ",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Text(
                                  "$detail20 ($d20)",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ) : Container(),
                            const SizedBox(
                              height: 10,
                            ),
                            detail10 != "0" ?  Row(
                              children: [
                                const Text(
                                  "GHS 10 Notes ➡️ ",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Text(
                                  "$detail10 ($d10)",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ): Container(),
                            const SizedBox(
                              height: 10,
                            ),
                            detail5 != "0" ?   Row(
                              children: [
                                const Text(
                                  "GHS 5 Notes ➡️ ",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Text(
                                  "$detail5 ($d5)",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ) : Container(),
                            const SizedBox(
                              height: 10,
                            ),
                            detail2 != "0" ? Row(
                              children: [
                                const Text(
                                  "GHS 2 Notes ➡️ ",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Text(
                                  "$detail2 ($d2)",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ):Container(),
                            const SizedBox(
                              height: 10,
                            ),
                            detail1 != "0" ?  Row(
                              children: [
                                const Text(
                                  "GHS 1 Notes ➡️ ",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Text(
                                  "$detail1 ($d1)",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ) : Container(),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                const Text(
                                  "Date paid ➡️ ",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Text(
                                  detailDate,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                const Text(
                                  "Time paid ➡️ ",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Text(
                                  detailTime.toString().split(".").first,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ));
  }
}
