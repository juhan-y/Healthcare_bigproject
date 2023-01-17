import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart'
    show ChangeNotifierProvider, MultiProvider;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'auth.dart';
import './drawer.dart';
import './waitlist.dart';
import './dashboard.dart';
import './qr_scanner.dart';
import './notification.dart';
import './style.dart' as style;
import './carousel.dart';
import './maps2.dart';
import './search_result.dart';

// 웹 서버와 연동하기 위해 도메인 설정 -> 어느 무선 네트워크에 연결되는 지에 따라 변경됨
// localhost(127.0.0.1)일 때는 10.0.2.2로 접속해야함 (웹 서버 실행시에는 그냥 실행),  본인 무선 네트워크일 때는 ipv4 -> 172.20.10.7 (웹 서버 실행시에도 동일)
final domain = '172.20.10.7'; // 10.0.2.2

// firebase authentication(회원가입, 로그인 기능) 선언
final auth = FirebaseAuth.instance;

// firebase firestore (DB) 선언
final firebase = FirebaseFirestore.instance;

void main() async {
  // 패키지 기능 초기화
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // splash 기능 설정
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  try {
    // firebase 초기화 (필수)
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print(e);
  }

  // App 실행 구조: MaterialApp -> MyAPP -> 각 페이지
  // ChangeNotifierProvider -> 전역 변수 같은 기능
  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FirebaseAuthProvider()),
      ],
      child: MaterialApp(
        theme: style.theme, // style.dart의 style 적용
        home: MyApp(),
      )));
}


// 메인 페이지  (main함수와 비슷)
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var qrData;
  var uid;
  var data;
  var infoList = [];
  var pages = [];
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  var notification_info = {}; // hospital -> doctor 순

  // splash가 유지될 수 있도록 설정
  void initialization() async {
    print('ready in 3...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 2...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 1...go!');
    FlutterNativeSplash.remove();
  }

  // QR Code에서 스캔한 정보와 유저 정보를 가지고 진료 대기열 추가
  pushQ (doc) async {
      var email = auth.currentUser?.email;
      Uri uri = Uri.parse("http://${domain}:8000/api/rsvs/${email.toString()}/");
      Map data = {
        "Doctor_ID": doc['Doctor_ID'],
      };

      // API 호출
      var body = json.encode(data);
      http.Response response = await http.post(
        uri,
        headers: <String, String> {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      // status code에 따른 성공/실패 여부 판단
      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
  }

  // 위치 권한 받아오는 메서드
  getLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      print('**************Location Permission Granted');
    } else {
      print('**************Location Permission Denied');
      await Permission.location.request();
    }
  }

  // 카메라 권한 받아오는 메서드
  getCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isGranted) {
      print('**************Permission Granted');
    } else {
      print('**************Permission Denied');
      await Permission.camera.request();
    }
  }

  // main 페이지의 초기화 메서드
  @override
  void initState() {
    super.initState();
    initialization();

    // 2초마다 새로운 예약 DB가져오기 (바뀌었다면 갱신)
    const oneSec = Duration(seconds:2);
    Timer.periodic(oneSec, (Timer t) => getAuthInfo());

    // notification 초기화 (앱 로드시 실행 필수)
    initNotification();
  }

  // 예약 DB 구축후 수정
  getAuthInfo() async {
    infoList = [];
    pages = [];
      // 현재 사용자 로그인 되어있을 경우
      if (auth.currentUser != null) {
        var email = auth.currentUser?.email;
        Uri uri = Uri.parse("http://${domain}:8000/api/rsvs/${email.toString()}/");
        final response = await http.get(uri);

        if (response.statusCode == 200) {
          var resData = jsonDecode(response.body);

          // 가져온 정보를 infoList에 추가
          for (var i = 0; i < resData.length; i++) {
            setState(() {
              infoList.add({
                'hospital': resData[i]['Hospital'].toString(),
                'doctor': resData[i]['doctor'],
                'order': resData[i]['Q'] - 1,
              });

              // 순서에 따른 notification이 진행되는데 만약 이미 호출된 경우라면 새로고침 시에 반복적으로 notification이 울리는 것을 방지
              if (notification_info.keys.contains(resData[i]['Hospital'].toString())) {
                if (!notification_info[resData[i]['Hospital'].toString()].keys.contains(resData[i]['doctor'].toString())) {
                  notification_info[resData[i]['Hospital'].toString()][resData[i]['doctor'].toString()] = [];
                }
              } else {
                notification_info[resData[i]['Hospital'].toString()] = {resData[i]['doctor'].toString(): []};
              }
            });

            // 대기 순서가 첫번째(0번째)인 경우
            if(resData[i]['Q'] == 1) {
              if (notification_info[resData[i]['Hospital'].toString()][resData[i]['doctor'].toString()].contains(0)) {
                continue;
              } else {
                showNotification0(resData[i]['Hospital'], resData[i]['doctor']);
                notification_info[resData[i]['Hospital'].toString()][resData[i]['doctor'].toString()].add(0);
              }
              // 대기 순서가 네번째(3번째)인 경우
            } else if (resData[i]['Q'] == 4) {
              if (notification_info[resData[i]['Hospital'].toString()][resData[i]['doctor'].toString()].contains(3)) {
                continue;
              } else {
                showNotification3(resData[i]['Hospital'], resData[i]['doctor']);
                notification_info[resData[i]['Hospital'].toString()][resData[i]['doctor'].toString()].add(3);
              }
            }

          }
        } else {
          print('Connection failed');
        }


      }
      // info List 잘 받아오는지 출력 확인
      print('!!!!!!!!!!!!!!!!infoList: ${infoList}');

      setState(() {
        // infoList를 잘 받아왔다면 pages를 예약정보 개수만큼 생성
        // pages는 메인 페이지 상단에 병원, 의사, 순서 표시하는 부분에 해당
        if (infoList.length != 0) {
          // 페이지 디자인
          pages = List.generate(
              infoList.length,
              (index) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Color.fromRGBO(231, 239, 250, 1),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Container(
                        margin: EdgeInsets.fromLTRB(15,10,15,10),
                        height: 300,
                        child: SafeArea(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('No.${index}', style: TextStyle(fontSize: 15, color: Colors.black87),),
                              Text(
                                'Hospital: ${infoList[index]['hospital']}',
                                style: TextStyle(color: Colors.black87),
                              ),
                              Text(
                                'Doctor: ${infoList[index]['doctor']}',
                                style: TextStyle(color: Colors.black87),
                              ),
                              Text(
                                'There are ${infoList[index]['order'].toString()} people waiting in front of you.',
                                style: TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                        )),
                  ));
        }
      });
  }

  var doc;
  var hos;
  var qrResult;
  final controller = PageController(viewportFraction: 0.9, );
  var value;

  @override
  Widget build(BuildContext context) {
    // 로그인되어 있지 않거나 예약이 없는 경우 표시할 dummy page
    final dummyPage = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Color.fromRGBO(231, 239, 250, 1),
      ),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Container(
          padding: EdgeInsets.all(10),
          height: 300,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('There is no reservation.'),
              ],
            ),
          )),
    );

    // QR 코드 찍고 난뒤 정보 받는 부분
    void _onPressedFAB() async {
      //비동기 실행으로 QR화면이 닫히기 전까지 await으로 기다리도록 한다.
      dynamic result =
          await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return QRCheckScreen(eventKeyword: 'doc');
        // doc라는 키워드가 포함되었을 때 반환받도록 한다.
      }));

      if (result != null) {
        setState(() {
          // qr스캐너에서 받은 결과값을 화면의 qrResult 에 적용하도록 한다.
          qrResult = result.toString();
          doc = jsonDecode(qrResult)['doc'];
          print(doc);
          // doctor 정보를 받아오기 위함
        });

        // pushQ 메서드에 doc정보 전달 -> 로그인되어 있다면 유저정보와 함께 대기열 추가 / 로그인 되어있지 않다면 대기열 추가 X
        var re = pushQ(doc);
        if (re == false) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text('Q push Failed. Something\'s wrong. please check again.')),
            );
          // 실행에 문제가 있다면 일시적인 하단 바 표시
        } else {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text('Q push Success')),
            );
          // 제대로 실행되었을 때의 일시적인 하단 바 표시
        }

      }
    }

    // 실제 페이지 디자인 구축
    return Scaffold(
      // menu(drawer) 생성
      drawer: MainDrawer(),

      // 가장 상단의 레이아웃 구성
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(246, 246, 246, 1),
        iconTheme: IconThemeData(
            color: Colors.black),
        actions: [
          (auth.currentUser != null) ? Image.asset('assets/profile.png',width: 50) : Icon(Icons.person_off, size:40),
          Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0)),
        ],
      ),

      // RefreshIndicator는 손으로 직접 내려 새로고침할 수 있는 기능
      body: RefreshIndicator(
        onRefresh: () async {
          getAuthInfo();
        },
        child: Container(
          // color: Color(0xdbddefff),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '  Wait List',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Stack(
                          children: [
                            waitListBox(
                                pages: pages,
                                controller: controller,
                                dummyPage: dummyPage),
                            Positioned(
                              top: 125,
                              left: 210,
                              child: Container(
                                width: 120,
                                height: 25,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (c) => Reservations()));
                                  },
                                  style: ButtonStyle(
                                    foregroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.white),
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Color(0xff82b3e3)),
                                    shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      //side: BorderSide(color: Colors.red) // border line color
                                    )),
                                  ),
                                  child: Row(children: [
                                    Icon(Icons.add, size: 15),
                                    Text('Receptions',style: TextStyle(fontSize: 12)),
                                  ]),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child: ClayContainer(

                    curveType: CurveType.none,
                    color: Colors.white,
                    depth: 30,
                    spread: 3,
                    borderRadius: 20,
                    width: 320, height: 50,
                    child: TextField(
                      keyboardType: TextInputType.text,
                      onChanged: (text){
                        value = text;
                      },
                      decoration: InputDecoration(
                          fillColor: Color.fromRGBO(231, 239, 250, 1),
                          border: InputBorder.none,
                          hintText: 'Search hospital',
                          icon: Padding(
                              padding: EdgeInsets.only(left: 13),
                              child: Icon(Icons.search))),
                      onSubmitted: (String value){
                        // 검색창에 text 입력 후 enter 또는 완료시 검색결과 페이지로 이동
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SearchResult(text:value)));
                      },
                    ),
                  ),
                ),

                // M2E (Super Walk) 메인 페이지에 표시
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(35, 30, 35, 10),
                      child: ClayContainer(
                        curveType: CurveType.none,
                        depth: 30,
                        spread: 3,
                        borderRadius: 20,
                        color: Colors.white,
                        width: double.infinity, height: 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              child: Text('Super Walk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black),),
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (c) => dashboard()));
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // maps 페이지로 이동하는 버튼 구현
                    Container(
                      margin: EdgeInsets.fromLTRB(35, 30, 35, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
                            width: MediaQuery.of(context).size.width*0.35, height: MediaQuery.of(context).size.width*0.35,
                            child: ClayContainer(
                            curveType: CurveType.none,
                            color: Colors.white, //Color(0xa8cce2f8)
                            depth: 30,
                            spread: 3,
                            borderRadius: 20,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  child: Text(
                                    'Maps',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  onPressed: () {
                                    getLocationPermission();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (c) => CurrentLocationScreen()));
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                          // QR Scanner로 이동하는 버튼 구현
                          Container(
                            margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                            width: MediaQuery.of(context).size.width*0.35, height: MediaQuery.of(context).size.width*0.35,
                            //color: Color(0xff94C6FF), width: 300, height: 200, margin: EdgeInsets.all(10),
                            child: ClayContainer(
                              curveType: CurveType.none,
                              color: Colors.white,
                              depth: 30,
                              spread: 3,
                              borderRadius: 15,
                              child: IconButton(
                                  onPressed: () {
                                    getCameraPermission();
                                    _onPressedFAB();
                                  },
                                  icon: Icon(Icons.qr_code_2, size:70)),
                            ),
                          ),]
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: MaterialStateColor.resolveWith((states) => Color.fromRGBO(246, 246, 246, 1)),

      // BM 접근 -> 하단에 광고 바 표시 (일정 시간마다 자동으로 넘김)
      bottomNavigationBar: BottomAppBar(child: Container(height: 50, child: Stack(children: [carousel()])), ),
    );
  }
}

// Wait List 동작 UI (오른쪽 왼쪽으로 넘기는 기능) 을 도와주는 위젯
class PageIndicator extends StatelessWidget {
  const PageIndicator({Key? key, this.n_pages, this.controller})
      : super(key: key);
  final n_pages;
  final controller;
  @override
  Widget build(BuildContext context) {
    return SmoothPageIndicator(
        controller: controller,
        count: n_pages == 0 ? 1 : n_pages,
        effect: ScrollingDotsEffect(
          activeStrokeWidth: 2.6,
          activeDotScale: 1.3,
          maxVisibleDots: 5,
          radius: 8,
          spacing: 10,
          dotHeight: 12,
          dotWidth: 12,
        ));
  }
}

// 실제 waitList 블럭을 구성하는 위젯
class waitListBox extends StatelessWidget {
  const waitListBox({Key? key, this.pages, this.controller, this.dummyPage})
      : super(key: key);
  final pages;
  final controller;
  final dummyPage;

  @override
  Widget build(BuildContext context) {
    if (pages.length != 0) {
      return SizedBox(
        height: 150,
        width: double.infinity,
        child: PageView.builder(
          controller: controller,
          // itemCount: pages.length,
          itemBuilder: (_, index) {
            return pages[index % pages.length];
          },
        ),
      );
    } else {
      return SizedBox(
        height: 150,
        width: double.infinity,
        child: PageView.builder(
          controller: controller,
          // itemCount: pages.length,
          itemBuilder: (_, index) {
            return dummyPage;
          },
        ),
      );
    }
  }
}