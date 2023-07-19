import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';

import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../static/app_colors.dart';

import 'homepage.dart';


class UpdateCustomersDetails extends StatefulWidget {
  final id;
  const UpdateCustomersDetails({Key? key,this.id}) : super(key: key);

  @override
  _UpdateCustomersDetailsState createState() => _UpdateCustomersDetailsState(id:this.id);
}

class _UpdateCustomersDetailsState extends State<UpdateCustomersDetails> {
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

  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _locationController = TextEditingController();
  late final TextEditingController _digitalAddressController = TextEditingController();
  late final TextEditingController _phoneController = TextEditingController();
  late final TextEditingController _idTypeController = TextEditingController();
  late final TextEditingController _idNumberController = TextEditingController();

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

  fetchData()async{
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
      });

      setState(() {
        isLoading = false;
      });
    }
  }

  updateCustomer()async{
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
          const SizedBox(height: 30,),
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
                      controller: _nameController..text= detailCustomerName,
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
                      controller: _locationController..text= detailCustomerLocation,
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
                      controller: _idNumberController..text= detailIdNumber,
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
                      controller: _digitalAddressController..text= detailCustomerDigitalAddress,
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
                      controller: _phoneController..text= detailCustomersPhone,
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
                        updateCustomer();
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

  void _onDropDownItemSelectedIdTypes(newValueSelected) {
    setState(() {
      _currentSelectedIdType = newValueSelected;
    });
  }
}
