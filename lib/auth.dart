import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

FirebaseAuth auth = FirebaseAuth.instance;

class AuthDB extends StatefulWidget {
  @override
  _AuthDBState createState() => _AuthDBState();
}

class _AuthDBState extends State<AuthDB> {
  var _controllerLogin = TextEditingController(),
      _controllerPass = TextEditingController();
  String userName, _passWord;
  FocusNode myFNodeUserName, myFNodePassWord;
  bool _makeSpin = false;
  bool _keepLoggedIn = false;

  @override
  void initState() {
    super.initState();
    myFNodeUserName = FocusNode();
    myFNodePassWord = FocusNode();
    setState(() {
      _controllerLogin.clear();
      _controllerPass.clear();
    });
  }

  @override
  void dispose() {
    myFNodeUserName.dispose();
    myFNodePassWord.dispose();
    super.dispose();
  }

  loginToProceed(String mailid, String pass) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: mailid, password: pass);
      // loggedIn = true;
      if (userCredential != null) {
        _passWord = null;
        _controllerPass.clear();
        Navigator.pushNamed(context, '/login');
        setState(() {
          _makeSpin = false;
        });
      }
    } catch (e) {
      _controllerPass.clear();
      setState(() {
        _makeSpin = false;
      });

      switch (e.message) {
        case 'The password is invalid or the user does not have a password.':
          Fluttertoast.showToast(
            msg: 'Incorrect Password!',
            backgroundColor: Colors.black,
            textColor: Colors.white,
          );
          break;
        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
          Fluttertoast.showToast(
            msg: 'User Does Not Exist',
            backgroundColor: Colors.black,
            textColor: Colors.white,
          );
          break;
        default:
          print(e.message);
      }
    }
  }

  signUptoCreateUser(String mailid, String pass) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: mailid, password: pass);
      // loggedIn = false;
      setState(() {
        _controllerLogin.text = userCredential.user.email;
        _controllerPass.clear();
        _makeSpin = false;
      });

      Fluttertoast.showToast(
        msg: 'Login to Proceed',
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    } catch (e) {
      setState(() {
        _makeSpin = false;
      });

      switch (e.message) {
        case 'The email address is already in use by another account.':
          Fluttertoast.showToast(
            msg: 'email already in-use',
            backgroundColor: Colors.black,
            textColor: Colors.white,
          );
          break;
        default:
          print(e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    createFlatButton(String name) {
      return Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width * 0.30,
        height: MediaQuery.of(context).size.height * 0.10,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Colors.blue.shade800,
          onPressed: () async {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            setState(() {
              _makeSpin = true;
            });

            name == 'LogIn'
                ? loginToProceed(userName, _passWord)
                : signUptoCreateUser(userName, _passWord);
          },
          child: name == 'LogIn' ? Text('LogIn') : Text('SignUp'),
        ),
      );
    }

    // under dev
    // ignore: unused_element
    createLoginViaButton(String name) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 0.80,
          height: MediaQuery.of(context).size.height * 0.05,
          child: FlatButton(
            color: name == 'FaceBook' ? Colors.blue : Colors.red,
            onPressed: () {
              name == 'FaceBook' ? print('Facebook') : print('GMail');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                name == 'FaceBook' ? Icon(Icons.face) : Icon(Icons.mail),
                SizedBox(width: MediaQuery.of(context).size.width * 0.07),
                name == 'FaceBook' ? Text('Facebook') : Text('GMail'),
              ],
            ),
          ),
        ),
      );
    }

    createTextField(String hint) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width * 0.75,
        height: MediaQuery.of(context).size.height * 0.08,
        child: TextField(
          controller: hint == 'PASSWORD' ? _controllerPass : _controllerLogin,
          autocorrect: false,
          enableSuggestions: hint != 'PASSWORD',
          focusNode: hint == 'PASSWORD' ? myFNodePassWord : myFNodeUserName,
          keyboardType: hint != 'PASSWORD'
              ? TextInputType.emailAddress
              : TextInputType.text,
          obscureText: hint == 'PASSWORD',
          textAlign: TextAlign.left,
          onChanged: (input) {
            hint == 'PASSWORD' ? _passWord = input : userName = input;
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            prefixIcon: hint != 'PASSWORD'
                ? Icon(Icons.mail_outline)
                : Icon(Icons.lock_outline),
          ),
        ),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.lightBlueAccent,
            )),
      );
    }

    Widget _buildWidget() {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Icons for decoration
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Icon(
                      Icons.account_circle,
                      size: MediaQuery.of(context).size.height * 0.2,
                      color: Colors.amberAccent,
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.18,
                    width: MediaQuery.of(context).size.width * 0.43,
                    alignment: Alignment.bottomCenter,
                    child: Icon(
                      Icons.lock,
                      size: MediaQuery.of(context).size.height * 0.1,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              createTextField('Login-ID: EMail'),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              createTextField('PASSWORD'),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Switch(
              //         value: _keepLoggedIn,
              //         onChanged: (bool x) {
              //           setState(() {
              //             _keepLoggedIn = x;
              //           });
              //           print("changed: " + _keepLoggedIn.toString());
              //         }),
              //     Text("Keep me Logged In"),
              //   ],
              // ),
              // SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // Login-SignUp Buttons
                  createFlatButton('LogIn'),
                  createFlatButton('SignUp'),
                ],
              ),
              /* // Login via Buttons
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  decoration: BoxDecoration(
                      border: Border(
                    top: BorderSide(
                      style: BorderStyle.solid,
                      width: 3,
                    ),
                  )),
                ),
              ),
              Text(
                'LogIn via',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              createLoginViaButton('FaceBook'),
              createLoginViaButton('Gmail'),
              */
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Authenticate',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        leading: Icon(Icons.security),
        actions: <Widget>[
          CircleAvatar(
            child: IconButton(
              tooltip: "Reset",
              icon: Icon(
                Icons.settings_backup_restore,
                color: Colors.amber,
              ),
              onPressed: () {
                print('reset');
                userName = null;

                setState(() {
                  _controllerLogin.clear();
                  _controllerPass.clear();
                });
              },
            ),
          ),
        ],
        backgroundColor: Colors.indigo.shade900,
        centerTitle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(15.0),
            bottomRight: Radius.circular(15.0),
          ),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _makeSpin,
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: _buildWidget(),
        ),
        progressIndicator: CircularProgressIndicator(
          backgroundColor: Colors.amber,
        ),
      ),
    );
  }
}
