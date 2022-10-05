
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:rxdart/rxdart.dart';

class LocalNotificationManager{
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  var initSetting;
  BehaviorSubject<ReceiveNotification> get didReceiveLocalNotificationSubject => BehaviorSubject<ReceiveNotification>();

  LocalNotificationManager.init(){
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if(Platform.isIOS){
      requestIOSPermission();
    }
    initializePlatform();
  }
  String greetingMessage(){
    var timeNow = DateTime.now().hour;
    if (timeNow <= 12) {
      return 'Good Morning';
    } else if ((timeNow > 12) && (timeNow <= 16)) {
      return 'Good Afternoon';
    } else if ((timeNow > 16) && (timeNow < 20)) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  requestIOSPermission(){
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
        alert: true,
        badge: true,
        sound: true
    );
  }

  initializePlatform(){
    var initSettingAndroid = const AndroidInitializationSettings("iconlauncher");
    // var initSettingIOS = IOSInitializationSettings(
    //     requestSoundPermission: true,
    //     requestBadgePermission: true,
    //     requestAlertPermission: true,
    //     onDidReceiveLocalNotification: (id,title,body,payload)async{
    //       ReceiveNotification notification = ReceiveNotification(id: id, title: title, body: body, payload: payload);
    //       didReceiveLocalNotificationSubject.add(notification);
    //
    //     }
    // );
    initSetting = InitializationSettings(android: initSettingAndroid,);
  }
  setOnNotificationReceive(Function onNotificationReceive){
    didReceiveLocalNotificationSubject.listen((notification) {
      onNotificationReceive(notification);
    });
  }

  // setOnNotificationClick(Function onNotificationClick)async{
  //   await flutterLocalNotificationsPlugin.initialize(initSetting,onSelectNotification: (String? payload)async{
  //     onNotificationClick(payload);
  //   });
  // }
  // setOnBirthDayNotificationClick(Function onBirthdayNotificationClick)async{
  //   await flutterLocalNotificationsPlugin.initialize(initSetting,onSelectNotification: (String? payload)async{
  //     onBirthdayNotificationClick(payload);
  //   });
  // }

  setOnApprovedPaymentNotificationReceive(Function onNotificationReceive){
    didReceiveLocalNotificationSubject.listen((notification) {
      onNotificationReceive(notification);
    });
  }

  // setOnApprovedPaymentNotificationClick(Function onNotificationClick)async{
  //   await flutterLocalNotificationsPlugin.initialize(initSetting,onSelectNotification: (String? payload)async{
  //     onNotificationClick(payload);
  //   });
  // }

  Future<void> showApprovedPaymentNotification(String title,String body) async{
    var androidChannel = const AndroidNotificationDetails(
        "CHANNEL_ID",
        "CHANNEL_NAME",
        importance: Importance.max,
        priority: Priority.high,
        playSound: true
    );

    var platformChannel = NotificationDetails(android: androidChannel,);
    await flutterLocalNotificationsPlugin.show(0, title, body, platformChannel,payload: "New Payload");
  }

  setOnApprovedBankDepositNotificationReceive(Function onNotificationReceive){
    didReceiveLocalNotificationSubject.listen((notification) {
      onNotificationReceive(notification);
    });
  }

  // setOnApprovedBankDepositNotificationClick(Function onNotificationClick)async{
  //   await flutterLocalNotificationsPlugin.initialize(initSetting,onSelectNotification: (String? payload)async{
  //     onNotificationClick(payload);
  //   });
  // }

  Future<void> showApprovedBankDepositNotification(String title,String body) async{
    var androidChannel = const AndroidNotificationDetails(
        "CHANNEL_ID",
        "CHANNEL_NAME",
        importance: Importance.max,
        priority: Priority.high,
        playSound: true
    );

    var platformChannel = NotificationDetails(android: androidChannel,);
    await flutterLocalNotificationsPlugin.show(0, title, body, platformChannel,payload: "New Payload");
  }
  Future<void> showNotification() async{
    var androidChannel = const AndroidNotificationDetails(
        "CHANNEL_ID",
        "CHANNEL_NAME",
        importance: Importance.max,
        priority: Priority.high,
        playSound: true
    );

    var platformChannel = NotificationDetails(android: androidChannel,);
    await flutterLocalNotificationsPlugin.show(0, "Test Title", "Test Body", platformChannel,payload: "New Payload");
  }
  Future<void> showBirthDayInFiveNotification() async{
    var androidChannel = const AndroidNotificationDetails(
        "CHANNEL_ID",
        "CHANNEL_NAME",
        importance: Importance.max,
        priority: Priority.high,
        playSound: true
    );

    var platformChannel = NotificationDetails(android: androidChannel,);
    await flutterLocalNotificationsPlugin.show(0, "Birth day alert", "Customers birthday in five days", platformChannel,payload: "New Payload");
  }
  Future<void> showBirthDayTodayNotification() async{
    var androidChannel = const AndroidNotificationDetails(
        "CHANNEL_ID",
        "CHANNEL_NAME",
        importance: Importance.max,
        priority: Priority.high,
        playSound: true
    );

    var platformChannel = NotificationDetails(android: androidChannel,);
    await flutterLocalNotificationsPlugin.show(0, "Birth day alert", "Customers birthday today", platformChannel,payload: "New Payload");
  }
  Future<void> showAddMomoAccountsNotification() async{

    var time = const Time(07,34,00);
    var androidChannel = const AndroidNotificationDetails(
        "CHANNEL_ID",
        "CHANNEL_NAME",
        importance: Importance.max,
        priority: Priority.high,
        playSound: true
    );

    var platformChannel = NotificationDetails(android: androidChannel,);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        0,
        greetingMessage(),
        "Don't forget to add and close your momo accounts for today.",
        time,
        platformChannel,
        payload: "New Payload"
    );
  }


  Future<void> showDailyAtTimeNotification() async{
    var time = Time(10,36,0);
    var androidChannel = AndroidNotificationDetails(
        "CHANNEL_ID",
        "CHANNEL_NAME",
        importance: Importance.max,
        priority: Priority.high,
        playSound: true
    );
    // var iosChannel = IOSNotificationDetails();
    var platformChannel = NotificationDetails(android: androidChannel,);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        0,
        "Test Title",
        "Test Body",
        time,
        platformChannel,
        payload: "New Payload"
    );
  }

  Future<void> showWeeklyAtDayTimeSundayNotification() async{
    var time = const Time(07,00,00);
    var androidChannel = AndroidNotificationDetails(
        "CHANNEL_ID",
        "CHANNEL_NAME",
        importance: Importance.max,
        priority: Priority.high,
        playSound: true
    );
    // var iosChannel = IOSNotificationDetails();
    var platformChannel = NotificationDetails(android: androidChannel,);
    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
        0,
        greetingMessage(),
        "It's a beautiful Sunday Morning,join us today at church as we worship God",
        Day.sunday,
        time,
        platformChannel,
        payload: "New Payload"
    );
  }
  Future<void> showWeeklyAtDayTimeMondayNotification() async{
    var time = const Time(07,00,00);
    var androidChannel = AndroidNotificationDetails(
        "CHANNEL_ID",
        "CHANNEL_NAME",
        importance: Importance.max,
        priority: Priority.high,
        playSound: true
    );
    // var iosChannel = IOSNotificationDetails();
    var platformChannel = NotificationDetails(android: androidChannel,);
    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
        0,
        greetingMessage(),
        "New Prayer Requests coming in everyday.Pray for someone",
        Day.monday,
        time,
        platformChannel,
        payload: "New Payload"
    );
  }
  Future<void> showWeeklyAtDayTimeTuesDayNotification() async{
    var time = const Time(07,00,00);
    var androidChannel = AndroidNotificationDetails(
        "CHANNEL_ID",
        "CHANNEL_NAME",
        importance: Importance.max,
        priority: Priority.high,
        playSound: true
    );
    // var iosChannel = IOSNotificationDetails();
    var platformChannel = NotificationDetails(android: androidChannel,);
    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
        0,
        greetingMessage(),
        "Other members are uploading beautiful stories just for you.",
        Day.tuesday,
        time,
        platformChannel,
        payload: "New Payload"
    );
  }
  Future<void> showWeeklyAtDayTimeWednesDayNotification() async{
    var time = const Time(12,03,00);
    var androidChannel = AndroidNotificationDetails(
        "CHANNEL_ID",
        "CHANNEL_NAME",
        importance: Importance.max,
        priority: Priority.high,
        playSound: true
    );
    // var iosChannel = IOSNotificationDetails();
    var platformChannel = NotificationDetails(android: androidChannel,);
    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
        0,
        greetingMessage(),
        "Don't miss any event.",
        Day.wednesday,
        time,
        platformChannel,
        payload: "New Payload"
    );
  }
  Future<void> showWeeklyAtDayTimeThursdayNotification() async{
    var time = const Time(07,00,00);
    var androidChannel = AndroidNotificationDetails(
        "CHANNEL_ID",
        "CHANNEL_NAME",
        importance: Importance.max,
        priority: Priority.high,
        playSound: true
    );
    // var iosChannel = IOSNotificationDetails();
    var platformChannel = NotificationDetails(android: androidChannel,);
    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
        0,
        greetingMessage(),
        "Don't miss any announcement.",
        Day.thursday,
        time,
        platformChannel,
        payload: "New Payload"
    );
  }
}

LocalNotificationManager localNotificationManager = LocalNotificationManager.init();

class ReceiveNotification{
  final int? id;
  final String? title;
  final String? body;
  final String? payload;
  ReceiveNotification({required this.id,required this.title,required this.body,required this.payload});
}