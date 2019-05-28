import 'package:flutter/material.dart';

// BT API related Imports
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:random_string/random_string.dart' as rnd;

//reg related checks and function calls
import 'package:brain_train_official/main.dart' as checkDB;

@override
Widget build(BuildContext context) {
  return new MaterialApp(
    home: new RegistrationTeachersPage(),
    theme: new ThemeData(primarySwatch: Colors.indigo),
  );
}

class RegistrationTeachersPage extends StatefulWidget {
  @override
  State createState() => new RegistrationTeachersPageState();
}

class RegistrationTeachersPageState extends State<RegistrationTeachersPage>
    with SingleTickerProviderStateMixin {

  bool loadCircle = false;

  final passController = TextEditingController();
  final emailController = TextEditingController();
  final userController = TextEditingController();
  final cAgeController = TextEditingController();
  final classController = TextEditingController();

  regUser(String uemail, String upass, String uname, String uclass,
      String uagegroup) {
    loading();
    Map<String, dynamic> teacherJsonMap = {
      'email': uemail,
      'password': upass,
      'uname': uname,
      'class_num': uclass,
      'age_group': uagegroup,
      'salt': "",
      'Teacher_id': "",
      "tD": ""
    };

    print("Registering Teacher...");
    String tJsonString = json.encode(teacherJsonMap);
    regTeacher(tJsonString);
  }

  void regTeacher(String tJS) async {
    int r = 1;
    final resp = await http.get('https://braintrainapi.com/btapi/teachers');
    //If http.get is successful
    if (resp.statusCode == 200) {
      print("Request #$r");
      r++;
      print("Successful connection to BT API");
      List btjson = json.decode(resp.body.toString());
      List<checkDB.Teachers> teachersList = checkDB.createTeachersList(btjson);
      var tot_par = teachersList.length;

      Map decoded = jsonDecode(tJS);
      for (int i = 0; i < tot_par; i++) {
        if (teachersList[i].email == decoded["email"]) {
          print("Teacher email already exists,registration incomplete");
          notLoading();
          return;
        }
        if (teachersList[i].username == decoded["uname"]) {
          print("Teacher username already exists,registration incomplete");
          notLoading();
          return;
        }
      }

      //hash and salt logic for insertion to DB
      int tid;
      String tSalt;

      //salt creation
      tSalt = rnd.randomAlphaNumeric(32);
      decoded["salt"] = tSalt;

      //Hashing function: SHA 256 + 32 byte salt, will make more robust in future
      var tPass = utf8.encode(decoded["password"] + tSalt);
      var tHash = sha256.convert(tPass);

      //Prepare hash for POST
      decoded["password"] = tHash.toString();
      tJS = json.encode(decoded);

      http
          .post('https://braintrainapi.com/btapi/teachers',
              headers: {"Content-Type": "application/json"}, body: tJS)
          .then((response) {
        //print("Response status: ${response.statusCode}");
        //print("Response body: ${response.body}");
        print("storing salt...");
        teachSalt(decoded, decoded["email"], tid);
      });
    } else {
      print(
          "Unsuccessful connection to BT API, please contact web server admin");
      notLoading();
    }
  }

  void teachSalt(Map dec, String d, int tid) async {
    final resp = await http.get('https://braintrainapi.com/btapi/teachers');
    //If http.get is successful
    if (resp.statusCode == 200) {
      List btjson = json.decode(resp.body.toString());
      List<checkDB.Teachers> teachList = checkDB.createTeachersList(btjson);
      var tot_par2 = teachList.length;

      String tidSalt = json.encode(dec);
      for (int i = 0; i < tot_par2; i++) {
        //find just created email, may make logic diff here eventually
        if (teachList[i].email == d) {
          tid = teachList[i].teacher_id;
          //put teacher id in DB for ref to salt
          dec["Teacher_id"] = tid;
          tidSalt = json.encode(dec);

          //store salt associated with registered teacher using POST
          http
              .post('https://braintrainapi.com/btapi/teachers',
                  headers: {"Content-Type": "application/json"}, body: tidSalt)
              .then((response) {
            print("Storing of salt w/ TID complete");
            //print("Response status: ${response.statusCode}");
            //print("Response body: ${response.body}");
            notLoading();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => checkDB.LoginPage()),
            );
            return;
          });
        }
      }
    } else {
      print(
          "Unsuccessful connection to BT API, please contact web server admin");
      checkDB.LoginPageState().notLoading();
    }
  }

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

  Widget loadingScreen() {
    return new Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: ExactAssetImage("assets/newlogo.png"), fit: BoxFit.cover),
      ),
      child: new Center(
        child: new Column(children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(top: 280.0),
            child: new Column(children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(left: 65),
                child: new Image.asset("assets/animated-train-image-0031.gif"),
              ),
              new Text(
                'Logging in',
                style: new TextStyle(color: Colors.white, fontSize: 35.0),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
              new ListView(
                children: <Widget>[
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
                            left: 40.0, top: 100, right: 40),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            new TextFormField(
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              decoration: new InputDecoration(
                                labelText: "Enter Email",
                              ),
                              keyboardType: TextInputType.emailAddress,
                              controller: emailController,
                            ),
                            new TextFormField(
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              decoration: new InputDecoration(
                                labelText: "Enter Password",
                              ),
                              keyboardType: TextInputType.text,
                              obscureText: true,
                              controller: passController,
                            ),
                            new TextFormField(
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              decoration: new InputDecoration(
                                labelText: "Enter Username",
                              ),
                              keyboardType: TextInputType.text,
                              controller: userController,
                            ),
                            new TextFormField(
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              decoration: new InputDecoration(
                                labelText: "Enter Class Number",
                              ),
                              keyboardType: TextInputType.text,
                              controller: classController,
                            ),
                            new TextFormField(
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              decoration: new InputDecoration(
                                labelText: "Enter Age Group",
                              ),
                              keyboardType: TextInputType.text,
                              controller: cAgeController,
                            ),
                            new Padding(
                                padding: const EdgeInsets.only(top: 20.0)),
                            new MaterialButton(
                              color: Colors.blue,
                              textColor: Colors.white,
                              child: new Text("Submit"),
                              onPressed: () {
                                String ema = emailController.text;
                                String pass = passController.text;
                                String unp = userController.text;
                                String clas = classController.text;
                                String cag = cAgeController.text;

                                regUser(ema, pass, unp, clas, cag);
                              },
                              splashColor: Colors.redAccent,
                            ),
                            new MaterialButton(
                              color: Colors.blue,
                              textColor: Colors.white,
                              child: new Text("Back to Login"),
                              onPressed: () {
                                Navigator.pop(context);
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
