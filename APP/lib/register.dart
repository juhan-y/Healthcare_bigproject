import 'package:flutter/material.dart';

// 회원가입시 잠시 수집한 정보를 저장할 provider ( 임시 DB )
class RegisterModel extends ChangeNotifier {
  String name ="";
  String email = "";
  String password = "";
  String passwordConfirm = "";
  String hp = "";
  String rnn = "";
  String addr = "";

  void setName(String name) {
    this.name = name;
    notifyListeners();
  }

  void setEmail(String email) {
    this.email = email;
    notifyListeners();
  }

  void setPassword(String password) {
    this.password = password;
    notifyListeners();
  }

  void setPasswordConfirm(String passwordConfirm) {
    this.passwordConfirm = passwordConfirm;
    notifyListeners();
  }

  void setHp(String hp) {
    this.hp = hp;
    notifyListeners();
  }

  void setRnn(String rnn) {
    this.rnn = rnn;
    notifyListeners();
  }

  void setAddr(String addr) {
    this.addr = addr;
    notifyListeners();
  }
}