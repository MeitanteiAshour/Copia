import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound_player.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:intl/date_symbol_data_local.dart';

class BottomAudioPlayer extends StatefulWidget {
  final int index;
  final bool hideFab;

  const BottomAudioPlayer({Key key, this.index, this.hideFab})
      : super(key: key);
  @override
  _BottomAudioPlayerState createState() => _BottomAudioPlayerState();
}

class _BottomAudioPlayerState extends State<BottomAudioPlayer>
    with SingleTickerProviderStateMixin {
  FlutterSoundPlayer flutterSoundPlayer;
  AnimationController _controller;
  bool _isPlaying = false;
  StreamSubscription _playerSubscription;
  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;
  String _playerTxt = '00:00:00';

  @override
  void initState() {
    _initializeSoundPlayer();
    initializeDateFormatting();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    super.initState();
  }

  @override
  void dispose() {
    flutterSoundPlayer.release();
    cancelPlayerSubscriptions();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Hive.box('name').getAt(widget.index).soundPath != null) {
      final _soundPath = Hive.box('name').getAt(widget.index).soundPath;
      return AnimatedOpacity(
        opacity: widget.hideFab ? 0.0 : 1.0,
        duration: Duration(milliseconds: 400),
        child: Container(
          color: Colors.black,
          height: 50,
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(
                    () {
                      if (_isPlaying) {
                        _pauseAudio();
                      } else {
                        _playAudio(_soundPath);
                      }
                    },
                  );
                },
                child: AnimatedIcon(
                  icon: AnimatedIcons.play_pause,
                  progress: _controller,
                  color: Colors.red,
                ),
              ),
              Container(
                width: 200,
                child: Slider(
                  value: min(sliderCurrentPosition, maxDuration),
                  inactiveColor: Colors.green,
                  activeColor: Colors.green,
                  onChanged: (double time) async {
                    if (flutterSoundPlayer.playerState !=
                        t_PLAYER_STATE.IS_STOPPED)
                      await flutterSoundPlayer.seekToPlayer(time.toInt());
                  },
                  max: maxDuration,
                  label: '$_playerTxt',
                  onChangeEnd: (e) {
                    print(e);
                  },
                  divisions: maxDuration == 0.0 ? 1 : maxDuration.toInt(),
                  min: 0,
                ),
              ),
              Text(
                '$_playerTxt',
                style: TextStyle(color: Colors.white),
              ),
              Icon(Icons.library_music, color: Colors.orange)
            ],
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Future<void> _initializeSoundPlayer() async =>
      flutterSoundPlayer = await FlutterSoundPlayer().initialize();

  void onPauseResumePlayerPressed() {
    if (flutterSoundPlayer == null) return null;
    if (flutterSoundPlayer.isPaused || flutterSoundPlayer.isPlaying) {
      flutterSoundPlayer.resumePlayer();
    }
    return null;
  }

  Future<void> _pauseAudio() async {
    _isPlaying = false;
    _controller.reverse();
    await flutterSoundPlayer.pausePlayer();
  }

  Future<void> _playAudio(String _soundPath) async {
    _isPlaying = true;
    _controller.forward();

    if (flutterSoundPlayer.isStopped) {
      await flutterSoundPlayer.startPlayer(_soundPath);
    } else {
      onPauseResumePlayerPressed();
    }
    _addListeners();
  }

  void _addListeners() {
    cancelPlayerSubscriptions();
    _playerSubscription = flutterSoundPlayer.onPlayerStateChanged.listen(
      (PlayStatus e) {
        setState(
          () {
            if (e != null) {
              maxDuration = e.duration;
              if (maxDuration <= 0) maxDuration = 0.0;

              sliderCurrentPosition = min(e.currentPosition, maxDuration);
              if (sliderCurrentPosition < 0.0) {
                sliderCurrentPosition = 0.0;
              }
              DateTime date = new DateTime.fromMillisecondsSinceEpoch(
                  e.currentPosition.toInt(),
                  isUtc: true);
              String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
              setState(() => _playerTxt = txt.substring(0, 8));
              if (e.duration == e.currentPosition) {
                setState(
                  () {
                    sliderCurrentPosition = 0.0;
                    _isPlaying = false;
                    _controller.reverse();
                  },
                );
              }
            }
          },
        );
      },
    );
  }

  void cancelPlayerSubscriptions() {
    if (_playerSubscription != null) {
      _playerSubscription.cancel();
      _playerSubscription = null;
    }
  }
}
