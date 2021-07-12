import 'dart:async';
import 'dart:html';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter_app_aimbooster/result.dart';

class MyApp extends StatefulWidget {
  final int ballCount;
  final double ballSize;
  final Color ballColor;

  MyApp(
      {required this.ballCount,
      required this.ballSize,
      required this.ballColor});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool create = true;
  List<Widget> balls = [];
  ListGenerator? generator;
  int counter = 0;
  int hits = 0;
  int misses = 0;
  int tick = 0;

  void _myFunction() {
    hits++;
    setState(() {
      balls = generator!.getBallList();
    });
  }

  AppBar appBar = AppBar(
    centerTitle: true,
    title: Text('Aim Booster'),
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight =
        MediaQuery.of(context).size.height - appBar.preferredSize.height;
    double screenWidth = MediaQuery.of(context).size.width;

    if (create) {
      Timer.periodic(Duration(seconds: 1), (t) async {
        setState(() {
          tick = t.tick;
        });
        if (t.tick == 60) {
          t.cancel();
          await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (c) => ResultPage(
                        hits: hits,
                        misses: misses,
                      )));
          Navigator.pop(context);
        }
      });
      generator = ListGenerator(
          ballSize: widget.ballSize,
          ballColor: widget.ballColor,
          count: widget.ballCount,
          setState: _myFunction,
          screenHeight: screenHeight,
          screenWidth: screenWidth);
      balls = generator!.getBallList();
      create = false;
    }
    appBar = AppBar(
      centerTitle: true,
      title: Text('Your Score is : ${hits*200 -  misses*50}, Time Remaining : ${60 - tick}'),
    );

    // TODO: implement build
    return GestureDetector(
      onTapDown: (e) {
        setState(() {
          misses++;
          print('wrong on tap down!');
        });
      },
      child: Scaffold(
        appBar: appBar,
        body: Stack(
          fit: StackFit.expand,
          children: balls,
        ),
      ),
    );
  }
}

class ListGenerator {
  int count;
  double screenWidth;
  double screenHeight;
  double ballSize;
  Color ballColor;
  late final List<double> tops;
  late final List<double> lefts;
  Function setState;

  ListGenerator(
      {this.count = 1,
      this.ballSize = 75,
      this.ballColor = Colors.blue,
      required this.setState,
      required this.screenHeight,
      required this.screenWidth}) {
    tops = [];
    lefts = [];
    for (int i = 0; i < count; i++) {
      tops.add(Random().nextInt((screenHeight - ballSize).toInt()).toDouble());
      lefts.add(Random().nextInt((screenWidth - ballSize).toInt()).toDouble());
    }
  }

  List<Widget> getBallList() {
    List<Widget> balls = [];
    for (int i = 0; i < count; i++) {
      balls.add(
        Positioned(
            key: ObjectKey(i),
            left: lefts.elementAt(i),
            top: tops.elementAt(i),
            child: ClipOval(
              child: Material(
                color: Colors.lightBlue, // Button color
                child: InkWell(
                  splashColor: Colors.lightBlue,
                  // Splash color
                  onTapDown: (TapDownDetails e) {
                    tops[i] = Random()
                        .nextInt((screenHeight - ballSize).toInt())
                        .toDouble();
                    lefts[i] = Random()
                        .nextInt((screenWidth - ballSize).toInt())
                        .toDouble();
                    setState();
                  },
                  onTap: () {},
                  child: SizedBox(width: ballSize, height: ballSize),
                ),
              ),
            )),
      );
    }
    return balls;
  }
}
