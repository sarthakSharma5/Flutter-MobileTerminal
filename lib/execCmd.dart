import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code3_terminal/animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:code3_terminal/auth.dart';
import 'package:code3_terminal/connect.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // TickerProviderStateMixin - To use vsyc: this
  List<String> cmds = [], opts = [];
  var hostIP, userName;
  FocusNode myFocusNode;
  bool _makeSpin = false;
  var _controller = new TextEditingController();

  // AnimationController _anime;
  // CurvedAnimation _animate;

  @override
  void initState() {
    super.initState();
    hostIP = passhostIP;
    myFocusNode = FocusNode();
    userName = auth.currentUser.email;
    print(userName + ' is using ' + hostIP);

    // _anime = AnimationController(
    //   vsync: this,
    //   duration: Duration(seconds: 2),
    // );
    // _animate = CurvedAnimation(curve: Curves.bounceIn, parent: _anime);
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    cmds.clear();
    opts.clear();
    // _anime.dispose();
    super.dispose();
  }

  var fs = FirebaseFirestore.instance;
  updateFirestoreDB(command, output) async {
    print(r'$' + command + '\n' + output);
    await fs.collection('cmdOutputs').add({
      'user': userName,
      'server': hostIP,
      'command': command,
      'output': output,
      'timeStamp': DateTime.now(),
    });
    print('updated');
  }

  executeCommand(cmd) async {
    try {
      // ignore: unnecessary_brace_in_string_interps
      var url = "http://${hostIP}/cgi-bin/fluttercmd.py?cmd=${cmd}";
      var r = await http.get(url);
      setState(() {
        //opts.add(r.body.replaceAll("<PRE>", "").trim());
        opts[opts.length - 1] = r.body.replaceAll("<PRE>", "").trim();
        _makeSpin = false;
      });
      updateFirestoreDB(cmd, opts[opts.length - 1]);
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.message,
        backgroundColor: Colors.blueAccent,
        textColor: Colors.white,
        timeInSecForIosWeb: 1,
      );
      print(e.message);
    }
  }

  initBody(String command) {
    if (command.isNotEmpty) {
      setState(() {
        _makeSpin = true;
        cmds.add(command);
        opts.add('');
      });
      executeCommand(command);
    }
  }

  closeSession() {
    Fluttertoast.showToast(
      msg: 'Session Closed',
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      timeInSecForIosWeb: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    String execCmd;

    Widget createList() {
      return cmds.isEmpty
          ? Container(
              color: Colors.black45,
              child: Center(
                  child: Text(
                'ENTER COMMAND BELOW',
                style: TextStyle(color: Colors.white38),
              )),
            )
          : ListView.builder(
              itemCount: cmds.length,
              itemBuilder: (context, int index) {
                return Card(
                  color: Colors.black45,
                  borderOnForeground: false,
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Text(
                          "root@${hostIP}",
                          style: TextStyle(
                              fontWeight: index == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: index == 0
                                  ? Colors.amber
                                  : Colors.yellowAccent),
                        ),
                        title: Text(
                          cmds[cmds.length - 1 - index],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing:
                                MediaQuery.of(context).textScaleFactor * 1.7,
                            color: index == 0
                                ? Colors.greenAccent
                                : Colors.lightBlueAccent,
                          ),
                        ),
                        subtitle: Text(DateTime.now().toString()),
                      ),
                      (_makeSpin && index == 0)
                          ? Center(child: BackAndForth())
                          : opts.isEmpty
                              ? SizedBox()
                              : ListTile(
                                  title: Text(
                                    opts[opts.length - 1 - index],
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                    ],
                  ),
                );
              });
    }

    Widget _buildWidget() {
      return Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.80,
            child: createList(),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Container(
                    margin: EdgeInsets.all(7),
                    height: MediaQuery.of(context).size.height * 0.07,
                    width: double.infinity,
                    padding: EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        width: 1,
                        color: Colors.white,
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: myFocusNode,
                      autocorrect: false,
                      cursorColor: Colors.blue,
                      decoration: InputDecoration(
                        hintText: 'Enter COMMAND',
                      ),
                      onChanged: (String cmd) {
                        execCmd = cmd.isNotEmpty ? cmd : '';
                      },
                      onSubmitted: (String cmd) {
                        _controller.text = cmd;
                        setState(() {
                          execCmd = cmd;
                        });
                      },
                    ),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.blue.shade400,
                  child: IconButton(
                    tooltip: "Execute",
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      if (execCmd == "clear") {
                        setState(() {
                          cmds.clear();
                          _controller.clear();
                          opts = []; //
                        });
                      } else if (execCmd == null) {
                      } else {
                        initBody(execCmd);
                        _controller.clear();
                        myFocusNode.unfocus();
                      }
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade900,
        automaticallyImplyLeading: false,
        //title: Text("terminal ${hostIP}"),
        title: Text("Terminal"),
        leadingWidth: 70.0,
        leading: Tooltip(
          child: Icon(Icons.info_outline),
          message: hostIP,
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Clear',
            icon: Icon(Icons.layers_clear),
            onPressed: () {
              setState(() {
                cmds.clear();
                opts = [''];
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.history),
            tooltip: "View History",
            onPressed: () => Navigator.pushNamed(context, "/view"),
          ),
          IconButton(
            tooltip: 'Close Session',
            icon: Icon(Icons.link_off),
            onPressed: () {
              hostIP = Null;
              closeSession();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: _buildWidget(),
    );
  }
}
