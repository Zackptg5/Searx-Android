import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
String? searxURL;
String defaultURL = "https://searx.fmac.xyz";
String title = 'Searx';

class Settings {
  Future<SharedPreferences> get prefs async =>
      await SharedPreferences.getInstance();

  void setURL(String data) async {
    await (await prefs).setString("url", data);
  }

  Future<void> errURL(url) async {
    String msg;
    if (url == defaultURL) {
      msg = "Unable to load default instance! Change instance to something else";
      title = 'Searx';
    } else {
      msg = "Invalid Searx URL! Setting to default";
      searxURL = defaultURL;
      await (await prefs).remove("url");
    }
    await Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0
    );
  }

  Future<String?> getURL() async {
    searxURL = (await prefs).getString("url") ?? defaultURL;
    try {
      var response = (await http.get(Uri.parse(searxURL!))).statusCode;
      if (response != 200) {
        await errURL(searxURL);
        }
      } catch (err) {
        await errURL(searxURL);
      }
    // Set title of appbar to title of searx instance (webpage title)
    var webpage = (await http.read(Uri.parse(searxURL!)));
    title = webpage.substring((webpage.indexOf('<title>') + 7), (webpage.indexOf('</title>')));
    // Have to return something for buildMain to trigger
    return searxURL;
  }
}
