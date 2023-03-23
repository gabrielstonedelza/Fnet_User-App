import 'dart:async';
import 'dart:convert';
import 'package:direct_dialer/direct_dialer.dart';
import 'package:fnet_new/views/addwithdrawreference.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get/get.dart';
import 'customerregistration.dart';

class WithDrawal extends StatefulWidget {
  const WithDrawal({Key? key}) : super(key: key);

  @override
  _WithDrawalState createState() => _WithDrawalState();
}

class _WithDrawalState extends State<WithDrawal> {
  final List banks = [
    "Select bank",
    "Access Bank",
    "Cal Bank",
    "Fidelity Bank",
    "Ecobank",
    "Pan Africa",
    "First Bank of Nigeria",
    "SGSSB",
    "Adansi rural bank",
    "Kwumawuman Bank",
    "Omini bank",
  ];
  var _currentSelectedBank = "Select bank";
  final List withDrawalTypes = [
    "Select Withdrawal Type",
    "Cheque",
    "Atm",
    "Phone"
  ];

  var _currrentWithDrawalType = "Select Withdrawal Type";

  final List idTypes = [
    "Select Id Type",
    "Passport",
    "Ghana Card",
    "Drivers License",
    "Voters Id",
  ];
  var _currentSelectedIdType = "Select Id Type";
  bool isPosting = false;
  void _startPosting() async {
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isPosting = false;
    });
  }

  bool userExists = false;
  late List allCustomers = [];
  bool isLoading = true;
  late List customersPhone = [];

  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _amountController = TextEditingController();
  late final TextEditingController _customerPhoneController =
      TextEditingController();
  late final TextEditingController _customerNameController =
      TextEditingController();
  late final TextEditingController _customerIdNumberController =
      TextEditingController();
  bool hasAmount = false;

  fetchCustomers() async {
    const url = "https://fnetghana.xyz/all_customers/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink);

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allCustomers = json.decode(jsonData);
      for (var i in allCustomers) {
        customersPhone.add(i['phone']);
      }
    }
    setState(() {
      isLoading = false;
      allCustomers = allCustomers;
    });
  }

  Future<void> dial() async {
    final dialer = await DirectDialer.instance;
    await dialer.dial('*171\%23#');
  }

  processWithdraw(context) async {
    const registerUrl = "https://fnetghana.xyz/customer_withdrawal/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "customer": _customerPhoneController.text,
      "bank": _currentSelectedBank,
      "withdrawal_type": _currrentWithDrawalType,
      "id_type": _currentSelectedIdType,
      "id_number": _customerIdNumberController.text,
      "amount": _amountController.text,
      "app_version" : "4"
    });
    if (res.statusCode == 201) {
      Get.snackbar("Success", "Withdrawal as saved",
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);
      // dial();
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return AddWithdrawReference(
            withdrawal_amount: _amountController.text,
            customerphone: _customerPhoneController.text);
      }));
    } else {
      Get.snackbar("Withdraw Error", res.body.toString(),
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
    fetchCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Customer Withdrawal"),
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      onChanged: (value) {
                        if (value.length == 10 &&
                            customersPhone.contains(value)) {
                          Get.snackbar("Success", "User is in system",
                              colorText: defaultTextColor,
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: snackColor);
                        }
                        if (value.length == 10 &&
                            !customersPhone.contains(value)) {
                          Get.snackbar(
                              "Customer Error", "User is not in system",
                              colorText: defaultTextColor,
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.red);

                          Timer(
                              const Duration(seconds: 3),
                              () => Navigator.push(context,
                                      MaterialPageRoute(builder: (_) {
                                    return const CustomerRegistration();
                                  })));
                        }
                      },
                      controller: _customerPhoneController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.person, color: secondaryColor),
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _customerNameController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.person, color: secondaryColor),
                          labelText: "Enter customer name",
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
                          return "Please enter customer name";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey, width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: DropdownButton(
                          hint: const Text("Select bank"),
                          isExpanded: true,
                          underline: const SizedBox(),

                          items: banks.map((dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {
                            _onDropDownItemSelectedBank(newValueSelected);
                          },
                          value: _currentSelectedBank,
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
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: DropdownButton(
                          hint: const Text("Select withdrawal type"),
                          isExpanded: true,
                          underline: const SizedBox(),

                          items: withDrawalTypes.map((dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {
                            _onDropDownItemSelectedIdWithDrawalType(newValueSelected);
                          },
                          value: _currrentWithDrawalType,
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
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: DropdownButton(
                          hint: const Text("Select Id Type"),
                          isExpanded: true,
                          underline: const SizedBox(),

                          items: idTypes.map((dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {
                            _onDropDownItemSelectedIdTypes(newValueSelected);
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
                          prefixIcon:
                              const Icon(Icons.person, color: secondaryColor),
                          labelText: "Enter id number",
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
                          return "Please enter id number";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _amountController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          prefixIcon: Image.asset(
                            "assets/images/cedi.png",
                            width: 15,
                            height: 15,
                          ),
                          labelText: "Enter amount",
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
                          return "Please enter a username";
                        }
                      },
                    ),
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
                            setState(() {
                              isPosting = true;
                            });
                            if (!_formKey.currentState!.validate()) {
                              return;
                            } else {
                              if (_currentSelectedIdType == "Select Id Type") {
                                Get.snackbar(
                                    "Id Error", "please select a valid id type",
                                    colorText: defaultTextColor,
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red);
                                return;
                              }
                              if (_currentSelectedBank == "Select bank") {
                                Get.snackbar("Bank Select error",
                                    "please select bank from the list",
                                    colorText: defaultTextColor,
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red);
                                return;
                              } else {
                                processWithdraw(context);
                              }
                            }
                          },
                          shape: const StadiumBorder(),
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onDropDownItemSelectedBank(newValueSelected) {
    setState(() {
      _currentSelectedBank = newValueSelected;
    });
  }

  void _onDropDownItemSelectedIdTypes(newValueSelected) {
    setState(() {
      _currentSelectedIdType = newValueSelected;
    });
  }
  void _onDropDownItemSelectedIdWithDrawalType(newValueSelected) {
    setState(() {
      _currrentWithDrawalType = newValueSelected;
    });
  }
}
