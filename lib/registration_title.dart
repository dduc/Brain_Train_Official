//Authors: Dirk
//Redirection for registration (better flow)

import 'package:flutter/material.dart';
import 'package:brain_train_official/registration_parents.dart';
import 'package:brain_train_official/registration_teachers.dart';

@override

Widget build(BuildContext context) {
  return new MaterialApp(
    home: new RegistrationTitlePage(),
    theme: new ThemeData(
        primarySwatch: Colors.indigo),);
}

class RegistrationTitlePage extends StatefulWidget {
  @override
  State createState() => new RegistrationTitlePageState();
}
class RegistrationTitlePageState extends State<RegistrationTitlePage> with SingleTickerProviderStateMixin{

  @override
  Widget build(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

    // TODO: implement build
    return new Scaffold(
      backgroundColor: Colors.deepOrange,
      //Logic to run loading screen
      body:
      new Stack(
          fit: StackFit.expand,
          children: <Widget>[
            new Image(
              image: AssetImage("assets/newlogo.png"),
              fit: BoxFit.cover,
              color: Colors.black87,
              colorBlendMode: BlendMode.difference,
            ),
              //mainAxisAlignment: MainAxisAlignment.center,
                new Form(
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new SizedBox(height: 100),
                          new MaterialButton(
                            minWidth: screenWidth/1.5,
                            height: screenHeight/5,
                            color: Colors.blue,
                            textColor: Colors.white,
                            child: new Text("Parents",textScaleFactor: 2),
                          onPressed: () {
                            Navigator.push(context,
                            MaterialPageRoute(builder: (context) => RegistrationParentsPage()),);
                            },
                            splashColor: Colors.redAccent,
                          ),
                          new Padding(
                              padding: const EdgeInsets.only(
                                  top: 25.0)
                          ),
                          new MaterialButton(
                            minWidth: screenWidth/1.5,
                            height: screenHeight/5,
                            color: Colors.green,
                            textColor: Colors.white,
                            child: new Text("Teachers",textScaleFactor: 2),
                            onPressed: () {
                              Navigator.push(context,
                                MaterialPageRoute(builder: (context) => RegistrationTeachersPage()),);
                            },
                            splashColor: Colors.redAccent,
                          ),
                        ],
                  ),
                ),
                new Form (
              child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new MaterialButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: new Text("Back to Login"),
                    onPressed: () {

                      Navigator.pop(context);

                    },
                      splashColor: Colors.redAccent,
                    ),
                    new Padding(
                        padding: const EdgeInsets.only(
                            bottom: 25.0)
                    )
                ]
              )
            ),

          ]),
    );
  }
}