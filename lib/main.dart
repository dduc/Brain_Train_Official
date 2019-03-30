//Authors: Kasean and Dirk
//DB related stuff,button logic,design,etc: Dirk

import 'package:flutter/material.dart';
import 'package:brain_train_official/title.dart';
import 'package:brain_train_official/registration.dart';

// BT API related Imports
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';

//DB imports
import 'package:postgres/postgres.dart' as pg;

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

//********** Dirk's part of code *************//
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

class LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {

  AnimationController iconAnimationController;
  Animation<double> iconAnimation;

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
    final resp = await http.get('https://braintrainapi.com/btapi/parents');
    //If http.get is successful
    if (resp.statusCode == 200) {
      print("Request #$r");
      r++;
      print("Successful connection to parents endpoint in BT API");
      List btjson = json.decode(resp.body.toString());

      if (btjson.isEmpty) {
        print('No parent API data');
        return List<Parents>();
      }
      List<Parents> parentsList = createParentsList(btjson);
      return parentsList;
    }
    else {
      throw Exception('Failed to retrieve API data');
    }
  }

  Future<List<Teachers>> getTeachers() async
  {
    loading();
    final resp = await http.get('https://braintrainapi.com/btapi/teachers');
    //If http.get is successful
    if (resp.statusCode == 200) {
      print("Request #$r");
      r++;
      print("Successful connection to teachers endpoint in BT API");
      List btjson = json.decode(resp.body.toString());
      if (btjson.isEmpty) {
        print('No teacher API data');
        return List<Teachers>();
      }

      List<Teachers> teachersList = createTeachersList(btjson);
      return teachersList;
    }
    else {
      throw Exception('Failed to retrieve API data');
    }
  }


  Future<String> checkPS(String pe) async {
    var connection = new pg.PostgreSQLConnection(
        "braintrainapi.com", 5432, "BrainTrain_App_WS", username: "postgres",
        password: "Gka\$&@45!?hal");
    await connection.open();

    List<List<dynamic>> pid = await connection.query(
        "SELECT parent_id from \"BT_App_WS\".parent where email = @email",
        substitutionValues: {"email": pe});
    //print(pid[0][0]);
    int pD = int.parse(pid[0][0].toString());
    //print(pD);

    List<Parents> plist = await getParents();
    for (int i = 0; i < plist.length; i++) {
      if (plist[i].parent_id == pD) {
        print("Found pID associated with salt! Retrieving Salt...");
        List<dynamic> salt = await connection.query(
            "SELECT salt from \"BT_App_WS\".s_parent where \"Parent_id\" = " +
                plist[i].parent_id.toString() + ";");
        //print(salt[0][0].toString());
        return salt[0][0].toString();
      }
    }
    connection.close();
  }

  Future<String> checkTS(String te) async {
    var connection = new pg.PostgreSQLConnection(
        "braintrainapi.com", 5432, "BrainTrain_App_WS", username: "postgres",
        password: "Gka\$&@45!?hal");
    await connection.open();

    List<List<dynamic>> tid = await connection.query(
        "SELECT teacher_id from \"BT_App_WS\".teacher where email = @email",
        substitutionValues: {"email": te});

    //print(tid[0][0]);
    int tD = int.parse(tid[0][0].toString());
    //print(tD);
    List<Teachers> tlist = await getTeachers();
    for (int i = 0; i < tlist.length; i++) {
      if (tlist[i].teacher_id == tD) {
        print("Found tID associated with salt! Retrieving Salt...");
        List<dynamic> salt = await connection.query(
            "SELECT salt from \"BT_App_WS\".s_teacher where \"Teacher_id\" = " +
                tlist[i].teacher_id.toString() + ";");
        //print(salt[0][0].toString());
        return salt[0][0].toString();
      }
    }
    connection.close();
  }

  void getAuth(String email, String pass) async {

    final parent = await getParents();
    final teacher = await getTeachers();

    if(parent.isNotEmpty) {
      checkParentLogin(parent, email, pass);
    }
    if(teacher.isNotEmpty) {
      checkTeacherLogin(teacher, email, pass);
    }
  }

  void checkParentLogin(List<Parents> parentJsonData, String pe, String pp) {
    var tot_par = parentJsonData.length;

    List<String> pelist = new List();
    List<String> pplist = new List();

    for (int i = 0; i < tot_par; i++) {
      pelist.add(parentJsonData[i].email);
      pplist.add(parentJsonData[i].password);
    }

    //stop checking if email isn't a parent email
    for(int i = 0; i < tot_par; i++) {
      if(pe == parentJsonData[i].email) {
        break;
      }
      else {
        print('Email not found in parents');
        return;
      }
    }

    Future <String> ps = checkPS(pe);
    ps.then((String pSalt) {

      //encode,hash,and salt pass for comparison
      var pPass = utf8.encode(pp + pSalt);
      var pHash = sha256.convert(pPass);
      pp = pHash.toString();

      for (int i = 0; i < pelist.length; i++) {
        if (pe == pelist[i] && pp == pplist[i]) {
          print("Valid Parent Email and Password");
          loggedIn = true;
          MyApp.email = pe;
          notLoading();
          Navigator.push(context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(title: 'Shape matching game')),);
          return;
        }
        else {
          print("Invalid Parent Email and/or Password");
          notLoading();
        }
      }
    });
  }

  void checkTeacherLogin(List<Teachers> teacherJsonData, String te, String tp) {
    var tot_par = teacherJsonData.length;

    List<String> telist = new List();
    List<String> tplist = new List();
    for(int i = 0; i < tot_par; i++) {
      telist.add(teacherJsonData[i].email);
      tplist.add(teacherJsonData[i].password);
    }


    //stop checking if email isn't a teacher email
    for(int i = 0; i < tot_par; i++) {
      if(te != teacherJsonData[i].email) {
        return;
      }
    }

    Future <String> ts = checkTS(te);
    ts.then((String tSalt) {

      //encode,hash,and salt pass for comparison
      var tPass = utf8.encode(tp + tSalt);
      var tHash = sha256.convert(tPass);
      tp = tHash.toString();

      for (int i = 0; i < telist.length; i++) {
        if (te == telist[i] && tp == tplist[i]) {
          print("Valid Teacher Email and Password");
          loggedIn = true;
          MyApp.email = te;
          notLoading();
          Navigator.push(context,
            MaterialPageRoute(builder: (context) =>
                MyHomePage(title: 'Shape matching game')),);
          return;
        }
        else {
          print("Invalid Teacher Email and/or Password");
          notLoading();
        }
      }
    });
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

  //************End of most of Dirks code *************//

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
                            keyboardType: TextInputType.text,
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
                            child: new Text("Create Account"),
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