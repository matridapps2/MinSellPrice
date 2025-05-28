import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class MyInAppBrowser extends InAppBrowser {
  PullToRefreshController? pullToRefreshController;

  MyInAppBrowser(
      {int? windowId, UnmodifiableListView<UserScript>? initialUserScripts})
      : super(windowId: windowId, initialUserScripts: initialUserScripts);

  @override
  Future onBrowserCreated() async {
    if (kDebugMode) {
      log("\n\nBrowser Created!\n\n");
    }
  }

  @override
  Future onLoadStart(url) async {}

  @override
  Future onLoadStop(url) async {
    pullToRefreshController?.endRefreshing();
  }

  @override
  void onLoadError(url, code, message) {
    pullToRefreshController?.endRefreshing();
  }

  @override
  void onProgressChanged(progress) {
    if (progress == 100) {
      pullToRefreshController?.endRefreshing();
    }
  }

  @override
  void onExit() {
    log("\n\nBrowser closed!\n\n");
  }

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(
      navigationAction) async {
    log("\n\nOverride ${navigationAction.request.url}\n\n");
    return NavigationActionPolicy.ALLOW;
  }
}

class InAppBrowserExampleScreen extends StatefulWidget {
  final MyInAppBrowser browser = MyInAppBrowser();

  InAppBrowserExampleScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _InAppBrowserExampleScreenState createState() =>
      _InAppBrowserExampleScreenState();
}

class _InAppBrowserExampleScreenState extends State<InAppBrowserExampleScreen> {
  PullToRefreshController? pullToRefreshController;

  @override
  void initState() {
    super.initState();

    pullToRefreshController = kIsWeb ||
        ![TargetPlatform.iOS, TargetPlatform.android]
            .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.black,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          widget.browser.webViewController?.reload();
        } else if (Platform.isIOS) {
          widget.browser.webViewController?.loadUrl(
              urlRequest: URLRequest(
                  url: WebUri((await widget.browser.webViewController
                      ?.getUrl()) as String)));
        }
      },
    );
    widget.browser.pullToRefreshController = pullToRefreshController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text(
              "InAppBrowser",
            )),
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                      onPressed: () async {
                        await widget.browser.openUrlRequest(
                          urlRequest:
                          URLRequest(url: WebUri("https://flutter.dev")),
                          options: InAppBrowserClassOptions(
                            crossPlatform: InAppBrowserOptions(
                              toolbarTopBackgroundColor: Colors.blue,
                            ),
                          ),
                        );
                      },
                      child: const Text("Open In-App Browser")),
                  Container(height: 40),
                  ElevatedButton(
                      onPressed: () async {
                        await InAppBrowser.openWithSystemBrowser(
                            url: WebUri("https://flutter.dev/"));
                      },
                      child: const Text("Open System Browser")),
                ])));
  }
}
