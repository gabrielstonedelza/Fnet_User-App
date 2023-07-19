import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../static/app_colors.dart';
import 'homepage.dart';


class AddNewReport extends StatefulWidget {
  const AddNewReport({Key? key}) : super(key: key);

  @override
  State<AddNewReport> createState() => _AddNewReportState();
}

class _AddNewReportState extends State<AddNewReport> {
  late final TextEditingController titleController = TextEditingController();
  late final TextEditingController reportController = TextEditingController();

  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  bool isPosting = false;

  final _formKey = GlobalKey<FormState>();
  void _startPosting()async{
    setState(() {
      isPosting = true;
    });
    await Future.delayed(const Duration(seconds: 4));
    setState(() {
      isPosting = false;
    });
  }
  addNewReport()async{
    const registerUrl = "https://fnetghana.xyz/add_report/";
    final myLink = Uri.parse(registerUrl);
    final res = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "report": reportController.text,
    });
    if(res.statusCode == 201){
      Get.snackbar("Congratulations", "report added successfully",
          colorText: defaultTextColor,
          snackPosition: SnackPosition.TOP,
          backgroundColor: snackColor);
      Get.offAll(()=>const HomePage(message: null,));
    }
    else{
      Get.snackbar("Error", "something went",
          colorText: defaultTextColor,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red);
    }
  }
  
  @override
  void initState() {
    super.initState();
    if(storage.read("usertoken") != null){
      setState(() {
        uToken = storage.read("usertoken");
      });
    }
    if(storage.read("username") != null){
      setState(() {
        username = storage.read("username");
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:Scaffold(
        appBar: AppBar(
          title: const Text("Add Report"),
          backgroundColor: primaryColor,
          actions: [
            isPosting ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 5,
                color: primaryColor,
              ),
            ) :  TextButton(
              onPressed:(){
                _startPosting();
                if (!_formKey.currentState!.validate()) {
                  Get.snackbar("Error", "something went wrong. Please try again",
                      colorText: defaultTextColor,
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red);
                  return;
                } else {
                  addNewReport();
                }
              },
              child: const Text("Done",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),)
            )
          ],
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        autofocus: true,
                        controller: reportController,
                        cursorColor: primaryColor,
                        cursorRadius: const Radius.elliptical(5, 5),
                        cursorWidth: 5,
                        maxLines: 50,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                            focusColor: primaryColor,
                            fillColor: Colors.white,
                            focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    color: Colors.transparent, width: 2),
                                borderRadius: BorderRadius.circular(12)),
                            // border: OutlineInputBorder(
                            //     borderRadius: BorderRadius.circular(12))
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter report";
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        )
      )
    );
  }
}
