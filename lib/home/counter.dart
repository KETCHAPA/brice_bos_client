import 'package:flutter/material.dart';

class Counter extends StatefulWidget {
  @override
  _CounterState createState() => _CounterState();
}

class _CounterState extends State<Counter> with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: Duration(minutes: 59, seconds: 59, hours: 23),
        value: 1.0);
    _controller.reverse();
  }

  String get _timerString {
    Duration duration = _controller.duration * _controller.value;
    return '${duration.inHours}:${duration.inMinutes % 60}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(.85),
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget child) {
              return Text(_timerString, style: TextStyle(color: Colors.orange[400]));
            },
          )),
    );
  }
}
