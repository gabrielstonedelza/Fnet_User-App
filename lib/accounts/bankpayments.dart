import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../sendsms.dart';
import '../static/app_colors.dart';
import '../views/homepage.dart';

class MyBankPayments extends StatefulWidget {
  const MyBankPayments({Key? key}) : super(key: key);

  @override
  State<MyBankPayments> createState() => _MyBankPaymentsState();
}

class _MyBankPaymentsState extends State<MyBankPayments> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tellerNameController = TextEditingController();
  late final TextEditingController _tellerNumberController = TextEditingController();
  late final TextEditingController _amountController = TextEditingController();
  late final TextEditingController _d200Controller = TextEditingController();
  late final TextEditingController _d100Controller = TextEditingController();
  late final TextEditingController _d50Controller = TextEditingController();
  late final TextEditingController _d20Controller = TextEditingController();
  late final TextEditingController _d10Controller = TextEditingController();
  late final TextEditingController _d5Controller = TextEditingController();
  late final TextEditingController _d2Controller = TextEditingController();
  late final TextEditingController _d1Controller = TextEditingController();

  late String d200 = "";
  late String d100 = "";
  late String d50 = "";
  late String d20 = "";
  late String d10 = "";
  late String d5 = "";
  late String d2 = "";
  late String d1 = "";
  late String total = "";
  bool amountNotEqualTotal = false;
  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  bool isPosting = false;
  void _startPosting()async{
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 5));
    setState(() {
      isPosting = false;
    });
  }
  final SendSmsController sendSms = SendSmsController();
  void launchWhatsapp({@required number,@required message})async{
    String url = "whatsapp://send?phone=$number&text=$message";
    await canLaunch(url) ? launch(url) : Get.snackbar("Sorry", "Cannot open whatsapp",
        colorText: defaultTextColor,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: snackColor
    );
  }

  processBankDeposit() async {
    const registerUrl = "https://fnetghana.xyz/post_at_bank/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "teller_name": _tellerNameController.text,
      "teller_phone": _tellerNumberController.text,
      "amount": _amountController.text,
      "d_200": _d200Controller.text,
      "d_100": _d100Controller.text,
      "d_50": _d50Controller.text,
      "d_20": _d20Controller.text,
      "d_10": _d10Controller.text,
      "d_5": _d5Controller.text,
      "d_2": _d2Controller.text,
      "d_1": _d1Controller.text,
      "app_version" : "4"
    });

    if (res.statusCode == 201) {
      Get.defaultDialog(
          title: "",
          radius: 20,
          backgroundColor: Colors.black54,
          barrierDismissible: false,
          content: const Row(
            children: [
              Expanded(child: Center(child: CircularProgressIndicator.adaptive(
                strokeWidth: 5,
                backgroundColor: primaryColor,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              ))),
              Expanded(child: Text("Processing",style: TextStyle(color: Colors.white),))
            ],
          )
      );
      Get.snackbar("Congratulations", "Transaction was successful",
          colorText: defaultTextColor,
          snackPosition: SnackPosition.TOP,
          backgroundColor: snackColor,duration: const Duration(seconds: 5));
      String telNum = _tellerNumberController.text;
      telNum = telNum.replaceFirst("0", '+233');
      launchWhatsapp(message: "Hello ${_tellerNameController.text},\n ${username.capitalize} just made a bank deposit of GHC${_amountController.text} to you.Transaction details include \n 200 Notes => ${_d200Controller.text}($d200),\n 100 Notes =>${_d100Controller.text}($d100), \n50 Notes =>${_d50Controller.text}($d50), \n20 Notes =>${_d20Controller.text}($d20), \n10 Notes =>${_d10Controller.text}($d10), \n5 Notes =>${_d5Controller.text}($d5), \n2 Notes =>${_d2Controller.text}($d2), \n1 Notes =>${_d1Controller.text}($d1),", number: telNum,);

      // sendSms.sendMySms(telNum, "FNET","Hello ${_tellerNameController.text},\n ${username.capitalize} just made a bank deposit of GHC${_amountController.text} to you.Transaction details include \n 200 Notes => ${_d200Controller.text}($d200),\n 100 Notes =>${_d100Controller.text}($d100), \n50 Notes =>${_d50Controller.text}($d50), \n20 Notes =>${_d20Controller.text}($d20), \n10 Notes =>${_d10Controller.text}($d10), \n5 Notes =>${_d5Controller.text}($d5), \n2 Notes =>${_d2Controller.text}($d2), \n1 Notes =>${_d1Controller.text}($d1),");

      Get.offAll(()=> const HomePage(message: null,));
      // Get.offAll(() => const HomePage());
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
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Bank Payments"),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 18.0,left: 10,right: 10),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      onChanged: (value) {
                      },
                      controller: _tellerNameController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          prefixIcon:
                          const Icon(Icons.person, color: secondaryColor),
                          labelText: "Teller name",
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
                          return "Please enter teller name";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      onChanged: (value) {
                      },
                      controller: _tellerNumberController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          prefixIcon:
                          const Icon(Icons.phone, color: secondaryColor),
                          labelText: "Teller's phone",
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
                          return "Please enter teller's phone";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      children: [
                        TextFormField(
                          onChanged: (value) {
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

                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Column(
                            children: [
                              TextFormField(
                                onChanged: (value) {
                                  var dt = int.parse(value) * 200;
                                  setState(() {
                                    d200 = dt.toString();
                                  });
                                },
                                controller: _d200Controller,
                                cursorColor: primaryColor,
                                cursorRadius: const Radius.elliptical(10, 10),
                                cursorWidth: 10,
                                decoration: InputDecoration(

                                    labelText: "200 Notes",
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
                                    return "Please enter GHS 200 Notes";
                                  }
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0,bottom: 12),
                                child: Text(d200,style: const TextStyle(fontWeight: FontWeight.bold),),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Column(
                            children: [
                              TextFormField(
                                onChanged: (value) {
                                  var dt = int.parse(value) * 100;
                                  setState(() {
                                    d100 = dt.toString();
                                  });
                                },
                                controller: _d100Controller,
                                cursorColor: primaryColor,
                                cursorRadius: const Radius.elliptical(10, 10),
                                cursorWidth: 10,
                                decoration: InputDecoration(

                                    labelText: "100 Notes",
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
                                    return "Please enter GHS 100 Notes";
                                  }
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0,bottom: 12),
                                child: Text(d100,style: const TextStyle(fontWeight: FontWeight.bold),),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Column(
                            children: [
                              TextFormField(
                                onChanged: (value) {
                                  var dt = int.parse(value) * 50;
                                  setState(() {
                                    d50 = dt.toString();
                                  });
                                },
                                controller: _d50Controller,
                                cursorColor: primaryColor,
                                cursorRadius: const Radius.elliptical(10, 10),
                                cursorWidth: 10,
                                decoration: InputDecoration(

                                    labelText: "50 Notes",
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
                                    return "Please enter GHS 50 Notes";
                                  }
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0,bottom: 12),
                                child: Text(d50,style: const TextStyle(fontWeight: FontWeight.bold),),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Column(
                            children: [
                              TextFormField(
                                onChanged: (value) {
                                  var dt = int.parse(value) * 20;
                                  setState(() {
                                    d20 = dt.toString();
                                  });
                                },
                                controller: _d20Controller,
                                cursorColor: primaryColor,
                                cursorRadius: const Radius.elliptical(10, 10),
                                cursorWidth: 10,
                                decoration: InputDecoration(

                                    labelText: "20 Notes",
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
                                    return "Please enter GHS 20 Notes";
                                  }
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0,bottom: 12),
                                child: Text(d20,style: const TextStyle(fontWeight: FontWeight.bold),),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Column(
                            children: [
                              TextFormField(
                                onChanged: (value) {
                                  var dt = int.parse(value) * 10;
                                  setState(() {
                                    d10 = dt.toString();
                                  });
                                },
                                controller: _d10Controller,
                                cursorColor: primaryColor,
                                cursorRadius: const Radius.elliptical(10, 10),
                                cursorWidth: 10,
                                decoration: InputDecoration(

                                    labelText: "10 Notes",
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
                                    return "Please enter GHS 10 Notes";
                                  }
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0,bottom: 12),
                                child: Text(d10,style: const TextStyle(fontWeight: FontWeight.bold),),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Column(
                            children: [
                              TextFormField(
                                onChanged: (value) {
                                  var dt = int.parse(value) * 5;
                                  setState(() {
                                    d5 = dt.toString();
                                  });
                                },
                                controller: _d5Controller,
                                cursorColor: primaryColor,
                                cursorRadius: const Radius.elliptical(10, 10),
                                cursorWidth: 10,
                                decoration: InputDecoration(

                                    labelText: "5 Notes",
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
                                    return "Please enter GHS 5 Notes";
                                  }
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0,bottom: 12),
                                child: Text(d5,style: const TextStyle(fontWeight: FontWeight.bold),),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Column(
                            children: [
                              TextFormField(
                                onChanged: (value) {
                                  var dt = int.parse(value) * 2;
                                  setState(() {
                                    d2 = dt.toString();
                                  });
                                },
                                controller: _d2Controller,
                                cursorColor: primaryColor,
                                cursorRadius: const Radius.elliptical(10, 10),
                                cursorWidth: 10,
                                decoration: InputDecoration(

                                    labelText: "2 Notes",
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
                                    return "Please enter GHS 2 Notes";
                                  }
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0,bottom: 12),
                                child: Text(d2,style: const TextStyle(fontWeight: FontWeight.bold),),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10,),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Column(
                            children: [
                              TextFormField(
                                onChanged: (value) {
                                  var dt = int.parse(value) * 1;
                                  setState(() {
                                    d1 = dt.toString();
                                  });
                                },
                                controller: _d1Controller,
                                cursorColor: primaryColor,
                                cursorRadius: const Radius.elliptical(10, 10),
                                cursorWidth: 10,
                                decoration: InputDecoration(

                                    labelText: "1 Notes",
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
                                    return "Please enter GHS 1 Notes";
                                  }
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0,bottom: 12),
                                child: Text(d1,style: const TextStyle(fontWeight: FontWeight.bold),),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Center(child:Text("Please enter (zero) in the note field that will be empty.")),
                  Row(
                    children: [
                      Expanded(
                          child: amountNotEqualTotal ? Text("TOTAL: $total",style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.red,fontSize: 20),) : const Text("")
                      ),
                      const SizedBox(width: 10,),
                      const Expanded(
                          child:  Text("")
                      )
                    ],
                  ),
              isPosting ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  backgroundColor: primaryColor
                )
              ) :   RawMaterialButton(
                    onPressed: () {
                      _startPosting();
                      setState(() {
                        isPosting = true;
                      });
                      if (!_formKey.currentState!.validate()) {
                        return;
                      } else {
                        var mainTotal = int.parse(d200) + int.parse(d100) + int.parse(d50) + int.parse(d20) + int.parse(d10) + int.parse(d5) + int.parse(d2) + int.parse(d1);
                        if(int.parse(_amountController.text) != mainTotal){
                          Get.snackbar("Total Error", "Your total should be equal to the amount",
                              colorText: Colors.white,
                              backgroundColor: Colors.red,
                              snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 5)
                          );
                          setState(() {
                            total = mainTotal.toString();
                            amountNotEqualTotal = true;
                          });
                                  return;
                        }
                        else{
                          processBankDeposit();
                        }
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
                  ),
                
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
