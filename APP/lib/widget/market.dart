import 'package:flutter/material.dart';
import '../dashboard.dart';

class Market extends StatefulWidget {
  const Market({Key? key}) : super(key: key);

  @override
  State<Market> createState() => _MarketState();
}

class _MarketState extends State<Market> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text('Market', style: TextStyle(color:Colors.black),),backgroundColor: Color.fromRGBO(246, 246, 246, 1),
          centerTitle: false,
          iconTheme: IconThemeData(
              color: Colors.black)),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: Color(0xa8cce2f8)),
                child : Text('Available',textAlign: TextAlign.center, style: TextStyle(color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.w500))
              ),
            Container(
                margin: EdgeInsets.fromLTRB(0, 300, 0, 0),
                child: Text('There are no items', style: TextStyle(fontSize: 20),)),
            Container(child: TextButton(child: Text('Go to shop',style: TextStyle(fontSize: 20)), onPressed: (){},))
           ],
          )
        ),
      );
  }
}