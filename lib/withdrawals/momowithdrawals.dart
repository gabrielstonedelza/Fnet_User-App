import 'dart:convert';

import 'package:direct_dialer/direct_dialer.dart';
import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ussd_advanced/ussd_advanced.dart';

import '../sendsms.dart';
import '../views/homepage.dart';

class MomoWithdraw extends StatefulWidget {
  const MomoWithdraw({Key? key}) : super(key: key);

  @override
  _MomoWithdrawState createState() => _MomoWithdrawState();
}

class _MomoWithdrawState extends State<MomoWithdraw> {
  bool isPosting = false;

  void _startPosting() async {
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 4));
    setState(() {
      isPosting = false;
    });
  }

  final SendSmsController sendSms = SendSmsController();

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController = TextEditingController();
  late final TextEditingController _customerPhoneController =
  TextEditingController();
  late final TextEditingController _referenceController = TextEditingController();

  bool hasAmount = false;

  final List mobileMoneyNetworks = [
    "Select Network",
    "Mtn",
    "AirtelTigo",
    "Vodafone"
  ];

  final List justMtnNetwork = [
    "Select Withdraw Type",
    'Cash Out',
    'Agent'
  ];

  final List withdrawTypes = [
    "Select Withdraw Type",
    "Cash Out",
  ];


  bool isMtn = false;

  late List allMomoWithdrawUsers = [];
  late List momoWithdrawalUsers = [];
  late List momoWithdrawalUsersPhones = [];
  bool isLoading = true;
  bool isAlreadyAUser = false;
  fetchMomoWithdrawals() async {
    const url = "https://fnetghana.xyz/get_all_momo_withdrawal_made/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink);

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allMomoWithdrawUsers = json.decode(jsonData);
      for (var i in allMomoWithdrawUsers) {
        momoWithdrawalUsersPhones.add(i['phone']);
      }
    }
    setState(() {
      isLoading = false;
      allMomoWithdrawUsers = allMomoWithdrawUsers;
    });
  }

  fetchCustomer(String customerPhone) async {
    final url = "https://fnetghana.xyz/get_momo_withdraw_user/$customerPhone/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink);

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      momoWithdrawalUsers = json.decode(jsonData);
    }
    setState(() {
      isLoading = false;
      momoWithdrawalUsers = momoWithdrawalUsers;
    });
  }

  Future<void> dialCashOutMtn(String customerNumber,String amount) async {
    UssdAdvanced.multisessionUssd(code: "*171*2*1*$customerNumber*$customerNumber*$amount#",subscriptionId: 1);
  }

  Future<void> dialMtn() async {
    final dialer = await DirectDialer.instance;
    await dialer.dial('*171\%23#');
  }

  Future<void> dialTigo() async {
    final dialer = await DirectDialer.instance;
    await dialer.dial('*110\%23#');
  }

  Future<void> dialVodafone() async {
    final dialer = await DirectDialer.instance;
    await dialer.dial('*110\%23#');
  }

  var _currentSelectedNetwork = "Select Network";

  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  late String mtnEcashNow = "";
  late String tigoAirtelEcashNow = "";
  late String vodafoneEcashNow = "";
  late String physicalNow = "";
  late String ecashNow = "";


  processMomoWithdrawal() async {
    const registerUrl = "https://fnetghana.xyz/post_momo_withdraw/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "customer_phone": _customerPhoneController.text,
      "network": _currentSelectedNetwork,
      "reference": _referenceController.text.trim(),
      // "type": _currentSelectedType,
      "amount": _amountController.text,

    });
    if (res.statusCode == 201) {
      Get.snackbar("Congratulations", "Transaction was successful",
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);
      if (_currentSelectedNetwork == "Mtn") {
        var mtnenow =
            double.parse(mtnEcashNow) + double.parse(_amountController.text);
        var enow =
            double.parse(ecashNow) + double.parse(_amountController.text);
        var phynow =
            double.parse(physicalNow) - double.parse(_amountController.text);

        storage.write("mtnecashnow", mtnenow);
        storage.write("physicalnow", phynow);
        storage.write("ecashnow", enow);
      }
      if (_currentSelectedNetwork == "AirtelTigo") {
        var tigoenow = double.parse(tigoAirtelEcashNow) +
            double.parse(_amountController.text);
        var enow =
            double.parse(ecashNow) + double.parse(_amountController.text);
        var phynow =
            double.parse(physicalNow) - double.parse(_amountController.text);
        storage.write("tigoairtelecashnow", tigoenow);
        storage.write("physicalnow", phynow);
        storage.write("ecashnow", enow);
      }
      if (_currentSelectedNetwork == "Vodafone") {
        var vodaenow = double.parse(vodafoneEcashNow) +
            double.parse(_amountController.text);
        var enow =
            double.parse(ecashNow) + double.parse(_amountController.text);
        var phynow =
            double.parse(physicalNow) - double.parse(_amountController.text);
        storage.write("vodafoneecashnow", vodaenow);
        storage.write("physicalnow", phynow);
        storage.write("ecashnow", enow);
      }

      Get.offAll(() => const HomePage(message: null,));
      if(_currentSelectedNetwork == "Mtn"){
        dialCashOutMtn(_customerPhoneController.text.trim(),_amountController.text.trim());
      }
      if(_currentSelectedNetwork == "Vodafone"){
        dialVodafone();
      }
      if(_currentSelectedNetwork == "AirtelTigo"){
        dialTigo();
      }
    } else {
      Get.snackbar("Request Error", res.body.toString(),
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);
    }
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
    if (storage.read("physicalnow") != null) {
      setState(() {
        physicalNow = storage.read("physicalnow").toString();
      });
    }
    if (storage.read("ecashnow") != null) {
      setState(() {
        ecashNow = storage.read("ecashnow").toString();
      });
    }

    if (storage.read("mtnecashnow") != null) {
      setState(() {
        mtnEcashNow = storage.read("mtnecashnow").toString();
      });
    }

    if (storage.read("tigoairtelecashnow") != null) {
      setState(() {
        tigoAirtelEcashNow = storage.read("tigoairtelecashnow").toString();
      });
    }

    if (storage.read("vodafoneecashnow") != null) {
      setState(() {
        vodafoneEcashNow = storage.read("vodafoneecashnow").toString();
      });
    }
    fetchMomoWithdrawals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Momo Cash Out"),
        backgroundColor: primaryColor,
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      onChanged: (value) {
                        if (value.length == 10 &&
                            momoWithdrawalUsers.contains(value)) {
                          Get.snackbar("Please Wait", "Checking customer",
                              colorText: defaultTextColor,
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: snackColor);
                        }
                        setState(() {
                          isAlreadyAUser = true;
                          fetchCustomer(_customerPhoneController.text);
                        });
                      },
                      controller: _customerPhoneController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(

                          labelText: "Customer or Agent Number",
                          labelStyle: const TextStyle(color: secondaryColor),
                          focusColor: primaryColor,
                          fillColor: primaryColor,
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: primaryColor, width: 2),
                              borderRadius: BorderRadius.circular(12)),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12))),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Enter agent or customer number";
                        }
                      },
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Padding(
                      //   padding: const EdgeInsets.only(bottom: 10.0),
                      //   child: TextFormField(
                      //     // controller: _customerNameController,
                      //     cursorColor: primaryColor,
                      //     cursorRadius: const Radius.elliptical(10, 10),
                      //     cursorWidth: 10,
                      //     decoration: InputDecoration(
                      //
                      //         labelText: "Enter customer name",
                      //         labelStyle:
                      //             const TextStyle(color: secondaryColor),
                      //         focusColor: primaryColor,
                      //         fillColor: primaryColor,
                      //         focusedBorder: OutlineInputBorder(
                      //             borderSide: const BorderSide(
                      //                 color: primaryColor, width: 2),
                      //             borderRadius: BorderRadius.circular(12)),
                      //         border: OutlineInputBorder(
                      //             borderRadius: BorderRadius.circular(12))),
                      //     keyboardType: TextInputType.text,
                      //     validator: (value) {
                      //       if (value!.isEmpty) {
                      //         return "Please enter customer name";
                      //       }
                      //     },
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey, width: 1)),
                          child: Padding(
                            padding:
                            const EdgeInsets.only(left: 10.0, right: 10),
                            child: DropdownButton(
                              hint: const Text("Select Network"),
                              isExpanded: true,
                              underline: const SizedBox(),
                              // style: const TextStyle(
                              //     color: Colors.black, fontSize: 20),
                              items:
                              mobileMoneyNetworks.map((dropDownStringItem) {
                                return DropdownMenuItem(
                                  value: dropDownStringItem,
                                  child: Text(dropDownStringItem),
                                );
                              }).toList(),
                              onChanged: (newValueSelected) {
                                if (newValueSelected == "Mtn") {
                                  setState(() {
                                    isMtn = true;
                                  });
                                } else {
                                  setState(() {
                                    isMtn = false;
                                  });
                                }
                                _onDropDownItemSelectedNetwork(
                                    newValueSelected);
                              },
                              value: _currentSelectedNetwork,
                            ),
                          ),
                        ),
                      ),
                      // _currentSelectedNetwork == "Mtn"
                      //     ? Padding(
                      //   padding: const EdgeInsets.only(bottom: 10.0),
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //         borderRadius: BorderRadius.circular(12),
                      //         border: Border.all(
                      //             color: Colors.grey, width: 1)),
                      //     child: Padding(
                      //       padding: const EdgeInsets.only(
                      //           left: 10.0, right: 10),
                      //       child: DropdownButton(
                      //         hint: const Text("Select Withdrawal Type"),
                      //         isExpanded: true,
                      //         underline: const SizedBox(),
                      //         // style: const TextStyle(
                      //         //     color: Colors.black, fontSize: 20),
                      //         items: justMtnNetwork
                      //             .map((dropDownStringItem) {
                      //           return DropdownMenuItem(
                      //             value: dropDownStringItem,
                      //             child: Text(dropDownStringItem),
                      //           );
                      //         }).toList(),
                      //         onChanged: (newValueSelected) {
                      //           _onDropDownItemSelectedWithdrawTypes(
                      //               newValueSelected);
                      //         },
                      //         value: _currentSelectedType,
                      //       ),
                      //     ),
                      //   ),
                      // )
                      //     : Padding(
                      //   padding: const EdgeInsets.only(bottom: 10.0),
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //         borderRadius: BorderRadius.circular(12),
                      //         border: Border.all(
                      //             color: Colors.grey, width: 1)),
                      //     child: Padding(
                      //       padding: const EdgeInsets.only(
                      //           left: 10.0, right: 10),
                      //       child: DropdownButton(
                      //         hint: const Text("Select Withdrawal Type"),
                      //         isExpanded: true,
                      //         underline: const SizedBox(),
                      //         items:
                      //         withdrawTypes.map((dropDownStringItem) {
                      //           return DropdownMenuItem(
                      //             value: dropDownStringItem,
                      //             child: Text(dropDownStringItem),
                      //           );
                      //         }).toList(),
                      //         onChanged: (newValueSelected) {
                      //           _onDropDownItemSelectedWithdrawTypes(
                      //               newValueSelected);
                      //         },
                      //         value: _currentSelectedType,
                      //       ),
                      //     ),
                      //   ),
                      // ),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          onChanged: (value) {
                            if (value.length > 1) {
                              setState(() {
                                hasAmount = true;
                              });
                            }
                            if (value == "") {
                              setState(() {
                                hasAmount = false;
                              });
                            }
                          },
                          controller: _amountController,
                          cursorColor: primaryColor,
                          cursorRadius: const Radius.elliptical(10, 10),
                          cursorWidth: 10,
                          decoration: InputDecoration(

                              labelText: "Enter amount",
                              labelStyle:
                              const TextStyle(color: secondaryColor),
                              focusColor: primaryColor,
                              fillColor: primaryColor,
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: primaryColor, width: 2),
                                  borderRadius: BorderRadius.circular(12)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter amount";
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          controller: _referenceController,
                          cursorColor: primaryColor,
                          cursorRadius: const Radius.elliptical(10, 10),
                          cursorWidth: 10,
                          decoration: InputDecoration(

                              labelText: "Enter reference",
                              labelStyle: const TextStyle(color: secondaryColor),
                              focusColor: primaryColor,
                              fillColor: primaryColor,
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: primaryColor, width: 2),
                                  borderRadius: BorderRadius.circular(12)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter reference";
                            }
                          },
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),
                      isPosting
                          ? const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 5,
                          color: primaryColor,
                        ),
                      )
                          : RawMaterialButton(
                        onPressed: () {
                          _startPosting();
                          if (!_formKey.currentState!.validate()) {
                            return;
                          } else {
                            if (_currentSelectedNetwork == "Select Network" ) {
                              Get.snackbar("Network Error",
                                  "Please select network from the dropdowns",
                                  colorText: Colors.white,
                                  backgroundColor: Colors.red,
                                  snackPosition: SnackPosition.BOTTOM);
                              return;
                            } else {
                              Get.snackbar("Please wait", "processing",
                                  colorText: defaultTextColor,
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: snackColor);
                              processMomoWithdrawal();
                            }
                          }
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 8,
                        fillColor: primaryColor,
                        splashColor: defaultColor,
                        child: const Text(
                          "Save",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onDropDownItemSelectedNetwork(newValueSelected) {
    setState(() {
      _currentSelectedNetwork = newValueSelected;
    });
  }


}