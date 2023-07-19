import 'package:flutter/material.dart';
import 'package:fnet_new/controllers/logincontroller.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../loadingui.dart';
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


  final _formKey = GlobalKey<FormState>();
  late final TextEditingController unameController;
  late final TextEditingController passWordController;
  LoginController loginController = Get.find();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _usernameFocusNode = FocusNode();

  @override
  void initState(){
    super.initState();
    unameController = TextEditingController();
    passWordController = TextEditingController();
  }

  @override
  void dispose(){
    super.dispose();
    unameController.dispose();
    passWordController.dispose();
  }

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
                    !isPosting ? Column(
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
                              focusNode: _usernameFocusNode,
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
                              focusNode: _passwordFocusNode,
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
                      ],
                    ) : Container(),
                    const SizedBox(height: 25,),
                    isPosting ? const LoadingUi() :  Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: primaryColor
                      ),
                      height: size.height * 0.08,
                      width: size.width * 0.8,
                      child: RawMaterialButton(
                        onPressed: () {
                          _startPosting();
                          FocusScopeNode currentFocus = FocusScope.of(context);

                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
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
                        fillColor: primaryColor,
                        splashColor: defaultColor,
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: defaultTextColor1),
                        ),
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
  }
}
