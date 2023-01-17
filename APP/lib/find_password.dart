import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// firebase authentication, firestore 불러오기
final auth  = FirebaseAuth.instance;
final firestore = FirebaseFirestore.instance;

// 비밀번호 찾기 위젯
class findPassword extends StatefulWidget {
  const findPassword({Key? key}) : super(key: key);

  @override
  State<findPassword> createState() => _findPasswordState();
}

class _findPasswordState extends State<findPassword> {

  var inputEmail;

  // 입력된 이메일에 대해서 비밀번호를 초기화할 수 있는 링크가 담긴 메일이 발송됨
  @override
  Future<void> resetPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: (){
            Navigator.pop(context);
          }, icon: Icon(Icons.arrow_back_ios_new),),
          title: Text('Find Password'),),
        body: Container(

          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(80, 80, 80, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email', style: TextStyle(fontSize: 18)),
                      TextField(
                        onChanged: (text) {
                          setState(() {
                            inputEmail = text;
                        });
                      }),
                    ],
                  ),
                ),
                changePasswordBtn(inputEmail:inputEmail),


              ]
          ),
        )
    );
  }
}

// password를 변경하고 싶을 때 누르는 위젯
class changePasswordBtn extends StatelessWidget {
  const changePasswordBtn({Key? key, this.inputEmail}) : super(key: key);
  final inputEmail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(80, 10, 80, 0),
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.1,
      color: Colors.white,
      child: ClayContainer(
        curveType: CurveType.none,
        color: Colors.white,
        depth: 30,
        spread: 3,
        width : 50,
        borderRadius: 30,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
            onPressed: () async{
              try {
                print('button clicked');
                // firebase가 제공하는 비밀번호 초기화 메일 발송
                await auth.sendPasswordResetEmail(email: inputEmail);

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text('Password Reset Email sent. : ${inputEmail}')),
                  );
              } on FirebaseAuthException catch (e){
                var temps = await firestore.collection('user').get();
                if(temps.docs.isNotEmpty){
                  for (var doc in temps.docs) {
                    print(doc['HP']);
                  }
                }

                print(e);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text('Invalid Email - ${inputEmail}')),
                    // 전화번호/ UID 별도로 DB에 넣기
                    // firestore collection 만들고 규칙 정하기
                  );
              }

            },
            child: Text('Change Password', style: TextStyle(fontSize: 15),),
        ),
      ),
    );
  }
}

