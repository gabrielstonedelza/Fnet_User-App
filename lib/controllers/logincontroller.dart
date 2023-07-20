import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../views/homepage.dart';

class LoginController extends GetxController{
  late TextEditingController usernameController,passwordController;
  final client = http.Client();
  final storage = GetStorage();
  final username = "".obs;
  final password = "".obs;
  final hasErrors = "".obs;
  final isObscured = true.obs;
  int agentId = 0;
  bool isLoggingIn = false;
  bool isUser = false;


  @override
  void onInit(){
    super.onInit();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose(){
    super.dispose();
    usernameController.dispose();
    passwordController.dispose();
  }

  setIsObscured(bool obscured){
    isObscured(obscured);
  }

  setHasErrors(String  errors){
    hasErrors(errors);
  }

  setUsername(String uname){
    username(uname);
  }

  setPassword(String upassword){
    password(upassword);
  }

  loginUser(String uname,String upass) async{
    const loginUrl = "https://www.fnetghana.xyz/auth/token/login";
    final myLink = Uri.parse(loginUrl);
    http.Response response = await client.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded"
    }, body: {
      "username": uname,
      "password": upass
    });

    if(response.statusCode == 200){

      isLoggingIn = false;
      isUser = true;
      final resBody = response.body;
      var jsonData = jsonDecode(resBody);
      var userToken = jsonData['auth_token'];
      storage.write("username", uname);
      storage.write("usertoken", userToken);
      if(!isLoggingIn && isUser){
        Get.offAll(()=> const HomePage(message: null,));
      }
    }
    else{
      isLoggingIn = false;
      isUser = false;
      setHasErrors("hasErrors");
      Get.snackbar("Error", "invalid login details",
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor
      );
    }
  }
}