import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:searx/pihole_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'settings.dart';
import 'settingsPage.dart';

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

  void initSettings() async {
    await Settings().getPihole();
    await Settings().getPiholeURL();
  }

  @override
  void initState() {
    super.initState();
      WidgetsBinding.instance.addObserver(this);
      if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    initSettings();
  }

  Future<bool> back() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
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

  Widget buildPihole(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pihole'),
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
      ),
      body: WebView(
        initialUrl: piholeURL,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _MyHomePageState()._controller.complete(webViewController);
        },
      ),
    );
  }

  Widget buildMain(BuildContext context) {
    return new WillPopScope(
      onWillPop: back,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: TextButton(
            style: TextButton.styleFrom(
              primary: Colors.white,
            ),
            onPressed: () {
              Phoenix.rebirth(context);
            },
            onLongPress: () {
              if (usePihole) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => buildPihole(context)),
                );
              }
            },
            child: Text(
              title,
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
          actions: <Widget>[
            NavigationControls(_controller.future),
          ],
        ),
        body: WebView(
          initialUrl: searxURL,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
          },
        ),
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
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              constraints: BoxConstraints(),
              icon: const Icon(Icons.arrow_back_ios),
              tooltip: 'Go back',
              onPressed: !webViewReady ? null : () => navigate(context, controller, goBack: true),
            ),
            IconButton(
              constraints: BoxConstraints(),
              icon: const Icon(Icons.arrow_forward_ios),
              tooltip: 'Go forward',
              onPressed: !webViewReady ? null : () => navigate(context, controller, goBack: false),
            ),
            IconButton(
              constraints: BoxConstraints(),
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh page',
              onPressed: !webViewReady ? null : () => controller.reload(),
            ),
            IconButton(
              constraints: BoxConstraints(),
              icon: const Icon(Icons.public),
              enableFeedback: true,
              tooltip: 'Open with Browser',
              onPressed: !webViewReady ? null : () async => await launch(await controller.currentUrl(),
                forceSafariVC: false,
                forceWebView: false,
              ),
            ),
            IconButton(
              constraints: BoxConstraints(),
              icon: const Icon(Icons.settings),
              enableFeedback: true,
              tooltip: 'Settings',
              onPressed: !webViewReady ? null : () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              ),
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
