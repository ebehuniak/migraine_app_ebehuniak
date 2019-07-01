import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter_sound/flutter_sound.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Migraine Research App',
//      theme: ThemeData(
//          primaryColor: Colors.deepPurple,
//          accentColor: Colors.deepPurpleAccent),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription<double> _dbPeakSubscription;

  double _dbLevel;
  FlutterSound flutterSound;
  // Set up flutterSound var to get microphone input
  @override
  void initState() {
    super.initState();
    flutterSound = new FlutterSound();
    flutterSound.setDbLevelEnabled(true);
    flutterSound.setSubscriptionDuration(.01);
    flutterSound.setDbPeakLevelUpdate(0.5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Migraine Homepage'),
      ),
      // must use new every time creating a new instance of a widget
      body: new Column(children: [
        _buildButtonWidget(
            _startRecording, Icons.play_arrow, "Start Recording"),
        _buildButtonWidget(_stopRecording, Icons.stop, "Stop Recording"),
        _buildSoundDisplay(),
      ]),
    );
  }

  // subscribe to stream
  void _startRecording() async {
    try {
      // This line starts the recording
      String path = await flutterSound.startRecorder(null);
      print('startRecording: $path');
      _dbPeakSubscription =
          flutterSound.onRecorderDbPeakChanged.listen((value) {
        print("got update -> $value");
        setState(() {
          this._dbLevel = value;
        });
      });
    } catch (error) {
      print("startRecording error: $error");
    }
  }

  void _stopRecording() async {
    try {
      String result = await flutterSound.stopRecorder();
      print('stopRecording: $result');

      if (_dbPeakSubscription != null) {
        _dbPeakSubscription.cancel();
        _dbPeakSubscription = null;
      }
    } catch (error) {
      print('stopRecording error: $error');
    }
  }

  // This private class will build each button
  Center _buildButtonWidget(Function function, IconData icon, String label) {
    // this automatically will center the new container widget
    return new Center(
      child: new Container(
        margin: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 100,
        ),

        // Using RaisedButton to allow easy button aspects
        child: RaisedButton(
          // TODO: Implement Button Actions
          onPressed: () {
            function();
          },

          padding: EdgeInsets.symmetric(
            vertical: 20,
          ),
          color: Theme.of(context).primaryColorLight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              new Text(label),
              new Icon(icon),
            ],
          ),
        ),
      ),
    );
  }

  Center _buildSoundDisplay() {
    return new Center(
        child: new Container(
      margin: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 100,
      ),
      padding: EdgeInsets.symmetric(
        vertical: 20,
      ),
/*        child: StreamBuilder(
          stream: flutterSound.onRecorderDbPeakChanged,
          builder: (context, snapshot) {
            String valueAsString = 'NoData';
            if (snapshot != null && snapshot.hasData) {
              valueAsString = snapshot.data.toString();
            }
            return Text(valueAsString);
          },
        ),*/
    ));
  }
}
