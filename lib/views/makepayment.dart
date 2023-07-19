import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fnet_new/sendsms.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:fnet_new/views/bankpayments.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import 'homepage.dart';


class MakePayment extends StatefulWidget {
  final id;
  final depositType;
  final amount;
  const MakePayment({Key? key, this.id, this.depositType, this.amount})
      : super(key: key);

  @override
  _MakePaymentState createState() => _MakePaymentState(
      id: this.id, depositType: this.depositType, amount: this.amount);
}

class _MakePaymentState extends State<MakePayment> {
  final id;
  final depositType;
  final amount;
  _MakePaymentState(
      {required this.id, required this.depositType, required this.amount});
  bool isLoading = true;
  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  late String adminPhone = "";
  final List banks = [
    "Select bank",
    "Access Bank",
    "Cal Bank",
    "Fidelity Bank",
    "Ecobank",
    "Pan Africa",
    "First Bank of Nigeria",
    "SGSSB",
    "Atwima Rural Bank",
    "Omnibsic Bank",
    "Stanbic Bank",
    "Absa Bank",
    "Universal Merchant Bank",
    "Adansi rural bank",
    "Kwumawuman Bank",
    "Omini bank",
  ];

  var _currentSelectedBank1 = "Select bank";
  var _currentSelectedBank2 = "Select bank";

  final List modeOfPayment = [
    "Select mode of payment",
    "Bank Payment",
    "Mtn",
    "AirtelTigo",
    "Vodafone",
    "Momo pay",
    "Agent to Agent",
    "Cash left @",
    "Own Accounts",
    "Company Accounts"
  ];

  var _currentSelectedModeOfPayment1 = "Select mode of payment";
  var _currentSelectedModeOfPayment2 = "Select mode of payment";

  final List cashLocation = [
    "Please select cash at location",
    "DVLA",
    "HEAD OFFICE",
    "KEJETIA",
    "ECOBANK",
    "PAN AFRICA",
    "MELCOM SANTASI",
    "MELCOM TANOSO",
    "MELCOM MANHYIA",
    "MELCOM TAFO",
    "MELCOM AHODWO",
    "MELCOM ADUM",
    "MELCOM SUAME",
  ];

  var _currentCashAtLocation1 = "Please select cash at location";
  var _currentCashAtLocation2 = "Please select cash at location";

  final List paymentAction = [
    "Select payment action",
    "Not Closed",
    "Close Payment"
  ];

  bool isAtLocation = false;
  bool isBank = false;
  final SendSmsController sendSms = SendSmsController();
  bool showPayment2 = false;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController1 = TextEditingController();
  late final TextEditingController _amountController2 = TextEditingController();
  late final TextEditingController _referenceController1 =
      TextEditingController();
  late final TextEditingController _referenceController2 =
      TextEditingController();
  DateTime now = DateTime.now();
  bool isPosting = false;
  var amountTotal;
  bool hasErrors = false;
  bool isEqual = false;
  bool hasAnotherPayment = false;
  String buttonText = "Add another payment";
  bool hasSelectedModeOfPayment = false;

  void _startPosting() async {
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 4));
    setState(() {
      isPosting = false;
    });
  }

  payCashRequestDeposit() async {
    final requestUrl = "https://fnetghana.xyz/approve_cash_deposit_paid/$id/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
    }, body: {
      "deposit_paid": "Paid",
      "app_name": "FNET"
    });
    if (response.statusCode == 200) {
      Get.snackbar("Congrats", "Request was paid",
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);
      Get.offAll(() => const HomePage(message: null,));
    } else {
      // print(response.body);
      // Get.snackbar("Approve Error", response.body.toString(),
      //     colorText: defaultTextColor,
      //     snackPosition: SnackPosition.BOTTOM,
      //     backgroundColor: snackColor
      // );
    }
  }

  payBankRequestDeposit() async {
    final requestUrl = "https://fnetghana.xyz/approve_bank_deposit_paid/$id/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
    }, body: {
      "deposit_paid": "Paid",
    });
    if (response.statusCode == 200) {
      Get.snackbar("Congrats", "Request was paid",
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);
      Get.offAll(() => const HomePage(message: null,));
    } else {
      Get.snackbar("Approve Error", response.body.toString(),
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);
    }
  }

  processPayment(context) async {
    const registerUrl = "https://fnetghana.xyz/make_payments/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "mode_of_payment1": _currentSelectedModeOfPayment1,
      "mode_of_payment2": _currentSelectedModeOfPayment2,
      "cash_at_location1": _currentCashAtLocation1,
      "cash_at_location2": _currentCashAtLocation2,
      "bank1": _currentSelectedBank1,
      "bank2": _currentSelectedBank2,
      "amount1": _amountController1.text,
      "amount2": _amountController2.text,
      "transaction_id1": _referenceController1.text,
      "transaction_id2": _referenceController2.text,
    });
    if (res.statusCode == 201) {
      Get.snackbar("Congratulations", "Payment is sent for approval",
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);
      String telnum1 = adminPhone;
      telnum1 = telnum1.replaceFirst("0", '+233');
      sendSms.sendMySms(telnum1, "FNET",
          "Hello Admin,${username.capitalize} just made a $_currentSelectedModeOfPayment1 of GHC${_amountController1.text} ,kindly login into Fnet and approve.Thank you");
      if (_currentSelectedModeOfPayment1 == "Cash left @") {}
      if (_currentSelectedModeOfPayment1 == "Bank Payment") {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return BankPayments(
              bank: _currentSelectedBank1,
              amount_delivered: _amountController1.text,
              agent: username);
        }));
      }

      Get.offAll(() => const HomePage(message: null,));
    } else {
      Get.snackbar("Request Error", res.body.toString(),
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);
    }
  }

  fetchAdmin() async {
    const agentUrl = "https://fnetghana.xyz/admin_user";
    final agentLink = Uri.parse(agentUrl);
    http.Response res = await http.get(agentLink);
    if (res.statusCode == 200) {
      final codeUnits = res.body;
      var jsonData = jsonDecode(codeUnits);
      var myUser = jsonData[0];
      setState(() {
        adminPhone = myUser['phone'];
      });
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
    fetchAdmin();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _amountController1.dispose();
    _amountController2.dispose();
    _referenceController1.dispose();
    _referenceController2.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Make payment"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      Text(
                        "Total to pay $amount",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 20,
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
                              hint: const Text("Select mode of payment1"),
                              isExpanded: true,
                              underline: const SizedBox(),
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 20),
                              items: modeOfPayment.map((dropDownStringItem) {
                                return DropdownMenuItem(
                                  value: dropDownStringItem,
                                  child: Text(dropDownStringItem),
                                );
                              }).toList(),
                              onChanged: (newValueSelected) {
                                if (newValueSelected !=
                                    "Select mode of payment") {
                                  setState(() {
                                    hasSelectedModeOfPayment = true;
                                  });
                                } else {
                                  setState(() {
                                    hasSelectedModeOfPayment = false;
                                  });
                                }
                                _onDropDownItemSelectedModeOfPayment(
                                    newValueSelected);
                              },
                              value: _currentSelectedModeOfPayment1,
                            ),
                          ),
                        ),
                      ),
                      hasSelectedModeOfPayment
                          ? Column(
                              children: [
                                _currentSelectedModeOfPayment1 == "Bank Payment"
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: Colors.grey,
                                                  width: 1)),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0, right: 10),
                                            child: DropdownButton(
                                              hint: const Text("Select bank1"),
                                              isExpanded: true,
                                              underline: const SizedBox(),
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20),
                                              items: banks
                                                  .map((dropDownStringItem) {
                                                return DropdownMenuItem(
                                                  value: dropDownStringItem,
                                                  child:
                                                      Text(dropDownStringItem),
                                                );
                                              }).toList(),
                                              onChanged: (newValueSelected) {
                                                _onDropDownItemSelectedBank(
                                                    newValueSelected);
                                              },
                                              value: _currentSelectedBank1,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                                _currentSelectedModeOfPayment1 == "Cash left @"
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: Colors.grey,
                                                  width: 1)),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0, right: 10),
                                            child: DropdownButton(
                                              hint: const Text(
                                                  "Please select cash at location1"),
                                              isExpanded: true,
                                              underline: const SizedBox(),
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 20),
                                              items: cashLocation
                                                  .map((dropDownStringItem) {
                                                return DropdownMenuItem(
                                                  value: dropDownStringItem,
                                                  child:
                                                      Text(dropDownStringItem),
                                                );
                                              }).toList(),
                                              onChanged: (newValueSelected) {
                                                _onDropDownItemSelectedLocation(
                                                    newValueSelected);
                                              },
                                              value: _currentCashAtLocation1,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: TextFormField(
                                    controller: _referenceController1,
                                    cursorColor: primaryColor,
                                    cursorRadius:
                                        const Radius.elliptical(10, 10),
                                    cursorWidth: 10,
                                    decoration: InputDecoration(
                                        labelText: "Enter reference",
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
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Please enter reference";
                                      }
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: TextFormField(
                                    controller: _amountController1,
                                    cursorColor: primaryColor,
                                    cursorRadius:
                                        const Radius.elliptical(10, 10),
                                    cursorWidth: 10,
                                    decoration: InputDecoration(
                                        labelText: "Enter amount",
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
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Please enter amount";
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 20),

                  //option for another payment
                  showPayment2
                      ? Column(
                          children: [
                            Padding(
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
                                    hint: const Text("Select mode of payment2"),
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 20),
                                    items:
                                        modeOfPayment.map((dropDownStringItem) {
                                      return DropdownMenuItem(
                                        value: dropDownStringItem,
                                        child: Text(dropDownStringItem),
                                      );
                                    }).toList(),
                                    onChanged: (newValueSelected) {
                                      _onDropDownItemSelectedModeOfPayment2(
                                          newValueSelected);
                                    },
                                    value: _currentSelectedModeOfPayment2,
                                  ),
                                ),
                              ),
                            ),
                            _currentSelectedModeOfPayment2 == "Bank Payment"
                                ? Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Colors.grey, width: 1)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, right: 10),
                                        child: DropdownButton(
                                          hint: const Text("Select bank"),
                                          isExpanded: true,
                                          underline: const SizedBox(),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 20),
                                          items:
                                              banks.map((dropDownStringItem) {
                                            return DropdownMenuItem(
                                              value: dropDownStringItem,
                                              child: Text(dropDownStringItem),
                                            );
                                          }).toList(),
                                          onChanged: (newValueSelected) {
                                            _onDropDownItemSelectedBank2(
                                                newValueSelected);
                                          },
                                          value: _currentSelectedBank2,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                            _currentSelectedModeOfPayment2 == "Cash left @"
                                ? Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 10.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Colors.grey, width: 1)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, right: 10),
                                        child: DropdownButton(
                                          hint: const Text(
                                              "Please select cash at location2"),
                                          isExpanded: true,
                                          underline: const SizedBox(),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 20),
                                          items: cashLocation
                                              .map((dropDownStringItem) {
                                            return DropdownMenuItem(
                                              value: dropDownStringItem,
                                              child: Text(dropDownStringItem),
                                            );
                                          }).toList(),
                                          onChanged: (newValueSelected) {
                                            _onDropDownItemSelectedLocation2(
                                                newValueSelected);
                                          },
                                          value: _currentCashAtLocation2,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: TextFormField(
                                controller: _referenceController2,
                                cursorColor: primaryColor,
                                cursorRadius: const Radius.elliptical(10, 10),
                                cursorWidth: 10,
                                decoration: InputDecoration(
                                    labelText: "Enter reference",
                                    labelStyle:
                                        const TextStyle(color: secondaryColor),
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
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Please enter reference";
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: TextFormField(
                                controller: _amountController2,
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
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12))),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Please enter amount";
                                  }
                                },
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        )
                      : Container(),
                  hasSelectedModeOfPayment
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              showPayment2 = !showPayment2;
                              if (!showPayment2) {
                                buttonText = "Add another payment";
                                hasAnotherPayment = false;
                              } else {
                                buttonText = "Remove field";
                                hasAnotherPayment = true;
                              }
                            });
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 12.0, bottom: 12),
                            child: Text(
                              buttonText,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ))
                      : Container(),
                  isPosting && !hasErrors
                      ? const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 5,
                            color: primaryColor,
                          ),
                        )
                      : hasSelectedModeOfPayment
                          ? RawMaterialButton(
                              onPressed: () {
                                _startPosting();
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                } else {
                                  if (_currentSelectedModeOfPayment1 ==
                                      "Select mode of payment") {
                                    setState(() {
                                      hasErrors = true;
                                    });
                                    Get.snackbar("Mode Error",
                                        "Please select at least one mode of payment",
                                        colorText: defaultTextColor,
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.red);
                                    return;
                                  }
                                  if (_amountController1.text.isNotEmpty &&
                                      _amountController2.text.isEmpty) {
                                    amountTotal = double.tryParse(
                                        _amountController1.text);
                                    if (amountTotal != double.parse(amount)) {
                                      setState(() {
                                        hasErrors = true;
                                      });
                                      Get.snackbar("Amount Error",
                                          "Your amount total is wrong,please check",
                                          colorText: defaultTextColor,
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.red);
                                      return;
                                    }
                                  }
                                  if (_amountController1.text.isNotEmpty &&
                                      _amountController2.text.isNotEmpty) {
                                    amountTotal = double.parse(
                                            _amountController1.text) +
                                        double.parse(_amountController2.text);
                                    if (amountTotal != double.parse(amount)) {
                                      setState(() {
                                        hasErrors = true;
                                      });
                                      Get.snackbar("Amount Error",
                                          "Your amount total is wrong,please check",
                                          colorText: defaultTextColor,
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.red);
                                      return;
                                    }
                                  }
                                  if (_amountController1.text.isEmpty &&
                                      _amountController2.text.isEmpty) {
                                    setState(() {
                                      hasErrors = true;
                                    });
                                    Get.snackbar("Payment Error",
                                        "Please make sure at least one amount is paid.",
                                        colorText: defaultTextColor,
                                        snackPosition: SnackPosition.TOP,
                                        backgroundColor: Colors.red);
                                    return;
                                  } else {
                                    // setState(() {
                                    //   hasErrors = false;
                                    // });
                                    processPayment(context);
                                    if (depositType == "Bank") {
                                      payBankRequestDeposit();
                                    }
                                    if (depositType == "Cash") {
                                      payCashRequestDeposit();
                                    }
                                  }
                                  //  check before save
                                  //   Get.defaultDialog(
                                  //     title: "Confirm Payment",
                                  //     middleText: "Are you sure you want to make payment?",
                                  //     content: Container(),
                                  //     cancel: RawMaterialButton(
                                  //         shape: const StadiumBorder(),
                                  //         fillColor: primaryColor,
                                  //         onPressed: () {
                                  //           Get.back();
                                  //         },
                                  //         child: const Text(
                                  //           "Cancel",
                                  //           style: TextStyle(color: Colors.white),
                                  //         )),
                                  //
                                  //     confirm: RawMaterialButton(onPressed: (){
                                  //       processPayment(context);
                                  //       if(depositType == "Bank"){
                                  //         payBankRequestDeposit();
                                  //       }
                                  //       if(depositType == "Cash"){
                                  //         payCashRequestDeposit();
                                  //       }
                                  //     },
                                  //       shape: const StadiumBorder(),
                                  //       fillColor: primaryColor,
                                  //       child: const Text("Yes",style: TextStyle(color: Colors.white)),
                                  //     ),
                                  //   );
                                }
                              },
                              shape: const StadiumBorder(),
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
                            )
                          : Container(),
                  const SizedBox(height: 20)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onDropDownItemSelectedModeOfPayment(newValueSelected) {
    setState(() {
      _currentSelectedModeOfPayment1 = newValueSelected;
    });
  }

  void _onDropDownItemSelectedModeOfPayment2(newValueSelected) {
    setState(() {
      _currentSelectedModeOfPayment2 = newValueSelected;
    });
  }

  void _onDropDownItemSelectedBank(newValueSelected) {
    setState(() {
      _currentSelectedBank1 = newValueSelected;
    });
  }

  void _onDropDownItemSelectedBank2(newValueSelected) {
    setState(() {
      _currentSelectedBank2 = newValueSelected;
    });
  }

  void _onDropDownItemSelectedLocation(newValueSelected) {
    setState(() {
      _currentCashAtLocation1 = newValueSelected;
    });
  }

  void _onDropDownItemSelectedLocation2(newValueSelected) {
    setState(() {
      _currentCashAtLocation2 = newValueSelected;
    });
  }
  // void _onDropDownItemSelectedPaymentAction(newValueSelected) {
  //   setState(() {
  //     _currentPaymentAction = newValueSelected;
  //   });
  // }
}
