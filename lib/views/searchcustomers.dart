import 'dart:convert';
import 'package:fnet_new/static/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;



class SearchCustomers extends StatefulWidget {
  const SearchCustomers({Key? key}) : super(key: key);

  @override
  _SearchCustomersState createState() => _SearchCustomersState();
}

class _SearchCustomersState extends State<SearchCustomers> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _searchFilter = TextEditingController();
  late List searchedCustomers = [];
  late List customers = [];
  bool isSearching = true;
  var items;
  late String uToken = "";
  final storage = GetStorage();
  late String username = "";

  fetchCustomer(String searchItem)async{
    final url = "https://fnetghana.xyz/search_user_customers?search=$searchItem";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      customers = json.decode(jsonData);
    }
    else{

    }

    setState(() {
      isSearching = false;
      customers = customers;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
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
  bool isFullScreen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Find any customer"),
          backgroundColor: primaryColor,
        ),
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 30,),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: _searchFilter,
                          cursorColor: primaryColor,
                          cursorRadius: const Radius.elliptical(10, 10),
                          cursorWidth: 10,
                          decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search,color: secondaryColor,),
                              labelText: "Enter customer's name or phone",
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
                              return "Please field cannot be empty";
                            }
                          },
                        ),
                        const SizedBox(height: 20,),
                        RawMaterialButton(
                          onPressed: () {
                            setState(() {
                              isSearching = false;
                            });
                            if (!_formKey.currentState!.validate()) {
                              return;
                            } else {
                              fetchCustomer(_searchFilter.text);
                            }
                          },
                          shape: const StadiumBorder(),
                          elevation: 8,
                          fillColor: primaryColor,
                          splashColor: defaultColor,
                          child: const Icon(Icons.search,color: Colors.white,),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              isSearching ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  color: secondaryColor,
                ),
              ) : Expanded(
                flex: 3,
                child: ListView.builder(
                    itemCount: customers != null ? customers.length : 0,
                    itemBuilder: (context,i){
                      items = customers[i];
                      return Column(
                        children: [
                          const SizedBox(height: 20,),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0,right: 8),
                            child: Card(
                              color: secondaryColor,
                              elevation: 12,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              // shadowColor: Colors.pink,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 18),
                                child: ListTile(

                                  title: Padding(
                                    padding: const EdgeInsets.only(bottom: 10.0),
                                    child: Row(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(top:10.0),
                                          child: Text("Name: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(top:10.0),
                                          child: Text(items['name'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                        ),
                                      ],
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Text("Phone: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                          Text(items['phone'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text("Location: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                          Text(items['location'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Text("Date of birth: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                          Text(items['date_of_birth'],style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: items["get_customer_pic"] != ""
                                      ? FullScreenWidget(
                                    disposeLevel: DisposeLevel.High,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: CircleAvatar(
                                        radius: 40,
                                        backgroundImage: NetworkImage(
                                          items["get_customer_pic"],
                                        ),
                                      ),
                                    ),
                                  )
                                      : const CircleAvatar(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      child: Icon(Icons.person)),
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    }
                ),
              )
            ],
          ),
        )
    );
  }
}
