import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
String? searxURL;
String? piholeURL;
String defaultURL = "https://searx.zackptg5.com";
String title = 'Searx';

class Settings {
  Future<SharedPreferences> get prefs async =>
      await SharedPreferences.getInstance();

  void setURL(String data) async {
    await (await prefs).setString("url", data);
  }

  void setPiholeURL(String data) async {
    await (await prefs).setString("url2", data);
  }

  Future<void> errURL(num, url) async {
    String msg;
    if (num == 0) {
      if (url == defaultURL) {
        msg = "Unable to load default instance! Change instance to something else";
        title = 'Searx';
      } else {
        msg = "Invalid Searx URL! Setting to default";
        searxURL = defaultURL;
        await (await prefs).remove("url");
      }
    } else {
      if (url == 'Not Set') {return null;}
      msg = "Invalid Pi-hole URL! Disabling Pi-hole functionality!";
      piholeURL = 'Not Set';
      await (await prefs).remove("url2");
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
    piholeURL = (await prefs).getString("url2") ?? 'Not Set';
    List<String?> items = [searxURL, piholeURL];
    for (var i = 0; i < items.length; i++) {
      var item = items[i]!;
      try {
        var response = (await http.get(Uri.parse(item))).statusCode;
        if (response != 200) {
          await errURL(i, item);
        }
      } catch (err) {
        await errURL(i, item);
      }
    }
    // Set title of appbar to title of searx instance (webpage title)
    var webpage = (await http.read(Uri.parse(searxURL!)));
    title = webpage.substring((webpage.indexOf('<title>') + 7), (webpage.indexOf('</title>')));
    // Have to return something for buildMain to trigger
    return searxURL;
  }
}
