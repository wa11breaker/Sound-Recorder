import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:sound_recorder/screens/widets/audio_list_tile.dart';
import 'package:sound_recorder/screens/widets/pulsing_animation.dart';
import 'package:sound_recorder/utils/path.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

enum AudioState {
  isPlaying,
  isPaused,
  isStopped,
  isRecording,
  isRecordingPaused,
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  FlutterAudioRecorder _recorder;
  RecordingStatus _currentStatus = RecordingStatus.Unset;

  List<String> _recordedAudioPath = List();
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: _recordedAudioPath.length == 0
                  ? Center(
                      child: Text('No recent recordings'),
                    )
                  : SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recent recordings',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: _recordedAudioPath.length,
                              itemBuilder: (context, index) => AudioListTile(
                                audioPath: _recordedAudioPath[index],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            Container(
              width: double.infinity,
              height: 150,
              color: Colors.black,
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _currentStatus == RecordingStatus.Recording
                      ? CustomPaint(
                          painter: PulseAnimation(_controller),
                          child: SizedBox(
                            width: 100,
                            height: 100,
                          ),
                        )
                      : SizedBox.shrink(),
                  GestureDetector(
                    onTap: () {
                      _currentStatus == RecordingStatus.Recording
                          ? _stop()
                          : _init();
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                        border: Border.all(
                          color: Colors.white,
                        ),
                      ),
                      child: _currentStatus == RecordingStatus.Recording
                          ? Icon(Icons.stop, color: Colors.white)
                          : Icon(Icons.circle, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// -----------------------animations-----------------------
  void _startAnimation() {
    _controller.stop();
    _controller.reset();
    _controller.repeat(
      period: Duration(seconds: 1),
    );
  }

  void _stopAnimation() {
    _controller.stop();
  }

// -----------------------recorder-----------------------
// initialization
  _init() async {
    try {
      // check if audio permission is accepetd
      if (await FlutterAudioRecorder.hasPermissions) {
        // get temporary path for saving audio
        String path = await getDirectory();

        _recorder = FlutterAudioRecorder(path, audioFormat: AudioFormat.WAV);

        await _recorder.initialized;
        // after initialization start recording
        _start();
      } else {
        // if audio permission is not accepetd show snakbar
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("You must accept permissions"),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

// start recording
  _start() async {
    try {
      await _recorder.start();
      var recording = await _recorder.current(channel: 0);
      setState(() {
        _currentStatus = recording.status;
        _startAnimation();
      });
    } catch (e) {
      print(e);
    }
  }

// stop recording
  _stop() async {
    var result = await _recorder.stop();
    _recordedAudioPath.add(result.path);

    setState(() {
      _currentStatus = result.status;
      _stopAnimation();
    });
  }
}
