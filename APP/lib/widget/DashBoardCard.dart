import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'imageContainer.dart';
import 'textWidget.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class dashboardCard extends StatefulWidget {
  int steps;
  int availableSteps;
  double miles, calories, duration;
  dashboardCard(this.steps, this.availableSteps, this.miles, this.calories, this.duration,
      {Key? key})
      : super(key: key);

  @override
  State<dashboardCard> createState() => _dashboardCardState();
}

class _dashboardCardState extends State<dashboardCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SafeArea(
        child: Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              SizedBox(
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        padding: EdgeInsets.fromLTRB(30, 10, 0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Text("Today's Steps",style: TextStyle(fontSize: 25),),
                            // this is for the count in foot step and edit button
                            Container(
                              height:50,
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  text(40, widget.steps.toString()),
                                  ClayContainer(curveType: CurveType.none,
                                      color: Colors.white,
                                      depth: 30,
                                      spread: 3,
                                      borderRadius: 20,child: Text('Usable steps ${widget.availableSteps.toString()}', style: TextStyle(fontSize: 20, color: Colors.red),)),
                                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 10, 0)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
                child: LinearPercentIndicator(
                  percent: (widget.steps/10000).clamp(0, 1),
                  progressColor: Colors.green,
                  lineHeight: 20,
                  animation: false,
                  center: Text(
                    (widget.steps/100).toStringAsFixed(1) + "%",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white),),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              // this is botton part
              Row(
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  imageContainer(
                      "assets/locations.png", widget.miles.toStringAsFixed(2), "Kilometers"),
                  imageContainer("assets/calories.png",
                      widget.calories.toStringAsFixed(2), "Calories"),
                  imageContainer("assets/stopwatch.png",
                      widget.duration.toStringAsFixed(2), "Duration"),
                ],
              ),
            ],
          ),
        ),

      )
    );
  }
}

class dailyAverage extends StatefulWidget {
  int steps;
  int availableSteps;
  int points;

  dailyAverage(this.steps, this.availableSteps, this.points, this.changeSteps, this.changePoints, {Key? key}) : super(key: key);
  final changeSteps;
  final changePoints;
  @override
  State<dailyAverage> createState() => _dailyAverageState();
}

class _dailyAverageState extends State<dailyAverage> {

  @override
  void FlutterDialog() {
    showDialog(
        context: context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        builder: (BuildContext context) {
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            //Dialog Main Title
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.asset("assets/point.png",height: 100 ,width: 100),
                Text(
                  "You got points!", style: TextStyle(fontSize: 30),
                ),
              ],
            ),
            actions: <Widget>[
              new ElevatedButton(
                child: new Text("close", style: TextStyle(fontSize: 20,)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  @override
  void FlutterDialogNo() {
    showDialog(
        context: context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        builder: (BuildContext context) {
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            //Dialog Main Title
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Image.asset("assets/run.png",height: 100 ,width: 100),
                Text(
                  "Collect more steps!", style: TextStyle(fontSize: 30),
                ),
              ],
            ),
            actions: <Widget>[
              new ElevatedButton(
                child: new Text("close", style: TextStyle(fontSize: 20,)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }


  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SafeArea(
          child: Container(
            height: 350,
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: text(20, 'My points : ${widget.points} p',)),
                ),
                Container(
                  height: 70,
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Color.fromRGBO(231, 239, 250, 1),
                      border: (
                          Border.all(width: 2, color: Colors.grey,)
                      )
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.roller_skating_rounded, color: Colors.blue), Spacer(flex: 3,),Text('2,000 Steps', style: TextStyle(fontSize: 20)
                      ),Spacer(flex: 30,),ElevatedButton(style: TextButton.styleFrom(onSurface: Colors.blue),
                        onPressed: (widget.availableSteps >= 2000) ? () async {setState(() {
                          widget.changePoints(10);
                          widget.changeSteps(2000);
                        }); FlutterDialog();
                        } : null,
                        child: Text("Get 10P", style: TextStyle(fontSize: 15)),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 70,
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Color.fromRGBO(231, 239, 250, 1),
                      border: (
                          Border.all(width: 2, color: Colors.grey,)
                      )
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.roller_skating_rounded, color: Colors.blue), Spacer(flex: 3,),Text('5,000 Steps', style: TextStyle(fontSize: 20),
                      ),Spacer(flex: 30,),ElevatedButton(style: TextButton.styleFrom(onSurface: Colors.blue),
                        onPressed: (widget.availableSteps >= 5000) ? () async {setState(() {
                          widget.changePoints(30);
                          widget.changeSteps(5000);
                        }); FlutterDialog();
                        } : null,
                        child: Text("Get 30p", style: TextStyle(fontSize: 15)),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 70,
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: Color.fromRGBO(231, 239, 250, 1),
                      border: (
                          Border.all(width: 2, color: Colors.grey,)
                      )
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.roller_skating_rounded, color: Colors.blue), Spacer(flex: 3,),Text('10,000 Steps', style: TextStyle(fontSize: 20)),
                      Spacer(flex: 30,),ElevatedButton(
                        style: TextButton.styleFrom(onSurface: Colors.blue),
                        onPressed: (widget.availableSteps >= 10000) ? () async {setState(() {
                          widget.changePoints(70);
                          widget.changeSteps(10000);
                        }); FlutterDialog();
                        } : null,
                        child: Text("Get 70p", style: TextStyle(fontSize: 15)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}

void pointup(){

}