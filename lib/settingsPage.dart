import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'settings.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with WidgetsBindingObserver {
  Completer<WebViewController> _controller = Completer<WebViewController>();

  void initSettings() async {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initSettings();
  }

  Future<bool> back() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
    throw '';
  }

  Widget buildInstance(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Searx Instance'),
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
      ),
      body: WebView(
        initialUrl: 'https://searx.space',
        javascriptMode: JavascriptMode.unrestricted,
        navigationDelegate: (request) {
          if (request.url.contains('https://github.com') ||
              request.url.contains('https://cryptcheck.fr') ||
              request.url.contains('https://observatory.mozilla.org') ||
              request.url.contains('https://www.w3.org/TR/server-timing') ||
              request.url.contains('https://crt.sh') ||
              request.url.contains('https://searx.neocities.org/changelog.html') ||
              request.url.contains('https://searx.space/data/instances.json') ||
              request.url.contains('https://searx.github.io')
          ){
            return NavigationDecision.prevent;
          } else if (request.url.contains('https://searx.space')) {
            launch(request.url);
            return NavigationDecision.navigate;
          } else {
            setState(() {
              searxURL = request.url;
              Settings().setURL(searxURL!);
              Navigator.pop(context);
            });
            return NavigationDecision.prevent; //Put in setState?
          }
        },
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: back,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: new ListView(
          padding: EdgeInsets.all(10),
          children: <Widget>[
            new ListTile(
              title: Text('Pi-hole URL (Optional)'),
              trailing: new Text(piholeURL!),
              onTap: () async {
                return showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (BuildContext context) {
                    return new PiholeURLDialog();
                  },
                ).then((var a) {
                  setState(() {});
                });
              },
              subtitle: Text('Tap to change URL. Long press the title (searx instance name - top left of main bar) to open pi-hole'),
            ),
            new ListTile(
              title: Text('Searx URL'),
              trailing: new Text(searxURL!),
              onTap: () {
                Fluttertoast.showToast(
                    msg: "Click on the link you want to change to",
                    toastLength: Toast.LENGTH_SHORT,
                    timeInSecForIosWeb: 2,
                    backgroundColor: Colors.deepPurple,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => buildInstance(context)),
                );
              },
              onLongPress: () async {
                return showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (BuildContext context) {
                    return new SearxURLDialog();
                  },
                ).then((var a) {
                  setState(() {});
                });
              },
              subtitle: Text('Tap to select instance, long tap to change to custom URL'),
            ),
          ],
        ),
      ),);
  }
}

class SearxURLDialog extends StatefulWidget {
  @override
  SearxURLDialogState createState() => new SearxURLDialogState();
}

class SearxURLDialogState extends State<SearxURLDialog> {
  @override
  Widget build(BuildContext context) {
    TextEditingController controller = new TextEditingController();
    controller.text = searxURL!;

    return SimpleDialog(
      title: Text('Enter URL'),
      children: [
        new TextField(
          onChanged: (String value) {
            searxURL = value;
          },
          autofocus: true,
          controller: controller,
        ),
        new TextButton(
            onPressed: () {
              Navigator.pop(context);
              Settings().setURL(searxURL!);
            },
            child: Text('Ok'))
      ],
      contentPadding: EdgeInsets.all(10),
    );
  }
}

class PiholeURLDialog extends StatefulWidget {
  @override
  PiholeURLDialogState createState() => new PiholeURLDialogState();
}

class PiholeURLDialogState extends State<PiholeURLDialog> {
  @override
  Widget build(BuildContext context) {
    TextEditingController controller = new TextEditingController();
    controller.text = piholeURL!;

    return SimpleDialog(
      title: Text('Enter URL'),
      children: [
        new TextField(
          onChanged: (String value) {
            piholeURL = value;
          },
          autofocus: true,
          controller: controller,
        ),
        new TextButton(
            onPressed: () {
              Navigator.pop(context);
              Settings().setPiholeURL(piholeURL!);
            },
            child: Text('Ok'))
      ],
      contentPadding: EdgeInsets.all(10),
    );
  }
}

