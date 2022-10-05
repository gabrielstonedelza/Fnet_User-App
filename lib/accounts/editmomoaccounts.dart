import 'dart:convert';
import 'package:fnet_new/static/app_colors.dart';
import 'package:fnet_new/views/bottomnavigation.dart';
import 'package:fnet_new/views/homepage.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;


class UpdateMomoAccounts extends StatefulWidget {
  final account_id;
  const UpdateMomoAccounts({Key? key, this.account_id}) : super(key: key);

  @override
  _UpdateMomoAccountsState createState() =>
      _UpdateMomoAccountsState(account_id: this.account_id);
}

class _UpdateMomoAccountsState extends State<UpdateMomoAccounts> {
  final account_id;
  _UpdateMomoAccountsState({required this.account_id});
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

  late String physicalBefore = "";
  late String mtnBefore = "";
  late String tigoairtelBefore = "";
  late String vodafoneBefore = "";
  late String eCashBefore = "";
  bool isLoading = true;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _physicalController = TextEditingController();
  late final TextEditingController _mtnController = TextEditingController();
  late final TextEditingController _tigoairtelController = TextEditingController();
  late final TextEditingController _vodafoneController = TextEditingController();
  late final TextEditingController _ecashController = TextEditingController();
  final storage = GetStorage();
  late String physicalNow = "";
  late String mtnNow = "";
  late String tigoairtelNow = "";
  late String vodafoneNow = "";
  late String ecashNow = "";

  fetchData() async {
    final requestUrl = "https://fnetghana.xyz/momo_accounts_started_detail/$account_id/";
    final myLink = Uri.parse(requestUrl);
    http.Response response = await http.get(myLink);
    if (response.statusCode == 200) {
      final codeUnits = response.body;
      var jsonData = jsonDecode(codeUnits);
      setState(() {
        physicalBefore = jsonData['physical'].toString();
        mtnBefore = jsonData['mtn_ecash'].toString();
        tigoairtelBefore = jsonData['tigoairtel_ecash'].toString();
        vodafoneBefore = jsonData['vodafone_ecash'].toString();
        eCashBefore = jsonData['ecash_total'].toString();
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  updateMomoAccounts() async {
    final requestUrl = "https://fnetghana.xyz/update_momo_accounts/$account_id/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
    }, body: {
      "physical": (double.parse(_physicalController.text) + double.parse(physicalNow)).toString(),
      "mtn_ecash": (double.parse(_mtnController.text) + double.parse(mtnNow)).toString(),
      "tigoairtel_ecash": (double.parse(_tigoairtelController.text) + double.parse(tigoairtelNow)).toString(),
      "vodafone_ecash": (double.parse(_vodafoneController.text) + double.parse(vodafoneNow)).toString(),
    });
    if (response.statusCode == 200) {
      Get.snackbar("Success", "Accounts were updated",
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);

      storage.write("physicalnow", double.parse(_physicalController.text) + double.parse(physicalNow));
      storage.write("mtnecashnow", double.parse(_mtnController.text) + double.parse(mtnNow));
      storage.write("tigoairtelecashnow", double.parse(_tigoairtelController.text) + double.parse(tigoairtelNow));
      storage.write("vodafoneecashnow", double.parse(_vodafoneController.text) + double.parse(vodafoneNow));
      storage.write("ecashnow", double.parse(eCashBefore) +double.parse(_mtnController.text) + double.parse(_tigoairtelController.text) + double.parse(_vodafoneController.text));

      Get.offAll(() => const MyBottomNavigationBar());
    } else {
      Get.snackbar("Update Error", response.body.toString(),
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
    if(storage.read("physicalnow") != null){
      setState(() {
        physicalNow = storage.read("physicalnow").toString();
      });
    }
    if(storage.read("ecashnow") != null){
      setState(() {
        ecashNow = storage.read("ecashnow").toString();
      });
    }
    if(storage.read("mtnecashnow") != null){
      setState(() {
        mtnNow = storage.read("mtnecashnow").toString();
      });
    }

    if(storage.read("tigoairtelecashnow") != null){
      setState(() {
        tigoairtelNow = storage.read("tigoairtelecashnow").toString();
      });
    }

    if(storage.read("vodafoneecashnow") != null){
      setState(() {
        vodafoneNow = storage.read("vodafoneecashnow").toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Update Accounts"),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          strokeWidth: 5,
          color: secondaryColor,
        ),
      )
          : ListView(
        children: [
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("Your old physical cash is: $physicalBefore"),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _physicalController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.person,
                            color: primaryColor,
                          ),
                          labelText: "Enter additional physical cash",
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
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text("Your old mtn ecash is: $mtnBefore"),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _mtnController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.person,
                            color: primaryColor,
                          ),
                          labelText: "Enter additional mtn ecash",
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
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text("Your old tigoairtel ecash is: $tigoairtelBefore"),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _tigoairtelController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.person,
                            color: primaryColor,
                          ),
                          labelText: "Enter additional tigoairtel ecash",
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
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text("Your old vodafone ecash is: $vodafoneBefore"),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _vodafoneController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.person,
                            color: primaryColor,
                          ),
                          labelText: "Enter additional vodafone ecash",
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
                    ),
                  ),
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
                      Get.snackbar("Please wait", "updating values",
                          colorText: defaultTextColor,
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: snackColor);
                      if (!_formKey.currentState!.validate()) {
                        return;
                      } else {
                        updateMomoAccounts();
                      }
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    elevation: 8,
                    child: const Text(
                      "Update",
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
}
