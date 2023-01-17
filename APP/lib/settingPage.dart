import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import './privacyPolicy.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './login.dart';
import './find_password.dart';

final auth = FirebaseAuth.instance;

// setting 페이지
class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: Colors.black)),
        backgroundColor: Color.fromRGBO(246, 246, 246, 1),
        centerTitle: false,
        iconTheme: IconThemeData(
            color: Colors.black),),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text('Common'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                title: Text('Language'),
                value: Text('English'),
                // onpressed -> multi lang
              ),
              SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: false, // switch default value
                title: Text('Enable Notification'),
              ),
              SettingsTile.switchTile(
                onToggle: (value) {},
                initialValue: false, // switch default value
                title: Text('GPS'),
              ),
            ],
          ),

          SettingsSection(
              title: Text('Account'),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  title: Text('Change Password'),
                  onPressed: (context){Navigator.push(context, MaterialPageRoute(builder: (c) => findPassword()));},
                )
              ]
          ),

          CustomSettingsSection(
              child: LoginLogout1()),

          SettingsSection(
            title: Text('Privacy'),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                  title: Text('Privacy Policy'),
                  onPressed: (context) {Navigator.push(context, MaterialPageRoute(builder: (c) => PrivacyPolicy()));}
              ),
              SettingsTile.navigation(
                title: Text('Terms of Use'),
                onPressed: (context) {Navigator.push(context, MaterialPageRoute(builder: (c) => TermsofUse()));}
                ,),
            ],
          ),
        ],
      ),
      backgroundColor: Color.fromRGBO(246, 246, 246, 1),
    );
  }
}

// setting page에서도 로그인 로그아웃 접근 가능케함
class LoginLogout1 extends StatefulWidget {
  const LoginLogout1({Key? key}) : super(key: key);

  @override
  State<LoginLogout1> createState() => _LoginLogoutState1();
}

class _LoginLogoutState1 extends State<LoginLogout1> {
  Future signOut(context) async {
    try {
      print('sign out complete');
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('LogOut Success')),);
      return await auth.signOut();
    } catch (e) {
      print('sign out failed');
      print(e.toString());
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('LogOut Failed')),);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {

    if(auth.currentUser != null) {
      return SettingsTile.navigation(
        onPressed: (context) {
          signOut(context);
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> SettingPage()));
          setState(() {});
        },
        title: Text('Log Out'),
      );
    } else {
      return SettingsTile.navigation(
        onPressed: (context) {
          Navigator.push(context, MaterialPageRoute(builder: (context)=> Login()));
          setState(() {});
        },
        title: Text('Log In'),
      );
    }


  }


}

