import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'settings.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

void main() {
  runApp(
    Phoenix(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Searx',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        primaryColor: Colors.deepPurple, //primarySwatch ignored when brightness is set to dark
        accentColor: Colors.deepPurpleAccent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Searx Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
      WidgetsBinding.instance.addObserver(this);
      if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Settings().getURL(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return buildMain(context);
        }
        return buildLoad(context); // or some other widget
      }
    );
  }

  Widget buildLoad(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Loading'),
      ),
      body: Center(
        child: CircularProgressIndicator()
      ),
    );
  }

  Widget buildMain(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextButton(
          style: TextButton.styleFrom(
            primary: Colors.white,
          ),
          onPressed: () {
            Phoenix.rebirth(context);
          },
          child: Text(
            searxURL.replaceAll(RegExp(r'//search.|'), '').replaceAll(RegExp(r'https:[/]*|http:[/]*|/searx/|.[a-z:0-9]*$'), '').capitalize(),
            style: TextStyle(fontSize: 20.0),
          ),
        ),
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
        actions: <Widget>[
          NavigationControls(_controller.future),
          Menu(_controller.future),
        ],
      ),
      body: WebView(
        initialUrl: searxURL,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
        },
      ),
    );
  }

  @override
  void didChangePlatformBrightness() {
    final Brightness brightness =
        WidgetsBinding.instance.window.platformBrightness;
    //inform listeners and rebuild widget tree
  }
}

class Menu extends StatelessWidget {
  Menu(this._webViewControllerFuture);
  final Future<WebViewController> _webViewControllerFuture;

  Widget buildInstance(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Searx Instance'),
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
      ),
      body: WebView(
        initialUrl: 'https://searx.space',
        javascriptMode: JavascriptMode.unrestricted,
        // navigationDelegate: this._interceptNavigation,
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
            searxURL = request.url;
            Settings().setURL(searxURL);
            Phoenix.rebirth(context);
            return NavigationDecision.prevent;
          }
        },
        onWebViewCreated: (WebViewController webViewController) {
          _MyHomePageState()._controller.complete(webViewController);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _webViewControllerFuture,
      builder: (BuildContext context, AsyncSnapshot<WebViewController> controller) {
        if (!controller.hasData) return Container();
        return PopupMenuButton<String>(
          onSelected: (String value) async {
            switch (value) {
              case 'Open in Browser':
                {
                  await launch(await controller.data.currentUrl(),
                    forceSafariVC: false,
                    forceWebView: false,
                  );
                }
                break;
              case 'Select Searx Instance':
                {
                  await Fluttertoast.showToast(
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
                }
                break;
              case 'Enter Custom Searx Instance':
                {
                  _displayTextInputDialog(context);
                }
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
            const PopupMenuItem<String>(
              value: 'Open in Browser',
              child: Text('Open in Browser'),
            ),
            const PopupMenuItem<String>(
              value: 'Select Searx Instance',
              child: Text('Select Searx Instance'),
            ),
            const PopupMenuItem<String>(
              value: 'Enter Custom Searx Instance',
              child: Text('Enter Custom Searx Instance'),
            ),
          ],
        );
      },
    );
  }

  TextEditingController _textFieldController = TextEditingController();
  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Searx Instance URL'),
          content: TextField(
            onChanged: (value) {
              searxURL = value;
            },
            controller: _textFieldController,
            decoration:
            InputDecoration(hintText: "i.e.: https://search.disroot.org"),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.red,
              ),

              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.blue,
              ),
              child: Text('Ok'),
              onPressed: () async {
                Navigator.pop(context);
                Settings().setURL(searxURL);
                Phoenix.rebirth(context);
              },
            ),
          ],
        );
      });
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture)
      : assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data;
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady
                  ? null
                  : () => navigate(context, controller, goBack: true),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady
                  ? null
                  : () => navigate(context, controller, goBack: false),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: !webViewReady ? null : () => controller.reload(),
            ),
          ],
        );
      },
    );
  }

  navigate(BuildContext context, WebViewController controller,
      {bool goBack: false}) async {
    bool canNavigate =
    goBack ? await controller.canGoBack() : await controller.canGoForward();
    if (canNavigate) {
      goBack ? controller.goBack() : controller.goForward();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("No ${goBack ? 'back' : 'forward'} history item")),
      );
    }
  }
}
