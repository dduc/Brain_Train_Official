//Authors: Kasean and Dirk
//DB related stuff,button logic,design,etc: Dirk

import 'package:flutter/material.dart';

// BT API related Imports
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:random_string/random_string.dart' as rnd;

//reg related checks
import 'package:brain_train_official/main.dart' as checkDB;

  @override

  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new RegistrationPage(),
      theme: new ThemeData(
          primarySwatch: Colors.indigo),);
  }

class RegistrationPage extends StatefulWidget {
  @override
  State createState() => new RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> with SingleTickerProviderStateMixin{

  AnimationController iconAnimationController;
  Animation<double> iconAnimation;

  //********** Dirk's part of code *************//
  final passController = TextEditingController();
  final emailController = TextEditingController();
  final userController = TextEditingController();
  final ageController = TextEditingController();
  final cAgeController = TextEditingController();
  final classController = TextEditingController();

  regUser(String uemail, String upass, String uname, String uclass, String uagegroup, String ca) {
    Map<String,dynamic> parentJsonMap = {
      'email' : uemail,
      'password' : upass,
      'uname': uname,
      'salt': "",
      'Parent_id':"",
      "pD":""
    };

    Map<String,dynamic> teacherJsonMap = {
      'email' : uemail,
      'password' : upass,
      'uname' : uname,
      'class_num' : uclass,
      'age_group' : uagegroup,
      'salt': "",
      'Teacher_id': "",
      "tD":""
    };

    Map<String,dynamic> playerJsonMap = {
    'age':ca
    };

    if(uclass == "" && uagegroup == "") {
      print("Registering Parent w/ player...");
      String pJsonString = json.encode(parentJsonMap);
      String plJsonString = json.encode(playerJsonMap);
      regParent(pJsonString,plJsonString);
    }

    if(uclass != "" && uagegroup != "") {
      print("Registering Teacher...");
      String tJsonString = json.encode(teacherJsonMap);
      regTeacher(tJsonString);
    }

  }

  void regParent(String pJS,String plJS) async {
    int r = 1;
    final resp = await http.get('https://braintrainapi.com/btapi/parents');
    //If http.get is successful
    if (resp.statusCode == 200) {
      print("Request #$r");
      r++;
      print("Successful connection to BT API");
      List btjson = json.decode(resp.body.toString());
      List<checkDB.Parents> parsList = checkDB.createParentsList(btjson);
      var tot_par = parsList.length;

      //Registration logic
      Map decoded = jsonDecode(pJS);
      for (int i = 0; i < tot_par; i++) {
        if (parsList[i].email == decoded["email"]) {
          print("Parent email already exists,registration incomplete");
          //put prompt here for email already exists
          return;
        }
        if (parsList[i].username != '' && parsList[i].username == decoded["uname"]) {
          print("Parent username already exists,registration incomplete");
          //put prompt here for username already exists
          return;
        }
      }

      //BELOW: hash and salt logic for insertion to DB
      int pid;
      String pSalt;

      //salt creation
      pSalt = rnd.randomAlphaNumeric(32);
      decoded["salt"] = pSalt;

      //Hashing function: SHA 256 + 32 byte salt, will make more robust in future
      var pPass = utf8.encode(decoded["password"] + pSalt);
      var pHash = sha256.convert(pPass);

      //Prepare hash for POST
      decoded["password"] = pHash.toString();
      pJS = json.encode(decoded);

      //print(pJS);
      //register user with hashed pass
      http.post('https://braintrainapi.com/btapi/parents',
          headers: {"Content-Type": "application/json"}, body: pJS).then((
          response) {
        //print("Response status: ${response.statusCode}");
        //print("Response body: ${response.body}");
        print("Registration Complete");
        //Store salt related to parent w/ function
        print("storing salt...");
        parSalt(decoded, decoded["email"], pid);
      });

      //register player for parent, and also insert age
      //http.post('https://braintrainapi.com/btapi/players',
          //headers: {"Content-Type": "application/json"}, body: plJS).then((
          //response) {
        //print("Response status: ${response.statusCode}");
        //print("Response body: ${response.body}");
        //print("Player Creation Complete");
      //});
    }
    else
      print("Unsuccessful connection to BT API, please contact web server admin");
  }

  void parSalt(Map dec, String d, int pid) async {

    final resp2 = await http.get('https://braintrainapi.com/btapi/parents');
    //If http.get is successful
    if (resp2.statusCode == 200) {
      List btjson2 = json.decode(resp2.body.toString());
      List<checkDB.Parents> parsList2 = checkDB.createParentsList(btjson2);
      var tot_par2 = parsList2.length;

      String pidSalt = json.encode(dec);
      for (int i = 0; i < tot_par2; i++) {
        //find just created email, may make logic diff here eventually
        if (parsList2[i].email == d) {
          pid = parsList2[i].parent_id;
          //put parent id in DB for ref to salt
          dec["Parent_id"] = pid;
          pidSalt = json.encode(dec);
          //print(pidSalt);

          //store salt associated with registered parent using POST
          http.post('https://braintrainapi.com/btapi/parents',
              headers: {"Content-Type": "application/json"}, body: pidSalt)
              .then((response) {
            print("Storing of salt w/ PID complete");
            //print("Response status: ${response.statusCode}");
            //print("Response body: ${response.body}");
          });
          return;
        }
      }
    }
    else
      print("Unsuccessful connection to BT API, please contact web server admin");
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
        //print(parsList[i].email);
        //print(decoded["email"]);
        if (teachersList[i].email == decoded["email"]) {
          print("Teacher email already exists,registration incomplete");
          return;
        }
        if (teachersList[i].username == decoded["uname"]) {
          print("Teacher username already exists,registration incomplete");
          return;
        }
      }

      //BELOW: hash and salt logic for insertion to DB
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

      http.post('https://braintrainapi.com/btapi/teachers',
          headers: {"Content-Type": "application/json"}, body: tJS).then
        ((response) {
        //print("Response status: ${response.statusCode}");
        //print("Response body: ${response.body}");
        print("storing salt...");
        teachSalt(decoded, decoded["email"], tid);
      });
    }
    else
      print("Unsuccessful connection to BT API, please contact web server admin");
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
          //print(tidSalt);

          //store salt associated with registered teacher using POST
          http.post('https://braintrainapi.com/btapi/teachers',
              headers: {"Content-Type": "application/json"}, body: tidSalt)
              .then((response) {
            print("Storing of salt w/ TID complete");
            //print("Response status: ${response.statusCode}");
            //print("Response body: ${response.body}");
          });
          return;
        }
      }
    }
    else
      print("Unsuccessful connection to BT API, please contact web server admin");
  }

  @override
  void initState(){
    super.initState();
    iconAnimationController = new AnimationController(
        vsync: this,
        duration: new Duration(milliseconds: 300)
    );
    iconAnimation = new CurvedAnimation(
        parent: iconAnimationController,
        curve: Curves.easeOut
    );
    iconAnimation.addListener(()=> this.setState((){}));
    iconAnimationController.forward();
  }
  //************End of most of Dirks code *************//

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      backgroundColor: Colors.deepOrange,
      //Logic to run loading screen
      body :
      new Stack(
          fit: StackFit.expand,
          children: <Widget>[
            new Image(
              image: AssetImage("assets/login_image.png"),
              fit: BoxFit.cover,
              color: Colors.black87,
              colorBlendMode: BlendMode.difference,
            ),
            new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Form(
                  child: new Theme(
                    data: new ThemeData(
                        brightness: Brightness.dark,
                        primarySwatch: Colors.blue,
                        inputDecorationTheme: new InputDecorationTheme(
                            labelStyle: new TextStyle(
                              color: Colors.black87,
                              fontSize: 15.0,
                            )
                        )
                    ),
                    child: new Container(
                      padding: const EdgeInsets.only(left: 40.0, top: 90, right: 40),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          new TextFormField(
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            decoration: new InputDecoration(
                              labelText: "Enter Email",
                            ),
                            keyboardType: TextInputType.emailAddress,
                            controller: emailController,
                          ),
                          new TextFormField(
                            style: TextStyle(
                                color: Colors.black
                            ),
                            decoration: new InputDecoration(
                              labelText: "Enter Password",
                            ),
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            controller: passController,
                          ),
                          new TextFormField(
                            style: TextStyle(
                                color: Colors.black
                            ),
                            decoration: new InputDecoration(
                              labelText: "Enter Username",
                            ),
                            keyboardType: TextInputType.text,
                            controller: userController,
                          ),
                          new TextFormField(
                            style: TextStyle(
                                color: Colors.black
                            ),
                            decoration: new InputDecoration(
                              labelText: "Enter Child's Age (Parents,optional)",
                            ),
                            keyboardType: TextInputType.text,
                            controller: cAgeController,
                          ),
                          new TextFormField(
                            style: TextStyle(
                                color: Colors.black
                            ),
                            decoration: new InputDecoration(
                              labelText: "Enter Class Number (Teachers)",
                            ),
                            keyboardType: TextInputType.text,
                            controller: classController,
                          ),
                          new TextFormField(
                            style: TextStyle(
                                color: Colors.black
                            ),
                            decoration: new InputDecoration(
                              labelText: "Enter Age Group (Teachers)",
                            ),
                            keyboardType: TextInputType.text,
                            controller: ageController,
                          ),
                          new Padding(
                              padding: const EdgeInsets.only(
                                  top: 20.0)
                          ),
                          new MaterialButton(
                            color: Colors.blue,
                            textColor: Colors.white,
                            child: new Text("Submit"),
                            onPressed: () {
                              String ema = emailController.text;
                              String pass = passController.text;
                              String clas = classController.text;
                              String ag = ageController.text;
                              String cag = cAgeController.text;
                              String un = userController.text;

                              regUser(ema,pass,un,clas,ag,cag);
                              },
                            splashColor: Colors.redAccent,
                          ),
                          new MaterialButton(
                            color: Colors.blue,
                            textColor: Colors.white,
                            child: new Text("Back to Login"),
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