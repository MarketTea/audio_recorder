import 'dart:io';
import 'package:audio_recorder/recorder_view.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'recorded_list_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Directory appDir;
  List<String> records;

  @override
  void initState() {
    super.initState();
    records = [];
    getExternalStorageDirectory().then((value) {
      appDir = value.parent.parent.parent.parent;
      Directory appDirectory = Directory("${appDir.path}/Audiorecords/");
      appDir = appDirectory;
      appDir.list().listen((onData) {
        records.add(onData.path);
      }).onDone(() {
        records = records.reversed.toList();
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    appDir = null;
    records = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Recorder(
              save: _onFinish,
            ),
          ),
          Container(
            child: Expanded(
              flex: 2,
              child: Records(
                records: records,
              ),
            ),
          )
        ],
      ),
    );
  }

  _onFinish() {
    records.clear();
    appDir.list().listen((onData) {
      records.add(onData.path);
    }).onDone(() {
      records.sort();
      records = records.reversed.toList();
      print("Record length is: -------------" + records.length.toString());
      setState(() {});
    });
  }
}
