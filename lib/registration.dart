//Authors: Kasean and Dirk
//DB related stuff,button logic,etc: Dirk

import 'package:flutter/material.dart';

// BT API related Imports
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      print("Registered Parent");
      String pJsonString = json.encode(parentJsonMap);
      regParent(pJsonString);
    }

    if(uclass != "" && uagegroup != "") {
      print("Registered Teacher");
      String tJsonString = json.encode(teacherJsonMap);
      regTeacher(tJsonString);
    }

  }

  regParent(String pJS) {

    //print(pJS);
    http.post('http://braintrainapi.com/bt_api/parents',headers: {"Content-Type":"application/json"}, body: pJS).then((response) {print("Response status: ${response.statusCode}"); print("Response body: ${response.body}");});

  }

  regTeacher(String tJS) {

    http.post('http://braintrainapi.com/bt_api/teachers',headers: {"Content-Type":"application/json"}, body: tJS).then((response) {print("Response status: ${response.statusCode}"); print("Response body: ${response.body}");});

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