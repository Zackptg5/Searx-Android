import 'package:shared_preferences/shared_preferences.dart';
String searxURL;

class Settings {
  Future<SharedPreferences> get prefs async =>
      await SharedPreferences.getInstance();

  void setURL(String data) async {
    await (await prefs).setString("url", data);
  }

  Future<String> getURL() async {
    searxURL = (await prefs).getString("url") ?? "https://search.disroot.org";
    return searxURL;
  }

  Future<String> getURL2() async {
    return (await prefs).getString("url") ?? "https://search.disroot.org";
  }
}
