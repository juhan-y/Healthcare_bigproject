import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final notifications = FlutterLocalNotificationsPlugin();


//1. 앱로드시 실행할 기본설정
initNotification() async {

  //안드로이드용 아이콘파일 이름
  var androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');

  //ios에서 앱 로드시 유저에게 권한요청 -> 안드로이드는 다른 설정파일에서 이미 진행
  var iosSetting = IOSInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  var initializationSettings = InitializationSettings(
      android: androidSetting,
      iOS: iosSetting
  );
  await notifications.initialize(
    initializationSettings,
  );
}

// 2. 이 함수 원하는 곳에서 실행하면 알림 뜸

// 0번째 (본인 차례일 때 notification)
showNotification0(hospital, doctor) async {

  var androidDetails = AndroidNotificationDetails(
    '유니크한 알림 채널 ID',
    '알림종류 설명',
    priority: Priority.high,
    importance: Importance.max,
    color: Color.fromARGB(255, 255, 0, 0),
  );

  var iosDetails = IOSNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  notifications.show(
      1,
      'Now, It\'s your turn',
      'hospital: ${hospital}, doctor: ${doctor}.',
      NotificationDetails(android: androidDetails, iOS: iosDetails)
  );
}

// 3번째 차례일 때 notification
showNotification3(hospital, doctor) async {

  var androidDetails = AndroidNotificationDetails(
    '유니크한 알림 채널 ID',
    '알림종류 설명',
    priority: Priority.high,
    importance: Importance.max,
    color: Color.fromARGB(255, 255, 0, 0),
  );

  var iosDetails = IOSNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  // 알림 id, 알림 내용 넣기
  notifications.show(
      1,
      'There are 3 people waiting in front of you.',
      'hospital: ${hospital}, doctor: ${doctor}.',
      NotificationDetails(android: androidDetails, iOS: iosDetails)
  );
}