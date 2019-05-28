import 'package:flutter/material.dart';
import 'package:brain_train_official/profile.dart' as profile;

//get relevant user info
import 'package:brain_train_official/main.dart' as login;

// BT API related Imports
import 'package:http/http.dart' as http;
import 'dart:convert';

@override
Widget build(BuildContext context) {
  return new MaterialApp(
    home: new childEdit(),
    theme: new ThemeData(primarySwatch: Colors.indigo),
  );
}

class childEdit extends StatefulWidget {
  @override
  childEditState createState() {
    return new childEditState();
  }
}

class childEditState extends State<childEdit>
    with SingleTickerProviderStateMixin {
  //Initialize controllers
  final List<TextEditingController> cunameController =
      <TextEditingController>[];
  final List<TextEditingController> ageController = <TextEditingController>[];

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

    //fill named list controllers with TextEditingControllers for all kids info
    for (int i = 0; i < login.MyApp.cuname.length; i++) {
      cunameController.add(TextEditingController());
      ageController.add(TextEditingController());
    }
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
            margin: const EdgeInsets.only(top: 260.0),
            child: new Column(children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(left: 65),
                //color: Colors.cyan[50],
                child: new Image.asset("assets/animated-train-image-0031.gif"),
              ),
              new Text(
                'Updating Child Information',
                style: new TextStyle(color: Colors.white, fontSize: 25.0),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  //dynamic list widget, only as long as how many children there are
  Widget childrenList(
      List<String> childname, List<String> childage, context, sW, sH) {
    return new Row(children: <Widget>[
      new Container(
        width: sW,
        padding: EdgeInsets.only(top: 20, bottom: sH / 5),
        child: new ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: childname.length,
            itemBuilder: (context, int index) {
              return new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Text("${childname[index]}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 30),
                      textAlign: TextAlign.center),
                  new PhysicalModel(
                    shape: BoxShape.circle,
                    borderRadius: new BorderRadius.all(Radius.circular(15)),
                    child: new Icon(
                        const IconData(59389, fontFamily: 'MaterialIcons'),
                        size: 120),
                    color: Colors.grey,
                  ),
                  new Form(
                    child: new Theme(
                      data: new ThemeData(
                        brightness: Brightness.dark,
                        primarySwatch: Colors.blue,
                        inputDecorationTheme: new InputDecorationTheme(
                            labelStyle: new TextStyle(
                          color: Colors.black87,
                          fontSize: 20.0,
                        )),
                      ),
                      child: new Container(
                        padding: const EdgeInsets.only(
                            left: 40.0, top: 0, right: 40, bottom: 40),
                        child: new Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              new TextFormField(
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                decoration: new InputDecoration(
                                  labelText: "Enter New Username",
                                  hintText: childname[index],
                                ),
                                keyboardType: TextInputType.text,
                                controller: cunameController[index],
                              ),
                              new TextFormField(
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                decoration: new InputDecoration(
                                  labelText: "Enter New Age",
                                  hintText: childage[index],
                                ),
                                keyboardType: TextInputType.text,
                                controller: ageController[index],
                              ),
                            ]),
                      ),
                    ),
                  )
                ],
              );
            }),
      )
    ]);
  }

  //update child info of parents information
  void updateChildAccount(
      newChildAges, newChildUNames, oldChildUNames, context) async {
    loading();

    Map<String, dynamic> cs = {
      'email': "",
      'password': "",
      'uname': oldChildUNames,
      'salt': "",
      'Parent_id': "",
      "pD": "updatechild",
      "age": newChildAges,
      "cuname": newChildUNames,
      "tuname": ""
    };
    String cS = json.encode(cs);
    //print(cS);
    final response = await http.post('https://braintrainapi.com/btapi/parents',
        headers: {"Content-Type": "application/json"}, body: cS);
    if (response.statusCode == 200) {
      //print("Response status: ${response.statusCode}");
      //print("Response body: ${response.body}");
    } else {
      setState(() {
        for (int i = 0; i < cunameController.length; i++) {
          if (newChildUNames[i] != "") {
            profile.cuname[i] = newChildUNames[i];
          }
          if (newChildAges[i] != "") {
            profile.cage[i] = newChildAges[i];
          }
        }
        profile.activeChild = profile.cuname[0];
      });

      Navigator.pop(context);
      //print("Response status: ${response.statusCode}");
      //print("Response body: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

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
                childrenList(login.MyApp.cuname, login.MyApp.cage, context,
                    screenWidth, screenHeight),
                new Align(
                  alignment: Alignment(0, 0.75),
                  child: new MaterialButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: new Text("Update"),
                    onPressed: () {
                      List<String> newages = [];
                      List<String> newcunames = [];
                      List<String> changedUsers = [];
                      //logic for checking which child has been updated, and what of each child is updated
                      for (int i = 0; i < cunameController.length; i++) {
                        if (cunameController[i].text != "" &&
                            ageController[i].text == "") {
                          newages.add("");
                          newcunames.add(cunameController[i].text);
                          changedUsers.add(login.MyApp.cuname[i]);
                        } else if (cunameController[i].text != "" &&
                            ageController[i].text != "") {
                          newcunames.add(cunameController[i].text);
                          newages.add(ageController[i].text);
                          changedUsers.add(login.MyApp.cuname[i]);
                        } else if (cunameController[i].text == "" &&
                            ageController[i].text != "") {
                          newcunames.add("");
                          newages.add(ageController[i].text);
                          changedUsers.add(login.MyApp.cuname[i]);
                        } else {
                          newcunames.add("");
                          newages.add("");
                        }
                      }
                      updateChildAccount(
                          newages, newcunames, changedUsers, context);
                    },
                    splashColor: Colors.redAccent,
                  ),
                ),
                new Flex(direction: Axis.vertical, children: <Widget>[
                  new Expanded(
                    child: Align(
                      alignment: FractionalOffset.bottomCenter,
                      child: new MaterialButton(
                        color: Colors.blue,
                        textColor: Colors.white,
                        child: new Text("Back to Profile"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        splashColor: Colors.redAccent,
                      ),
                    ),
                  )
                ])
              ]));
  }
}
