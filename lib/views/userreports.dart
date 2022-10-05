import 'dart:convert';
import 'package:fnet_new/views/reportdetail.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../static/app_colors.dart';
import 'addreport.dart';

class Reports extends StatefulWidget {
  const Reports({Key? key}) : super(key: key);

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  late String username = "";
  final storage = GetStorage();
  late String uToken = "";
  bool hasToken = false;
  List allReports = [];
  bool isLoading = true;
  var items;

  fetchAllUserReports() async {
    const url = "https://fnetghana.xyz/get_all_my_reports/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allReports = json.decode(jsonData);
    }
    setState(() {
      isLoading = false;
      allReports = allReports;
    });
  }

  @override
  void initState() {
    super.initState();
    if (storage.read("username") != null) {
      setState(() {
        username = storage.read("username");
      });
    }

    if (storage.read("usertoken") != null) {
      setState(() {
        hasToken = true;
        uToken = storage.read("usertoken");
      });
    }
    fetchAllUserReports();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        backgroundColor: primaryColor,
      ),
      body: isLoading ? const Center(
        child: CircularProgressIndicator(
          strokeWidth: 5,
          color: secondaryColor,
        ),
      ) :
      ListView.builder(
          itemCount: allReports != null ? allReports.length : 0,
          itemBuilder: (context,i){
            items = allReports[i];
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
                    child: ListTile(

                      title: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            "${items['date_reported']}",style: const TextStyle(color:Colors.white)
                        ),
                      ),

                      onTap: (){
                        Get.to(() => ReportDetail(id:allReports[i]['id'].toString()));
                      },

                    ),
                  ),
                )
              ],
            );
          }
      ),
        floatingActionButton:FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: (){
            Get.to(() => const AddNewReport());
          },
          child: const Icon(Icons.edit,size:20,color:Colors.white)
        )
    )
    );
  }
}
