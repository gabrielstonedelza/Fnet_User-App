import 'package:flutter/material.dart';
import 'package:fnet_new/controllers/accountcontroller.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../loadingui.dart';
import '../views/homepage.dart';

class AccountView extends StatefulWidget {
  const AccountView({Key? key}) : super(key: key);

  @override
  _AccountViewState createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
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

  final accountController = AccountController.to;
  late final TextEditingController physicalController = TextEditingController();
  late final TextEditingController _mtnEcashController = TextEditingController();
  late final TextEditingController _tigoAirtelEcashController = TextEditingController();
  late final TextEditingController _vodafoneEcashController = TextEditingController();
  var mtnECash = "";
  var mtnECashNow = "";

  var tigoAirtelECash = "";
  var tigoAirtelECashNow = "";
  var vodafoneECash = "";
  var vodafoneECashNow = "";
  var accountsToday = "";

  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  double tigoairtel = 0.0;
  double vodafone = 0.0;
  double physical = 0.0;

  addAccountsToday() async {
    const accountUrl = "https://www.fnetghana.xyz/post_momo_accounts_started/";
    final myLink = Uri.parse(accountUrl);
    http.Response response = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "physical": physical.toString(),
      "mtn_ecash": _mtnEcashController.text,
      "tigoairtel_ecash": tigoairtel.toString(),
      "vodafone_ecash": vodafone.toString(),
    });
    if (response.statusCode == 201) {
      Get.snackbar("Success", "You have added accounts for today",
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);

      var accountCreatedToday = "Account Created";
      // int pnow = int.parse(physicalController.text);
      int enow = int.parse(_mtnEcashController.text);

      storage.write("mtnecashnow", _mtnEcashController.text);
      // storage.write("tigoairtelecashnow", _tigoAirtelEcashController.text);
      // storage.write("vodafoneecashnow", _vodafoneEcashController.text);
      // storage.write("physicalnow", pnow);
      storage.write("ecashnow", enow);

      storage.write("accountcreatedtoday", accountsToday);
      Get.offAll(() => const HomePage(message: null,));
    } else {
      Get.snackbar("Account", response.body.toString(),
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

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Add accounts today"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 40,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.only(bottom: 10.0,left: 10),
                  //   child: TextFormField(
                  //     controller: physicalController,
                  //     cursorColor: primaryColor,
                  //     cursorRadius: const Radius.elliptical(10, 10),
                  //     cursorWidth: 10,
                  //     decoration: InputDecoration(
                  //         labelText: "Physical Cash",
                  //         labelStyle: const TextStyle(color: secondaryColor),
                  //         focusColor: primaryColor,
                  //         fillColor: primaryColor,
                  //         focusedBorder: OutlineInputBorder(
                  //             borderSide: const BorderSide(
                  //                 color: primaryColor, width: 2),
                  //             borderRadius: BorderRadius.circular(12)),
                  //         border: OutlineInputBorder(
                  //             borderRadius: BorderRadius.circular(12))),
                  //     keyboardType: TextInputType.number,
                  //     validator: (value) {
                  //       if(value!.isEmpty){
                  //         return "Please enter your physical cash";
                  //       }
                  //     },
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: TextFormField(
                      controller: _mtnEcashController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          labelText: "Mtn ECash",
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
                        if(value!.isEmpty){
                          return "Please enter your mtn ecash";
                        }
                      },
                    ),
                  ),
                  // const SizedBox(height: 10,),
                  // Row(
                  //   children: [
                  //
                  //     Expanded(
                  //       child: Padding(
                  //         padding: const EdgeInsets.only(left: 10.0),
                  //         child: TextFormField(
                  //           controller: _tigoAirtelEcashController,
                  //           cursorColor: primaryColor,
                  //           cursorRadius: const Radius.elliptical(10, 10),
                  //           cursorWidth: 10,
                  //           decoration: InputDecoration(
                  //               labelText: "TigoAirtel ECash",
                  //               labelStyle: const TextStyle(color: secondaryColor),
                  //               focusColor: primaryColor,
                  //               fillColor: primaryColor,
                  //               focusedBorder: OutlineInputBorder(
                  //                   borderSide: const BorderSide(
                  //                       color: primaryColor, width: 2),
                  //                   borderRadius: BorderRadius.circular(12)),
                  //               border: OutlineInputBorder(
                  //                   borderRadius: BorderRadius.circular(12))),
                  //           keyboardType: TextInputType.number,
                  //           validator: (value) {
                  //             if(value!.isEmpty){
                  //               return "Please enter your tigoairtel ecash";
                  //             }
                  //           },
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 10,),
                  // Row(
                  //   children: [
                  //
                  //     Expanded(
                  //       child: Padding(
                  //         padding: const EdgeInsets.only(left: 10.0),
                  //         child: TextFormField(
                  //           controller: _vodafoneEcashController,
                  //           cursorColor: primaryColor,
                  //           cursorRadius: const Radius.elliptical(10, 10),
                  //           cursorWidth: 10,
                  //           decoration: InputDecoration(
                  //               labelText: "Vodafone ECash",
                  //               labelStyle: const TextStyle(color: secondaryColor),
                  //               focusColor: primaryColor,
                  //               fillColor: primaryColor,
                  //               focusedBorder: OutlineInputBorder(
                  //                   borderSide: const BorderSide(
                  //                       color: primaryColor, width: 2),
                  //                   borderRadius: BorderRadius.circular(12)),
                  //               border: OutlineInputBorder(
                  //                   borderRadius: BorderRadius.circular(12))),
                  //           keyboardType: TextInputType.number,
                  //           validator: (value) {
                  //             if(value!.isEmpty){
                  //               return "Please enter your ecash";
                  //             }
                  //           },
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  const SizedBox(height: 30,),
                  isPosting ? const LoadingUi() :
                  RawMaterialButton(
                    onPressed: () {
                      _startPosting();
                      if (!_formKey.currentState!.validate()) {
                        return;
                      } else {
                        addAccountsToday();
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
