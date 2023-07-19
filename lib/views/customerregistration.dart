import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../loadingui.dart';
import '../sendsms.dart';

import 'homepage.dart';

class CustomerRegistration extends StatefulWidget {

  const CustomerRegistration({Key? key}) : super(key: key);

  @override
  _UserRegistration createState() => _UserRegistration();
}

class _UserRegistration extends State<CustomerRegistration> {
  final _formKey = GlobalKey<FormState>();
  void _startPosting()async{
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 4));
    setState(() {
      isPosting = false;
    });
  }

  bool isPosting = false;
  late List allCustomers = [];
  bool isLoading = true;
  late List customersPhones = [];
  late List customersNames = [];
  bool isInSystem = false;
  final List ids = [
    "Select Id Type",
    "Ghana Card",
    "Passport",
    "Drivers License",
    "Voters Id",
  ];
  var _currentSelectedId = "Select Id Type";

  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  late DateTime _dateTime;
  fetchCustomers() async {
    const url = "https://fnetghana.xyz/all_customers/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink);

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allCustomers = json.decode(jsonData);
      for (var i in allCustomers) {
        customersPhones.add(i['phone']);
        customersNames.add(i['name']);
      }
    }
    setState(() {
      isLoading = false;
      allCustomers = allCustomers;
    });
  }

  late final TextEditingController name = TextEditingController();
  late final TextEditingController location = TextEditingController();
  late final TextEditingController digitalAddress = TextEditingController();
  late final TextEditingController phoneController = TextEditingController();
  late final TextEditingController idTypeController = TextEditingController();
  late final TextEditingController idNumberController = TextEditingController();
  late TextEditingController dob = TextEditingController();
  final SendSmsController sendSms = SendSmsController();

  registerCustomer()async{
    const registerUrl = "https://fnetghana.xyz/register_customer/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "name": name.text,
      "location": location.text,
      "digital_address": digitalAddress.text,
      "id_type": _currentSelectedId,
      "id_number": idNumberController.text,
      "phone": phoneController.text,
      "date_of_birth": dob.text,
    });
    if(res.statusCode == 201){
      Get.snackbar("Congratulations", "Customer was created successfully",
          colorText: defaultTextColor,
          snackPosition: SnackPosition.TOP,
          backgroundColor: snackColor);
      String telnum = phoneController.text;
      telnum = telnum.replaceFirst("0", '+233');
      sendSms.sendMySms(telnum, "FNET",
          "Welcome ${name.text}, you are now registered on FNET App.For more information please kindly call 0244950505.");
      Get.offAll(()=>const HomePage(message: null,));
    }
    else{
      Get.snackbar("Error", res.body.toString(),
          colorText: defaultTextColor,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCustomers();
    if(storage.read("usertoken") != null){
      setState(() {
        uToken = storage.read("usertoken");
      });
    }
    if(storage.read("username") != null){
      setState(() {
        username = storage.read("username");
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Customer Registration"),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      onChanged: (value){
                        if(value.length == 10 && customersPhones.contains(value)){
                          Get.snackbar("Sorry", "Customer is already in the system",
                              colorText: defaultTextColor,
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: snackColor);
                          setState(() {
                            isInSystem = true;
                          });
                        }
                        else if(value.length == 10 && !customersPhones.contains(value)){
                          Get.snackbar("New Customer", "Customer is not in the system",
                              colorText: defaultTextColor,
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: snackColor);
                          setState(() {
                            isInSystem = false;
                          });
                        }
                      },
                      controller: phoneController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          labelText: "customer phone number",
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
                          return "Please enter customer phone number";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: name,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
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
                          return "Please enter customer's name";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: location,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          labelText: "Enter customer's location",
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
                          return "Please enter customer's location";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: digitalAddress,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          labelText: "Enter customer's digital address",
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
                          return "Please enter customer's digital address";
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
                          hint: const Text("Select id type"),
                          isExpanded: true,
                          underline: const SizedBox(),
                          style: const TextStyle(
                              color: Colors.black, fontSize: 20),
                          items: ids.map((dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {
                            _onDropDownItemSelectedBank(newValueSelected);
                          },
                          value: _currentSelectedId,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: idNumberController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
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
                      controller: dob,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      readOnly: true,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.event,color: secondaryColor,),
                          onPressed: (){
                              showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime(2080)
                              ).then((value) {
                                setState(() {
                                  _dateTime = value!;
                                  dob.text = _dateTime.toString().split("00").first;
                                });
                              });
                          },
                        ),
                          labelText: "click on icon to pick date of birth",
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
                          return "Please enter customer's date of birth";
                        }
                      },
                    ),
                  ),

                  !isInSystem ? isPosting ? const LoadingUi() : RawMaterialButton(
                    onPressed: () {
                      _startPosting();
                      if (!_formKey.currentState!.validate()) {
                        return;
                      } else {
                        registerCustomer();
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
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
                  ):Container(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
  void _onDropDownItemSelectedBank(newValueSelected) {
    setState(() {
      _currentSelectedId = newValueSelected;
    });
  }
}
