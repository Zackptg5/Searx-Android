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
    if (searxURL == defaultURL) {
      await Fluttertoast.showToast(
          msg: "Unable to load default instance! Change instance to something else",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    } else {
      searxURL = defaultURL;
      await (await prefs).setString("url", defaultURL);
      await Fluttertoast.showToast(
          msg: "Invalid URL! Setting to default",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  Future<String> getURL() async {
    searxURL = (await prefs).getString("url") ?? defaultURL;
    try {
      var response = (await http.get(Uri.parse(searxURL))).statusCode;
      if (response != 200) {
        await errURL();
      }
    } catch(err){
      await errURL();
    }
    return searxURL;
  }
}
