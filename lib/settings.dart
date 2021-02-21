import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
String searxURL;
String defaultURL = "https://search.disroot.org";

class Settings {
  Future<SharedPreferences> get prefs async =>
      await SharedPreferences.getInstance();

  void setURL(String data) async {
    await (await prefs).setString("url", data);
  }

  Future<void> errURL() async {
    searxURL = defaultURL;
    await (await prefs).setString("url", defaultURL);
    await Fluttertoast.showToast(
        msg: "Invalid URL! Setting to default",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  Future<void> valURL(String data) async {
    await Fluttertoast.showToast(
        msg: "Setting instance...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  Future<String> getURL() async {
    searxURL = (await prefs).getString("url") ?? defaultURL;
    try {
      var response = (await http.get(searxURL)).statusCode;
      if (response == 200) {
        await valURL(searxURL);
      }else {
        await errURL();
      }
    } catch(err){
      await errURL();
    }
    return searxURL;
  }
}
