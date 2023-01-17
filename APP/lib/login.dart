import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';
import './signup.dart';
import './find_password.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

// firebase Authentication 불러오기
final auth = FirebaseAuth.instance;

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var inputEmail;
  var inputPWD;

  // 이메일, 패스워드 입력시 유효성 검사 후 로그인 결정
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(246, 246, 246, 1),
        appBar: AppBar(title: Text('Log In', style: TextStyle(color:Colors.black),),
            backgroundColor: Color.fromRGBO(246, 246, 246, 1),
            centerTitle: false,
            iconTheme: IconThemeData(
                color: Colors.black)),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(80, 80, 80, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email', style: TextStyle(fontSize: 18)),
                        TextField(
                          onChanged: (text) {
                            setState(() {
                              inputEmail = text;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(80, 20, 80, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Password', style: TextStyle(fontSize: 18)),
                        TextField(
                          obscureText: true,
                          onChanged: (text) {
                            inputPWD = text;
                          },
                        ),
                      ],
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.fromLTRB(80, 30, 80, 10),
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: ClayContainer(
                      borderRadius: 30,
                      color: Color(0xff82b3e3),
                      spread:2,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff82b3e3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          onPressed: () async {
                            try {
                              await auth.signInWithEmailAndPassword(
                                  email: inputEmail, password: inputPWD);
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(content: Text('Login Success')),
                                );
                              Navigator.popUntil(context, ModalRoute.withName("/"));
                            } catch (e) {
                              print('login fail: ${e}');
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(content: Text('Login Fail')),
                                );
                            }
                          },
                          child: const Text(
                            'Log In',
                            style: TextStyle(fontSize: 20),
                          )),
                    ),
                  ),

                  // 로그인 창 밑에 비밀번호 찾기, 새 계정 만들기 옵션
                  Container(
                    child: Column(
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (c) => findPassword()));
                            },
                            child: Text('Forgotten Password?')),
                        TextButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (c) => SignUp()));
                            },
                            child: Text('Or Create New Account'))
                      ],
                    ),
                  ),

                  // google 로그인 연동
                  ClayContainer(
                    borderRadius: 20,
                    color: Color(0xff82b3e3),
                    spread:2,
                    child: TextButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff82b3e3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            onPressed: () {
                              signInWithGoogle();
                            },
                            child: Text('Start with Google',
                                style: TextStyle(fontSize: 15, color: Colors.white)))
                    ),
                ]),
          ),
        ));
  }
}

// 구글 로그인 연동
Future<UserCredential> signInWithGoogle() async {
  // Google 로그인 연동 API
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Google 로그인 연동
  final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  return await FirebaseAuth.instance.signInWithCredential(credential);
}
