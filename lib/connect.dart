import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

String passhostIP;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var lengthIP;
  var _controllerURI = TextEditingController();
  FocusNode _focusNode;
  var auth = FirebaseAuth.instance;
  var fs = FirebaseFirestore.instance;
  List serverList;
  bool isConnected; //, _progressControl;

  @override
  void initState() {
    super.initState();
    passhostIP = null;
    serverList = [];
    isConnected = false;
    // _progressControl = false;
    print(auth.currentUser.email + ' is authenticated');
    _focusNode = FocusNode();
    _controllerURI.clear();
  }

  gotoServer() async {
    if (!serverList.contains(passhostIP)) {
      try {
        await fs.collection('servers').add({
          'url': passhostIP.toString().trim(),
          'online': true,
        });
      } catch (e) {
        setState(() {
          isConnected = false;
        });
      }
    }
    if (isConnected) {
      print("connected to " + passhostIP);
      setState(() {
        isConnected = false;
      });
      Navigator.pushNamed(context, "/exec");
      Fluttertoast.showToast(
        msg: 'session started',
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue,
      );
    } else {
      Fluttertoast.showToast(
        msg: 'Issue Occured on server',
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red.shade300,
      );
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Confirm?'),
            content: new Text('Do you want to LogOut?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              TextButton(
                onPressed: () {
                  // Navigator.popUntil(context, ModalRoute.withName('/login'));
                  Navigator.of(context).pop(true);
                  Navigator.of(context).pop();
                },
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    // serverList.clear();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _buildServerList() {
      return StreamBuilder(
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: Text(
              'None Recorded',
              style: TextStyle(color: Colors.white38),
            ));
          }
          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              serverList.add(snapshot.data.docs[index].data()['url']);
              return Card(
                elevation: 5,
                child: ListTile(
                  title: Text(snapshot.data.docs[index].data()['url']),
                  trailing: Icon(
                    Icons.circle,
                    color: snapshot.data.docs[index].data()['online']
                        ? Colors.green
                        : Colors.blue,
                  ),
                  onTap: () {
                    setState(() {
                      _controllerURI.text =
                          snapshot.data.docs[index].data()['url'];
                      passhostIP = snapshot.data.docs[index].data()['url'];
                    });
                  },
                ),
              );
            },
          );
        },
        stream: fs.collection("servers").snapshots(),
      );
    }

    _buildLoginWindow() {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).orientation == Orientation.landscape
                  ? MediaQuery.of(context).size.aspectRatio * 100
                  : MediaQuery.of(context).size.width * 0.45,
              height: MediaQuery.of(context).size.height * 0.20,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/terminal-256.png'),
                  fit: BoxFit.contain,
                ),
                color: Colors.black,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  width: 2,
                  color: Colors.lightGreen,
                ),
              ),
            ),
            SizedBox(height: 20),
            // Input Box for Server
            Padding(
              padding: EdgeInsets.only(left: 25),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Choose Host-URI",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.00,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Card(
                          elevation: 7,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: TextField(
                            controller: _controllerURI,
                            enableSuggestions: true,
                            focusNode: _focusNode,
                            autocorrect: false,
                            onChanged: (input) {
                              passhostIP = input.trim();
                            },
                            autofocus: false,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).textScaleFactor * 20,
                            ),
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'Enter URI / IP',
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
            // Connect and Clear
            Container(
              margin: EdgeInsets.only(
                  right: MediaQuery.of(context).size.width * 0.08),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RaisedButton(
                    onPressed: () {
                      if (passhostIP != null && passhostIP.length > 6) {
                        setState(() {
                          isConnected = true;
                        });
                        gotoServer();
                      } else {
                        setState(() {
                          isConnected = false;
                        });
                        Fluttertoast.showToast(
                          msg: 'Enter URI',
                          textColor: Colors.white,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                        );
                      }
                    },
                    onLongPress: () {
                      Fluttertoast.showToast(
                        msg: 'Execute commands in URI',
                        backgroundColor: Colors.deepPurple,
                      );
                    },
                    child: Text("Connect"),
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(color: Colors.deepPurple),
                    ),
                  ),
                  SizedBox(width: 10),
                  RaisedButton(
                    child: Text("Clear"),
                    onPressed: () {
                      _controllerURI.clear();
                      passhostIP = null;
                    },
                    elevation: 12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      side: BorderSide(color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Shell Command Executor"),
          actions: <Widget>[
            IconButton(
              tooltip: 'LogOut',
              icon: Icon(Icons.link_off),
              onPressed: () async {
                await auth.signOut();
                Navigator.of(context).pop();
              },
            ),
          ],
          backgroundColor: Colors.blue.shade900,
          centerTitle: false,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15.0),
              bottomRight: Radius.circular(15.0),
            ),
          ),
        ),
        body: ModalProgressHUD(
          inAsyncCall: isConnected,
          child: Stack(
            children: [
              // Create New Server
              GestureDetector(
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.03),
                  height: MediaQuery.of(context).size.height * 0.45,
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: _buildLoginWindow(),
                  ),
                ),
              ),
              // Heading - Available Server
              Container(
                margin: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.width * 0.07,
                  MediaQuery.of(context).size.height * 0.48,
                  0,
                  0,
                ),
                child: Text(
                  "Available Servers",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).textScaleFactor * 22,
                  ),
                ),
              ),
              // Server List
              Container(
                margin: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.width * 0.07,
                  MediaQuery.of(context).size.height * 0.54,
                  MediaQuery.of(context).size.width * 0.07,
                  MediaQuery.of(context).size.height * 0.07,
                ),
                child: _buildServerList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
