import 'dart:async';
import 'dart:convert';
import 'package:age_calculator/age_calculator.dart';
import 'package:badges/badges.dart' as badge;
import 'package:badges/badges.dart';
import 'package:direct_dialer/direct_dialer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart' as mySms;
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:fnet_new/accounts/accountsummary.dart';
import 'package:fnet_new/accounts/addaccounts.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:fnet_new/views/accountdashboard.dart';
import 'package:fnet_new/views/addcustomeraccount.dart';
import 'package:fnet_new/views/customerregistration.dart';
import 'package:fnet_new/views/usercustomers.dart';
import 'package:fnet_new/views/usernotifications.dart';
import 'package:fnet_new/views/userreports.dart';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:telephony/telephony.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ussd_advanced/ussd_advanced.dart';
import '../accounts/userbankpayments.dart';
import '../controllers/usercontroller.dart';
import '../payments/paymentsavailable.dart';
import '../points.dart';
import '../sendsms.dart';
import 'birthdays.dart';
import 'depositrequest.dart';
import 'groupchat.dart';
import 'loginview.dart';
import 'momopage.dart';

class HomePage extends StatefulWidget {
  final message;
  const HomePage({Key? key, required this.message}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState(message: this.message);
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final message;
  _HomePageState({required this.message});
  final storage = GetStorage();
  bool hasAccountsToday = false;
  bool isLoading = true;
  late String uToken = "";
  late List allPaymentTotal = [];
  late List allCashPaymentTotal = [];
  late List allBankPending = [];
  late List allCashPending = [];
  late String username = "";
  bool hasBankPaymentNotApproved = false;
  bool hasCashPaymentNotApproved = false;
  bool needApproval = false;
  int notPaidBankCount = 0;
  int notPaidCashCount = 0;
  late List pendingBankLists = [];
  late List pendingCashLists = [];
  late List allUserBankRequests = [];
  late List allUserCashRequests = [];
  late List bankAmounts = [];
  late List cashAmounts = [];
  double bankSum = 0.0;
  double cashSum = 0.0;
  late List allUserBankPayments = [];
  late List allUserCashPayments = [];
  bool hasUnpaidBankRequests = false;
  bool hasUnpaidCashRequests = false;
  late List bankNotPaid = [];
  late List cashNotPaid = [];
  late List amountsBankPayments = [];
  late List amountsCashPayments = [];
  double sumBankPayment = 0.0;
  double sumCashPayment = 0.0;

  Future<void> fetchBankPaymentTotal() async {
    const url = "https://fnetghana.xyz/payment_summary/";
    var myLink = Uri.parse(url);
    final response =
        await http.get(myLink, headers: {"Authorization": "Token $uToken"});

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allPaymentTotal = json.decode(jsonData);
      for (var i in allPaymentTotal) {
        allBankPending.add(i['payment_status']);
      }
    }
    setState(() {
      isLoading = false;
    });
    if (allBankPending.contains("Pending")) {
      setState(() {
        hasBankPaymentNotApproved = true;
      });
    }
    for (var pp in allBankPending) {
      if (pp == "Pending") {
        pendingBankLists.add(pp);
      }
    }
    if (pendingBankLists.length == 3) {
      setState(() {
        notPaidBankCount = 3;
        needApproval = true;
      });
    }
  }

  Future<void> fetchCashPaymentTotal() async {
    const url = "https://fnetghana.xyz/cash_payment_summary/";
    var myLink = Uri.parse(url);
    final response =
        await http.get(myLink, headers: {"Authorization": "Token $uToken"});

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allCashPaymentTotal = json.decode(jsonData);
      for (var i in allCashPaymentTotal) {
        allCashPending.add(i['payment_status']);
      }
    }
    setState(() {
      isLoading = false;
    });
    if (allCashPending.contains("Pending")) {
      setState(() {
        hasCashPaymentNotApproved = true;
      });
    }
    for (var pp in allCashPending) {
      if (pp == "Pending") {
        pendingCashLists.add(pp);
      }
    }
    if (pendingCashLists.length == 3) {
      setState(() {
        notPaidCashCount = 3;
        needApproval = true;
      });
    }
  }

  Future<void> fetchUserBankRequestsToday() async {
    const url = "https://fnetghana.xyz/get_bank_total_today/";
    var myLink = Uri.parse(url);
    final response =
        await http.get(myLink, headers: {"Authorization": "Token $uToken"});

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allUserBankRequests = json.decode(jsonData);
      bankAmounts.assignAll(allUserBankRequests);
      for (var i in bankAmounts) {
        bankSum = bankSum + double.parse(i['amount']);
        bankNotPaid.add(i['deposit_paid']);
      }
    }

    setState(() {
      isLoading = false;
      allUserBankRequests = allUserBankRequests;
      if (bankNotPaid.contains("Not Paid")) {
        hasUnpaidBankRequests = true;
      }
    });
  }

  Future<void> fetchUserCashRequestsToday() async {
    const url = "https://fnetghana.xyz/get_cash_requests_for_today/";
    var myLink = Uri.parse(url);
    final response =
        await http.get(myLink, headers: {"Authorization": "Token $uToken"});

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allUserCashRequests = json.decode(jsonData);
      cashAmounts.assignAll(allUserCashRequests);
      for (var i in cashAmounts) {
        cashSum = cashSum + double.parse(i['amount']);
        cashNotPaid.add(i['deposit_paid']);
      }
    }

    setState(() {
      isLoading = false;
      allUserCashRequests = allUserCashRequests;
      if (cashNotPaid.contains("Not Paid")) {
        hasUnpaidCashRequests = true;
      }
    });
  }

  Future<void> fetchUserPayments() async {
    const url = "https://fnetghana.xyz/get_payment_approved_total/";
    var myLink = Uri.parse(url);
    final response =
        await http.get(myLink, headers: {"Authorization": "Token $uToken"});

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allUserBankPayments = json.decode(jsonData);
      amountsBankPayments.assignAll(allUserBankPayments);
      for (var i in amountsBankPayments) {
        sumBankPayment = sumBankPayment + double.parse(i['amount']);
      }
    }

    setState(() {
      isLoading = false;
      allUserBankPayments = allUserBankPayments;
    });
  }

  Future<void> fetchUserCashPayments() async {
    const url = "https://fnetghana.xyz/get_cash_payment_approved_total/";
    var myLink = Uri.parse(url);
    final response =
        await http.get(myLink, headers: {"Authorization": "Token $uToken"});

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allUserCashPayments = json.decode(jsonData);
      amountsCashPayments.assignAll(allUserCashPayments);
      for (var i in amountsCashPayments) {
        sumCashPayment = sumCashPayment + double.parse(i['amount']);
      }
    }

    setState(() {
      isLoading = false;
      allUserCashPayments = allUserCashPayments;
    });
  }

  late List hasBirthDayInFive = [];
  late List hasBirthDayToday = [];
  late List todaysBirthdayPhones = [];
  bool hasbdinfive = false;
  bool hasbdintoday = false;
  late List allCustomers = [];
  late int sentCount = 1;
  bool isFetching = true;
  late DateDuration duration;
  final SendSmsController sendSms = SendSmsController();
  late List allCustomerRequests = [];
  bool hasPreviousDepositUnPaid = false;
  late List allBankDeposits = [];
  late List depositPaidBank = [];
  bool hasAlreadySent = false;
  late List sentBirthdays = [];
  String smsSent = "No";
  late List yourNotifications = [];
  late List notRead = [];
  late List triggered = [];
  late List unreadNotifications = [];
  late List triggeredNotifications = [];
  late List allNotifications = [];
  late List allNots = [];
  bool hasToken = false;
  bool isCheckingBalance = false;
  bool isCheckingCommission = false;
  int backgroundCount = 0;
  late Timer _timer;
  UserController userController = Get.find();
  final Telephony telephony = Telephony.instance;
  final _advancedDrawerController = AdvancedDrawerController();

  final Uri _url = Uri.parse('https://aop.ecobank.com/register');

  Future<void> _launchInBrowser() async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  Future<void> checkMtnCommission() async {
    await UssdAdvanced.multisessionUssd(code: "*171*7*2*1#", subscriptionId: 1);
  }

  Future checkMtnBalance() async {
    fetchInbox();
    Get.defaultDialog(
        content: Column(
          children: [Text(mySmss.first)],
        ),
        confirm: TextButton(
          onPressed: () {
            Get.back();
          },
          child:
              const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
        ));
  }

  Future<void> fetchAllUserBankRequests() async {
    const url = "https://fnetghana.xyz/get_bank_total_today/";
    var myLink = Uri.parse(url);
    final response =
        await http.get(myLink, headers: {"Authorization": "Token $uToken"});

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allBankDeposits = json.decode(jsonData);

      for (var i in allBankDeposits) {
        depositPaidBank.add(i['deposit_paid']);
      }
    }

    setState(() {
      isLoading = false;
      if (depositPaidBank.contains("Not Paid")) {
        hasPreviousDepositUnPaid = true;
      }
    });
  }

  Future<void> fetchCustomers() async {
    const url = "https://fnetghana.xyz/user_customers/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    });

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allCustomers = json.decode(jsonData);
      for (var i in allCustomers) {
        DateTime birthday = DateTime.parse(i['date_of_birth']);
        duration = AgeCalculator.timeToNextBirthday(birthday);
        if (duration.months == 0 && duration.days == 5) {
          setState(() {
            hasBirthDayInFive.add(i['name']);
            hasbdinfive = true;
            // localNotificationManager.showBirthDayInFiveNotification();
          });
          if (storage.read("birthdaySent") != null &&
              storage.read("birthdaySent") == "Yes") {
            storage.remove("birthdaySent");
            storage.write("birthdaySent", smsSent);
          }
        }
        if (duration.months == 0 &&
            duration.days == 0 &&
            storage.read("birthdaySent") != null &&
            storage.read('birthdaySent') == "No") {
          if (duration.months == 0 && duration.days == 0) {
            setState(() {
              hasbdintoday = true;
              hasBirthDayToday.add(i['name']);
              todaysBirthdayPhones.add(i['phone']);
              // localNotificationManager.showBirthDayTodayNotification();
            });
            for (var b in todaysBirthdayPhones) {
              String birthdayNum = b;
              birthdayNum = birthdayNum.replaceFirst("0", '+233');
              sendSms.sendMySms(birthdayNum, "FNET",
                  "Hello, FNET ENTERPRISE is wishing you a happy birthday,may God grant all your heart desires,thank you.");
              sendSms.sendMySms(birthdayNum, "FNET",
                  "Download customer app from https://play.google.com/store/apps/details?id=com.fnettransaction.fnet_customer");
              sentBirthdays.add(b);
              setState(() {
                smsSent = "Yes";
                storage.write("birthdaySent", smsSent);
              });
            }
          }
        }
      }
    }

    setState(() {
      isLoading = false;
      isFetching = false;
    });
  }

  Future<void> getAllTriggeredNotifications() async {
    const url = "https://fnetghana.xyz/get_triggered_notifications/";
    var myLink = Uri.parse(url);
    final response =
        await http.get(myLink, headers: {"Authorization": "Token $uToken"});
    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      triggeredNotifications = json.decode(jsonData);
      triggered.assignAll(triggeredNotifications);
      // setState(() {
      //   isLoading = false;
      //   isFetching = false;
      // });
    }
  }

  Future<void> getAllUnReadNotifications() async {
    const url = "https://fnetghana.xyz/get_user_notifications/";
    var myLink = Uri.parse(url);
    final response =
        await http.get(myLink, headers: {"Authorization": "Token $uToken"});
    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      yourNotifications = json.decode(jsonData);
      notRead.assignAll(yourNotifications);
      // setState(() {
      //   isLoading = false;
      //   isFetching = false;
      // });
    }
  }

  Future<void> getAllNotifications() async {
    const url = "https://fnetghana.xyz/get_all_user_notifications/";
    var myLink = Uri.parse(url);
    final response =
        await http.get(myLink, headers: {"Authorization": "Token $uToken"});
    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allNotifications = json.decode(jsonData);
      allNots.assignAll(allNotifications);
    }
    setState(() {
      isLoading = false;
      allNotifications = allNotifications;
      isFetching = false;
    });
  }

  unTriggerNotifications(int id) async {
    final requestUrl = "https://fnetghana.xyz/read_notification/$id/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    }, body: {
      "notification_trigger": "Not Triggered",
    });
    if (response.statusCode == 200) {}
  }

  late List bankDepositsNotPaid = [];
  bool isOwningBankPayment = false;

  Future<void> fetchUserNotPaidBankRequests() async {
    const url = "https://fnetghana.xyz/get_unpaid_bank_deposits_for_today/";
    var myLink = Uri.parse(url);
    final response =
        await http.get(myLink, headers: {"Authorization": "Token $uToken"});

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      bankDepositsNotPaid = json.decode(jsonData);
    }
  }

  final UserController controller = Get.find();
  addToBlockedList() async {
    final depositUrl =
        "https://fnetghana.xyz/update_blocked/${controller.userProfileId}/";
    final myLink = Uri.parse(depositUrl);
    final res = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "user_blocked": "True",
      "email": controller.email,
      "username": username,
      "company_name": controller.companyName,
      "phone": controller.phoneNumber,
      "full_name": controller.fullName,
    });
    if (res.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
    } else {
      if (kDebugMode) {
        print(res.body);
      }
    }
  }

  bool isActive = true;
  SmsQuery query = SmsQuery();
  late List mySmss = [];

  fetchInbox() async {
    List<mySms.SmsMessage> messages = await query.getAllSms;
    for (var message in messages) {
      if (message.address == "MobileMoney") {
        if (!mySmss.contains(message.body)) {
          mySmss.add(message.body);
        }
      }
    }
  }

  void checkTheTime() {
    var hour = DateTime.now().hour;
    // var date = DateTime.now();
    // if (kDebugMode) {
    //   // print(hour);
    //   // print(date);
    // }
    switch (hour) {
      // case 18:
      //   if (bankDepositsNotPaid.isNotEmpty) {
      //     setState(() {
      //       isOwningBankPayment = true;
      //     });
      //     addToBlockedList();
      //   }
      //   if (bankDepositsNotPaid.isEmpty) {
      //     setState(() {
      //       isOwningBankPayment = false;
      //     });
      //   }
      //   break;
      case 20:
        logoutUser();
        break;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (storage.read("username") != null) {
      setState(() {
        username = storage.read("username");
      });
    }

    if (storage.read("usertoken") != null) {
      setState(() {
        hasToken = true;
        uToken = storage.read("usertoken");
      });
    }
    if (storage.read("accountcreatedtoday") != null) {
      setState(() {
        hasAccountsToday = true;
      });
    }
    userController.getUserProfile(uToken);

    fetchCustomers();
    fetchAllUserBankRequests();
    getAllTriggeredNotifications();
    fetchUserNotPaidBankRequests();

    //
    fetchBankPaymentTotal();
    fetchCashPaymentTotal();
    fetchUserBankRequestsToday();
    fetchUserCashRequestsToday();
    fetchUserPayments();
    fetchUserCashPayments();
    checkTheTime();

    _timer = Timer.periodic(const Duration(seconds: 12), (timer) {
      getAllTriggeredNotifications();
      getAllUnReadNotifications();
      checkTheTime();
      fetchUserNotPaidBankRequests();
    });
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      for (var e in triggered) {
        unTriggerNotifications(e["id"]);
      }
    });

    fetchInbox();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
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

  onBankDepositNotificationClick(String payload) {
    Get.to(() => const AllYourNotifications());
  }

  onBirthdayNotificationClick(String payload) async {
    Get.to(() => const Birthdays());
  }

  logoutUser() async {
    storage.remove("username");
    Get.offAll(() => const LoginView());
    const logoutUrl = "https://www.fnetghana.xyz/auth/token/logout";
    final myLink = Uri.parse(logoutUrl);
    http.Response response = await http.post(myLink, headers: {
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    });

    if (response.statusCode == 200) {
      Get.snackbar("Success", "You were logged out",
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);
      storage.remove("username");
      storage.remove("usertoken");
      Get.offAll(() => const LoginView());
    }
  }

  Future<void> openDialer() async {
    await UssdAdvanced.multisessionUssd(code: "*171#", subscriptionId: 1);
  }

  @override
  Widget build(BuildContext context) {
    return AdvancedDrawer(
      backdrop: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueGrey, Colors.blueGrey.withOpacity(0.2)],
          ),
        ),
      ),
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      // openScale: 1.0,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      drawer: SafeArea(
        child: ListTileTheme(
          textColor: Colors.white,
          iconColor: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 100.0,
                height: 100.0,
                margin: const EdgeInsets.only(
                  top: 10.0,
                  bottom: 10.0,
                ),
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                ),
              ),
              ListTile(
                onTap: () {
                  Get.to(() => const MyPointsSummary());
                },
                leading: Image.asset(
                  "assets/images/customer-loyalty.png",
                  width: 30,
                  height: 30,
                ),
                title: const Text('points'),
              ),
              ListTile(
                onTap: () {
                  showMaterialModalBottomSheet(
                    context: context,
// expand: true,
                    isDismissible: true,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(25.0))),
                    bounce: true,
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: SizedBox(
                          height: 300,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 30),
                              const Center(
                                  child: Text("Select network",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              const SizedBox(height: 30),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: GestureDetector(
                                            onTap: () {
                                              dialMtn();
                                              Get.back();
                                            },
                                            child: Card(
                                              elevation: 12,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(5.0),
                                                child: Image.asset(
                                                  "assets/images/1860906.png",
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ))),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                        child: GestureDetector(
                                            onTap: () {
                                              dialVodafone();
                                              Get.back();
                                            },
                                            child: Card(
                                                elevation: 12,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Image.asset(
                                                    "assets/images/vodafone.png",
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )))),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                        child: GestureDetector(
                                            onTap: () {
                                              dialTigo();
                                              Get.back();
                                            },
                                            child: Card(
                                                elevation: 12,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.0),
                                                  child: Image.asset(
                                                    "assets/images/airtel-tigo-logos.jpg",
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )))),
                                  ],
                                ),
                              )
                            ],
                          )),
                    ),
                  );
                },
                leading: const Icon(Icons.phone),
                title: const Text('Dialer'),
              ),
              ListTile(
                onTap: () {
                  Get.to(() => const AccountView());
                },
                leading: const Icon(Icons.add_circle_outlined),
                title: const Text('Add Accounts'),
              ),
              ListTile(
                onTap: () {
                  Get.defaultDialog(
                      buttonColor: primaryColor,
                      title: "Confirm Logout",
                      middleText: "Are you sure you want to logout?",
                      confirm: RawMaterialButton(
                          shape: const StadiumBorder(),
                          fillColor: primaryColor,
                          onPressed: () {
                            logoutUser();
                            Get.back();
                          },
                          child: const Text(
                            "Yes",
                            style: TextStyle(color: Colors.white),
                          )),
                      cancel: RawMaterialButton(
                          shape: const StadiumBorder(),
                          fillColor: primaryColor,
                          onPressed: () {
                            Get.back();
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.white),
                          )));
                },
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
              ),
              const Spacer(),
              Container(
                width: 100.0,
                height: 100.0,
                margin: const EdgeInsets.only(
                  top: 10.0,
                  bottom: 14.0,
                ),
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/png.png',
                  width: 50,
                  height: 50,
                ),
              ),
              const DefaultTextStyle(
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white54,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('App created by Havens Software Development'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: defaultColor,
            title: Text("😃 ${username.capitalize}"),
            leading: IconButton(
              onPressed: _handleMenuButtonPressed,
              icon: ValueListenableBuilder<AdvancedDrawerValue>(
                valueListenable: _advancedDrawerController,
                builder: (_, value, __) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      value.visible ? Icons.clear : Icons.menu,
                      key: ValueKey<bool>(value.visible),
                    ),
                  );
                },
              ),
            ),
            // actions: [
            //   IconButton(
            //       onPressed: () {
            //         Get.to(() => const LocationScreen());
            //       },
            //       icon: const Icon(Icons.location_on_outlined))
            // ],
          ),
          body: SafeArea(
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => const MomoPage());
                            },
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/images/momo.png",
                                  width: 70,
                                  height: 70,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text("Pay To"),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/images/deposit.png",
                                  width: 70,
                                  height: 70,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text("Bank"),
                                const Text("Deposit"),
                              ],
                            ),
                            onTap: () {
                              Get.to(() => const Deposits());
                            },
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 18.0),
                                  child: badge.Badge(
                                    position: BadgePosition.bottomStart(),
                                    toAnimate: false,
                                    shape: BadgeShape.square,
                                    badgeColor: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                    badgeContent: Column(
                                      children: [
                                        Text("${bankDepositsNotPaid.length}",
                                            style: const TextStyle(
                                                color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                                Image.asset(
                                  "assets/images/cashless-payment.png",
                                  width: 70,
                                  height: 70,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text("Payments"),
                                const Text("Available"),
                              ],
                            ),
                            onTap: () {
                              Get.to(() => const PaymentsAvailable());
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => const CustomerRegistration());
                            },
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/images/mobile-payment.png",
                                  width: 70,
                                  height: 70,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text("Register Customer"),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/images/mobile-payment.png",
                                  width: 70,
                                  height: 70,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text("Accounts"),
                                const Text("Registration"),
                              ],
                            ),
                            onTap: () {
                              Get.to(() => const AddCustomerAccount());
                            },
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 18.0),
                                  child: badge.Badge(
                                    position: BadgePosition.bottomStart(),
                                    toAnimate: false,
                                    shape: BadgeShape.square,
                                    badgeColor: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                    badgeContent: isFetching
                                        ? const Center(
                                            child: Text("loading..",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          )
                                        : Column(
                                            children: [
                                              hasbdinfive
                                                  ? Text(
                                                      "${hasBirthDayInFive.length}",
                                                      style: const TextStyle(
                                                          color: Colors.white))
                                                  : hasbdintoday
                                                      ? Text(
                                                          "${hasBirthDayToday.length}",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white))
                                                      : const Text("0",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)),
                                            ],
                                          ),
                                  ),
                                ),
                                Image.asset(
                                  "assets/images/cake.png",
                                  width: 70,
                                  height: 70,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text("Birthdays"),
                              ],
                            ),
                            onTap: () {
                              Get.to(() => const Birthdays());
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/images/group.png",
                                  width: 70,
                                  height: 70,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text("Your Customers"),
                              ],
                            ),
                            onTap: () {
                              Get.to(() => const UserCustomers());
                            },
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Get.to(() => const GroupChat());
                            },
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/images/team1.png",
                                  width: 70,
                                  height: 70,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text("Group"),
                                const Text("Chats"),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/images/notebook.png",
                                  width: 70,
                                  height: 70,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text("Reports"),
                              ],
                            ),
                            onTap: () {
                              Get.to(() => const Reports());
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/images/business-report.png",
                                  width: 70,
                                  height: 70,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text("Account"),
                                const Text("Total"),
                              ],
                            ),
                            onTap: () {
                              Get.to(() => const UserAccountTotal());
                            },
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/images/business-report.png",
                                  width: 70,
                                  height: 70,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text("Transaction "),
                                const Text("Summary"),
                              ],
                            ),
                            onTap: () {
                              Get.to(() => const TransactionSummary());
                            },
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/images/bank.png",
                                  width: 70,
                                  height: 70,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text("Bank "),
                                const Text("Payments"),
                              ],
                            ),
                            onTap: () {
                              Get.to(() => const UserBankPayments());
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 18.0),
                                  child: badge.Badge(
                                    position: BadgePosition.bottomStart(),
                                    toAnimate: false,
                                    shape: BadgeShape.square,
                                    badgeColor: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                    badgeContent: isFetching
                                        ? const Center(
                                            child: Text("loading..",
                                                style: TextStyle(
                                                    color: Colors.white)),
                                          )
                                        : Column(
                                            children: [
                                              Text("${notRead.length}",
                                                  style: const TextStyle(
                                                      color: Colors.white)),
                                            ],
                                          ),
                                  ),
                                ),
                                Image.asset(
                                  "assets/images/notification.png",
                                  width: 60,
                                  height: 60,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text("Notifications"),
                              ],
                            ),
                            onTap: () {
                              Get.to(() => const AllYourNotifications());
                            },
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/images/law.png",
                                  width: 70,
                                  height: 70,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text("Balance"),
                              ],
                            ),
                            onTap: () {
                              checkMtnBalance();
                            },
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            child: Column(
                              children: [
                                Image.asset(
                                  "assets/images/ecomobile.png",
                                  width: 70,
                                  height: 70,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Text("Open Account"),
                              ],
                            ),
                            onTap: () async {
                              await _launchInBrowser();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }
}
