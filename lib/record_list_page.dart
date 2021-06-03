import 'dart:io';

import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';

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
    print("Directory Path file $file");

    return directoryPath;
  }

  Future<void> deleteFiles(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
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
                      direction: DismissDirection.startToEnd,
                      onDismissed: (direction) {
                        deleteFiles(file.elementAt(index));
                        setState(() {
                          file.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$item dismissed')));
                      },
                      background: Container(
                        color: Colors.red,
                        //margin: EdgeInsets.symmetric(horizontal: 15),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            SizedBox(width: 8.0,),
                            Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                            Text('Delete', style: TextStyle(color: Colors.white),)
                          ],
                        ),
                      ),
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
