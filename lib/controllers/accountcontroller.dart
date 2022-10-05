import 'package:flutter/cupertino.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:fnet_new/views/bottomnavigation.dart';
import 'package:fnet_new/views/homepage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class AccountController extends GetxController {
  final client = http.Client();
  final storage = GetStorage();

  late final TextEditingController _mtnPhysicalController,_mtnEcashController,_tigoAirtelPhysicalController,_vodafonePhysicalController,_tigoAirtelEcashController,_vodafoneEcashController;
  static AccountController get to => Get.find<AccountController>();

  final mtnPhysicalCash = "".obs;
  final mtnPhysicalCashNow = "".obs;
  final mtnECash = "".obs;
  final mtnECashNow = "".obs;
  final tigoAirtelPhysicalCash = "".obs;
  final tigoAirtelPhysicalCashNow = "".obs;
  final tigoAirtelECash = "".obs;
  final tigoAirtelECashNow = "".obs;
  final vodafonePhysicalCash = "".obs;
  final vodafonePhysicalCashNow = "".obs;
  final vodafoneECash = "".obs;
  final vodafoneECashNow = "".obs;
  final accountsToday = "".obs;

  late String physicalNow = "";
  late String eNow = "";
  final username = "".obs;
  final uToken = "".obs;

  setUsername(String uname){
    username(uname);
  }
  setUToken(String utoken){
    uToken(utoken);
  }


  setAccountToday(String accounttoday) {
    accountsToday(accounttoday);
  }

  @override
  void onInit() {
    super.onInit();
    _mtnPhysicalController = TextEditingController();
    _mtnEcashController = TextEditingController();
    _tigoAirtelPhysicalController = TextEditingController();
    _tigoAirtelEcashController = TextEditingController();
    _vodafonePhysicalController = TextEditingController();
    _vodafoneEcashController = TextEditingController();

    if (storage.read("usertoken") != null) {
      setUToken(storage.read("usertoken"));
    }
    if (storage.read("username") != null) {
      setUsername(storage.read("username"));
    }
  }

  @override
  void dispose() {
    super.dispose();
    _mtnPhysicalController.dispose();
    _mtnEcashController.dispose();
    _tigoAirtelPhysicalController.dispose();
    _tigoAirtelEcashController.dispose();
    _vodafonePhysicalController.dispose();
    _vodafoneEcashController.dispose();
  }

  addAccountsToday(String mtnPhysical, String mtnEcash,String tigoAirtelPhysical, String tigoAirtelEcash,String vodafonePhysical, String vodafoneEcash) async {
    const accountUrl = "https://www.fnetghana.xyz/post_momo_accounts_started/";
    final myLink = Uri.parse(accountUrl);
    http.Response response = await client.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token ${uToken.value}"
    }, body: {
      "mtn_physical": mtnPhysical,
      "tigoairtel_physical": tigoAirtelPhysical,
      "vodafone_physical": vodafonePhysical,
      "mtn_ecash": mtnEcash,
      "tigoairtel_ecash": tigoAirtelEcash,
      "vodafone_ecash": vodafoneEcash,
    });
    if (response.statusCode == 201) {
      Get.snackbar("Success", "You have added accounts for today",
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);

      var accountCreatedToday = "Account Created";
      setAccountToday(accountCreatedToday);
      storage.write("mtnphysicalcashnow", mtnPhysical);
      storage.write("mtnecashnow", mtnEcash);
      storage.write("tigoairtelphysicalcashnow", tigoAirtelPhysical);
      storage.write("tigoairtelecashnow", tigoAirtelEcash);
      storage.write("vodafonephysicalcashnow", vodafonePhysical);
      storage.write("vodafoneecashnow", vodafoneEcash);

      storage.write("accountcreatedtoday", accountsToday.value);
      Get.offAll(() => const MyBottomNavigationBar());
    } else {

      Get.snackbar("Account", response.body.toString(),
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);
    }
  }

  closeAccounts() async {
    const accountUrl = "https://www.fnetghana.xyz/post_momo_accounts_closed/";
    final myLink = Uri.parse(accountUrl);
    http.Response response = await client.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded"
    }, body: {
      "mtn_physical": mtnPhysicalCashNow,
      "tigoairtel_physical": tigoAirtelPhysicalCashNow,
      "vodafone_physical": vodafonePhysicalCashNow,
      "mtn_ecash": mtnECashNow,
      "tigoairtel_ecash": tigoAirtelECashNow,
      "vodafone_ecash": vodafoneECashNow,
    });

    if (response.statusCode == 201) {
      var accountCreatedToday = "Account Closed";
      setAccountToday(accountCreatedToday);
      storage.remove("mtnphysicalcashnow");
      storage.remove("mtnecashnow");
      storage.remove("tigoairtelphysicalcashnow");
      storage.remove("tigoairtelecashnow");
      storage.remove("tigoairtelphysicalcashnow");
      storage.remove("tigoairtelecashnow");
      storage.remove("accountcreatedtoday");
      Get.offAll(() => const MyBottomNavigationBar());
    } else {
      Get.snackbar("Account", response.body.toString(),
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor);
    }
  }
}
