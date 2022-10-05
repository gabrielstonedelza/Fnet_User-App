import 'dart:convert';
import 'package:direct_dialer/direct_dialer.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../sendsms.dart';
import 'bottomnavigation.dart';
import 'homepage.dart';

class DepositDetail extends StatefulWidget {
  final id;
  const DepositDetail({Key? key,this.id}) : super(key: key);

  @override
  _DepositDetailState createState() => _DepositDetailState(id:this.id);
}

class _DepositDetailState extends State<DepositDetail> {
  final id;
  _DepositDetailState({required this.id});
  late String detailCustomer = "";
  late String detailAmount = "";
  late String detailRequestOption = "";
  late String detailDate = "";
  late String detailTime = "";
  late String agentId = "";
  bool isLoading = true;
  bool isFetching = true;
  late String uToken = "";
  final storage = GetStorage();
  late String username = "";
  late String adminPhone = "";

  final SendSmsController sendSms = SendSmsController();
  Future<void> dial() async {
    final dialer = await DirectDialer.instance;
    await dialer.dial('*171\%23#');
  }

  fetchData()async{
    final requestUrl = "https://fnetghana.xyz/customer_request_detail/$id/";
    final myLink = Uri.parse(requestUrl);
    http.Response response = await http.get(myLink);
    if(response.statusCode == 200){
      final codeUnits = response.body;
      var jsonData = jsonDecode(codeUnits);
      setState(() {
        detailCustomer = jsonData['customer_name'];
        detailAmount = jsonData['amount'];
        detailRequestOption = jsonData['request_option'];
        detailDate = jsonData['date_requested'];
        detailTime = jsonData['time_requested'];
        agentId = jsonData['agent'].toString();
      });
    }
    setState(() {
      isLoading = false;
      isFetching = false;
    });
  }
  fetchAdmin() async {
    const agentUrl = "https://fnetghana.xyz/admin_user";
    final agentLink = Uri.parse(agentUrl);
    http.Response res = await http.get(agentLink);
    if (res.statusCode == 200) {
      final codeUnits = res.body;
      var jsonData = jsonDecode(codeUnits);
      var myUser = jsonData[0];
      setState(() {
        adminPhone = myUser['phone'];
      });
    }
  }

  approveRequest()async{
    final requestUrl = "https://fnetghana.xyz/approve_customer_request/$id/";
    final myLink = Uri.parse(requestUrl);
    final response = await http.put(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      'Accept': 'application/json',
      "Authorization": "Token $uToken"
    },body: {
      "agent": agentId,
      "request_status": "Approved"
    });
    if(response.statusCode == 200){
      Get.snackbar("Congrats", "Request was approved",
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor
      );
      Get.offAll(()=> const MyBottomNavigationBar());
    }
    else{
      Get.snackbar("Approve Error", response.body.toString(),
          colorText: defaultTextColor,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: snackColor
      );
    }
  }

  deleteCustomerRequest()async{
    final url = "https://fnetghana.xyz/delete_customer_request/$id";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink);

    if(response.statusCode == 204){
      Get.offAll(()=> const MyBottomNavigationBar());
    }
    else{

    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (storage.read("usertoken") != null) {
      setState(() {
        uToken = storage.read("usertoken");
      });
    }
    if (storage.read("username") != null) {
      setState(() {
        username = storage.read("username");
      });
    }
    fetchData();
    fetchAdmin();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text("Approve Request"),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 30,),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 12,
              color: secondaryColor,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: isFetching ? const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    color: primaryColor,
                  ),
                ) : ListTile(
                  title: Row(
                    children: [
                      const Text("User: ",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
                      Text("${detailCustomer.capitalize}",style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Colors.white),),
                    ],
                  ),
                  subtitle: Column(
                    children: [
                      Row(
                        children: [
                          const Text("Request Option: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                          Text(detailRequestOption,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("Amount: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                          Text(detailAmount,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("Date requested: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                          Text(detailDate,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("Time requested: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                          Text(detailTime.toString().split(".").first,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RawMaterialButton(
              onPressed: () {
                Get.defaultDialog(
                    buttonColor: primaryColor,
                    title: "Confirm approval",
                    middleText: "Are you sure you want to approve this request?",
                    confirm: RawMaterialButton(
                        shape: const StadiumBorder(),
                        fillColor: primaryColor,
                        onPressed: (){
                          approveRequest();
                          Get.back();
                        }, child: const Text("Yes",style: TextStyle(color: Colors.white),)),
                    cancel: RawMaterialButton(
                        shape: const StadiumBorder(),
                        fillColor: primaryColor,
                        onPressed: (){Get.back();},
                        child: const Text("Cancel",style: TextStyle(color: Colors.white),))
                );
              },
              shape: const StadiumBorder(),
              elevation: 8,
              child: const Text(
                "Approve",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white),
              ),
              fillColor: primaryColor,
              splashColor: defaultColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RawMaterialButton(
              onPressed: () {
                Get.defaultDialog(
                    buttonColor: primaryColor,
                    title: "Confirm cancel",
                    middleText: "Are you sure you want to cancel and delete this request?",
                    confirm: RawMaterialButton(
                        shape: const StadiumBorder(),
                        fillColor: primaryColor,
                        onPressed: (){
                          deleteCustomerRequest();
                          Get.back();
                        }, child: const Text("Yes",style: TextStyle(color: Colors.white),)),
                    cancel: RawMaterialButton(
                        shape: const StadiumBorder(),
                        fillColor: primaryColor,
                        onPressed: (){Get.back();},
                        child: const Text("Cancel",style: TextStyle(color: Colors.white),))
                );
              },
              shape: const StadiumBorder(),
              elevation: 8,
              child: const Text(
                "Cancel and delete",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white),
              ),
              fillColor: primaryColor,
              splashColor: defaultColor,
            ),
          ),
        ],
      ),
    );
  }
}
