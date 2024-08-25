import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart' as myGet;
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../static/app_colors.dart';

import 'homepage.dart';


class UpdateCustomersDetails extends StatefulWidget {
  final id;
  const UpdateCustomersDetails({Key? key,this.id}) : super(key: key);

  @override
  _UpdateCustomersDetailsState createState() => _UpdateCustomersDetailsState(id:this.id);
}

class _UpdateCustomersDetailsState extends State<UpdateCustomersDetails> {
  File? image;

  final picker = ImagePicker();
  File? imageFile;
  void showInstalled() {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => Card(
        elevation: 12,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10), topLeft: Radius.circular(10))),
        child: SizedBox(
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(
                  child: Text("Select Source",
                      style: TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      _imgFromGallery();
                      Navigator.pop(context);
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/gallery.png",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("Gallery",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _imgFromCamera();
                      Navigator.pop(context);
                    },
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/images/camera.png",
                          width: 50,
                          height: 50,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Text("Camera",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _imgFromCamera() async {
    await picker
        .pickImage(source: ImageSource.camera, imageQuality: 50)
        .then((value) {
      if (value != null) {
        // _cropImage(File(value.path));
        setState(() {
          uploadedPath = value.path;
          imageFile = File(value.path);
        });
      }
    });
  }

  _imgFromGallery() async {
    await picker
        .pickImage(source: ImageSource.gallery, imageQuality: 50)
        .then((value) {
      if (value != null) {
        // _cropImage(File(value.path));
        setState(() {
          uploadedPath = value.path;
          imageFile = File(value.path);
        });
      }
    });
  }

  var dio = Dio();
  bool isUpLoading = false;
  late String uploadedPath = "";

  Future<void> updateAndSaveCustomer(File file) async {
    try {
      isUpLoading = true;
      //updating user profile details
      String fileName = file.path.split('/').last;
      var formData1 = FormData.fromMap({
        'customer_pic':
        await MultipartFile.fromFile(file.path, filename: fileName),
        "name": _nameController.text,
        "location": _locationController.text,
        "id_type": _currentSelectedIdType,
        "id_number": _idNumberController.text,
        "digital_address": _digitalAddressController.text,
        "phone": _phoneController.text
      });
      var response = await dio.put(
        'https://fnetghana.xyz/update_customers_details/$id/',
        data: formData1,
        options: Options(headers: {
          // "Authorization": "Token $uToken",
          "HttpHeaders.acceptHeader": "accept: application/json",
        }, contentType: Headers.formUrlEncodedContentType),
      );
      if (response.statusCode != 200) {
        Get.snackbar("Sorry", "something went wrong. Please try again",
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red);
      } else {
        setState((){
          isUpLoading = false;
        });
        Get.snackbar("Hurray 😀", "details updated successfully.",
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: defaultColor,
            duration: const Duration(seconds: 5));
        Get.offAll(() => const HomePage(
          message: null,
        ));
      }
    } on DioException catch (e) {
      Get.snackbar("Sorry", e.toString(),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red);
    } finally {
      isUpLoading = false;
    }
  }
  final id;
  _UpdateCustomersDetailsState({required this.id});
  late String detailCustomerName = "";
  late String detailCustomerLocation = "";
  late String detailCustomerDigitalAddress = "";
  late String detailCustomersPhone = "";
  late String detailCustomersDob= "";
  late String detailIdType = "";
  late String detailIdNumber = "";
  bool isLoading = true;

  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _digitalAddressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _idNumberController;

  bool isPosting = false;
  final List idTypes = [
    "Select Id Type",
    "Passport",
    "Ghana Card",
    "Drivers License",
    "Voters Id"
  ];
  var _currentSelectedIdType = "Select Id Type";

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

  Future<void>fetchData()async{
    final requestUrl = "https://fnetghana.xyz/update_customers_details/$id/";
    final myLink = Uri.parse(requestUrl);
    http.Response response = await http.get(myLink);
    if(response.statusCode == 200){
      final codeUnits = response.body;
      var jsonData = jsonDecode(codeUnits);
      setState(() {
        detailCustomerName = jsonData['name'];
        detailCustomerLocation = jsonData['location'];
        detailIdType = jsonData['id_type'];
        detailIdNumber = jsonData['id_number'];
        detailCustomerDigitalAddress = jsonData['digital_address'];
        detailCustomersPhone = jsonData['phone'];
        detailCustomersDob = jsonData['date_of_birth'];
        _currentSelectedIdType = detailIdType;
        _nameController = TextEditingController(text: detailCustomerName);
        _locationController = TextEditingController(text: detailCustomerLocation);
        _digitalAddressController = TextEditingController(text: detailCustomerDigitalAddress);
        _phoneController = TextEditingController(text: detailCustomersPhone);
        _idNumberController = TextEditingController(text: detailIdNumber);
      });

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void>updateCustomer()async{
    final requestUrl = "https://fnetghana.xyz/update_customers_details/$id/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
    },body: {
      "name": _nameController.text,
      "location": _locationController.text,
      "id_type": _currentSelectedIdType,
      "id_number": _idNumberController.text,
      "digital_address": _digitalAddressController.text,
      "phone": _phoneController.text
    });
    if(response.statusCode == 200){
      Get.snackbar("Congrats", "Details were updated",
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor
      );

      Get.offAll(()=> const HomePage(message: null,));
    }
    else{

      Get.snackbar("Approve Error", response.body.toString(),
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor
      );
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Details"),
        backgroundColor: primaryColor,
      ),
      body: isLoading ? const Center(
          child: CircularProgressIndicator(
            color: primaryColor,
            strokeWidth: 5,
          )
      ) : ListView(
        children: [
          const SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18.0),
                    child: TextFormField(
                      controller: _nameController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,
                      decoration: InputDecoration(
                          labelText: "Edit name",
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
                    padding: const EdgeInsets.only(bottom: 18.0),
                    child: TextFormField(
                      controller: _locationController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,

                      decoration: InputDecoration(
                          labelText: "Edit location",
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
                          return "Please enter a location";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Customers current id type is $detailIdType",style: const TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Select the same id type as previous from the list if id type hasn't changed"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey, width: 1)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 10),
                        child: DropdownButton(
                          hint: const Text("Select Id Type"),
                          isExpanded: true,
                          underline: const SizedBox(),

                          items: idTypes.map((dropDownStringItem) {
                            return DropdownMenuItem(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem),
                            );
                          }).toList(),
                          onChanged: (newValueSelected) {

                            _onDropDownItemSelectedIdTypes(newValueSelected);
                          },
                          value: _currentSelectedIdType,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18.0),
                    child: TextFormField(
                      controller: _idNumberController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,

                      decoration: InputDecoration(
                          labelText: "Edit id number",
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
                          return "Please enter id number";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18.0),
                    child: TextFormField(
                      controller: _digitalAddressController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,

                      decoration: InputDecoration(
                          labelText: "Edit digital address",
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
                          return "Please enter address";
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18.0),
                    child: TextFormField(
                      controller: _phoneController,
                      cursorColor: primaryColor,
                      cursorRadius: const Radius.elliptical(10, 10),
                      cursorWidth: 10,

                      decoration: InputDecoration(
                          labelText: "Edit phone",
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
                          return "Please enter phone number";
                        }
                      },
                    ),
                  ),
                  Row(
                      children: [
                        const Icon(Icons.upload),
                        const SizedBox(width:30),
                        uploadedPath != "" ? const Text("Image picked",style:TextStyle(fontWeight:FontWeight.bold))
                            : TextButton(
                            onPressed:(){
                              showInstalled();
                            },
                            child:const Text("Add or update Customer pic",style:TextStyle(fontWeight:FontWeight.bold))
                        ),
                      ]),
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
                      if (!_formKey.currentState!.validate()) {
                        return;
                      } else {
                        if(_currentSelectedIdType == "Select Id Type"){
                          Get.snackbar("Id Type Error", "Please select an id Type",snackPosition: SnackPosition.BOTTOM,colorText: Colors.white,backgroundColor: Colors.red);
                          return;
                        }
                        if(imageFile != null){
                          updateAndSaveCustomer(imageFile!);
                        }else{
                          updateCustomer();
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
                      "Update",
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

  void _onDropDownItemSelectedIdTypes(newValueSelected) {
    setState(() {
      _currentSelectedIdType = newValueSelected;
    });
  }
}
