//Authors: Kasean and Dirk
//DB related stuff,button logic,etc: Dirk

import 'package:flutter/material.dart';
import 'package:brain_train_official/title.dart';
import 'package:brain_train_official/registration.dart';

// BT API related Imports
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {

  //Futures
  final Future<Parents> parents;
  final Future<Teachers> teachers;
  MyApp({Key key, this.parents,this.teachers}) : super(key:key);

  //email for welcome on title page
  static String email;

  @override

  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new LoginPage(),
      theme: new ThemeData(
          primarySwatch: Colors.indigo),);
  }
}

//Parent object constructor for json data
class Parents {
  final int parent_id;
  final String email;
  final String password;
  final String username;

  Parents({
    this.parent_id,
    this.email,
    this.password,
    this.username
  });
}

//take raw json info from API and make new Parent object list
List<Parents> createParentsList(List data) {
  List<Parents> list = new List();
  for (int i = 0; i < data.length; i++) {

    Parents parent = new Parents(
        parent_id: data[i]["parent_id"],
        email: data[i]["email"],
        username: data[i]["username"],
        password: data[i]["password"]);
    list.add(parent);
  }
  return list;
}

//Teacher object constructor for json data
class Teachers {
  final int teacher_id;
  final String email;
  final String password;
  final String username;
  final int class_num;
  final String age_group;

  Teachers({
    this.teacher_id,
    this.email,
    this.password,
    this.username,
    this.class_num,
    this.age_group
  });
}

//take raw json info from API and make new Parent object list
List<Teachers> createTeachersList(List data) {
  List<Teachers> list = new List();
  for (int i = 0; i < data.length; i++) {

    Teachers teacher = new Teachers(
        teacher_id: data[i]["teacher_id"],
        email: data[i]["email"],
        username: data[i]["username"],
        password: data[i]["password"],
        age_group: data[i]["age_group"],
        class_num: data[i]["class_num"]);
    list.add(teacher);
  }
  return list;
}

class LoginPage extends StatefulWidget {
  @override
  State createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin{

  AnimationController iconAnimationController;
  Animation<double> iconAnimation;

  //Dirk's LoginPageState code
  bool loadCircle = false;
  int r = 1;
  bool loggedIn = false;

  final passController = TextEditingController();
  final emailController = TextEditingController();
  final ageController = TextEditingController();
  final classController = TextEditingController();

  //get the parent response from the BT REST API
  Future<List<Parents>> getParents() async
  {
    loading();
    final resp = await http.get('http://172.13.66.158/bt_api/parents');
    //If http.get is successful
    if (resp.statusCode == 200) {
      print("Request #$r");
      r++;
      print("Successful connection to BT API");
      notLoading();
      List btjson = json.decode(resp.body.toString());
      List<Parents> parentsList = createParentsList(btjson);
      return parentsList;
    }
    else {
      throw Exception('Failed to retrieve API data');
    }
  }

  //get the parent response from the BT REST API
  Future<List<Teachers>> getTeachers() async
  {
    loading();
    final resp = await http.get('http://172.13.66.158:80/bt_api/teachers');
    //If http.get is successful
    if (resp.statusCode == 200) {
      print("Request #$r");
      r++;
      print("Successful connection to BT API");
      notLoading();
      List btjson = json.decode(resp.body.toString());
      List<Teachers> teachersList = createTeachersList(btjson);
      return teachersList;
    }
    else {
      throw Exception('Failed to retrieve API data');
    }
  }

  void getAuth(String email, String pass) async {
    final parent = await getParents();
    final teacher = await getTeachers();

    checkParentLogin(parent, email, pass);
    checkTeacherLogin(teacher, email, pass);

  }

  void checkParentLogin(List<Parents> parentJsonData, String pe, String pp) {
    var tot_par = parentJsonData.length;

    List<String> pelist = new List();
    List<String> pplist = new List();
    for(int i = 0; i < tot_par; i++) {
      pelist.add(parentJsonData[i].email);
      pplist.add(parentJsonData[i].password);
    }

    //Testing purposes below
    /*
    print(pelist);
    print(pplist);
    print(pe);
    print(pp);
    */

    for(int i = 0; i < pelist.length; i++) {
      if(pe == pelist[i] && pp == pplist[i]) {
        print("Valid Parent Email and Password");
        loggedIn = true;
        MyApp.email = pe;
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => MyHomePage(title: 'Shape matching game')),);
        return;
      }
      else {
        print("Invalid Parent Email and/or Password");
      }
    }
  }

  void checkTeacherLogin(List<Teachers> teacherJsonData, String te, String tp) {
    var tot_par = teacherJsonData.length;

    List<String> telist = new List();
    List<String> tplist = new List();
    for(int i = 0; i < tot_par; i++) {
      telist.add(teacherJsonData[i].email);
      tplist.add(teacherJsonData[i].password);
    }

    //Testing purposes below

    /*
    print(telist);
    print(tplist);
    print(te);
    print(tp);
    */

    for(int i = 0; i < telist.length; i++) {
      if(te == telist[i] && tp == tplist[i]) {
        print("Valid Teacher Email and Password");
        loggedIn = true;
        MyApp.email = te;
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => MyHomePage(title: 'Shape matching game')),);
        return;
      }
      else {
        print("Invalid Teacher Email and/or Password");
      }
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
        margin: const EdgeInsets.only(top: 320.0),
        child: new Center(
            child: new Column(
              children: <Widget>[
                new CircularProgressIndicator(
                  strokeWidth: 10.0,
                  backgroundColor: Colors.blue,
                ),
                new Container(
                  padding: const EdgeInsets.all(8.0),
                  child: new Text(
                    'Logging In',
                    style: new TextStyle(
                        color: Colors.white,
                        fontSize: 40.0
                    ),
                  ),
                ),
              ],
            )
        )
    );
  }

  //End of this sections Dirks code

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

      body:  loadCircle ? loadingScreen() :
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
                      padding: const EdgeInsets.all(40.0),
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
                          new Padding(
                              padding: const EdgeInsets.only(
                                  top: 20.0)
                          ),
                          new MaterialButton(
                            color: Colors.blue,
                            textColor: Colors.white,
                            child: new Text("Login"),
                            onPressed: () {
                              String em = emailController.text;
                              String pas = passController.text;

                              getAuth(em, pas);
                            },
                            splashColor: Colors.redAccent,
                          ),
                          new MaterialButton(
                            color: Colors.blue,
                            textColor: Colors.white,
                            child: new Text("Register New Account"),
                            onPressed: () {

                              Navigator.push(context,
                                MaterialPageRoute(builder: (context) => RegistrationPage()),);
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