import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:fnet_new/pointssummarydetails.dart';
import 'package:fnet_new/static/app_colors.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import 'loadingui.dart';



class MyPointsSummary extends StatefulWidget {
  const MyPointsSummary({Key? key}) : super(key: key);

  @override
  State<MyPointsSummary> createState() => _MyPointsSummaryState();
}

class _MyPointsSummaryState extends State<MyPointsSummary> {
  double sum = 0.0;
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  late List allPoints = [];
  var items;
  bool isLoading = true;
  late List amounts = [];
  late List bankAmounts = [];
  late List pointsDates = [];

  Future<void>fetchAllPoints()async{
    const url = "https://fnetghana.xyz/get_my_account_number_points/";
    var myLink = Uri.parse(url);
    final response = await http.get(myLink, headers: {
      "Authorization": "Token $uToken"
    });

    if(response.statusCode ==200){
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allPoints = json.decode(jsonData);
      if (kDebugMode) {
        print(allPoints);
      }

      for(var i in allPoints){
        if(!pointsDates.contains(i['date_deposited'].toString().split("T").first)){
          pointsDates.add(i['date_deposited'].toString().split("T").first);
        }
      }
      setState(() {
        isLoading = false;
      });
    }
    else{
      if (kDebugMode) {
        print(response.body);
      }
    }

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
    fetchAllPoints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Points Summary"),
          backgroundColor: defaultColor,
        ),
        body: isLoading ? const LoadingUi() :
        ListView.builder(
            itemCount: pointsDates != null ? pointsDates.length : 0,
            itemBuilder: (context,i){
              items = pointsDates[i];
              return Column(
                children: [
                  const SizedBox(height: 10,),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return PointsSummaryDetail(date_deposited:pointsDates[i]);
                      }));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0,right: 8),
                      child: Card(
                        color: secondaryColor,
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        // shadowColor: Colors.pink,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0,bottom: 5),
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: Row(
                                children: [
                                  const Text("Date: ",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),
                                  Text(items,style: const TextStyle(fontSize: 15,fontWeight: FontWeight.bold,color: Colors.white),),

                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              );
            }
        ),
    );
  }
}
