
import 'package:direct_dialer/direct_dialer.dart';
import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:fnet_new/views/bottomnavigation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../sendsms.dart';

class MomoDeposit extends StatefulWidget {
  const MomoDeposit({Key? key}) : super(key: key);

  @override
  _MomoDepositState createState() => _MomoDepositState();
}

class _MomoDepositState extends State<MomoDeposit> {
  bool isPosting = false;

  void _startPosting()async{
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 4));
    setState(() {
      isPosting = false;
    });
  }
  bool hasAmount = false;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController = TextEditingController();
  late final TextEditingController _customerPhoneController = TextEditingController();
  // late final TextEditingController _customerNameController = TextEditingController();
  late final TextEditingController _agentCommissionController = TextEditingController();
  late final TextEditingController _chargesController = TextEditingController();
  late final TextEditingController _depositorNameController = TextEditingController();
  late final TextEditingController _depositorPhoneController = TextEditingController();

  final List mobileMoneyNetworks = [
    "Select Network",
    "Mtn",
    "AirtelTigo",
    "Vodafone"
  ];

  final List depositTypes = [
    "Select Deposit Type",
    "Loading",
    "Direct",
    "Agent to Agent",
  ];

  var _currentSelectedNetwork = "Select Network";
  var _currentSelectedType = "Select Deposit Type";
  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  late String mtnEcashNow = "";
  late String tigoAirtelEcashNow = "";
  late String vodafoneEcashNow = "";
  late String physicalNow = "";
  late String ecashNow = "";
  bool isRegular = false;
  final SendSmsController sendSms = SendSmsController();
  bool isDirect = false;

  bool isLoading = true;
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


  processMomoDeposit() async {
    const registerUrl = "https://fnetghana.xyz/post_momo_deposit/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "customer_phone": _customerPhoneController.text,
      // "customer_name": _customerNameController.text,
      "depositor_name": _depositorNameController.text,
      "depositor_number": _depositorPhoneController.text,
      "network": _currentSelectedNetwork,
      "type": _currentSelectedType,
      "amount": _amountController.text,
      "charges": _chargesController.text,
      "agent_commission": _agentCommissionController.text,
    });

    if (res.statusCode == 201) {
      Get.snackbar("Congratulations", "Transaction was successful",
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);
      String telnum = _depositorPhoneController.text;
      telnum = telnum.replaceFirst("0", '+233');
      sendSms.sendMySms(telnum, "FNET",
          "Dear ${_depositorNameController.text}, your MTN deposit of ${_amountController.text}  ${_customerPhoneController.text} at F-NET is successful. For more information call 0244950505 Thanks");
      if(_currentSelectedNetwork == "Mtn"){
        var mtnenow = double.parse(mtnEcashNow) - double.parse(_amountController.text);
        var enow = double.parse(ecashNow) - double.parse(_amountController.text);
        var phynow = double.parse(physicalNow) + double.parse(_amountController.text);

        storage.write("mtnecashnow", mtnenow.round());
        storage.write("physicalnow", phynow.round());
        storage.write("ecashnow", enow.round());
      }

      if(_currentSelectedNetwork == "AirtelTigo"){
        var tigoenow = double.parse(tigoAirtelEcashNow) - double.parse(_amountController.text);
        var enow = double.parse(ecashNow) - double.parse(_amountController.text);
        var phynow = double.parse(physicalNow) + double.parse(_amountController.text);
        storage.write("tigoairtelecashnow", tigoenow.round());
        storage.write("physicalnow", phynow.round());
        storage.write("ecashnow", enow.round());
      }
      if(_currentSelectedNetwork == "Vodafone"){
        var vodaenow = double.parse(vodafoneEcashNow) - double.parse(_amountController.text);
        var enow = double.parse(ecashNow) - double.parse(_amountController.text);
        var phynow = double.parse(physicalNow) + double.parse(_amountController.text);
        storage.write("vodafoneecashnow", vodaenow.round());
        storage.write("physicalnow", phynow.round());
        storage.write("ecashnow", enow.round());
      }
      Get.offAll(() => const MyBottomNavigationBar());
      if(_currentSelectedNetwork == "Mtn"){
        dialMtn();
        Get.back();
      }
      if(_currentSelectedNetwork == "Vodafone"){
        dialVodafone();
        Get.back();
      }
      if(_currentSelectedNetwork == "AirtelTigo"){
        dialTigo();
        Get.back();
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

    if(storage.read("mtnecashnow") != null){
      setState(() {
        mtnEcashNow = storage.read("mtnecashnow").toString();
      });
    }
    if(storage.read("tigoairtelecashnow") != null){
      setState(() {
        tigoAirtelEcashNow = storage.read("tigoairtelecashnow").toString();
      });
    }

    if(storage.read("vodafoneecashnow") != null){
      setState(() {
        vodafoneEcashNow = storage.read("vodafoneecashnow").toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Momo Deposit"),
        backgroundColor: primaryColor,
      ),
      body:  ListView(
        children: [
          const SizedBox(height: 40,),
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
                  // Padding(
                  //   padding: const EdgeInsets.only(bottom: 10.0),
                  //   child: TextFormField(
                  //     // controller: _customerNameController,
                  //     cursorColor: primaryColor,
                  //     cursorRadius: const Radius.elliptical(10, 10),
                  //     cursorWidth: 10,
                  //     decoration: InputDecoration(
                  //         prefixIcon:
                  //         const Icon(Icons.person, color: secondaryColor),
                  //         labelText: "Enter customer name",
                  //         labelStyle: const TextStyle(color: secondaryColor),
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
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: DropdownButton(
                          hint: const Text("Select Network"),
                          isExpanded: true,
                          underline: const SizedBox(),

                          items: mobileMoneyNetworks.map((dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {
                            _onDropDownItemSelectedNetwork(newValueSelected);
                          },
                          value: _currentSelectedNetwork,
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
                          hint: const Text("Select Deposit Type"),
                          isExpanded: true,
                          underline: const SizedBox(),

                          items: depositTypes.map((dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {
                            _onDropDownItemSelectedDepositTypes(newValueSelected);
                            if(newValueSelected == "Direct") {
                              setState(() {
                                isDirect = true;
                              });
                            }
                            else{
                              setState(() {
                                isDirect = false;
                              });
                            }
                          },
                          value: _currentSelectedType,
                        ),
                      ),
                    ),
                  ),
               isDirect ?  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _depositorNameController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          prefixIcon:
                          const Icon(Icons.person, color: secondaryColor),
                          labelText: "Enter depositors name",
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
                          return "Please enter depositors name";
                        }
                      },
                    ),
                  ) : Container(),
                  isDirect ? Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _depositorPhoneController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          prefixIcon:
                          const Icon(Icons.person, color: secondaryColor),
                          labelText: "Enter depositors phone number",
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
                          return "Please enter depositors phone number";
                        }
                      },
                    ),
                  ) : Container(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      onChanged: (value){
                        if(value.length > 1){
                          setState(() {
                            hasAmount = true;
                          });
                        }
                        if(value == ""){
                          setState(() {
                            hasAmount = false;
                          });
                        }
                        if(_currentSelectedType == "Direct"){
                          if(int.parse(value) > 0 && int.parse(value) <= 50){
                            setState(() {
                              _agentCommissionController.text = .50.toString();
                              _chargesController.text = .50.toString();
                            });
                          }
                          if(int.parse(value) >= 51 && int.parse(value) <= 1000){
                            setState(() {
                              var charges = double.parse(value) / 100;
                              var agentcommission = double.parse(value) / 100;
                              _agentCommissionController.text = agentcommission.toString();
                              _chargesController.text = charges.toString();
                            });
                          }
                          if(int.parse(value) >= 1000 && int.parse(value) <= 2900){
                            setState(() {
                              int charges = 10;
                              _agentCommissionController.text = charges.toString();
                              _chargesController.text = charges.toString();
                            });
                          }
                          if(int.parse(value) >= 3000 && int.parse(value) <= 3900){
                            setState(() {
                              int charges = 15;
                              _agentCommissionController.text = charges.toString();
                              _chargesController.text = charges.toString();
                            });
                          }
                          if(int.parse(value) >= 4000 && int.parse(value) <= 4900){
                            setState(() {
                              int charges = 20;
                              _agentCommissionController.text = charges.toString();
                              _chargesController.text = charges.toString();
                            });
                          }
                          if(int.parse(value) >= 5000 && int.parse(value) <= 5900){
                            setState(() {
                              int charges = 25;
                              _agentCommissionController.text = charges.toString();
                              _chargesController.text = charges.toString();
                            });
                          }
                          if(int.parse(value) >= 6000 && int.parse(value) <= 6900){
                            setState(() {
                              int charges = 30;
                              _agentCommissionController.text = charges.toString();
                              _chargesController.text = charges.toString();
                            });
                          }
                          if(int.parse(value) >= 7000 && int.parse(value) <= 7900){
                            setState(() {
                              int charges = 35;
                              _agentCommissionController.text = charges.toString();
                              _chargesController.text = charges.toString();
                            });
                          }
                          if(int.parse(value) >= 8000 && int.parse(value) <= 8900){
                            setState(() {
                              int charges = 40;
                              _agentCommissionController.text = charges.toString();
                              _chargesController.text = charges.toString();
                            });
                          }
                          if(int.parse(value) >= 9000 && int.parse(value) <= 9999){
                            setState(() {
                              int charges = 45;
                              _agentCommissionController.text = charges.toString();
                              _chargesController.text = charges.toString();
                            });
                          }
                          if(int.parse(value) >= 10000){
                            setState(() {
                              int charges = 50;
                              _agentCommissionController.text = charges.toString();
                              _chargesController.text = charges.toString();
                            });
                          }
                        }
                      //  agent to agent
                        if(_currentSelectedType == "Agent to Agent"){
                          if(int.parse(value) >= 1000 && int.parse(value) <= 2900){
                            setState(() {
                              int charges = 10;
                              _agentCommissionController.text = charges.toString();
                              _chargesController.text = charges.toString();
                            });
                          }
                          if(int.parse(value) >= 3000 && int.parse(value) <= 3900){
                            setState(() {
                              int charges = 15;
                              _agentCommissionController.text = charges.toString();
                              _chargesController.text = charges.toString();
                            });
                          }
                          if(int.parse(value) >= 4000 && int.parse(value) <= 4900){
                            setState(() {
                              int charges = 20;
                              _agentCommissionController.text = charges.toString();
                              _chargesController.text = charges.toString();
                            });
                          }
                          if(int.parse(value) >= 5000 && int.parse(value) <= 5900){
                            setState(() {
                              int charges = 25;
                              _agentCommissionController.text = charges.toString();
                              _chargesController.text = charges.toString();
                            });
                          }
                          if(int.parse(value) >= 6000 && int.parse(value) <= 6900){
                            setState(() {
                              int charges = 30;
                              _agentCommissionController.text = charges.toString();
                              _chargesController.text = charges.toString();
                            });
                          }
                          if(int.parse(value) >= 7000 && int.parse(value) <= 7900){
                            setState(() {
                              int charges = 35;
                              _agentCommissionController.text = charges.toString();
                              _chargesController.text = charges.toString();
                            });
                          }
                          if(int.parse(value) >= 8000 && int.parse(value) <= 8900){
                            setState(() {
                              int charges = 40;
                              _agentCommissionController.text = charges.toString();
                              _chargesController.text = charges.toString();
                            });
                          }
                          if(int.parse(value) >= 9000 && int.parse(value) <= 9999){
                            setState(() {
                              int charges = 45;
                              _agentCommissionController.text = charges.toString();
                              _chargesController.text = charges.toString();
                            });
                          }
                          if(int.parse(value) >= 10000){
                            setState(() {
                              int charges = 50;
                              _agentCommissionController.text = charges.toString();
                              _chargesController.text = charges.toString();
                            });
                          }
                        }
                        if(_currentSelectedType == "Regular"){
                          setState(() {
                            isRegular = true;
                          });
                        }
                      },
                      controller: _amountController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          prefixIcon:
                          const Icon(Icons.person, color: secondaryColor),
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
                          return "Please enter amount";
                        }
                      },
                    ),
                  ),
                hasAmount ?  Column(
                    children: [
                     !isRegular ? Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          controller: _agentCommissionController,
                          cursorColor: primaryColor,
                          cursorRadius: const Radius.elliptical(10, 10),
                          cursorWidth: 10,
                          readOnly: true,
                          decoration: InputDecoration(
                              prefixIcon:
                              const Icon(Icons.person, color: secondaryColor),
                              labelText: "Agent Commission",
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

                        ),
                      ):Container(),
                      !isRegular ?  Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          controller: _chargesController,
                          cursorColor: primaryColor,
                          cursorRadius: const Radius.elliptical(10, 10),
                          cursorWidth: 10,
                          readOnly: true,
                          decoration: InputDecoration(
                              prefixIcon:
                              const Icon(Icons.person, color: secondaryColor),
                              labelText: "Charges",
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

                        ),
                      ):Container(),
                    ],
                  ):Container(),
                  const SizedBox(
                    height: 20,
                  ),
                  isPosting ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                      color: primaryColor,
                    ),
                  ) : RawMaterialButton(
                    onPressed: () {
                      _startPosting();
                      if (!_formKey.currentState!.validate()) {
                        return;
                      } else {

                        if(_currentSelectedType == "Select Deposit Type" || _currentSelectedNetwork == "Select Network"){
                          Get.snackbar("Bank Error", "Please select customers bank from the list",colorText: Colors.white,backgroundColor: Colors.red,snackPosition: SnackPosition.BOTTOM);

                          return;
                        }
                        else{
                          Get.snackbar("Please wait", "processing",
                              colorText: defaultTextColor,
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: snackColor);
                          processMomoDeposit();
                        }
                      }
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
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

  void _onDropDownItemSelectedDepositTypes(newValueSelected) {
    setState(() {
      _currentSelectedType = newValueSelected;
    });
  }
}
