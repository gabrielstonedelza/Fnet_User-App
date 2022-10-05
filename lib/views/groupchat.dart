import 'dart:async';
import 'dart:convert';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import "package:get/get.dart";
import 'package:grouped_list/grouped_list.dart';
import '../static/app_colors.dart';
import 'allusers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class GroupChat extends StatefulWidget {
  const GroupChat({Key? key}) : super(key: key);

  @override
  State<GroupChat> createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  late String username = "";
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  List groupMessages = [];
  bool isLoading = true;
  late Timer _timer;
  late final TextEditingController messageController = TextEditingController();
  final FocusNode messageFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  sendGroupMessage() async {
    const bidUrl = "https://fnetghana.xyz/send_group_message/";
    final myLink = Uri.parse(bidUrl);
    http.Response response = await http.post(myLink, headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": "Token $uToken"
    }, body: {
      "message": messageController.text,
    });
    if (response.statusCode == 201) {
    } else {
      if (kDebugMode) {
        print(response.body);
      }
    }
  }

  fetchAllGroupMessages() async {
    const url = "https://fnetghana.xyz/get_all_group_message/";
    var myLink = Uri.parse(url);
    final response =
        await http.get(myLink, headers: {"Authorization": "Token $uToken"});

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      groupMessages = json.decode(jsonData);
    }

    setState(() {
      isLoading = false;
      groupMessages = groupMessages;
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
    fetchAllGroupMessages();
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      fetchAllGroupMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.grey,
            appBar: AppBar(
              title: const Text("Group Chats"),
              backgroundColor: primaryColor,
              actions: [
                IconButton(
                    onPressed: () {
                      Get.to(() => const AllUsers());
                    },
                    icon: const Icon(Icons.people_alt))
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: GroupedListView<dynamic, String>(
                    padding: const EdgeInsets.all(8),
                    reverse: true,
                    order: GroupedListOrder.DESC,
                    elements: groupMessages,
                    groupBy: (element) =>
                        element['timestamp'].toString().split("T").first,
                    groupSeparatorBuilder: (String groupByValue) => Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        groupByValue,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    // groupHeaderBuilder: (),
                    itemBuilder: (context, dynamic element) => SlideInUp(
                      animate: true,
                      child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 12,
                          child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 18.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          element['get_phone_number'],
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          element['get_username'],
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 18.0),
                                    child: SelectableText(
                                      element['message'],
                                      showCursor: true,
                                      cursorColor: Colors.blue,
                                      cursorRadius: const Radius.circular(10),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        element['timestamp']
                                            .toString()
                                            .split("T")
                                            .first,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        element['timestamp']
                                            .toString()
                                            .split("T")
                                            .last
                                            .substring(0, 8),
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ))),
                    ),
                    // itemComparator: (item1, item2) => item1['get_username'].compareTo(item2['get_username']), // optional
                    useStickyGroupSeparators: true, // optional
                    floatingHeader: true, // optional
                    // order: GroupedListOrder.ASC, // optional
                  ),
                ),
                Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Form(
                    key: _formKey,
                    child: Container(
                      color: Colors.grey.shade300,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: TextFormField(
                          controller: messageController,
                          focusNode: messageFocusNode,
                          cursorColor: defaultTextColor2,
                          cursorRadius: const Radius.elliptical(10, 10),
                          cursorWidth: 5,
                          maxLines: null,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: const Icon(
                                  Icons.send,
                                  color: primaryColor,
                                ),
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  if (messageController.text == "") {
                                    Get.snackbar("Sorry",
                                        "message field cannot be empty",
                                        snackPosition: SnackPosition.TOP,
                                        colorText: defaultTextColor1,
                                        backgroundColor: Colors.red);
                                  } else {
                                    sendGroupMessage();
                                    messageController.text = "";
                                  }
                                },
                              ),
                              hintText: "Message here.....",
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.transparent, width: 2),
                                  borderRadius: BorderRadius.circular(12))),
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            )));
  }
}
