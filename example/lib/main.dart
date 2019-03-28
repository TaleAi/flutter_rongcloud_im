import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_rongcloud_im/flutter_rongcloud_im.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _token = 'token';

  @override
  void initState() {
    super.initState();
    _init();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _init() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      await FlutterRongcloudIm.init(_token); //appkey
      FlutterRongcloudIm.connect(_token); // 服务器生成的token
      FlutterRongcloudIm.joinChatRoom('roomid', -1); // 加入聊天室
      FlutterRongcloudIm.responseFromMessageReceived.listen((data) {
        //收到消息
      });
//      FlutterRongcloudIm.setUserInfo(id, name, avatar, level); // 设置用户信息
//      FlutterRongcloudIm.sendImageMessage(conversationType, targetId, imagePath, extra); //发送文字消息
//    FlutterRongcloudIm.sendTextMessage(conversationType, targetId, content, extra);
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on:\n'),
        ),
      ),
    );
  }
}
