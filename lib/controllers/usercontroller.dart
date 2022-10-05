import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';


import '../static/app_colors.dart';

class UserController extends GetxController {
  final storage = GetStorage();
  var username = "";
  String uToken = "";
  String passengerProfileId = "";
  String passengerUsername = "";
  String profileImage = "";
  String nameOnGhanaCard = "";
  String email = "";
  String phoneNumber = "";
  String fullName = "";
  String companyName = "";
  late bool verified;
  bool isVerified = false;
  bool isUpdating = true;

  late List profileDetails = [];


  bool isLoading = true;



  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    if (storage.read("userToken") != null) {
      uToken = storage.read("userToken");
    }
    if (storage.read("username") != null) {
      username = storage.read("username");
    }
  }


  Future<void> getUserProfile(String token) async {
    try {
      isLoading = true;
      const profileLink = "https://fnetghana.xyz/profile/";
      var link = Uri.parse(profileLink);
      http.Response response = await http.get(link, headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Authorization": "Token $token"
      });
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        email = jsonData['get_email'];
        phoneNumber = jsonData['get_phone'];
        fullName = jsonData['get_username'];
        companyName = jsonData['get_company_name'];
        profileImage = jsonData['get_profile_pic'];
        passengerProfileId = jsonData['user'].toString();
        update();
        storage.write("verified", "Verified");
        storage.write("profile_id", passengerProfileId);
        storage.write("profile_name", fullName);
        storage.write("profile_pic", profileImage);
      }
      else{
        if (kDebugMode) {
          print("This is coming from the usercontroller file ${response.body}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      isLoading = false;
      update();
    }
  }


}
