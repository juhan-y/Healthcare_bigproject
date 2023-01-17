import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './auth.dart';
import './register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import './main.dart' as main;

final domain = main.domain;

final auth = FirebaseAuth.instance;

// PP, TOU 동의 이후의 사용자의 정보 수집 및 회원 가입 페이지.

class Signup1 extends StatelessWidget {
  Signup1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterModel(),
      child: Scaffold(
        backgroundColor: Color.fromRGBO(246, 246, 246, 1),
        appBar: AppBar(
          leading: IconButton(onPressed: (){
            Navigator.pop(context);
          }, icon: Icon(Icons.arrow_back_ios_new),),
          title: Text('Sign Up', style: TextStyle(color: Colors.black)),
            backgroundColor: Color.fromRGBO(246, 246, 246, 1),
            centerTitle: false,
            iconTheme: IconThemeData(color: Colors.black)),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.all(10),
          child: Column(
            children:[
              // 이름, 이메일, 비밀번호, 전화번호, 고유번호( 주민번호 ), 주소 등의 개인 정보 수집
              NameInput(),
              EmailInput(),
              PasswordInput(),
              PasswordConfirmInput(),
              HpInput(),
              RnnInput(),
              AddrInput(),
              Container(
                margin: EdgeInsets.fromLTRB(20,50,20,20),
                  child: RegistButton()
              ),

              ]
          ),
        ),
      ),
    );
  }
}



// register.dart에 있는 provider에 저장하는 위젯들 -> 각각의 사용자 정보가 담기게 됨.
class NameInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final register = Provider.of<RegisterModel>(context, listen: false);
    return Container(
      padding: EdgeInsets.fromLTRB(80, 60, 80, 0),
      child: TextField(
        onChanged: (name) {
          register.setName(name);
        },
        obscureText: false,
        decoration: InputDecoration(
          labelText: 'User Name',
          labelStyle: TextStyle(fontSize: 20),
          //helperText: '',
        ),
      ),
    );
  }
}

class EmailInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final register = Provider.of<RegisterModel>(context, listen: false);
    return Container(
      padding: EdgeInsets.fromLTRB(80, 10, 80, 0),
      child: TextField(
        onChanged: (email) {
          register.setEmail(email);
        },
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'Email',
          labelStyle: TextStyle(fontSize: 20),
          //helperText: '',
        ),
      ),
    );
  }
}

class PasswordInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final register = Provider.of<RegisterModel>(context);
    return Container(
      padding: EdgeInsets.fromLTRB(80, 10, 80, 0),
      child: TextFormField(
        autovalidateMode: AutovalidateMode.always,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Password',
          labelStyle: TextStyle(fontSize: 20),
        ),
        onChanged: (password) {
          // This optional block of code can be used to run
          // code when the user saves the form.
          register.password = password;
        },
      ),
    );
  }
}

class PasswordConfirmInput extends StatelessWidget {
  var _name;

  @override
  Widget build(BuildContext context) {
    final register = Provider.of<RegisterModel>(context, listen: false);
    return Container(
      padding: EdgeInsets.fromLTRB(80, 10, 80, 0),
      child: TextFormField(
        autovalidateMode: AutovalidateMode.always,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Password Confirm',
          labelStyle: TextStyle(fontSize: 20),
        ),
        onChanged: (password) {
          // This optional block of code can be used to run
          // code when the user saves the form.
          register.passwordConfirm = password;
        },
        validator: (String? value) {
          return (value != register.password) ? 'Password does not match.' : null;
        },
      ),
    );
  }
}



class HpInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final register = Provider.of<RegisterModel>(context, listen: false);
    return Container(
      padding: EdgeInsets.fromLTRB(80, 10, 80, 0),
      child: TextField(
        onChanged: (hp) {
          register.setHp(hp);
        },
        obscureText: false,
        decoration: InputDecoration(
          labelText: 'H.P.',
          labelStyle: TextStyle(fontSize: 20),
          //helperText: '',
        ),
      ),
    );
  }
}

class RnnInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final register = Provider.of<RegisterModel>(context, listen: false);
    return Container(
      padding: EdgeInsets.fromLTRB(80, 10, 80, 0),
      child: TextField(
        onChanged: (rnn) {
          register.setRnn(rnn);
        },
        obscureText: false,
        decoration: InputDecoration(
          labelText: 'RNN',
          labelStyle: TextStyle(fontSize: 20),
          //helperText: '',
        ),
      ),
    );
  }
}

class AddrInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final register = Provider.of<RegisterModel>(context, listen: false);
    return Container(
      padding: EdgeInsets.fromLTRB(80, 10, 80, 0),
      child: TextField(
        onChanged: (addr) {
          register.setAddr(addr);
        },
        obscureText: false,
        decoration: InputDecoration(
          labelText: 'User Address',
          labelStyle: TextStyle(fontSize: 20),
          //helperText: '',
        ),
      ),
    );
  }
}

// 실제 Sign Up 위젯
class RegistButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authClient =
    Provider.of<FirebaseAuthProvider>(context, listen: false);
    final register = Provider.of<RegisterModel>(context);
    return Container(
      padding: EdgeInsets.fromLTRB(80, 10, 80, 0),
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.08,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xff82b3e3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),

        // 패스워드와 패스워드 확인이 동일할 때만 버튼을 활성화
        // 버튼을 누르면 서버로 이메일과 비밀번호 전달 -> 계정 생성 및 DB 저장
        onPressed: ((register.password != register.passwordConfirm) || (register.password == null)) ? null : () async {
          Uri uri = Uri.parse("http://${domain}:8000/api/user/");
          http.Response response = await http.post(
            uri,
            headers: <String, String> {
              'Content-Type': 'application/x-www-form-urlencoded',
            },
            body: <String, String> {
              "user_name": register.name.toString(),
              "user_account": register.email.toString(),
              "user_tel": register.hp.toString(),
              "user_pwd": register.password.toString(),
              "user_rnn": register.rnn.toString(),
              "user_addr": register.addr.toString(),
            },
          );

          // firebase Authentication에도 이메일과 비밀번호로 계정 생성
          var user = await authClient
              .registerWithEmail(register.email, register.password)
              .then((registerStatus) {
                // 계정 생성 완료 후 메인 페이지로 이동 + 하단 성공 바 알림
            if (registerStatus == AuthStatus.registerSuccess && response.statusCode == 201) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('Regist Success'))
                );

              print(auth.currentUser?.uid);

              // 홈으로 pop
              Navigator.popUntil(context, ModalRoute.withName("/"));
            } else {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('Regist Fail')),
                );
            }
          });


          print('post complete.');
          print('response: ${response.statusCode}, ${response.statusCode.runtimeType}, ${jsonDecode(response.body)}');
        },
        child: Text('Sign Up', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}