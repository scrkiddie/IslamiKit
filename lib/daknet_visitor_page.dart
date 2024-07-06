import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DakNetVisitorPage extends StatefulWidget {
  const DakNetVisitorPage({Key? key}) : super(key: key);

  @override
  _DakNetVisitorPageState createState() => _DakNetVisitorPageState();
}

class _DakNetVisitorPageState extends State<DakNetVisitorPage> {
  late WebViewController _controller;

  
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {},
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onWebResourceError: (WebResourceError error) {},
      ))
      ..loadRequest(Uri.parse("http://10.0.2.2/beranda"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DakNet Visitor', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 53, 88, 231),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
