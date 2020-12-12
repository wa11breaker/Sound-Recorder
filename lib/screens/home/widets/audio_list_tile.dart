import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class AudioListTile extends StatefulWidget {
  final String audioPath;

  const AudioListTile({Key key, this.audioPath}) : super(key: key);
  @override
  _AudioListTileState createState() => _AudioListTileState();
}

class _AudioListTileState extends State<AudioListTile> {
  _playAudio() async {
    AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.play(widget.audioPath, isLocal: true);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.audioPath.split('/').last,
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.play_arrow,
        ),
        onPressed: () {
          _playAudio();
        },
      ),
    );
  }
}
