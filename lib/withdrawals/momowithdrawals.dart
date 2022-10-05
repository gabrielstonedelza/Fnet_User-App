import 'dart:convert';

import 'package:direct_dialer/direct_dialer.dart';
import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:fnet_new/views/bottomnavigation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../sendsms.dart';

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
  // late final TextEditingController _customerNameController = TextEditingController();
  late final TextEditingController _customerIdNumberController =
      TextEditingController();
  late final TextEditingController _mtnCommissionController =
      TextEditingController();
  late final TextEditingController _agentCommissionController =
      TextEditingController();
  late final TextEditingController _cashoutCommissionController =
      TextEditingController();
  late final TextEditingController _chargesController = TextEditingController();
  late final TextEditingController _amountToPush = TextEditingController();
  bool hasAmount = false;

  final List mobileMoneyNetworks = [
    "Select Network",
    "Mtn",
    "AirtelTigo",
    "Vodafone"
  ];

  final List justMtnNetwork = [
    "Select Withdraw Type",
    'MomoPay',
    'Cash Out',
    'Agent to Agent'
  ];

  final List withdrawTypes = [
    "Select Withdraw Type",
    "Cash Out",
    "Agent to Agent",
  ];

  final List idTypes = [
    "Select Id Type",
    "Passport",
    "Ghana Card",
    "Drivers License",
    "Voters Id"
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

  Future<void> dial() async {
    final dialer = await DirectDialer.instance;
    await dialer.dial('*171\%23#');
  }

  var _currentSelectedNetwork = "Select Network";
  var _currentSelectedType = "Select Withdraw Type";
  var _currentSelectedIdType = "Select Id Type";
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
      // "customer_name": _customerNameController.text,
      "network": _currentSelectedNetwork,
      "type": _currentSelectedType,
      "id_type": _currentSelectedIdType,
      "id_number": _customerIdNumberController.text,
      "charges": _chargesController.text,
      "cash_out_commission": _cashoutCommissionController.text,
      "agent_commission": _agentCommissionController.text,
      "mtn_commission": _mtnCommissionController.text,
      "amount": _amountController.text,
      "app_version" : "4"
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

      Get.offAll(() => const MyBottomNavigationBar());
      dial();
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
        title: const Text("Momo Withdrawal"),
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

                          labelText: "Enter customer number",
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
                          return "Please enter customer number";
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
                                    withdrawTypes.add("MomoPay");
                                  });
                                } else {
                                  setState(() {
                                    isMtn = false;
                                    withdrawTypes.remove("MomoPay");
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
                      _currentSelectedNetwork == "Mtn"
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.grey, width: 1)),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10),
                                  child: DropdownButton(
                                    hint: const Text("Select Withdrawal Type"),
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    // style: const TextStyle(
                                    //     color: Colors.black, fontSize: 20),
                                    items: justMtnNetwork
                                        .map((dropDownStringItem) {
                                      return DropdownMenuItem(
                                        value: dropDownStringItem,
                                        child: Text(dropDownStringItem),
                                      );
                                    }).toList(),
                                    onChanged: (newValueSelected) {
                                      _onDropDownItemSelectedWithdrawTypes(
                                          newValueSelected);
                                    },
                                    value: _currentSelectedType,
                                  ),
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.grey, width: 1)),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10),
                                  child: DropdownButton(
                                    hint: const Text("Select Withdrawal Type"),
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    items:
                                        withdrawTypes.map((dropDownStringItem) {
                                      return DropdownMenuItem(
                                        value: dropDownStringItem,
                                        child: Text(dropDownStringItem),
                                      );
                                    }).toList(),
                                    onChanged: (newValueSelected) {
                                      _onDropDownItemSelectedWithdrawTypes(
                                          newValueSelected);
                                    },
                                    value: _currentSelectedType,
                                  ),
                                ),
                              ),
                            ),
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
                              hint: const Text("Select Id Type"),
                              isExpanded: true,
                              underline: const SizedBox(),
                              // style: const TextStyle(
                              //     color: Colors.black, fontSize: 20),
                              items: idTypes.map((dropDownStringItem) {
                                return DropdownMenuItem(
                                  value: dropDownStringItem,
                                  child: Text(dropDownStringItem),
                                );
                              }).toList(),
                              onChanged: (newValueSelected) {
                                _onDropDownItemSelectedIdTypes(
                                    newValueSelected);
                              },
                              value: _currentSelectedIdType,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          controller: _customerIdNumberController,
                          cursorColor: primaryColor,
                          cursorRadius: const Radius.elliptical(10, 10),
                          cursorWidth: 10,
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person,
                                  color: secondaryColor),
                              labelText: "Enter id number",
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
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please enter id number";
                            }
                          },
                        ),
                      ),
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
                            if (_currentSelectedType == "Cash Out") {
                              if(int.parse(value) > 0 && int.parse(value) <= 50){
                                setState(() {
                                  _mtnCommissionController.text = 0.30.toString();
                                  _cashoutCommissionController.text = 0.20.toString();
                                  _chargesController.text = .50.toString();
                                });
                              }
                              if(int.parse(value) >= 51 && int.parse(value) <= 1000){
                                setState(() {
                                  var charges = double.parse(value) / 100;
                                  _mtnCommissionController.text = 0.60.toString();
                                  _cashoutCommissionController.text = 0.40.toString();
                                  _chargesController.text = charges.toString();
                                });
                              }

                              if (int.parse(value) >= 1000 &&
                                  int.parse(value) <= 2900) {
                                setState(() {
                                  int charges = 10;
                                  var amounttopush = charges + int.parse(value);
                                  _agentCommissionController.text =
                                      0.toString();
                                  _chargesController.text = charges.toString();
                                  _amountToPush.text = amounttopush.toString();
                                  _mtnCommissionController.text =
                                      charges.toString();
                                  _cashoutCommissionController.text =
                                      0.40.toString();
                                });
                              }
                              if (int.parse(value) >= 3000 &&
                                  int.parse(value) <= 3900) {
                                setState(() {
                                  int charges = 15;
                                  var amounttopush = 5 + int.parse(value);
                                  _agentCommissionController.text =
                                      5.toString();
                                  _chargesController.text = charges.toString();
                                  _amountToPush.text = amounttopush.toString();
                                  _mtnCommissionController.text = 10.toString();
                                });
                              }
                              if (int.parse(value) >= 4000 &&
                                  int.parse(value) <= 4900) {
                                setState(() {
                                  int charges = 20;
                                  var amounttopush = 10 + int.parse(value);
                                  _agentCommissionController.text =
                                      10.toString();
                                  _chargesController.text = charges.toString();
                                  _amountToPush.text = amounttopush.toString();
                                  _mtnCommissionController.text = 10.toString();
                                });
                              }
                              if (int.parse(value) >= 5000 &&
                                  int.parse(value) <= 5900) {
                                setState(() {
                                  int charges = 25;
                                  var amounttopush = 15 + int.parse(value);
                                  _agentCommissionController.text =
                                      10.toString();
                                  _chargesController.text = charges.toString();
                                  _amountToPush.text = amounttopush.toString();
                                  _mtnCommissionController.text = 10.toString();
                                });
                              }
                              if (int.parse(value) >= 6000 &&
                                  int.parse(value) <= 6900) {
                                setState(() {
                                  int charges = 30;
                                  var amounttopush = 20 + int.parse(value);
                                  _agentCommissionController.text =
                                      20.toString();
                                  _chargesController.text = charges.toString();
                                  _amountToPush.text = amounttopush.toString();
                                  _mtnCommissionController.text = 10.toString();
                                });
                              }
                              if (int.parse(value) >= 7000 &&
                                  int.parse(value) <= 7900) {
                                setState(() {
                                  int charges = 35;
                                  var amounttopush = 25 + int.parse(value);
                                  _agentCommissionController.text =
                                      25.toString();
                                  _chargesController.text = charges.toString();
                                  _amountToPush.text = amounttopush.toString();
                                  _mtnCommissionController.text = 10.toString();
                                });
                              }
                              if (int.parse(value) >= 8000 &&
                                  int.parse(value) <= 8900) {
                                setState(() {
                                  int charges = 40;
                                  var amounttopush = 30 + int.parse(value);
                                  _agentCommissionController.text =
                                      30.toString();
                                  _chargesController.text = charges.toString();
                                  _amountToPush.text = amounttopush.toString();
                                  _mtnCommissionController.text = 10.toString();
                                });
                              }
                              if (int.parse(value) >= 9000 &&
                                  int.parse(value) <= 9999) {
                                setState(() {
                                  int charges = 50;
                                  var amounttopush = 40 + int.parse(value);
                                  _agentCommissionController.text =
                                      40.toString();
                                  _chargesController.text = charges.toString();
                                  _amountToPush.text = amounttopush.toString();
                                  _mtnCommissionController.text = 10.toString();
                                });
                              }
                              if (int.parse(value) >= 10000) {
                                setState(() {
                                  int charges = 50;
                                  var amounttopush = 40 + int.parse(value);
                                  _agentCommissionController.text =
                                      40.toString();
                                  _chargesController.text = charges.toString();
                                  _amountToPush.text = amounttopush.toString();
                                  _mtnCommissionController.text = 10.toString();
                                });
                              }
                            }
                            //momo pay
                            if (_currentSelectedType == "MomoPay") {
                              if (int.parse(value) >= 10 &&
                                  int.parse(value) <= 1000) {
                                var charges = double.parse(value) / 100 * 1;
                                var agentcommission = double.parse(value) / 100;
                                // var agentCommission = 2.5;
                                int commissionDivide = 2;
                                var acommission = agentcommission / commissionDivide;
                                _agentCommissionController.text = acommission.toString();
                                _chargesController.text = charges.toString();
                                var amountToPush = double.parse(value) + acommission;
                                _chargesController.text = charges.toString();
                                _amountToPush.text = amountToPush.toString();
                              }
                              // if (int.parse(value) >= 51 &&
                              //     int.parse(value) <= 1000) {
                              //   var charges = double.parse(value) / 100 * 1;
                              //   var agentCommission =
                              //       double.parse(value) / 100 * 0.8;
                              //   var amountToPush =
                              //       double.parse(value) + agentCommission;
                              //
                              //   _agentCommissionController.text =
                              //       agentCommission.toString();
                              //   _chargesController.text = charges.toString();
                              //   _amountToPush.text = amountToPush.toString();
                              // }

                              if (int.parse(value) >= 1000 &&
                                  int.parse(value) <= 1900) {
                                var charges = 10;
                                var agentCommission = 5;
                                var amountToPush =
                                    double.parse(value) + agentCommission;

                                _agentCommissionController.text =
                                    agentCommission.toString();
                                _chargesController.text = charges.toString();
                                _amountToPush.text = amountToPush.toString();
                              }
                              if (int.parse(value) >= 2000 &&
                                  int.parse(value) <= 2900) {
                                var charges = 15;
                                var agentCommission = 10;
                                var amountToPush = double.parse(value) + agentCommission;

                                _agentCommissionController.text =
                                    agentCommission.toString();
                                _chargesController.text = charges.toString();
                                _amountToPush.text = amountToPush.toString();
                              }
                              if (int.parse(value) >= 3000 &&
                                  int.parse(value) <= 3900) {
                                var charges = 20;
                                var agentCommission = 15;
                                var amountToPush = double.parse(value) + agentCommission;

                                _agentCommissionController.text =
                                    agentCommission.toString();
                                _chargesController.text = charges.toString();
                                _amountToPush.text = amountToPush.toString();
                              }
                              if (int.parse(value) >= 4000 &&
                                  int.parse(value) <= 4900) {
                                var charges = 25;
                                var agentCommission = 20;
                                var amountToPush = double.parse(value) + agentCommission;

                                _agentCommissionController.text =
                                    agentCommission.toString();
                                _chargesController.text = charges.toString();
                                _amountToPush.text = amountToPush.toString();
                              }
                              if (int.parse(value) >= 5000 &&
                                  int.parse(value) <= 5900) {
                                var charges = 30;
                                var agentCommission = 25;
                                var amountToPush = double.parse(value) + agentCommission;

                                _agentCommissionController.text =
                                    agentCommission.toString();
                                _chargesController.text = charges.toString();
                                _amountToPush.text = amountToPush.toString();
                              }
                              if (int.parse(value) >= 6000 &&
                                  int.parse(value) <= 6900) {
                                var charges = 35;
                                var agentCommission = 30;
                                var amountToPush = double.parse(value) + agentCommission;

                                _agentCommissionController.text =
                                    agentCommission.toString();
                                _chargesController.text = charges.toString();
                                _amountToPush.text = amountToPush.toString();
                              }
                              if (int.parse(value) >= 7000 &&
                                  int.parse(value) <= 7900) {
                                var charges = 40;
                                var agentCommission = 35;
                                var amountToPush = double.parse(value) + agentCommission;

                                _agentCommissionController.text =
                                    agentCommission.toString();
                                _chargesController.text = charges.toString();
                                _amountToPush.text = amountToPush.toString();
                              }
                              if (int.parse(value) >= 8000 &&
                                  int.parse(value) <= 8999) {
                                var charges = 45;
                                var agentCommission = 40;
                                var amountToPush = double.parse(value) + agentCommission;

                                _agentCommissionController.text =
                                    agentCommission.toString();
                                _chargesController.text = charges.toString();
                                _amountToPush.text = amountToPush.toString();
                              }
                              if (int.parse(value) >= 9000 && int.parse(value) <= 10000) {
                                var charges = 50;
                                var agentCommission = 45;
                                var amountToPush = double.parse(value) + agentCommission;

                                _agentCommissionController.text =
                                    agentCommission.toString();
                                _chargesController.text = charges.toString();
                                _amountToPush.text = amountToPush.toString();
                              }
                            }
                            //  agent to agent
                            if (_currentSelectedType == "Agent to Agent") {
                              if (int.parse(value) > 0 &&
                                  int.parse(value) <= 50) {
                                setState(() {
                                  var charges = double.parse(value) / 100;
                                  var agentcommission =
                                      double.parse(value) / 100;
                                  _agentCommissionController.text =
                                      agentcommission.toString();
                                  _chargesController.text = charges.toString();
                                });
                              }
                              if (int.parse(value) >= 1000 &&
                                  int.parse(value) <= 2900) {
                                setState(() {
                                  int charges = 10;
                                  var amounttopush = charges + int.parse(value);
                                  _agentCommissionController.text =
                                      0.toString();
                                  _chargesController.text = charges.toString();
                                  _amountToPush.text = amounttopush.toString();
                                  _mtnCommissionController.text =
                                      charges.toString();
                                  _cashoutCommissionController.text =
                                      0.40.toString();
                                });
                              }
                              if (int.parse(value) >= 3000 &&
                                  int.parse(value) <= 3900) {
                                setState(() {
                                  int charges = 15;
                                  var amounttopush = 5 + int.parse(value);
                                  _agentCommissionController.text =
                                      5.toString();
                                  _chargesController.text = charges.toString();
                                  _amountToPush.text = amounttopush.toString();
                                  _mtnCommissionController.text = 10.toString();
                                });
                              }
                              if (int.parse(value) >= 4000 &&
                                  int.parse(value) <= 4900) {
                                setState(() {
                                  int charges = 20;
                                  var amounttopush = 10 + int.parse(value);
                                  _agentCommissionController.text =
                                      10.toString();
                                  _chargesController.text = charges.toString();
                                  _amountToPush.text = amounttopush.toString();
                                  _mtnCommissionController.text = 10.toString();
                                });
                              }
                              if (int.parse(value) >= 5000 &&
                                  int.parse(value) <= 5900) {
                                setState(() {
                                  int charges = 25;
                                  var amounttopush = 15 + int.parse(value);
                                  _agentCommissionController.text =
                                      10.toString();
                                  _chargesController.text = charges.toString();
                                  _amountToPush.text = amounttopush.toString();
                                  _mtnCommissionController.text = 10.toString();
                                });
                              }
                              if (int.parse(value) >= 6000 &&
                                  int.parse(value) <= 6900) {
                                setState(() {
                                  int charges = 30;
                                  var amounttopush = 20 + int.parse(value);
                                  _agentCommissionController.text =
                                      20.toString();
                                  _chargesController.text = charges.toString();
                                  _amountToPush.text = amounttopush.toString();
                                  _mtnCommissionController.text = 10.toString();
                                });
                              }
                              if (int.parse(value) >= 7000 &&
                                  int.parse(value) <= 7900) {
                                setState(() {
                                  int charges = 35;
                                  var amounttopush = 25 + int.parse(value);
                                  _agentCommissionController.text =
                                      25.toString();
                                  _chargesController.text = charges.toString();
                                  _amountToPush.text = amounttopush.toString();
                                  _mtnCommissionController.text = 10.toString();
                                });
                              }
                              if (int.parse(value) >= 8000 &&
                                  int.parse(value) <= 8900) {
                                setState(() {
                                  int charges = 40;
                                  var amounttopush = 30 + int.parse(value);
                                  _agentCommissionController.text =
                                      30.toString();
                                  _chargesController.text = charges.toString();
                                  _amountToPush.text = amounttopush.toString();
                                  _mtnCommissionController.text = 10.toString();
                                });
                              }
                              if (int.parse(value) >= 9000 &&
                                  int.parse(value) <= 9999) {
                                setState(() {
                                  int charges = 50;
                                  var amounttopush = 40 + int.parse(value);
                                  _agentCommissionController.text =
                                      40.toString();
                                  _chargesController.text = charges.toString();
                                  _amountToPush.text = amounttopush.toString();
                                  _mtnCommissionController.text = 10.toString();
                                });
                              }
                              if (int.parse(value) >= 10000) {
                                setState(() {
                                  int charges = 50;
                                  var amounttopush = 40 + int.parse(value);
                                  _agentCommissionController.text =
                                      40.toString();
                                  _chargesController.text = charges.toString();
                                  _amountToPush.text = amounttopush.toString();
                                  _mtnCommissionController.text = 10.toString();
                                });
                              }
                            }
                          },
                          controller: _amountController,
                          cursorColor: primaryColor,
                          cursorRadius: const Radius.elliptical(10, 10),
                          cursorWidth: 10,
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person,
                                  color: secondaryColor),
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
                      hasAmount
                          ? Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: TextFormField(
                                    controller: _amountToPush,
                                    cursorColor: primaryColor,
                                    cursorRadius:
                                        const Radius.elliptical(10, 10),
                                    cursorWidth: 10,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                        prefixIcon: const Icon(Icons.person,
                                            color: secondaryColor),
                                        labelText: "Amout to push",
                                        labelStyle: const TextStyle(
                                            color: secondaryColor),
                                        focusColor: primaryColor,
                                        fillColor: primaryColor,
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: primaryColor, width: 2),
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12))),
                                    keyboardType: TextInputType.text,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: TextFormField(
                                    controller: _agentCommissionController,
                                    cursorColor: primaryColor,
                                    cursorRadius:
                                        const Radius.elliptical(10, 10),
                                    cursorWidth: 10,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                        prefixIcon: const Icon(Icons.person,
                                            color: secondaryColor),
                                        labelText: "Agent Commission",
                                        labelStyle: const TextStyle(
                                            color: secondaryColor),
                                        focusColor: primaryColor,
                                        fillColor: primaryColor,
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: primaryColor, width: 2),
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12))),
                                    keyboardType: TextInputType.text,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: TextFormField(
                                    controller: _chargesController,
                                    cursorColor: primaryColor,
                                    cursorRadius:
                                        const Radius.elliptical(10, 10),
                                    cursorWidth: 10,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                        prefixIcon: const Icon(Icons.person,
                                            color: secondaryColor),
                                        labelText: "Charges",
                                        labelStyle: const TextStyle(
                                            color: secondaryColor),
                                        focusColor: primaryColor,
                                        fillColor: primaryColor,
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: primaryColor, width: 2),
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12))),
                                    keyboardType: TextInputType.text,
                                  ),
                                ),
                              ],
                            )
                          : Container(),
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
                                  if (_currentSelectedType ==
                                          "Select Withdraw Type" ||
                                      _currentSelectedNetwork ==
                                          "Select Network" ||
                                      _currentSelectedIdType ==
                                          "Select Id Type") {
                                    Get.snackbar("Bank Error",
                                        "Please select all necessary items from the dropdowns",
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
                              child: const Text(
                                "Save",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.white),
                              ),
                              fillColor: primaryColor,
                              splashColor: defaultColor,
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

  void _onDropDownItemSelectedWithdrawTypes(newValueSelected) {
    setState(() {
      _currentSelectedType = newValueSelected;
    });
  }

  void _onDropDownItemSelectedIdTypes(newValueSelected) {
    setState(() {
      _currentSelectedIdType = newValueSelected;
    });
  }
}
