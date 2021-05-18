import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code3_terminal/connect.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ViewCommands extends StatefulWidget {
  @override
  _ViewCommandsState createState() => _ViewCommandsState();
}

class _ViewCommandsState extends State<ViewCommands> {
  FocusNode myFocusNode;
  var auth = FirebaseAuth.instance;
  bool _makeSpin = false;
  String user;
  String hostIP = passhostIP;
  var fs = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
    user = auth.currentUser.email;
    print(user + hostIP);
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    user = null;
    hostIP = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _buildHistory() {
      return StreamBuilder<QuerySnapshot>(
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: Text(
              'No History to show',
              style: TextStyle(color: Colors.white38),
            ));
          }

          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              if (snapshot.data.docs[index].data()['server'].toString() !=
                  hostIP) {
                return SizedBox();
              }

              return Card(
                color: Colors.black45,
                borderOnForeground: false,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Text(
                        'COMMAND:',
                        style: TextStyle(
                          color: Colors.lightGreenAccent,
                          height: MediaQuery.of(context).textScaleFactor * 2,
                        ),
                      ),
                      title: Text(
                        snapshot.data.docs[index].data()['command'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          height: MediaQuery.of(context).textScaleFactor * 2,
                          color: Colors.white,
                          letterSpacing:
                              MediaQuery.of(context).textScaleFactor * 1.3,
                        ),
                      ),
                      subtitle: Text(
                        snapshot.data.docs[index]
                            .data()['timeStamp']
                            .toDate()
                            .toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlueAccent,
                        ),
                      ),
                      trailing: Tooltip(
                        message: snapshot.data.docs[index].data()['user'],
                        waitDuration: Duration(microseconds: 0),
                        child: Icon(
                          Icons.person_outline,
                          size: MediaQuery.of(context).size.height * 0.05,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    ListTile(
                      leading: Text(
                        'Output:',
                        style: TextStyle(
                          color: Colors.lightGreenAccent,
                        ),
                      ),
                      title: Text(
                        snapshot.data.docs[index].data()['output'],
                        textAlign: TextAlign.start,
                      ),
                      subtitle: Text(
                        "\nServer: " +
                            snapshot.data.docs[index].data()['server'],
                        style: TextStyle(
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        stream: fs
            .collection('cmdOutputs')
            .orderBy('timeStamp', descending: true)
            .snapshots(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: "Go Back",
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('History of Commands'),
      ),
      body: ModalProgressHUD(
        dismissible: false,
        inAsyncCall: _makeSpin,
        child: _buildHistory(),
      ),
    );
  }
}
