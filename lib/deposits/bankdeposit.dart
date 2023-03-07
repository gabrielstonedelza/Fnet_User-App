import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:device_apps/device_apps.dart';
import 'package:direct_dialer/direct_dialer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:fnet_new/views/bottomnavigation.dart';
import 'package:fnet_new/views/customerregistration.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../sendsms.dart';

class BankDeposit extends StatefulWidget {
  const BankDeposit({Key? key}) : super(key: key);

  @override
  _BankDepositState createState() => _BankDepositState();
}

class _BankDepositState extends State<BankDeposit> {
  bool isPosting = false;
  bool hasOTP = false;
  bool sentOTP = false;
  late int oTP = 0;
  generate5digit(){
    var rng = Random();
    var rand = rng.nextInt(90000) + 10000;
    oTP = rand.toInt();
  }

  void _startPosting()async{
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 4));
    setState(() {
      isPosting = false;
    });
  }

  late List allCustomers = [];
  bool isLoading = true;
  late List customersPhone = [];
  late List accountNames = [];

  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  late String adminPhone = "";
  final List customerBanks = [
    "Select bank",
  ];
  final List customerAccounts = [
    "Select account number"
  ];
  var _currentAccountNumberSelected = "Select account number";

  final List customerAccountsNumbers = [];
  var _currentSelectedBank = "Select bank";
  var customerDetailBanks = {};

  final List depositRequests = [
    "Select Request Option",
    "Cash",
    "Mobile Money",
    "Bank",
  ];


  final SendSmsController sendSms = SendSmsController();
  bool isCustomer = false;
  bool isBank = false;
  bool isMobileMoney = false;
  late List myUser = [];
  late List deCustomer = [];
  bool isAccountNumberAndName = false;
  late String customerAccountName = "";
  bool isFetching = false;
  bool bankSelected = false;
  bool fetchingCustomerAccounts = true;
  late String errorMessage = "";


  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController = TextEditingController();
  late final TextEditingController _customerController = TextEditingController();
  late final TextEditingController _depositorController = TextEditingController();
  late final TextEditingController _idTypeController = TextEditingController();
  late final TextEditingController _idNumberController = TextEditingController();
  late final TextEditingController _customerAccountNameController = TextEditingController();
  late final TextEditingController _oTPController = TextEditingController();
  bool isAboveFiveThousand = false;
  late List allUserRequests = [];
  late List amounts = [];
  double sum = 0.0;
  late List bankNotPaid = [];
  bool hasUnpaidBankRequests = false;
  late String customerName = "";
  late String idType = "";
  late String idNumber = "";
  late List customer = [];
  bool accountNumberSelected = false;

  fetchUserBankRequestsToday()async{
    const url = "https://fnetghana.xyz/get_bank_total_today/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allUserRequests = json.decode(jsonData);
      amounts.assignAll(allUserRequests);
      for(var i in amounts){
        sum = sum + double.parse(i['amount']);
        bankNotPaid.add(i['deposit_paid']);
      }
    }

    setState(() {
      isLoading = false;
      allUserRequests = allUserRequests;
      if(bankNotPaid.contains("Not Paid")){
        hasUnpaidBankRequests = true;
      }
    });
  }
  fetchCustomerAccounts() async {
    final agentUrl = "https://fnetghana.xyz/get_customer_account/${_customerController.text}/";
    final agentLink = Uri.parse(agentUrl);
    http.Response res = await http.get(agentLink);
    if (res.statusCode == 200) {
      final codeUnits = res.body;
      var jsonData = jsonDecode(codeUnits);
      myUser = jsonData;
      for(var i in myUser){
        if (!customerBanks.contains(i['bank'])) {
          customerBanks.add(i['bank']);
        }
      }

      setState(() {
        fetchingCustomerAccounts = false;
      });
    }
  }
  fetchCustomerBankAndNames(String deBank)async{
    try{
      final customerAccountUrl = "https://fnetghana.xyz/get_customer_accounts_by_bank/${_customerController.text}/$deBank";
      final customerAccountLink = Uri.parse(customerAccountUrl);
      http.Response response = await http.get(customerAccountLink);
      if(response.statusCode == 200){
        final results = response.body;
        var jsonData = jsonDecode(results);
        deCustomer = jsonData;
        for(var cm in deCustomer){
          if(!customerAccounts.contains(cm['account_number'])){
            customerAccounts.add(cm['account_number']);
            accountNames.add(cm['account_name']);
          }
        }
      }
      else{
      }
    }
    finally{
      setState(() {
        isFetching = true;
      });
    }
  }
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
  fetchCustomer(String customerPhone)async{
    final url = "https://fnetghana.xyz/get_customer_by_phone/$customerPhone/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink);

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      customer = json.decode(jsonData);

      for (var i in customer) {
        setState(() {
          customerName = i['name'];
          idType = i['id_type'];
          idNumber = i['id_number'];
        });
      }
    }
    setState(() {
      isLoading = false;
      customer = customer;
    });
  }

  Future<void> dial() async {
    final dialer = await DirectDialer.instance;
    await dialer.dial('*171\%23#');
  }
  
  sendOtp() async{
    const otpUrl = "https://fnetghana.xyz/send_otp_to_customer_admin/";
    final myLink = Uri.parse(otpUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "customer": _customerController.text,
      "otp": oTP.toString(),
      "app_version" : "4"
    });
    if(res.statusCode == 201){
      Get.snackbar("OTP sent to customer", "Get code from customer",
          snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.white,
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 5)
      );
    }
    else{
      Get.snackbar("Sorry", res.body,
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.white,
          backgroundColor: primaryColor,
          duration: const Duration(seconds: 5)
      );
    }
  }

  processDeposit() async {
    const depositUrl = "https://fnetghana.xyz/post_bank_deposit/";
    final myLink = Uri.parse(depositUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "bank": _currentSelectedBank,
      "customer": _customerController.text,
      "amount": _amountController.text,
      "depositor_name": _depositorController.text,
      "account_number": _currentAccountNumberSelected,
      "account_name": _customerAccountNameController.text,
    });
    if (res.statusCode == 201) {
      Get.snackbar("Congratulations", "Transaction sent for approval",
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);
      String telnum1 = adminPhone;
      telnum1 = telnum1.replaceFirst("0", '+233');
      sendSms.sendMySms(telnum1, "FNET",
          "Hello Admin,${username.capitalize} just made a bank deposit request of GHC${_amountController.text},kindly login into Fnet and approve.Thank you");

      String telnum = _customerController.text;
      telnum = telnum.replaceFirst("0", '+233');
      sendSms.sendMySms(telnum, "FNET",
          "Hello,your deposit of ${_amountController.text} into your $_currentSelectedBank is loading,it will hit your account soon.For more information call 0244950505.");

      setState(() {
        _currentSelectedBank = "Select bank";
        _customerController.text = "";
        _amountController.text = "";
        _customerAccountNameController.text = "";
        _currentAccountNumberSelected = "Select account number";
        isCustomer = false;
        isAccountNumberAndName = false;
      });
      Get.offAll(()=> const MyBottomNavigationBar());
      Get.bottomSheet(
          Wrap(
            children: [
              const SizedBox(
                height: 30,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 18.0, bottom: 18),
                child: Center(
                    child: Text(
                      "Continue with",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
              ),
              const SizedBox(
                height: 30,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18.0, bottom: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: GestureDetector(
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/1860906.png",
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("MTN")
                            ],
                          ),
                          onTap: () {
                            dial();
                          },
                        )),
                    // Expanded(
                    //     child: GestureDetector(
                    //       child: Column(
                    //         children: [
                    //           Image.asset(
                    //             "assets/images/fidelity.png",
                    //             width: 70,
                    //             height: 70,
                    //           ),
                    //           const SizedBox(
                    //             height: 10,
                    //           ),
                    //           const Text("Fidelity")
                    //         ],
                    //       ),
                    //       onTap: () {
                    //         DeviceApps.openApp("com.fidelity.mobile");
                    //       },
                    //     )),
                    Expanded(
                        child: GestureDetector(
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/xpresspoint.png",
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Text("Xpresspoint")
                            ],
                          ),
                          onTap: () {
                            DeviceApps.openApp("com.ecobank.xpresspoint");
                          },
                        )),
                  ],
                ),
              ),
              // const SizedBox(
              //   height: 30,
              // ),
              // const Divider(),
              // const SizedBox(
              //   height: 30,
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(top: 18.0, bottom: 18),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Expanded(
              //           child: GestureDetector(
              //             child: Column(
              //               children: [
              //                 Image.asset(
              //                   "assets/images/accessbank.png",
              //                   width: 70,
              //                   height: 70,
              //                 ),
              //                 const SizedBox(
              //                   height: 10,
              //                 ),
              //                 const Text("Agency Banking")
              //               ],
              //             ),
              //             onTap: () {
              //               DeviceApps.openApp("com.unicornheights.agencybanking");
              //             },
              //           )),
              //       Expanded(
              //           child: GestureDetector(
              //             child: Column(
              //               children: [
              //                 Image.asset(
              //                   "assets/images/ecomobile.png",
              //                   width: 100,
              //                   height: 100,
              //                 ),
              //                 const SizedBox(
              //                   height: 10,
              //                 ),
              //                 const Text("Ecobank")
              //               ],
              //             ),
              //             onTap: () {
              //               DeviceApps.openApp("com.app.ecobank");
              //             },
              //           )),
              //       Expanded(
              //           child: GestureDetector(
              //             child: Column(
              //               children: [
              //                 Image.asset("assets/images/fbnbank.png",width: 70,height: 70,),
              //                 const SizedBox(height: 10,),
              //                 const Text("FBN")
              //               ],
              //             ),
              //             onTap: () {
              //               DeviceApps.openApp("com.fbndl.fbnmobileghana");
              //             },
              //           )),
              //     ],
              //   ),
              // ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
          backgroundColor: Colors.white);
      // Get.offAll(() => const HomePage());
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
  
  fetchAllInstalled() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
        onlyAppsWithLaunchIntent: true, includeSystemApps: true);
    if (kDebugMode) {
      // print(apps);
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
    generate5digit();
    fetchCustomers();
    fetchAdmin();
    fetchAllInstalled();
    fetchUserBankRequestsToday();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bank Deposit"),
        backgroundColor: primaryColor,
      ),
      body:isLoading ? const Center(
        child: CircularProgressIndicator(
          strokeWidth: 8,
          color: primaryColor
        )
      ) : ListView(
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: hasUnpaidBankRequests ? const Center(
              child: Text("Sorry you have an unpaid deposit")
            ) : Form(
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
                          Get.snackbar("Success", "Customer is in system",
                              colorText: defaultTextColor,
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: snackColor);

                          setState(() {
                            isCustomer = true;
                            fetchCustomerAccounts();
                            fetchCustomer(_customerController.text);
                          });
                        } else if (value.length == 10 &&
                            !customersPhone.contains(value)) {
                          Get.snackbar(
                              "Customer Error", "Customer is not in system",
                              colorText: defaultTextColor,
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.red);
                          setState(() {
                            isCustomer = false;
                          });
                          Timer(const Duration(seconds: 3),
                                  () => Get.to(() => const CustomerRegistration()));
                        }
                      },
                      controller: _customerController,
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
                              borderRadius: BorderRadius.circular(12))
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter customer number";
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 10,),

                  isCustomer && !fetchingCustomerAccounts ?
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
                          // style: const TextStyle(
                          //     color: Colors.black, fontSize: 20),
                          items: customerBanks.map((dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {
                            if(newValueSelected=="GT Bank"){
                              fetchCustomerBankAndNames("GT Bank");
                              setState(() {
                                bankSelected = true;
                              });
                            }
                            if(newValueSelected=="Access Bank"){
                              fetchCustomerBankAndNames("Access Bank");
                              setState(() {
                                bankSelected = true;
                              });
                            }
                            if(newValueSelected=="Cal Bank"){
                              fetchCustomerBankAndNames("Cal Bank");
                              setState(() {
                                bankSelected = true;
                              });
                            }
                            if(newValueSelected=="Fidelity Bank"){
                              fetchCustomerBankAndNames("Fidelity Bank");
                              setState(() {
                                bankSelected = true;
                              });
                            }
                            if(newValueSelected=="Ecobank"){
                              fetchCustomerBankAndNames("Ecobank");
                              setState(() {
                                bankSelected = true;
                              });
                            }
                            if(newValueSelected=="Pan Africa"){
                              fetchCustomerBankAndNames("Pan Africa");
                              setState(() {
                                bankSelected = true;
                              });
                            }
                            if(newValueSelected=="First Bank of Nigeria"){
                              fetchCustomerBankAndNames("First Bank of Nigeria");
                              setState(() {
                                bankSelected = true;
                              });
                            }
                            if(newValueSelected=="SGSSB"){
                              fetchCustomerBankAndNames("SGSSB");
                              setState(() {
                                bankSelected = true;
                              });
                            }
                            if(newValueSelected=="Mtn"){
                              fetchCustomerBankAndNames("Mtn");
                              setState(() {
                                bankSelected = true;
                              });
                            }
                            if(newValueSelected=="Vodafone"){
                              fetchCustomerBankAndNames("Vodafone");
                              setState(() {
                                bankSelected = true;
                              });
                            }
                            if(newValueSelected=="Tigoairtel"){
                              fetchCustomerBankAndNames("Tigoairtel");
                              setState(() {
                                bankSelected = true;
                              });
                            }

                            _onDropDownItemSelectedBank(newValueSelected);
                          },
                          value: _currentSelectedBank,
                        ),
                      ),
                    ),
                  ): isCustomer ? const Text("Please wait fetching customer's banks"):Container(),
                  isCustomer && isFetching ? Column(
                    children: [
                     accountNumberSelected ? Container() : Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey, width: 1)),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0, right: 10),
                            child: DropdownButton(
                              hint: const Text("Select account number"),
                              isExpanded: true,
                              underline: const SizedBox(),
                              // style: const TextStyle(
                              //     color: Colors.black, fontSize: 20),
                              items: customerAccounts.map((dropDownStringItem) {
                                return DropdownMenuItem(
                                  value: dropDownStringItem,
                                  child: Text(dropDownStringItem),
                                );
                              }).toList(),
                              onChanged: (newValueSelected) {
                                for(var cNum in myUser){
                                  if(cNum['account_number'] == newValueSelected){
                                    setState(() {
                                      isAccountNumberAndName = true;
                                      customerAccountName = cNum['account_name'];
                                      accountNumberSelected = true;
                                    });
                                  }
                                }
                                _onDropDownItemSelectedAccountNumber(newValueSelected);
                              },
                              value: _currentAccountNumberSelected,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ): bankSelected ? Text("Please wait fetching customer's $_currentSelectedBank account numbers"):Container(),

                  isAccountNumberAndName ?
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          readOnly: true,
                          initialValue: _currentAccountNumberSelected.toString(),
                          cursorColor: primaryColor,
                          cursorRadius: const Radius.elliptical(10, 10),
                          cursorWidth: 10,
                          decoration: InputDecoration(

                              labelText: "Account Number",
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
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          controller: _customerAccountNameController..text=customerAccountName,
                          cursorColor: primaryColor,
                          cursorRadius: const Radius.elliptical(10, 10),
                          cursorWidth: 10,
                          readOnly: true,
                          decoration: InputDecoration(
                              labelText: "Account's name",
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
                              return "Please enter a name";
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          readOnly: true,
                          controller: _depositorController..text = customerName,
                          cursorColor: primaryColor,
                          cursorRadius: const Radius.elliptical(10, 10),
                          cursorWidth: 10,
                          decoration: InputDecoration(

                              labelText: "Depositor name",
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
                              return "Please enter amount";
                            }
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          readOnly: true,
                          controller: _idTypeController..text = idType,
                          cursorColor: primaryColor,
                          cursorRadius: const Radius.elliptical(10, 10),
                          cursorWidth: 10,
                          decoration: InputDecoration(

                              labelText: "Id Type",
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
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: TextFormField(
                          readOnly: true,
                          controller: _idNumberController..text = idNumber,
                          cursorColor: primaryColor,
                          cursorRadius: const Radius.elliptical(10, 10),
                          cursorWidth: 10,
                          decoration: InputDecoration(

                              labelText: "Id Number",
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
                      ),
                    ],
                  ):
                  Container(),
                  isAccountNumberAndName ?
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      controller: _amountController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(

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
                  ):Container(),

                  const SizedBox(
                    height: 20,
                  ),
                  isPosting ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                      color: primaryColor,
                    ),
                  ) : isCustomer && !fetchingCustomerAccounts ? RawMaterialButton(
                    onPressed: () {
                      _startPosting();
                      if (!_formKey.currentState!.validate()) {
                        return;
                      } else {

                        if(_currentSelectedBank == "Select bank"){
                          Get.snackbar("Bank Error", "Please select customers bank from the list",colorText: Colors.white,backgroundColor: Colors.red,snackPosition: SnackPosition.BOTTOM);
                          setState(() {
                            bankSelected = false;
                          });
                          return;
                        }

                        else{
                          Get.snackbar("Please wait", "sending your request",
                              colorText: defaultTextColor,
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: snackColor);
                          processDeposit();
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
                  ) : Container(),
                  const SizedBox(height: 20,),
                  const Text("Note: Please restart bank deposit session again if you want to change customers bank.Thank you.")
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
      _currentSelectedBank = newValueSelected;
    });
  }

  void _onDropDownItemSelectedAccountNumber(newValueSelected) {
    setState(() {
      _currentAccountNumberSelected = newValueSelected;
    });
  }
}
