import 'package:flutter/material.dart';

class LogPainter extends CustomPainter {
  LogPainter(this.color1, this.color2, this.reverse);
  final Color color1;
  final Color color2;
  final bool reverse;

  @override
  void paint(Canvas canvas, Size mainSize) {
    Path path = Path();
    Paint paint = Paint();

    switch (reverse) {
      case true:
        path.lineTo(0, mainSize.height - 1.0);
        path.quadraticBezierTo(mainSize.width * .1, mainSize.height * .9,
            mainSize.width / 2, mainSize.height * .87);
        path.quadraticBezierTo(mainSize.width * .9, mainSize.height * .85,
            mainSize.width, mainSize.height * .67);
        path.lineTo(mainSize.width, mainSize.height);
        path.lineTo(0, mainSize.height);
        Rect rect = new Rect.fromCircle(
          center: new Offset(165.0, 55.0),
          radius: 180.0,
        );
        paint
          ..shader = RadialGradient(
            colors: <Color>[this.color1, this.color2],
            stops: [
              0.5,
              1.0,
            ],
          ).createShader(rect);
        canvas.drawPath(path, paint);

        path = Path();
        path.lineTo(0, mainSize.height - 5.0);
        path.quadraticBezierTo(mainSize.width * .1, mainSize.height * .89,
            mainSize.width / 2, mainSize.height * .86);
        path.quadraticBezierTo(mainSize.width * .9, mainSize.height * .83,
            mainSize.width, mainSize.height * .65);
        path.lineTo(mainSize.width, mainSize.height);
        path.lineTo(0, mainSize.height);
        canvas.drawPath(path, paint);
        
        break;

      default:
        Size size = Size(mainSize.width, mainSize.height * .33);
        path.lineTo(0, size.height - 30.0);
        path.quadraticBezierTo(
            0, size.height - 30.03, size.width * .01, size.height - 40.0);
        path.quadraticBezierTo(size.width * .1, size.height * .3 - 20.0,
            size.width * .5, size.height * .23 - 10.0);
        path.quadraticBezierTo(
            size.width * .9, size.height * .15 - 10.0, size.width, 0);

        path.close();
        Rect rect = new Rect.fromCircle(
          center: new Offset(165.0, 55.0),
          radius: 180.0,
        );
        paint
          ..shader = RadialGradient(
            colors: <Color>[this.color1, this.color2],
            stops: [
              0.5,
              1.0,
            ],
          ).createShader(rect);
        canvas.drawPath(path, paint);

        path = Path();
        path.lineTo(0, size.height);
        path.quadraticBezierTo(
            0, size.height - .03, size.width * .01, size.height - 10.0);
        path.quadraticBezierTo(size.width * .1, size.height * .3,
            size.width * .5, size.height * .23);
        path.quadraticBezierTo(
            size.width * .9, size.height * .15, size.width, 0);

        path.close();
        paint.color = Colors.red;
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
