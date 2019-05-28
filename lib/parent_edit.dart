import 'package:flutter/material.dart';
import 'package:brain_train_official/profile.dart' as profile;

//get relevant user info
import 'package:brain_train_official/main.dart' as login;

// BT API related Imports
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:random_string/random_string.dart' as rnd;

@override
Widget build(BuildContext context) {
  return new MaterialApp(
    home: new parentEdit(),
    theme: new ThemeData(primarySwatch: Colors.indigo),
  );
}

class parentEdit extends StatefulWidget {
  @override
  parentEditState createState() {
    return new parentEditState();
  }
}

class parentEditState extends State<parentEdit>
    with SingleTickerProviderStateMixin {
  static String email;
  static String uname;
  static String pid;

  final passController = TextEditingController();
  final emailController = TextEditingController();
  final unameController = TextEditingController();

  bool loadCircle = false;

  loading() {
    setState(() {
      loadCircle = true;
    });
  }

  notLoading() {
    setState(() {
      loadCircle = false;
    });
  }

  initState() {
    super.initState();

    email = login.MyApp.pemail;
    uname = login.MyApp.puname;
    pid = login.MyApp.pid;
  }

  dispose() {
    super.dispose();
  }

  Widget loadingScreen() {
    return new Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: ExactAssetImage("assets/newlogo.png"), fit: BoxFit.cover),
      ),
      child: new Center(
        child: new Column(children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(top: 260),
            child: new Column(children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(left: 65),
                //color: Colors.cyan[50],
                child: new Image.asset("assets/animated-train-image-0031.gif"),
              ),
              new Text(
                'Updating Account',
                style: new TextStyle(color: Colors.white, fontSize: 25.0),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  void updateCurrentParSalt(Map dec, context) async {
    String pidSalt;
    //put parent id in DB for ref to salt
    dec["Parent_id"] = login.MyApp.pid;

    pidSalt = json.encode(dec);

    //store salt associated with registered parent using POST
    http
        .post('https://braintrainapi.com/btapi/parents',
            headers: {"Content-Type": "application/json"}, body: pidSalt)
        .then((response) {
      print("Storing of salt w/ PID complete");
      //print("Response status: ${response.statusCode}");
      //print("Response body: ${response.body}");

      Navigator.pop(context);
    });
  }

  void updateParSalt(Map dec, String d, int pid, context) async {
    final resp2 = await http.get('https://braintrainapi.com/btapi/parents');
    //If http.get is successful
    if (resp2.statusCode == 200) {
      List btjson2 = json.decode(resp2.body.toString());
      List<login.Parents> parsList2 = login.createParentsList(btjson2);
      var tot_par2 = parsList2.length;

      String pidSalt = json.encode(dec);

      // if no new email, make it old email
      if (d == "") {
        d = login.MyApp.pemail;
      }
      for (int i = 0; i < tot_par2; i++) {
        //find just created email
        if (parsList2[i].email == d) {
          pid = parsList2[i].parent_id;
          //put parent id in DB for ref to salt
          dec["Parent_id"] = pid;
          pidSalt = json.encode(dec);

          //store salt associated with updated parent using POST
          http
              .post('https://braintrainapi.com/btapi/parents',
                  headers: {"Content-Type": "application/json"}, body: pidSalt)
              .then((response) {
            print("Storing of salt w/ PID complete");
            //print("Response status: ${response.statusCode}");
            //print("Response body: ${response.body}");

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => profile.userProfile()),
            );
          });
        }
      }
    } else {
      print(
          "Unsuccessful connection to BT API, please contact web server admin");
      notLoading();
    }
  }

  //update parents information
  void updateAccount(newEmail, newUName, newPass, oldEmail, context) async {
    loading();

    Map<String, dynamic> parentJsonMap = {
      'email': newEmail,
      'password': newPass,
      'uname': newUName,
      'salt': "",
      'Parent_id': "",
      "pD": "updateparent",
      "age": "",
      "cuname": oldEmail,
      "tuname": "",
    };

    String pJsonString = json.encode(parentJsonMap);

    int r = 1;
    final resp = await http.get('https://braintrainapi.com/btapi/parents');
    //If http.get is successful
    if (resp.statusCode == 200) {
      print("Parent Request #$r");
      r++;
      print("Successful connection to Parent BT API Endpoint");
      List btjson = json.decode(resp.body.toString());
      List<login.Parents> parsList = login.createParentsList(btjson);
      var tot_par = parsList.length;

      //Check parent emails and usernames
      Map padecoded = jsonDecode(pJsonString);
      for (int i = 0; i < tot_par; i++) {
        if (parsList[i].email == padecoded["email"]) {
          print("Parent email already exists,update incomplete");
          notLoading();
          //put prompt here for parent email already exists
          return;
        }
        if (parsList[i].username == padecoded["uname"]) {
          print("Parent username already exists,update incomplete");
          notLoading();
          //put prompt here for parent username already exists
          return;
        }
      }

      //beginning of hash and salt logic for insertion to DB
      int pid;

      // updating only password
      if (newPass != "" && newEmail == "" && newUName == "") {
        print("only password");
        String pSalt;

        //salt creation
        pSalt = rnd.randomAlphaNumeric(32);
        padecoded["salt"] = pSalt;

        //Hashing function: SHA 256 + 32 byte salt, will make more robust in future
        var pPass = utf8.encode(padecoded["password"] + pSalt);
        var pHash = sha256.convert(pPass);

        //Prepare hash for POST
        padecoded["password"] = pHash.toString();
        pJsonString = json.encode(padecoded);

        //Store salt related to parent w/ function
        print("updating salt...");
        updateCurrentParSalt(padecoded, context);
      }

      //updating all fields
      if (newPass != "" && newEmail != "" && newUName != "") {
        print("password and everything else");
        String pSalt;

        //salt creation
        pSalt = rnd.randomAlphaNumeric(32);
        padecoded["salt"] = pSalt;

        //Hashing function: SHA 256 + 32 byte salt, will make more robust in future
        var pPass = utf8.encode(padecoded["password"] + pSalt);
        var pHash = sha256.convert(pPass);

        //Prepare hash for POST
        padecoded["password"] = pHash.toString();
        pJsonString = json.encode(padecoded);

        //update parent with new hashed pass
        http
            .post('https://braintrainapi.com/btapi/parents',
                headers: {"Content-Type": "application/json"},
                body: pJsonString)
            .then((response) {
          print("Response status: ${response.statusCode}");
          print("Response body: ${response.body}");
          print("Parent Update Complete");
          //Store salt related to parent w/ function
          print("updating salt...");
          updateParSalt(padecoded, padecoded["email"], pid, context);
        });
      } else {
        http
            .post('https://braintrainapi.com/btapi/parents',
                headers: {"Content-Type": "application/json"},
                body: pJsonString)
            .then((response) {
          notLoading();
          print("Response status: ${response.statusCode}");
          print("Response body: ${response.body}");
          print("Parent Update Complete");
          setState(() {
            if (profile.email != login.MyApp.pemail) {
              print("email changed");
              profile.email = newEmail;
            }
            if (profile.uname != login.MyApp.puname) {
              print("username changed");
              profile.uname = newUName;
            }
          });
          Navigator.pop(context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,

      //Logic to run loading screen
      body: loadCircle
          ? loadingScreen()
          : new Stack(fit: StackFit.expand, children: <Widget>[
              new Image(
                image: AssetImage("assets/newlogo2.png"),
                fit: BoxFit.cover,
                color: Colors.black87,
                colorBlendMode: BlendMode.difference,
              ),
              new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Text(
                      "Welcome, $uname. Please enter your new information below:",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 20),
                      textAlign: TextAlign.center),
                  new Form(
                    child: new Theme(
                      data: new ThemeData(
                          brightness: Brightness.dark,
                          primarySwatch: Colors.blue,
                          inputDecorationTheme: new InputDecorationTheme(
                              labelStyle: new TextStyle(
                            color: Colors.black87,
                            fontSize: 20.0,
                          ))),
                      child: new Container(
                        padding: const EdgeInsets.only(
                            top: 13, left: 40, bottom: 40, right: 40),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            new TextFormField(
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              decoration: new InputDecoration(
                                labelText: "Enter New Email",
                                hintText: email,
                              ),
                              keyboardType: TextInputType.text,
                              controller: emailController,
                            ),
                            new TextFormField(
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              decoration: new InputDecoration(
                                  labelText: "Enter New Username",
                                  hintText: uname),
                              keyboardType: TextInputType.text,
                              controller: unameController,
                            ),
                            new TextFormField(
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              decoration: new InputDecoration(
                                labelText: "Enter New Password",
                              ),
                              keyboardType: TextInputType.text,
                              obscureText: true,
                              controller: passController,
                            ),
                            new Padding(
                                padding: const EdgeInsets.only(top: 20.0)),
                            new MaterialButton(
                              color: Colors.blue,
                              textColor: Colors.white,
                              child: new Text("Update"),
                              onPressed: () {
                                String newem = '';
                                String newpas = '';
                                String newuname = '';

                                newem = emailController.text;
                                newpas = passController.text;
                                newuname = unameController.text;

                                updateAccount(newem, newuname, newpas,
                                    login.MyApp.pemail, context);
                              },
                              splashColor: Colors.redAccent,
                            ),
                            new MaterialButton(
                              color: Colors.blue,
                              textColor: Colors.white,
                              child: new Text("Back to Profile"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              splashColor: Colors.redAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ]),
    );
  }
}
