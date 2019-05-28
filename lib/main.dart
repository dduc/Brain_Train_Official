//Authors: Kasean and Dirk
//DB related items,button logic,design,etc: Dirk

import 'package:flutter/material.dart';
import 'package:brain_train_official/title.dart';
import 'package:brain_train_official/registration_title.dart';

//BT API related imports
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

//get functions from reg_par for players
import 'package:brain_train_official/registration_parents.dart' as reg;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {

  //********** Dirk's part of code *************//
  //Futures
  final Future<Parents> parents;
  final Future<Teachers> teachers;
  MyApp({Key key, this.parents,this.teachers}) : super(key:key);

  //init all parent user info for later app use
  static String pemail = '';
  static String puname = '';
  static List<String> cuname = [];
  static List<String> cage = [];
  static List<String> cid = [];
  static String pid;

  //init all teacher user info for later app use
  static String temail = '';
  static String tuname = '';
  static String tagegroup = '';
  static String tclassnum = '';
  static List<String> tcuname = [];
  static List<String> tcage = [];
  static List<String> tcid = [];
  static String tid;


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

//get the parent response from the BT REST API
Future<List<Parents>> getParents() async
{
  try {
    final resp = await http.get('https://braintrainapi.com/btapi/parents');
    //If http.get is successful
    if (resp.statusCode == 200) {
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
  on SocketException catch (e) {
    print(e);
    //return empty list for error logic
    return List<Parents>();
  }
}

//get associated parent salt
Future<String> checkPS(String pe,List<Parents> pJM) async {
  for (int i = 0; i < pJM.length; i++) {
    if (pJM[i].email == pe) {
      print("Found parent email associated with salt! Retrieving Salt...");
      Map<String, dynamic> ps = {
        'email': "",
        'password': "",
        'uname': "",
        'salt': "",
        'Parent_id': "",
        "pD": pJM[i].parent_id.toString(),
        "age":"",
        "cuname":"",
        "tuname":""
      };
      String pS = json.encode(ps);

      final response = await http.post('https://braintrainapi.com/btapi/parents',
          headers: {"Content-Type": "application/json"}, body: pS);
      print("Parent salt retrieved, returning salt");
      //print("Response status: ${response.statusCode}");
      //print("Response body: ${response.body}");
      return response.body;
    }
  }
  //if email isn't found
  return "";
}

//get the player response from the BT API
Future<List<reg.Players>> getPlayers() async
{
  try {
    final resp = await http.get('https://braintrainapi.com/btapi/players');
    //If http.get is successful
    if (resp.statusCode == 200) {
      print("Successful connection to players endpoint in BT API");
      List btjson = json.decode(resp.body.toString());

      if (btjson.isEmpty) {
        print('No parent API data');
        return List<reg.Players>();
      }
      List<reg.Players> playersList = reg.createPlayersList(btjson);
      return playersList;
    }
    else {
      throw Exception('Failed to retrieve API data');
    }
  }
  on SocketException catch (e) {
    print(e);
    return List<reg.Players>();
  }
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

//take raw json info from API and make new Teacher object list
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

Future<List<Teachers>> getTeachers() async
{
  try {
    final resp = await http.get('https://braintrainapi.com/btapi/teachers');
    //If http.get is successful
    if (resp.statusCode == 200) {
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
  on SocketException catch (e) {
    print(e);
    return List<Teachers>();
  }
}

Future<String> checkTS(String te,List<Teachers> tJM) async {
  for (int i = 0; i < tJM.length; i++) {
    if (tJM[i].email == te) {

      print("Found teacher email associated with salt! Retrieving Salt...");
      Map<String, dynamic> ts = {
        'email' : "",
        'password' : "",
        'uname' : "",
        'class_num' : "",
        'age_group' : "",
        'salt': "",
        'Teacher_id': "",
        "tD": tJM[i].teacher_id.toString()
      };
      String tS = json.encode(ts);

      final response = await http.post('https://braintrainapi.com/btapi/teachers',
          headers: {"Content-Type": "application/json"}, body: tS);
      print("Teacher salt retrieved, returning salt");
      //print("Response status: ${response.statusCode}");
      //print("Response body: ${response.body}");
      return response.body;
    }
  }
  return "";
}


class LoginPage extends StatefulWidget {
  @override
  State createState() => new LoginPageState();
}

class LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {



  bool loadCircle = false;

  final passController = TextEditingController();
  final emailController = TextEditingController();
  final ageController = TextEditingController();
  final classController = TextEditingController();

  //authenticate user login info
  void getAuth(String email, String pass) async {

    loading();
    final parent = await getParents();
    final teacher = await getTeachers();

    if (parent.isEmpty) {
      print("Cant access parent API endpoint");
      notLoading();
      return;
    }

    if (teacher.isEmpty) {
      print("Cant access teacher API endpoint");
      notLoading();
      return;
    }

    if(parent.isNotEmpty) {
      String parentCheck = await checkParentLogin(parent, email, pass);
        //if email isnt parent, check teacher
        if (parentCheck == "") {
          if (teacher.isNotEmpty) {
            String teacherCheck = await checkTeacherLogin(teacher, email, pass);
            //email isn't in database
            if(teacherCheck == "") {
              print("Cant find parent/teacher email");
              notLoading();
            }
          }
        }
    }
  }

  Future<String> checkParentLogin(List<Parents> parentJsonData, String pe, String pp) {
    var tot_par = parentJsonData.length;

    List<String> pelist = new List();
    List<String> pplist = new List();

    for (int i = 0; i < tot_par; i++) {
      pelist.add(parentJsonData[i].email);
      pplist.add(parentJsonData[i].password);
    }

    //quick check for parent email
    if(pelist.indexOf(pe) == -1) {
      print("Invalid Parent Email");
      return Future.value("");
    }

        //check parent salt
        Future<String> ps = checkPS(pe,parentJsonData);
        ps.then((String pSalt) {
          if(pSalt != "") {
            //encode,hash,and salt pass for password check
            var pPass = utf8.encode(pp + pSalt);
            var pHash = sha256.convert(pPass);
            pp = pHash.toString();
            for (int i = 0; i < pelist.length; i++) {
              if (pe == pelist[i] && pp == pplist[i]) {
                print("Valid Parent Email and Password");
                //cache parent info
                MyApp.pemail = pe;
                MyApp.puname = parentJsonData[i].username;
                MyApp.pid = parentJsonData[i].parent_id.toString();
                //grab kids of parent, if any
                getPlayersOfParent(MyApp.pemail,MyApp.pid,context);
              }
            }
          }
          else {
            print("No salt found for parent");
            return "";
          }
        });
  }

  Future<String> getPlayersOfParent(String pemail,String pid,context) async {
    //format JSON body for backend logic
    Map<String, dynamic> ps = {
      'email': pemail,
      'password': "",
      'uname': "",
      'salt': "",
      'Parent_id': "",
      "pD": pid,
      "age": "",
      "cuname": "",
      "tuname": ""
    };
    String pS = json.encode(ps);

    final response = await http.post(
        'https://braintrainapi.com/btapi/parents',
        headers: {"Content-Type": "application/json"}, body: pS);
    if (response.statusCode == 200) {
      print("Child info retrieved");
      //print("Response status: ${response.statusCode}");
      //print("Response body: ${response.body}");
      List btjson = json.decode(response.body.toString());

      final List<reg.Players> players = await getPlayers();

      //grab all children attached to parent from matching player ids of
      // bridge table and player endpoint
      for (int i = 0; i < players.length; i++) {
        for (int j = 0; j < btjson.length; j++) {
          if (players[i].player_id == btjson[j]) {
            print("Found player ID's for parent");
            //cache child info
            MyApp.cuname.add(players[i].username);
            MyApp.cid.add(players[i].player_id.toString());
            if (players[i].age == null) {
              MyApp.cage.add('N/A');
            }
            if (players[i].age != null) {
              MyApp.cage.add(players[i].age.toString());
            }
          }
        }
      }
        emailController.clear();
        passController.clear();
        Navigator.push(context,
          MaterialPageRoute(
              builder: (context) =>
                  MyHomePage(title: 'Shape matching game')),);

        //stop load screen state by setting loadCircle to false for login page
        //after valid log in and navigation to profile page
        loadCircle = false;
    }
    else {
      print("Failed to retrieve API data");
      notLoading();
      //print("Response status: ${response.statusCode}");
      //print("Response body: ${response.body}");
    }
  }

  Future<String> checkTeacherLogin(List<Teachers> teacherJsonData, String te, String tp) {
    var tot_par = teacherJsonData.length;

    List<String> telist = new List();
    List<String> tplist = new List();
    for(int i = 0; i < tot_par; i++) {
      telist.add(teacherJsonData[i].email);
      tplist.add(teacherJsonData[i].password);
    }

    if(telist.indexOf(te) == -1) {
      print("Invalid Teacher Email");
      return Future.value("");
    }

        Future <String> ts = checkTS(te,teacherJsonData);
        ts.then((String tSalt) {
          if(tSalt != "") {
            //encode,hash,and salt pass for comparison
            var tPass = utf8.encode(tp + tSalt);
            var tHash = sha256.convert(tPass);
            tp = tHash.toString();
            for (int i = 0; i < telist.length; i++) {
              if (te == telist[i] && tp == tplist[i]) {
                print("Valid Teacher Email and Password");
                //cache teacher info
                MyApp.temail = te;
                MyApp.tuname = teacherJsonData[i].username;
                MyApp.tid = teacherJsonData[i].teacher_id.toString();
                MyApp.tagegroup = teacherJsonData[i].age_group.toString();
                MyApp.tclassnum = teacherJsonData[i].class_num.toString();
                getPlayersOfTeacher(MyApp.temail,MyApp.tid,context);
              }
            }
          }
          else {
            print("Cant find teacher salt");
            return "";
          }
        });
  }

  Future getPlayersOfTeacher(String temail,String tid,context) async {
    Map<String, dynamic> ts = {
      'email' : temail,
      'password' : "",
      'uname' : "",
      'class_num' : "",
      'age_group' : "",
      'salt': "",
      'Teacher_id': "",
      "tD": tid
    };

    String tS = json.encode(ts);

    final response = await http.post(
        'https://braintrainapi.com/btapi/teachers',
        headers: {"Content-Type": "application/json"}, body: tS);
    if (response.statusCode == 200) {
      print("Child info retrieved");
      //print("Response status: ${response.statusCode}");
      //print("Response body: ${response.body}");
      List btjson = json.decode(response.body.toString());

      final List<reg.Players> players = await getPlayers();

      for (int i = 0; i < players.length; i++) {
        for (int j = 0; j < btjson.length; j++) {
          if (players[i].player_id == btjson[j]) {
            print("Found player ID's for teacher");
            MyApp.tcuname.add(players[i].username);
            MyApp.tcid.add(players[i].player_id.toString());
            if (players[i].age == null) {
              MyApp.tcage.add('N/A');
            }
            if (players[i].age != null) {
              MyApp.tcage.add(players[i].age.toString());
            }
          }
        }
      }
        emailController.clear();
        passController.clear();
        Navigator.push(context,
          MaterialPageRoute(builder: (context) =>
              MyHomePage(title: 'Shape matching game')),);

        loadCircle = false;
    }
    else {
      print("Failed to retrieve API data");
      notLoading();
      //print("Response status: ${response.statusCode}");
      //print("Response body: ${response.body}");
    }
  }

  //loading screen set state functions
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

  //widget to display loading screen
  Widget loadingScreen() {
    return new Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: ExactAssetImage("assets/newlogo.png"),
            fit: BoxFit.cover
        ),
      ),
      child: new Center(
        child: new Column(
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(top: 280.0),
                child: new Column(
                    children:<Widget> [
                      new Container(
                        margin: const EdgeInsets.only(left: 65),
                        //color: Colors.cyan[50],
                        child: new Image.asset("assets/animated-train-image-0031.gif"),
                      ),
                      new Text(
                        'Logging In',
                        style: new TextStyle(
                            color: Colors.white,
                            fontSize: 35.0
                        ),
                      ),
                    ]
                ),
              ),
            ]
        ),
      ),
    );
  }

  //************End of most of Dirks code *************//

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
      body:  loadCircle ? loadingScreen() :
      new Stack(
          fit: StackFit.expand,
          children: <Widget>[
            new Image(
              image: AssetImage("assets/newlogo.png"),
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
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                            ),
                            decoration: new InputDecoration(
                              labelText: "Enter Email",
                            ),
                            keyboardType: TextInputType.text,
                            controller: emailController,
                          ),
                          new TextFormField(
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold
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
                                MaterialPageRoute(builder: (context) => RegistrationTitlePage()),);
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