import 'package:flutter/material.dart';

class BackAndForth extends StatefulWidget {
  @override
  _BackAndForthState createState() => _BackAndForthState();
}

class _BackAndForthState extends State<BackAndForth> {
  Color _newColor = Colors.indigo.shade900;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder(
        tween: ColorTween(begin: Colors.white, end: _newColor),
        duration: Duration(seconds: 2),
        onEnd: () {
          setState(() {
            _newColor = _newColor == Colors.indigo.shade900
                ? Colors.white
                : Colors.indigo.shade900;
          });
        },
        builder: (_, Color color, __) {
          return ColorFiltered(
            child: Icon(
              Icons.sync_alt_rounded,
              size: MediaQuery.of(context).textScaleFactor * 30,
            ),
            colorFilter: ColorFilter.mode(color, BlendMode.modulate),
          );
        },
      ),
    );
  }
}
