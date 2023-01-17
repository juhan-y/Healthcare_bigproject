import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './main.dart' as main;

final auth = FirebaseAuth.instance;
final firebase = FirebaseFirestore.instance;

final domain = main.domain;



// 위젯이름은 reservation이지만 예약을 뜻하는 것이 아닌 대기 리스트를 뜻하는 것입니다.
class Reservations extends StatefulWidget {
  Reservations({Key? key}) : super(key: key);

  @override
  State<Reservations> createState() => _ReservationsState();
}

class _ReservationsState extends State<Reservations> {
  var ls = [];

  // setState 메서드로 새로고침 메서드 생성.
  refreshFunc() {
    setState(() {

    });
  }

  @override
  void initState() {
    super.initState();
    getList();
  }

  // 사용자가 예약한 대기 정보 받아오기 -> 병원, 의사, 대기 순서, 예약 ID
  getList() async {
    ls = [];
    var email = auth.currentUser?.email;
    Uri uri = Uri.parse("http://${domain}:8000/api/rsvs/${email.toString()}/");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      var resData = jsonDecode(response.body);

      for (var i = 0; i < resData.length; i++) {
        ls.add({
          'Hospital': resData[i]['Hospital'].toString(),
          'Doctor': resData[i]['doctor'],
          'Q': resData[i]['Q'],
          'RsvID': resData[i]['RsvID'],
        });

      }
    } else {
      print('Connection failed');
    }

    // 새로고침 용
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 246, 246, 1),
      appBar: AppBar(
        title: Text('My Receptions',style: TextStyle(color: Colors.black)),
        backgroundColor: Color.fromRGBO(246, 246, 246, 1),
        centerTitle: false,
        iconTheme: IconThemeData(
            color: Colors.black),
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: ListView.builder(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(10),
        itemCount: ls.length, //length로 수정
        itemBuilder: (c, i) {
          return waitentry(i: i, ls: ls, getList:getList);
        },
      ),
    );
  }
}

// 실제 대기열 정보 디자인 구성
class waitentry extends StatelessWidget {
  const waitentry({Key? key, this.i, this.ls, this.getList})
      : super(key: key);
  final i;
  final ls;
  final getList;

  @override
  Widget build(BuildContext context) {
    print('ls: ${ls}');
    return Container(
      height: 200,
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.white,),
        boxShadow: [BoxShadow(
          color: Colors.grey,
          blurRadius: 10,
          spreadRadius: 0.05,
        )],
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        color: Colors.white,
      ),// color: Color(0xff82b3e3),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              waitlight(order: ls[i]['Q']),
              Text('Hospital : ${ls[i]['Hospital']}'),
              Text('Doctor : ${ls[i]['Doctor']}'),
              // Text('Order : ${ls[i]['Queue']}'),
              OutlinedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.pressed)) {
                          return Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5);
                        }
                        return Colors.grey[300]; // Use the component's default.
                      },
                    ),
                  ),
                  child: Text('Cancel'),

                  // Cancel 버튼 누를 시 DB로 대기 정보 ID가 전달되면서 대기 취소.
                  onPressed: () async {
                    Uri uri = Uri.parse("http://${domain}:8000/api/rsv/${ls[i]['RsvID']}/");
                    http.Response response = await http.post(
                      uri,
                    );
                    getList();
                    print('post complete.');
                  }),
            ]),
      );
  }
}

// 대기열 정보 위에 표시할 부분
class waitlight extends StatelessWidget {
  const waitlight({Key? key, this.order}) : super(key: key);
  final order;

  @override
  Widget build(BuildContext context) {
    // 대기순서 4명 미만 일때 초록불, 이외에는 빨간불로 표시
    var green = (order < 4);
    var w = '0' * (3 - order.toString().length) + order.toString();
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
      width: double.infinity,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.all(
          Radius.circular(5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          (w == '000')
              ? Text('${w} : Wait Status  ', style: TextStyle(fontSize: 15))
              : Text('${w} : Wait Status  ', style: TextStyle(fontSize: 10)),
          // 대기중, 완료 등 색상 if문 처리
          (green)
              ? Icon(
                  Icons.circle,
                  size: 8,
                  color: Colors.green,
                )
              : Icon(Icons.circle, size: 8, color: Colors.red)
        ],
      ),
    );
  }
}

class WaitList extends StatelessWidget {
  const WaitList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('대기 현황 Wait List', style: TextStyle(fontWeight: FontWeight.w700)),
        Container(
            margin: EdgeInsets.all(10),
            alignment: Alignment.center,
            child: ClayContainer(
                width: double.infinity,
                height: 70,
                color: Colors.white,
                child: Text('ex) 대기 3번째입니다.')))
      ],
    );
  }
}
