import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

class Recorder extends StatefulWidget {
  final Function save;

  const Recorder({Key key, @required this.save}) : super(key: key);

  @override
  _RecorderState createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> {
  IconData _recordIcon = Icons.mic;
  MaterialColor color = Colors.blue;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  bool stop = false;
  Recording _recording;

  // Recorder properties
  FlutterAudioRecorder audioRecorder;

  @override
  void initState() {
    super.initState();

    FlutterAudioRecorder.hasPermissions.then((hasPermision) {
      if (hasPermision) {
        _currentStatus = RecordingStatus.Initialized;
        _recordIcon = Icons.mic;
      }
    });
  }

  @override
  void dispose() {
    _currentStatus = RecordingStatus.Unset;
    audioRecorder = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            Text(
              "Press the button to record",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              _recording?.duration?.toString()?.substring(0, 7) ?? "0:00:00",
              style: TextStyle(color: Colors.black, fontSize: 36, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            stop == false
                ? CircleAvatar(
                    backgroundColor: Colors.teal[400],
                    radius: 40,
                    child: IconButton(
                      onPressed: () async {
                        await _onRecordButtonPressed();
                        setState(() {});
                      },
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        _recordIcon,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.teal[400],
                          radius: 50,
                          child: IconButton(
                            onPressed: () async {
                              await _onRecordButtonPressed();
                              setState(() {});
                            },
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              _recordIcon,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.0),
                        CircleAvatar(
                          backgroundColor: Colors.teal[400],
                          radius: 30,
                          child: IconButton(
                            onPressed: _currentStatus != RecordingStatus.Unset
                                ? _stop
                                : null,
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.stop,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ],
    );
  }

  Future<void> _onRecordButtonPressed() async {
    switch (_currentStatus) {
      case RecordingStatus.Initialized:
        {
          _recorder();
          break;
        }
      case RecordingStatus.Recording:
        {
          _pause();
          break;
        }
      case RecordingStatus.Paused:
        {
          _resume();
          break;
        }
      case RecordingStatus.Stopped:
        {
          _recorder();
          break;
        }
      default:
        break;
    }
  }

  _initial() async {
    Directory appDir = await getExternalStorageDirectory();
    String audioRecord = 'Recordings';
    String date = "${DateTime.now()?.millisecondsSinceEpoch?.toString()}.mp4";
    Directory appDirectory = Directory("${appDir.parent.parent.parent.parent.path}/$audioRecord/");
    if (await appDirectory.exists()) {
      String path = "${appDirectory.path}$date";
      print("PATH IS:-------------" + path);
      audioRecorder = FlutterAudioRecorder(path, audioFormat: AudioFormat.AAC);
      await audioRecorder.initialized;
    } else {
      appDirectory.create(recursive: true);
      Fluttertoast.showToast(msg: "Start Recording , Press Start");
      String path = "${appDirectory.path}$date";
      print("PATH IS:-------------" + path);
      audioRecorder = FlutterAudioRecorder(path, audioFormat: AudioFormat.AAC);
      await audioRecorder.initialized;
    }
  }

  _start() async {
    await audioRecorder.start();
    var recording = await audioRecorder.current(channel: 0);
    setState(() {
      _recording = recording;
    });

    const tick = const Duration(milliseconds: 50);
    new Timer.periodic(tick, (Timer t) async {
      if (_currentStatus == RecordingStatus.Stopped) {
        t.cancel();
      }

      var current = await audioRecorder.current(channel: 0);
      print("CURRENT:---------------------" + current.status.toString());
      setState(() {
        _recording = current;
        _currentStatus = _recording.status;
      });
    });
  }

  _resume() async {
    await audioRecorder.resume();
    Fluttertoast.showToast(msg: "Resume Recording");
    setState(() {
      _recordIcon = Icons.pause;
      color = Colors.red;
    });
  }

  _pause() async {
    await audioRecorder.pause();
    Fluttertoast.showToast(msg: "Pause Recording");
    setState(() {
      _recordIcon = Icons.mic;
      color = Colors.green;
    });
  }

  _stop() async {
    var result = await audioRecorder.stop();
    Fluttertoast.showToast(msg: "Stop Recording , File Saved");
    widget.save();
    setState(() {
      _recording = result;
      _currentStatus = _recording.status;
      _recording.duration = null;
      _recordIcon = Icons.mic;
      stop = false;
    });
  }

  Future<void> _recorder() async {
    if (await FlutterAudioRecorder.hasPermissions) {
      await _initial();
      await _start();
      Fluttertoast.showToast(msg: "Start Recording");
      setState(() {
        _currentStatus = RecordingStatus.Recording;
        _recordIcon = Icons.pause;
        color = Colors.blue;
        stop = true;
      });
    } else {
      Fluttertoast.showToast(msg: "Allow App To Use Mic");
    }
  }
}
