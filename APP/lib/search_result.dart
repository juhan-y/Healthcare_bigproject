import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './main.dart' as main;
import 'dart:convert';
import 'package:http/http.dart' as http;
import './maps2.dart';

final domain = main.domain;

// 검색결과 페이지 위젯
class SearchResult extends StatefulWidget {
  SearchResult({Key? key, this.text}) : super(key: key);
  final text;

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  final firebase = FirebaseFirestore.instance;
  dynamic data = 0;
  var search_bool = false;
  var hospitals = [];

  // 페이지 접속 시 전달받은 text를 바탕으로 검색 결과 찾기
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      getResult(widget.text);
    });

  }

  // text를 받아 탐색 api 호출 -> 이후 받은 정보 hospitals에 저장
  getResult(text) async{
    try {
      Uri uri = Uri.parse("http://${domain}:8000/api/hospital_search/${text}/");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        hospitals = jsonDecode(response.body);
        print('hospitals = ${hospitals}');
      } else {
        print('Connection failed');
      }
      setState((){
        if (hospitals.length != 0) {search_bool = true;}
        else {search_bool = false;}
      });

    } catch (e) {
      print(e);
      setState((){
        search_bool = false;
      });
    }
  }
  final controller = PageController(keepPage: true);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search Result'), centerTitle: true, ),
      body: ListView.builder(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.all(10),
          itemCount: (hospitals.length == 0) ? 1 : hospitals.length, //length로 수정
          itemBuilder: (c, i) {
            return (hospitals.length == 0) ? DummyResult(searchText:widget.text): ResultText(data: hospitals[i]);
          },
        ),
    );
  }
}

// 받아온 병원 정보들 레이아웃 구성
class ResultText extends StatelessWidget {
  const ResultText({Key? key, this.data}) : super(key: key);
  final data;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin:EdgeInsets.fromLTRB(30, 10, 30, 10),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.12,
      child: ClayContainer(
        curveType: CurveType.none,
        color: Colors.white,
        depth: 30,
        spread: 3,
        borderRadius: 20,
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text(data['hospital_name'], style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [Text('Hospital Status'), Icon(Icons.circle, color: (data['hospital_status'] == true) ? Colors.green:Colors.red,), IconButton(onPressed: (){Navigator.push(context,MaterialPageRoute(builder: (c)=>CurrentLocationScreen(lat:data['lat'], lng:data['lng'])));}, icon: Icon(Icons.map))]),
        ],),
      ),
    );
  }
}

// 검색결과가 없다면 dummy 레이아웃 표시
class DummyResult extends StatelessWidget {
  const DummyResult({Key? key, this.searchText}) : super(key: key);
  final searchText;
  @override
  Widget build(BuildContext context) {
    return ClayContainer(
      child: Column(children: [
        Text('There is no result for ${searchText}'),
      ],),
    );
  }
}