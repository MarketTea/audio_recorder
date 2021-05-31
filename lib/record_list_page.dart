import 'dart:io';

import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'audio.dart';

class RecordingList extends StatefulWidget {
  @override
  _RecordingListState createState() => _RecordingListState();
}

class _RecordingListState extends State<RecordingList> {
  String path;
  String directoryPath;
  List<dynamic> file = new List<dynamic>();

  @override
  void initState() {
    super.initState();
    _listOfFiles();
    // _localPath;
  }

  Future<String> _listOfFiles() async {
    path = (await ExtStorage.getExternalStorageDirectory()) + "/Recordings/";
    setState(() {
      file = Directory("$path")
          .listSync(); //use your folder name insted of resume.
      directoryPath = path;
    });
    print("Directory Path is $directoryPath");

    return directoryPath;
  }

  Future<File> get _localFile async {
    final abc = _listOfFiles;
    print('ABC------------------------ $abc');
    return File('$abc');
  }

  Future<void> deleteFile() async {
    try {
      final file = await _localFile;
      await file.delete();
    } catch (e) {
      // Error in getting access to the file.
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                  itemCount: file.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = file[index].toString();
                    return Dismissible(
                      key: Key(item),
                      onDismissed: (direction) {
                        deleteFile();
                        setState(() {
                          file.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$item dismissed')));
                      },
                      background: Container(color: Colors.red),
                      child: Card(
                        elevation: 2.0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Audio(
                                    file: file[index],
                                  ),
                                ));
                          },
                          child: ListTile(
                            leading: Icon(
                              Icons.play_circle_filled,
                              color: Colors.blue[800],
                              size: 40.0,
                            ),
                            title: Text(file[index].path.split('/').last),
                            // subtitle: Text(file[index].toString()),
                          ),
                        ),
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
