import 'dart:math';
import 'package:flutter/material.dart';
import 'widget/DashBoardCard.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widget/market.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final firebase = FirebaseFirestore.instance;

// M2E (Super Walk) 페이지에 접근하면 가장 먼저 나타나는 페이지
class dashboard extends StatefulWidget {
  const dashboard({Key? key}) : super(key: key);

  @override
  _dashboardState createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
  // M2E 기능에 필요한 변수들
  double x = 0.0;
  double y = 0.0;
  double z = 0.0;
  double miles = 0.0;
  double duration = 0.0;
  double calories = 0.0;
  double addValue = 0.025;
  int steps = 0;
  int availableSteps = 0;
  int points = 0;

  // 이전까지 사용됐던 steps, availableSteps, points DB에서 불러오기
  getSteps() async {
    var step = await firebase.collection('m2e').doc('superwalk').get();
    steps = step['steps'];
    availableSteps = step['availableSteps'];
    points = step['points'];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSteps();
  }

  double previousDistacne = 0.0;
  double distance = 0.0;

  // 자식 위젯에서 steps를 사용할 때 steps를 감소시키는 메서드
  changeSteps(int value) {
    setState(() {
      availableSteps -= value;
    });
  }

  // 자식 위젯에서 points를 교환할 때 points를 증가시키는 메서드
  changePoints(int value) {
    setState(() {
      points += value;
    });
  }

  // 저장 메서드 -> M2E 페이지를 나갈 때 적용 (변동사항 저장)
  saveVariable() async {
    await firebase.collection('m2e').doc('superwalk').set(
        {'steps': steps, 'availableSteps': availableSteps, 'points': points});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 246, 246, 1),
      appBar: AppBar(
        title: Text(
          'SuperWalk',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color.fromRGBO(246, 246, 246, 1),
        centerTitle: false,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            saveVariable();
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (c) => Market()));
              },
              icon: Icon(
                Icons.shopping_basket,
                size: 40,
                color: Colors.blue,
              )),
          Padding(padding: EdgeInsets.fromLTRB(0, 0, 20, 0)),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: StreamBuilder<AccelerometerEvent>(
          stream: SensorsPlatform.instance.accelerometerEvents,
          builder: (context, snapShort) {
            if (snapShort.hasData) {
              x = snapShort.data!.x;
              y = snapShort.data!.y;
              z = snapShort.data!.z;
              distance = getValue(x, y, z);

              // 센서의 value를 가져와 일정 이상 움직였을 때 steps 증가.
              if (distance > 7) {
                steps++;
                availableSteps++;
              }
              calories = calculateCalories(steps);
              duration = calculateDuration(steps);
              miles = calculateMiles(steps);
            }
            return Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                        Color.fromRGBO(246, 246, 246, 1),
                        Colors.white,
                      ])),
                ),
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(),

                        // M2E 페이지 내부 2개의 Card형식의 위젯들
                        dashboardCard(
                            steps, availableSteps, miles, calories, duration),
                        dailyAverage(steps, availableSteps, points, changeSteps,
                            changePoints),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 모바일 기기 센서의 값을 가져온다. (이전값과 비교하여 계산됨)
  double getValue(double x, double y, double z) {
    double magnitude = sqrt(x * x + y * y + z * z);
    getPreviousValue();
    double modDistance = magnitude - previousDistacne;
    setPreviousValue(magnitude);
    return modDistance;
  }

  // 현재까지 사용한 value 저장
  void setPreviousValue(double distance) async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    _pref.setDouble("preValue", distance);
  }

  // 이전 저장 value를 가져오기
  void getPreviousValue() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    setState(() {
      previousDistacne = _pref.getDouble("preValue") ?? 0.0;
    });
  }

  // 이동거리 계산
  double calculateMiles(int steps) {
    double milesValue = (0.0005 * steps);
    return milesValue;
  }

  // 이용한 시간 계산
  double calculateDuration(int steps) {
    double durationValue = (steps * 1 / 83.333);
    return durationValue;
  }

  // 칼로리 계산
  double calculateCalories(int steps) {
    double caloriesValue = (steps * 0.0566);
    return caloriesValue;
  }
}
