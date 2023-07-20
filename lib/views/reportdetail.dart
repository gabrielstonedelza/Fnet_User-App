import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../static/app_colors.dart';

class ReportDetail extends StatefulWidget {
  String id;
  ReportDetail({Key? key,required this.id}) : super(key: key);

  @override
  State<ReportDetail> createState() => _ReportDetailState(id:this.id);
}

class _ReportDetailState extends State<ReportDetail> {
  String id;
  _ReportDetailState({required this.id});

  late String title = "";
  late String report = "";
  late String dateReporter = "";
  late String timeReporter = "";
  late String username = "";
  List allReports = [];
  final storage = GetStorage();
  late String uToken = "";
  bool hasToken = false;
  bool isLoading = true;

  fetchReportDetail() async {
    final url = "https://fnetghana.xyz/report_detail/$id/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});

    if (response.statusCode == 200) {
      final codeUnits = response.body;
      var jsonData = jsonDecode(codeUnits);
      report = jsonData["report"];
      timeReporter = jsonData["time_reported"];
      dateReporter = jsonData["date_reported"];
    }

    setState(() {
      isLoading = false;
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
    fetchReportDetail();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:Scaffold(
        appBar: AppBar(
          title: const Text("Report Detail"),
          backgroundColor: primaryColor,
        ),
        body:isLoading ? const Center(
          child: CircularProgressIndicator(
            strokeWidth: 5,
            color: secondaryColor,
          ),
        ) : ListView(
          children: [
            const SizedBox(height:20),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 12,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: Text(report,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 15),)
                      ),
                      const SizedBox(height:20),
                      Text(dateReporter)
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
      )
    );
  }
}
