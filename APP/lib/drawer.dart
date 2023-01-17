import 'package:flutter/material.dart';
import './login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './settingPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
final auth = FirebaseAuth.instance;
final firebase = FirebaseFirestore.instance;


// 메인 페이지의 왼쪽 상단 menu 버튼을 눌렀을 때 일부 페이지만 등장하는 위젯
class MainDrawer extends StatefulWidget {
  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  var uid;
  var data;

  getData() {
    data = auth.currentUser?.email;
    print(data);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (auth.currentUser != null) {
      uid = auth.currentUser?.uid;
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero, // 이 코드 중요. 이거 없으면 상단 부분이 짤리게 나옴
        children: [
          UserAccountsDrawerHeader(
            //drawer에 들어가는 이름과 이메일
            accountName: (auth.currentUser != null) ? Text('User', style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.w900),) : Text('Temp User', style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.w900),),
            accountEmail: (auth.currentUser != null) ? Text(data.toString(), style: TextStyle(color: Colors.black, fontSize: 20),) : Text('Temp User', style: TextStyle(color: Colors.black, fontSize: 20),),

            onDetailsPressed: () {
              print('Header is clicked');
            },
            decoration: BoxDecoration(
              // 데코레이션이라고 해서 박스를 꾸미기
                color: Color.fromRGBO(231, 239, 250, 1),
                borderRadius: BorderRadius.only(
                  // 하단에만 적용하겠다.
                    bottomLeft: Radius.circular(40.0),
                    bottomRight: Radius.circular(40.0))),
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.grey[850]),
            onTap: () {
              print('settings is clicked');
              // setting page 이동 버튼
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingPage()));
            },
            title: Text('Settings'),
          ),
          // login 되어 있을 때는 logout, logout시에는 login버튼으로 바뀜
          LoginLogout(),
        ],
      ),
    );
  }
}

// login logout 담당 위젯
class LoginLogout extends StatefulWidget {
  const LoginLogout({Key? key}) : super(key: key);

  @override
  State<LoginLogout> createState() => _LoginLogoutState();
}

class _LoginLogoutState extends State<LoginLogout> {

  // 로그아웃 메서드
  Future signOut(context) async {
    try {
      print('sign out complete');
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('LogOut Success')),);
      setState(() {});
      return await auth.signOut();
    } catch (e) {
      print('sign out failed');
      print(e.toString());
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('LogOut Failed')),);
      setState(() {});
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {

    if(auth.currentUser != null) {
      return ListTile(
        leading: Icon(Icons.logout, color: Colors.grey[850]),
        onTap: () {
          // 로그아웃 버튼 누르면 로그아웃과 동시에 초기화면으로 돌아감
          signOut(context);
          Navigator.popUntil(context, ModalRoute.withName("/"));
          setState(() {});
        },
        title: Text('Log Out'),
      );
    } else {
      return ListTile(
        leading: Icon(Icons.login, color: Colors.grey[850]),
        onTap: () {
          // 로그인 버튼을 누르면 로그인 페이지로 이동
          Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
          setState(() {});
          },
        title: Text('Log In'),
      );
    }
  }
}
