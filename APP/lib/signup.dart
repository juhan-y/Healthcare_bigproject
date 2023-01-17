import 'package:flutter/material.dart';
import './signup1.dart';

// 회원가입 페이지 위젯
class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignInState();
}

class _SignInState extends State<SignUp> {

  // 페이지 동의 체크박스 리스트
  var _isChecked = [false, false, false, false];

  // 가장 마지막 체크박스(all)이 체크되었다면 모든 체크박스 체크.
  // 가장 마지막 체크박스 제외 모든 체크박스 체크되었으면 마지막 체크박스 체크.
  changeChecked(id){
    if (id == 3) {

      if (_isChecked[id] == false) {
        setState(() {
          for( var i = 0; i < 4; i ++) {
            _isChecked[i] = true;
          }
        });
      } else {
        setState(() {
          for( var i = 0; i < 4; i ++) {
            _isChecked[i] = false;
          }
        });
      }
    } else {
      setState(() {
        if (_isChecked[id] == false) {
          _isChecked[id] = true;
        } else {
          _isChecked[id] = false;
        }
      });
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 246, 246, 1),
      appBar: AppBar(
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back)),
        title: Text('Sign up', style: TextStyle(color: Colors.black)),
        backgroundColor: Color.fromRGBO(246, 246, 246, 1),
        centerTitle: false,
        iconTheme: IconThemeData(
            color: Colors.black),),

      // 개인 정보 정책  ->  현재 dummy 글
      body: Container(padding:EdgeInsets.all(30), color:Color.fromRGBO(246, 246, 246, 1), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(flex:1,child:Text('Privacy Policy',  style: TextStyle(fontSize: 20))),
        Expanded(
          flex:3,
          child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(15,5,15,30),
              scrollDirection: Axis.vertical,
              child: Container(
                child: Text( "1 Description that is too long in text format(Here Data is coming from API) jdlksaf j klkjjflkdsjfkddfdfsdfds " +
                    "2 Description that is too long in text format(Here Data is coming from API) d fsdfdsfsdfd dfdsfdsf sdfdsfsd d " +
                    "3 Description that is too long in text format(Here Data is coming from API)  adfsfdsfdfsdfdsf   dsf dfd fds fs" +
                    "4 Description that is too long in text format(Here Data is coming from API) dsaf dsafdfdfsd dfdsfsda fdas dsad" +
                    "5 Description that is too long in text format(Here Data is coming from API) dsfdsfd fdsfds fds fdsf dsfds fds " +
                    "6 Description that is too long in text format(Here Data is coming from API) asdfsdfdsf fsdf sdfsdfdsf sd dfdsf" +
                    "7 Description that is too long in text format(Here Data is coming from API) df dsfdsfdsfdsfds df dsfds fds fsd" +
                    "8 Description that is too long in text format(Here Data is coming from API)" +
                    "9 Description that is too long in text format(Here Data is coming from API)" +
                    "10 Description that is too long in text format(Here Data is coming from API)",style: TextStyle(
                    fontSize: 16.0, color: Colors.black)),
              )
          ),
        ),
        CheckBox(isChecked: _isChecked, changeChecked:changeChecked, id:0, content:'Agree'),
        Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 0)),
        Expanded(flex:1,child:Text('Terms of Use', style: TextStyle(fontSize: 20))),

        // 이용 약관  ->  현재 dummy 글
        Expanded(
          flex:3,
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.all(15),
              child: Text( "1 Description that is too long in text format(Here Data is coming from API) jdlksaf j klkjjflkdsjfkddfdfsdfds " +
                  "2 Description that is too long in text format(Here Data is coming from API) d fsdfdsfsdfd dfdsfdsf sdfdsfsd d " +
                  "3 Description that is too long in text format(Here Data is coming from API)  adfsfdsfdfsdfdsf   dsf dfd fds fs" +
                  "4 Description that is too long in text format(Here Data is coming from API) dsaf dsafdfdfsd dfdsfsda fdas dsad" +
                  "5 Description that is too long in text format(Here Data is coming from API) dsfdsfd fdsfds fds fdsf dsfds fds " +
                  "6 Description that is too long in text format(Here Data is coming from API) asdfsdfdsf fsdf sdfsdfdsf sd dfdsf" +
                  "7 Description that is too long in text format(Here Data is coming from API) df dsfdsfdsfdsfds df dsfds fds fsd" +
                  "8 Description that is too long in text format(Here Data is coming from API)" +
                  "9 Description that is too long in text format(Here Data is coming from API)" +
                  "10 Description that is too long in text format(Here Data is coming from API)",style: TextStyle(
                  fontSize: 16.0, color: Colors.black))
          ),
        ),
        CheckBox(isChecked: _isChecked,changeChecked:changeChecked, id:1, content:'Agree'),
        Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 0)),
        CheckBox(isChecked: _isChecked,changeChecked:changeChecked, id:2, content:'Adult'),
        CheckBox(isChecked: _isChecked,changeChecked:changeChecked, id:3, content:'Agree all'),
        Expanded(
          child: Row(mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 모든 체크박스가 체크되었을 때만 다음 버튼을 활성화  ->  이후 다음 회원가입 페이지로 이동
              TextButton(onPressed: ((_isChecked[0] == true) && (_isChecked[1] == true) && (_isChecked[2] == true)) ? (){
                Navigator.push(context, MaterialPageRoute(builder: (c) => Signup1() ));
              } : null, child: Text(
                'Next',
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.blue),)),
            ],
          ),
        )
      ],

      )
      ),

    );
  }
}

// 위에서 언급한 체크박스 알고리즘을 따라 작성된 위젯
class CheckBox extends StatefulWidget {
  CheckBox({Key? key, this.isChecked, this.content, this.changeChecked, this.id}) : super(key: key);
  var isChecked;
  var content;
  var changeChecked;
  var id;
  @override
  State<CheckBox> createState() => _CheckBoxState();
}

class _CheckBoxState extends State<CheckBox> {
  @override
  Widget build(BuildContext context) {
    if((widget.isChecked[0] == true) && (widget.isChecked[1] == true) && (widget.isChecked[2] == true)) {
      widget.isChecked[3] = true;
    } else {
      widget.isChecked[3] = false;
    }
    return Expanded(flex:1,child:
    Row(children: [Checkbox(
        value: widget.isChecked[widget.id],
        onChanged: (value) {
          widget.changeChecked(widget.id);
        }
    ), Text(widget.content)]
    )
    );
  }
}
