import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi/flutter_midi.dart';

import '../../plugins/vibrate/vibrate.dart';
import '../common/index.dart';
import '../common/piano_view.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  @override
  initState() {
    _loadSoundFont();
    Future.delayed(Duration(seconds: 60)).then((_) {
    });
    super.initState();
  }

  void _loadSoundFont() async {
    FlutterMidi.unmute();
    rootBundle.load("assets/sf2/Piano.sf2").then((sf2) {
      FlutterMidi.prepare(sf2: sf2, name: "Piano.sf2");
    });
    VibrateUtils.canVibrate.then((vibrate) {
        setState(() {
          canVibrate = vibrate;
        });
    });
  }
  Duration _seconds = Duration(seconds: 0, microseconds: 0);
  bool _playing = false;
  Timer _timer;
  bool canVibrate = false;


  void startTimer() {
    const oneMimiSec = const Duration(milliseconds: 1);
    _timer = new Timer.periodic(
      oneMimiSec,
      (Timer timer) => setState(
        () {
            _seconds = _seconds + oneMimiSec;
        },
      ),
    );
  }
  void stopTimer(){
    _timer.cancel();
    _seconds = Duration(seconds: 0, microseconds: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
        appBar: AppBar(
          backgroundColor: Color(0xff8B16FF),
          title: Center(
            child: Text(
              "The pocket piano",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 30.0,
              ),
            ),
          ),
          leading: FlatButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          actions: <Widget>[
            Row(
              children: <Widget>[
                Text("$_seconds"),
                FlatButton(
                  onPressed: (){
                    _playing ? stopTimer() : startTimer(); 
                    setState(() {_playing = !_playing;});
                  },
                  child: _playing ? Icon(
                    Icons.pause,
                    color: Colors.red,
                    size: 40,
                  ) : Icon(
                    Icons.fiber_manual_record,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Container(
            color: Colors.black,
            child: _buildKeys(context),
          ),
        ),
    );
  }

  Widget _buildKeys(BuildContext context) {
    double keyWidth = 40 + (80 * 0.5);
    final _vibrate = true;
    return Flex(
      direction: Axis.vertical,
      children: <Widget>[
        Flexible(
          child: PianoView(
            seconds: _seconds,
            keyWidth: keyWidth,
            labelsOnlyOctaves: false,
            feedback: _vibrate,
          ),
        ),
        Flexible(
          child: PianoView(
            seconds: _seconds,
            keyWidth: keyWidth,
            labelsOnlyOctaves: false,
            feedback: _vibrate,
          ),
        ),
      ],
    );
  }
}