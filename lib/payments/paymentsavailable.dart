import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:fnet_new/views/makepayment.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../views/unpaidbankrequests.dart';
import '../views/unpaidcashrequest.dart';

class PaymentsAvailable extends StatefulWidget {
  const PaymentsAvailable({Key? key}) : super(key: key);

  @override
  _PaymentsAvailableState createState() => _PaymentsAvailableState();
}

class _PaymentsAvailableState extends State<PaymentsAvailable> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Unpaid Requests"),
        backgroundColor: primaryColor,
      ),
      body:  ListView(
        children: [
          const SizedBox(height: 100,),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => const UnpaidBankRequests());
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/bank.png",
                        width: 70,
                        height: 70,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Bank"),
                      const Text("Requests"),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/cash-on-delivery.png",
                        width: 70,
                        height: 70,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Cash"),
                      const Text("Requests"),
                    ],
                  ),
                  onTap: () {
                    Get.to(() => const UnpaidCashRequests());
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
