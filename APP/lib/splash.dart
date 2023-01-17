import 'dart:async';
import 'package:flutter/material.dart';
import 'package:healthcare_bigproject/main.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';


// 앱 처음에 실행할 때 로딩시간 동안 표시할 배너 페이지

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen> {
  var dummy = 0;
  @override
  void initState() {
    super.initState();
    print('splash init!!!!');
    setState(() {
      dummy += 1;
      // 최소 2초 동안 보여줄 수 있도록 함
      Timer(
        Duration(seconds: 2),
            () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        ),
      );
    });

  }

  // 배너 이미지 레이아웃 구성
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return WidgetAnimator(
        atRestEffect: WidgetRestingEffects.pulse(effectStrength: 1),
        incomingEffect: WidgetTransitionEffects.incomingSlideInFromTop(
            blur: const Offset(0, 20), scale: 3),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xff82b3e3),
          image: DecorationImage(
              image: AssetImage('assets/logoWhite.png'), fit: BoxFit.contain),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0.0,
              left: 0.0,
              child: Container(
                width: width -100,
                height: height -100,
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(),
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}