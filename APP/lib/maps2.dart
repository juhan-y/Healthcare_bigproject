import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocode/geocode.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './main.dart' as main;

// firebase firestore (DB) 불러오기
final firebase = FirebaseFirestore.instance;
final domain = main.domain;

// 현재 위치 화면 띄우기
class CurrentLocationScreen extends StatefulWidget {
  const CurrentLocationScreen({Key? key, this.lat, this.lng}) : super(key: key);
  final lat;
  final lng;

  @override
  _CurrentLocationScreenState createState() => _CurrentLocationScreenState();
}

class _CurrentLocationScreenState extends State<CurrentLocationScreen> {
  String address = '' ;
  final Completer<GoogleMapController> _controller = Completer();

  // 사용자의 현재 위치 권한 있다면 현재 위치 가져오기
  Future<Position> _getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value) {
    }).onError((error, stackTrace){
      print(error.toString());
    });

    return await Geolocator.getCurrentPosition();
  }

  // 지도에 병원 표시할 marker
  final List<Marker> _markers =  <Marker>[];

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.501, 127.01),
    zoom: 14,
  );

  // DB에 저장되어 있는 병원 정보들 가져와서 marker에 추가
  getHospitals () async {
    var hospitals = [];
    Uri uri = Uri.parse("http://${domain}:8000/api/hospital_api/");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      hospitals = jsonDecode(response.body);
      print('news[0][\'Hospital_ID\'] = ${hospitals}');
    } else {
      print('Connection failed');
    }
    for (var i = 0; i < hospitals.length; i++) {
      print(hospitals[i]['lat']);
      setState(() {
        _markers.add(Marker(
            markerId: MarkerId(hospitals[i]['Hospital_ID'].toString()),
            position: LatLng(hospitals[i]['lat'] as double, hospitals[i]['lng'] as double),
            onTap: (){showDialog(context: context, builder: (context) => TapToHos(data:hospitals[i]));},
            infoWindow: InfoWindow(
              title: hospitals[i]['hospital_name'],
            )
        ));
      });

    }
  }


  @override
  void initState() {
    super.initState();
    getHospitals();
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition _kResult = CameraPosition(
      target: LatLng(37.5, 127.1),
      zoom: 14,
    );
    if (widget.lat != null && widget.lng != null) {
      _kResult = CameraPosition(
        target: LatLng(widget.lat as double, widget.lng as double),
        zoom: 14,
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xffB3D6FF),
        title: Text('Flutter Google Map'),
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            GoogleMap(
              initialCameraPosition: (widget.lat == null || widget.lng == null)?_kGooglePlex:_kResult,
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              markers: Set<Marker>.of(_markers),
              onMapCreated: (GoogleMapController controller){
                _controller.complete(controller);
              },
                padding: EdgeInsets.only(
                    bottom:MediaQuery.of(context).size.height*0.15)
            ),
          ],
        ),

      ),
    );
  }
}

// 병원 마커 클릭시 상세 내용 표시 위젯  ( Dialog로 표시 )
class TapToHos extends StatelessWidget {
  const TapToHos({Key? key, this.data}) : super(key: key);
  final data;
  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(10),
        child: Stack(
          // overflow: Overflow.visible,
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color(0xffB3D6FF),
              ),
              padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hospital Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
                  Text("Hospital Name: ${data['hospital_name']}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  Text("Status: ${(data['hospital_status'] == true) ? 'OPEN' : 'CLOSED'}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color:Colors.red)),
                  TextButton(onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Text('Reservation Page'),));
                  }, child: Text('More Information', style: TextStyle(fontSize: 15))),
                ],
              ),
            ),
            Positioned(
                top: -100,
                child: Image.asset("assets/hospital.png", width: 150, height: 150)
            )
          ],
        )
    );
  }
}
