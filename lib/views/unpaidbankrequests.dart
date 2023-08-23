import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:fnet_new/views/makepayment.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../loadingui.dart';

class UnpaidBankRequests extends StatefulWidget {
  const UnpaidBankRequests({Key? key}) : super(key: key);

  @override
  _UnpaidBankRequestsState createState() => _UnpaidBankRequestsState();
}

class _UnpaidBankRequestsState extends State<UnpaidBankRequests> {
  final storage = GetStorage();
  bool isLoading = true;
  late String uToken = "";
  late List bankDepositsNotPaid = [];
  late String username = "";
  var items;

  Future<void> fetchUserBankRequestsToday() async {
    const url = "https://fnetghana.xyz/get_unpaid_bank_deposits_for_today/";
    var myLink = Uri.parse(url);
    final response =
        await http.get(myLink, headers: {"Authorization": "Token $uToken"});

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      bankDepositsNotPaid = json.decode(jsonData);
    }

    setState(() {
      isLoading = false;
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
    fetchUserBankRequestsToday();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unpaid Bank Request"),
        backgroundColor: primaryColor,
      ),
      body: isLoading
          ? const LoadingUi()
          : Column(
              children: [
                const SizedBox(
                  height: 30,
                ),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                      itemCount: bankDepositsNotPaid != null
                          ? bankDepositsNotPaid.length
                          : 0,
                      itemBuilder: (context, i) {
                        items = bankDepositsNotPaid[i];
                        return Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8),
                              child: Card(
                                elevation: 12,
                                color: secondaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                // shadowColor: Colors.pink,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 18.0, bottom: 18),
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return MakePayment(
                                            id: bankDepositsNotPaid[i]['id'],
                                            depositType: "Bank",
                                            amount: bankDepositsNotPaid[i]
                                                ['amount']);
                                      }));
                                    },
                                    title: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 15.0),
                                        child: Row(
                                          children: [
                                            const Text(
                                              "Customer: ",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              items['customer']
                                                  .toString()
                                                  .toUpperCase(),
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        )),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10.0),
                                          child: Row(
                                            children: [
                                              const Text(
                                                "Bank: ",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                items['bank'],
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10.0),
                                          child: Row(
                                            children: [
                                              const Text(
                                                "Amount: ",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                items['amount'],
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10.0),
                                          child: Row(
                                            children: [
                                              const Text(
                                                "Deposit Paid: ",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                              Text(
                                                items['deposit_paid'],
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Text(
                                              "Date Requested: ",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              items['date_requested'],
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Text(
                                              "Time Requested: ",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                            Text(
                                              items['time_requested']
                                                  .toString()
                                                  .split(".")
                                                  .first,
                                              style: const TextStyle(
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
                      }),
                ),
              ],
            ),
    );
  }
}
