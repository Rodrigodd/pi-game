import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const PiGame(),
    );
  }
}

class PiGame extends StatefulWidget {
  const PiGame({Key? key}) : super(key: key);

  @override
  PiGameState createState() => PiGameState();
}

class PiGameState extends State<PiGame> {
  static const String _pi =
      "3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067982148086513282306647093844609550582231725359408128481";
  String _text = "";
  String _redText = "   ";
  int errorButton = -1;
  int expectedButton = -1;
  int cursorPos = 0;

  @override
  Widget build(BuildContext context) {
    const digitsStyle = TextStyle(fontSize: 48, color: Colors.black);

    var digitsText = TextSpan(
        text: 'π is $_text',
        style: digitsStyle,
        children: [
          TextSpan(text: _redText, style: const TextStyle(color: Colors.red))
        ]);

    final TextPainter textPainter = TextPainter(
        text: digitsText, maxLines: 1, textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return Scaffold(
        appBar: AppBar(
          title: const Text('π game App'),
        ),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomPaint(
              size: Size(0.0, textPainter.size.height),
              painter: MyPainter(textPainter),
            ),
            Center(
                child: Text(
              '${_text.length < 2 ? _text.length : _text.length - 1} digits',
              style: const TextStyle(fontSize: 16),
            )),
            _keypad()
          ],
        )));
  }

  Widget _keypad() {
    List<Widget> rows = [];
    for (var i = 0; i < 4; i++) {
      List<Widget> buttons = [];
      for (var j = i * 3 + 1; j < (i + 1) * 3 + 1; j++) {
        String text;
        if (j <= 9) {
          text = "$j";
        } else if (j == 11) {
          text = "0";
        } else if (j == 10) {
          text = ".";
        } else {
          text = _redText == "   " ? "" : "RETRY";
        }
        var button = SizedBox(
          width: 80,
          height: 80,
          child: TextButton(
              onPressed: () {
                setState(() {
                  if (_redText != "   ") {
                    if (j == 12) {
                      _redText = "   ";
                      errorButton = -1;
                      _text = "";
                      cursorPos = 0;
                    }
                    return;
                  }

                  if (text[0] == _pi[cursorPos]) {
                    _text += text;
                    cursorPos += 1;
                  } else {
                    _redText = _pi.substring(cursorPos, cursorPos + 3);
                    errorButton = j;
                    expectedButton =
                        _pi[cursorPos] == "." ? 10 : int.parse(_pi[cursorPos]);
                    if (expectedButton == 0) {
                      expectedButton = 11;
                    }
                    HapticFeedback.vibrate();
                  }
                });
              },
              style: errorButton == j
                  ? ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                          return Colors.red.withOpacity(0.5);
                        },
                      ),
                    )
                  : errorButton != -1 && expectedButton == j
                      ? ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              return Colors.green.withOpacity(0.5);
                            },
                          ),
                        )
                      : null,
              child: Text(text)),
        );
        buttons.add(button);
      }
      var row =
          Row(mainAxisAlignment: MainAxisAlignment.center, children: buttons);
      rows.add(row);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

class MyPainter extends CustomPainter {
  TextPainter textPainter;

  MyPainter(this.textPainter);

  @override
  void paint(Canvas canvas, Size size) {
    // canvas.drawCircle(const Offset(40, 40), 40, Paint());
    Offset offset;
    if (size.width > textPainter.size.width) {
      offset = Offset((size.width - textPainter.size.width) / 2, 0);
    } else {
      offset = Offset(size.width - textPainter.size.width, 0);
    }
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
