import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:vibration/vibration.dart';
import 'dart:io';
//import 'package:flutter/services.dart';
import 'dart:async';

void main() => runApp(MyApp());

enum OptionChoice { reset, exit }

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puck Possession',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: MyHomePage(title: 'Puck Possession Timers'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentPeriod = 0;
  List<Stopwatch> _homeTimeByPeriod = List<Stopwatch>();
  List<Stopwatch> _awayTimeByPeriod = List<Stopwatch>();

  @override
  void initState() {
    super.initState();
    _homeTimeByPeriod.add(Stopwatch());
    _homeTimeByPeriod.add(Stopwatch());
    _homeTimeByPeriod.add(Stopwatch());
    _awayTimeByPeriod.add(Stopwatch());
    _awayTimeByPeriod.add(Stopwatch());
    _awayTimeByPeriod.add(Stopwatch());
    //_createTimers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _updatePeriod(int p) {
    if ((p < 0) || (p > 2)) {
      p = 0;
    }
    setState(() {
      _awayTimeByPeriod[_currentPeriod].stop();
      _homeTimeByPeriod[_currentPeriod].stop();
      _currentPeriod = p;
    });
  }

  void _toggleHomeTimer(int period) async {
    if (_homeTimeByPeriod[period].isRunning) {
      Vibration.vibrate(duration: 50);
      await Future.delayed(Duration(milliseconds: 150));
      Vibration.vibrate(duration: 50);
      _homeTimeByPeriod[period].stop();
    } else {
      Vibration.vibrate(duration: 50);
      _homeTimeByPeriod[period].start();
      _awayTimeByPeriod[period].stop();
    }
    setState(() {});
  }

  void _toggleAwayTimer(int period) async {
    if (_awayTimeByPeriod[period].isRunning) {
      Vibration.vibrate(duration: 50);
      await Future.delayed(Duration(milliseconds: 150));
      Vibration.vibrate(duration: 50);
      _awayTimeByPeriod[period].stop();
    } else {
      Vibration.vibrate(duration: 50);
      _awayTimeByPeriod[period].start();
      _homeTimeByPeriod[period].stop();
    }
    setState(() {});
  }

  void _resetAll() {
    setState(() {
      _currentPeriod = 0;
      for (var period = 0; period < 3; period++) {
        _homeTimeByPeriod[period].stop();
        _awayTimeByPeriod[period].stop();

        _homeTimeByPeriod[period].reset();
        _awayTimeByPeriod[period].reset();
      }
    });
  }

  Future<bool> _stopAll() async {
    setState(() {
      for (var period = 0; period < 3; period++) {
        _homeTimeByPeriod[period].stop();
        _awayTimeByPeriod[period].stop();
      }
    });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          PopupMenuButton<OptionChoice>(
            onSelected: (OptionChoice result) {
              if (result == OptionChoice.reset) {
                setState(() {
                  _confirmReset();
                });
              } else if (result == OptionChoice.exit) {
                exit(0);
              }
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<OptionChoice>>[
              const PopupMenuItem<OptionChoice>(
                value: OptionChoice.reset,
                //child: Icon(Icons.restore),
                child: Text("Reset All Timers"),
              ),
              const PopupMenuItem<OptionChoice>(
                value: OptionChoice.exit,
                child: Text("EXIT"),
              ),
              const PopupMenuItem<OptionChoice>(
                value: null,
                //child: Icon(Icons.restore),
                child: Text("Version 0.6"),
              ),
            ],
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: _stopAll, // prevent the back button for now, must kill app
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: RaisedButton(
                          textColor: Colors.white,
                          color: _awayTimeByPeriod[_currentPeriod].isRunning
                              ? Colors.green[300]
                              : Colors.red[200],
                          child: Text(
                            "THEM",
                            style: TextStyle(fontSize: 30),
                          ),
                          elevation: 10,
                          onPressed: () => _toggleAwayTimer(_currentPeriod),
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      Container(height: 50),
                      TimerText(
                        sw: _awayTimeByPeriod[0],
                        period: 1,
                      ),
                      Container(height: 20),
                      TimerText(
                        sw: _awayTimeByPeriod[1],
                        period: 2,
                      ),
                      Container(height: 20),
                      TimerText(
                        sw: _awayTimeByPeriod[2],
                        period: 3,
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: RaisedButton(
                          textColor: Colors.white,
                          color: _homeTimeByPeriod[_currentPeriod].isRunning
                              ? Colors.green[300]
                              : Colors.red[200],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset('assets/viperhead.png'),
                              //Text( "Vipers", style: TextStyle(fontSize: 30), ),
                            ],
                          ),
                          elevation: 10,
                          onPressed: () => _toggleHomeTimer(_currentPeriod),
                          shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      Container(height: 50),
                      TimerText(
                        sw: _homeTimeByPeriod[0],
                        period: 1,
                      ),
                      Container(height: 20),
                      TimerText(
                        sw: _homeTimeByPeriod[1],
                        period: 2,
                      ),
                      Container(height: 20),
                      TimerText(
                        sw: _homeTimeByPeriod[2],
                        period: 3,
                      ),
                    ],
                  )
                ],
              ),
              Container(
                height: 30,
              ),
              Text("Choose Period(long press)"),
              Container(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: GestureDetector(
                      onLongPress: () => _updatePeriod(0),
                      child: RaisedButton(
                        onPressed: () => print("press 1"),
                        textColor: Colors.white,
                        color: _currentPeriod == 0
                            ? Colors.blue[300]
                            : Colors.grey[300],
                        child: Text(
                          "1",
                          style: TextStyle(fontSize: 30),
                        ),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: GestureDetector(
                      onLongPress: () => _updatePeriod(1),
                      child: RaisedButton(
                        onPressed: () => print("press 2"),
                        textColor: Colors.white,
                        color: _currentPeriod == 1
                            ? Colors.blue[300]
                            : Colors.grey[300],
                        child: Text(
                          "2",
                          style: TextStyle(fontSize: 30),
                        ),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: GestureDetector(
                      onLongPress: () => _updatePeriod(2),
                      child: RaisedButton(
                        onPressed: () => print("press 3"),
                        textColor: Colors.white,
                        color: _currentPeriod == 2
                            ? Colors.blue[300]
                            : Colors.grey[300],
                        child: Text(
                          "3",
                          style: TextStyle(fontSize: 30),
                        ),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: _resetAll,
        child: Text("RESET"),
      ),
       */
    );
  }

  Future<void> _confirmReset() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Timer Reset'),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Reset All'),
              onPressed: () {
                _resetAll();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class TimerText extends StatefulWidget {
  TimerText({this.team, this.period, this.sw});
  final int team;
  final int period;
  final Stopwatch sw;

  TimerTextState createState() => new TimerTextState(sw: sw);
}

class TimerTextState extends State<TimerText> {
  TimerTextState({this.sw});
  final Stopwatch sw;
  Timer timer;
  int milliseconds = 0;
  int hundreds = 0;
  int seconds = 0;
  int minutes = 0;

  @override
  void initState() {
    timer = new Timer.periodic(new Duration(milliseconds: 100), callback);
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  void callback(Timer timer) {
    setState(() {
      if (milliseconds != sw?.elapsedMilliseconds) {
        milliseconds = sw.elapsedMilliseconds;
        hundreds = (milliseconds / 10).truncate();
        seconds = (hundreds / 100).truncate();
        minutes = (seconds / 60).truncate();
        //print("$minutes : $seconds : $hundreds");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //String theTime = sprintf("P%d%s%02d:%02d", [widget.period, "\u2192", minutes, seconds]);
    String theTime = sprintf(
        "%02d:%02d.%01d", [minutes, seconds % 60, ((hundreds % 100) ~/ 10)]);
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("Period ${widget.period}"),
        RepaintBoundary(
          child: new SizedBox(
              height: 42.0,
              child: Text(
                "$theTime",
                style: TextStyle(fontSize: 28),
              )),
        ),
      ],
    );
  }
}
