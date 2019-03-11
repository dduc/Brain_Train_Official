//Authors: Kasean and Dirk
//DB related stuff,button logic,design,etc: Dirk

import 'package:flutter/material.dart';

// BT API related Imports
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  final passController = TextEditingController();
  final emailController = TextEditingController();
  final ageController = TextEditingController();
  final classController = TextEditingController();

  regUser(String uemail, String upass, String uclass, String uagegroup) {
    Map<String,dynamic> parentJsonMap = {
      'email' : uemail,
      'password' : upass,
    };
    Map<String,dynamic> teacherJsonMap = {
      'email' : uemail,
      'password' : upass,
      'class_num' : uclass,
      'age_group' : uagegroup
    };

    if(uclass == "" && uagegroup == "") {
      print("Registering Parent...");
      String pJsonString = json.encode(parentJsonMap);
      regParent(pJsonString);
    }

    if(uclass != "" && uagegroup != "") {
      print("Registering Teacher...");
      String tJsonString = json.encode(teacherJsonMap);
      regTeacher(tJsonString);
    }

  }

  void regParent(String pJS) async {
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

      Map decoded = jsonDecode(pJS);
      for (int i = 0; i < tot_par; i++) {
        //print(parsList[i].email);
        //print(decoded["email"]);
        if(parsList[i].email == decoded["email"]) {
          print("Parent email already exists,registration incomplete");
          return;
        }
      }

      //print(pJS);
      http.post('https://braintrainapi.com/btapi/parents',
          headers: {"Content-Type": "application/json"}, body: pJS).then((
          response) {
        //print("Response status: ${response.statusCode}");
        //print("Response body: ${response.body}");
        print("Registration Complete");
      });
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
      }

      http.post('https://braintrainapi.com/btapi/teachers',
          headers: {"Content-Type": "application/json"}, body: tJS).then
        ((response) {
        print("Response status: ${response.statusCode}");
        print("Response body: ${response.body}");
      });
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
                              fontSize: 20.0,
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
                              color: Colors.black
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
                              labelText: "Enter Class Number (Teachers)",
                            ),
                            keyboardType: TextInputType.text,
                            controller: classController,
                            obscureText: false,
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
                            obscureText: false,
                          ),
                          new Padding(
                              padding: const EdgeInsets.only(
                                  top: 20.0)
                          ),
                          new MaterialButton(
                            color: Colors.blue,
                            textColor: Colors.white,
                            child: new Text("Register"),
                            onPressed: () {
                              String ema = emailController.text;
                              String pass = passController.text;
                              String clas = classController.text;
                              String ag = ageController.text;

                              regUser(ema,pass,clas,ag);
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