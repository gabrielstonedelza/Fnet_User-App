import 'package:flutter/material.dart';
import 'package:fnet_new/controllers/logincontroller.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool isObscured = true;

  final Uri _url = Uri.parse('https://fnetghana.xyz/password-reset/');


  Future<void> _launchInBrowser() async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }


  final _formKey = GlobalKey<FormState>();
  late final TextEditingController unameController = TextEditingController();
  late final TextEditingController passWordController = TextEditingController();
  bool isPosting = false;
  LoginController loginController = Get.find();

  @override
  Widget build(BuildContext context) {
    Size size  = MediaQuery.of(context).size;
    return Stack(
      children: [
        const BackgroundImage(image: "assets/images/pexels-alesia-kozik-6771985.jpg",),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              const Flexible(
                  child:
                  Center(
                    child: Text("FNET",style: TextStyle(color: primaryColor,fontSize: 50,fontWeight: FontWeight.bold),
                    ),
                  )
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: size.height * 0.08,
                      width: size.width * 0.8,
                      decoration: BoxDecoration(
                          color: Colors.grey[500]?.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16)
                      ),
                      child: Center(
                        child: TextFormField(
                          controller: unameController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.person,color: defaultTextColor1,),
                            hintText: "Username",
                            hintStyle: TextStyle(color: defaultTextColor1,),

                          ),
                          cursorColor: defaultTextColor1,
                          style: const TextStyle(color: defaultTextColor1),
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          validator: (value){
                            if(value!.isEmpty){
                              return "Enter username";
                            }
                            else{
                              return null;
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15,),
                    Container(
                      height: size.height * 0.08,
                      width: size.width * 0.8,
                      decoration: BoxDecoration(
                          color: Colors.grey[500]?.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16)
                      ),
                      child: Center(
                        child: TextFormField(
                          controller: passWordController,
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              onPressed: (){
                                setState(() {
                                  isObscured = !isObscured;
                                });
                              },
                              icon: Icon(isObscured ? Icons.visibility : Icons.visibility_off,color: defaultTextColor1,),
                            ),
                            border: InputBorder.none,
                            prefixIcon: const Icon(FontAwesomeIcons.lock,color: defaultTextColor1,),
                            hintText: "Password",
                            hintStyle: const TextStyle(color: defaultTextColor1),

                          ),
                          cursorColor: defaultTextColor1,
                          style: const TextStyle(color: defaultTextColor1),
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          obscureText: isObscured,
                          validator: (value){
                            if(value!.isEmpty){
                              return "Enter password";
                            }
                            else{
                              return null;
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15,),
                    InkWell(
                        onTap: () async{
                          await _launchInBrowser();
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(width: 1,color: defaultTextColor1))
                          ),
                          child: const Text("Forgot Password",style: TextStyle(fontWeight: FontWeight.bold,color: defaultTextColor1),),
                        )),
                    const SizedBox(height: 25,),
                    loginController.isLoggingIn ? const Center(
                        child: CircularProgressIndicator.adaptive()
                    ) :  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: primaryColor
                      ),
                      height: size.height * 0.08,
                      width: size.width * 0.8,
                      child: RawMaterialButton(
                        onPressed: () {
                          loginController.isLoggingIn = true;
                          if (_formKey.currentState!.validate()) {
                            loginController.loginUser(unameController.text.trim(), passWordController.text.trim());

                          } else {
                            Get.snackbar("Error", "Something went wrong",
                                colorText: defaultTextColor1,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red
                            );
                            return;
                          }
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)
                        ),
                        elevation: 8,
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: defaultTextColor1),
                        ),
                        fillColor: primaryColor,
                        splashColor: defaultColor,
                      ),
                    ),
                    const SizedBox(height: 25,),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
    // return Scaffold(
    //   body: ListView(
    //     children: [
    //       const SizedBox(height: 100,),
    //       // Image.asset("assets/images/logo.png"),
    //       SizedBox(
    //         height: 150,
    //           child: Lottie.asset("assets/json/26436-login-circle.json")),
    //       const SizedBox(height: 30,),
    //
    //       Padding(
    //         padding: const EdgeInsets.all(18.0),
    //         child: Form(
    //           key: _formKey,
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.stretch,
    //             children: [
    //               Padding(
    //                 padding: const EdgeInsets.only(bottom: 10.0),
    //                 child: TextFormField(
    //                   controller: unameController,
    //                   cursorColor: primaryColor,
    //                   cursorRadius: const Radius.elliptical(10, 10),
    //                   cursorWidth: 10,
    //                   decoration: InputDecoration(
    //                     prefixIcon: const Icon(Icons.person,color: primaryColor,),
    //                       labelText: "Enter your username",
    //                       labelStyle: const TextStyle(color: secondaryColor),
    //                       focusColor: primaryColor,
    //                       fillColor: primaryColor,
    //                       focusedBorder: OutlineInputBorder(
    //                           borderSide: const BorderSide(
    //                               color: primaryColor, width: 2),
    //                           borderRadius: BorderRadius.circular(12)),
    //                       border: OutlineInputBorder(
    //                           borderRadius: BorderRadius.circular(12))),
    //                   keyboardType: TextInputType.text,
    //                   validator: (value) {
    //                     if(value!.isEmpty){
    //                       return "Please enter your username";
    //                     }
    //                   },
    //                 ),
    //               ),
    //               Padding(
    //                 padding: const EdgeInsets.only(bottom: 10.0),
    //                 child: TextFormField(
    //                   controller: passWordController,
    //                   cursorColor: primaryColor,
    //                   cursorRadius: const Radius.elliptical(10, 10),
    //                   cursorWidth: 10,
    //                   decoration: InputDecoration(
    //                     prefixIcon: const Icon(Icons.lock,color: primaryColor,),
    //                       suffixIcon: IconButton(
    //                         onPressed: (){
    //                           setState(() {
    //                             loginController.isObscured.value = !loginController.isObscured.value;
    //                           });
    //                         },
    //                         icon: Icon(loginController.isObscured.value ? Icons.visibility : Icons.visibility_off,color: primaryColor,),
    //                       ),
    //                       labelText: "Enter your password",
    //                       labelStyle: const TextStyle(color: secondaryColor),
    //                       focusColor: primaryColor,
    //                       fillColor: primaryColor,
    //                       focusedBorder: OutlineInputBorder(
    //                           borderSide: const BorderSide(
    //                               color: primaryColor, width: 2),
    //                           borderRadius: BorderRadius.circular(12)),
    //                       border: OutlineInputBorder(
    //                           borderRadius: BorderRadius.circular(12))),
    //                   keyboardType: TextInputType.text,
    //                   validator: (value) {
    //                     if(value!.isEmpty){
    //                       return "Please enter your password";
    //                     }
    //                   },
    //                   obscureText: loginController.isObscured.value,
    //                 ),
    //               ),
    //               const SizedBox(height: 20,),
    //                RawMaterialButton(
    //                 onPressed: () {
    //                   _startPosting();
    //                   Get.snackbar("Please wait", "Verifying your details",
    //                       colorText: defaultTextColor,
    //                       snackPosition: SnackPosition.BOTTOM,
    //                       backgroundColor: snackColor
    //                   );
    //                   if (!_formKey.currentState!.validate()) {
    //                     return;
    //                   } else {
    //                     loginController.loginUser(unameController.text, passWordController.text);
    //                   }
    //                 },
    //                 shape: const StadiumBorder(),
    //                 elevation: 8,
    //                 child: const Text(
    //                   "Login",
    //                   style: TextStyle(
    //                       fontWeight: FontWeight.bold,
    //                       fontSize: 20,
    //                       color: Colors.white),
    //                 ),
    //                 fillColor: primaryColor,
    //                 splashColor: defaultColor,
    //               ),
    //               const SizedBox(height: 10,),
    //               GestureDetector(
    //                   onTap: (){
    //                     //  open forgot password url
    //                     _lanchInBrowser(resetPasswordUrl);
    //                   },
    //                   child: const Text("Forgot Password?",style: TextStyle(fontWeight: FontWeight.bold),
    //                   ))
    //             ],
    //           ),
    //         ),
    //       )
    //     ],
    //   ),
    // );
  }
}
