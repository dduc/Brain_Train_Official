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
    home: new RegistrationParentsPage(),
    theme: new ThemeData(
        primarySwatch: Colors.indigo),);
}

//Parent object constructor for json data
class Players {
  final int player_id;
  final int age;
  final String username;

  Players({
    this.player_id,
    this.age,
    this.username,
  });
}

//take raw json info from API and make new Player object list
List<Players> createPlayersList(List data) {
  List<Players> list = new List();
  for (int i = 0; i < data.length; i++) {

    Players player = new Players(
        player_id: data[i]["player_id"],
        age: data[i]["age"],
        username: data[i]["username"]);
    list.add(player);
  }
  return list;
}

class RegistrationParentsPage extends StatefulWidget {
  @override
  State createState() => new RegistrationParentsPageState();
}
class RegistrationParentsPageState extends State<RegistrationParentsPage> with SingleTickerProviderStateMixin{

  bool loadCircle = false;

  final passController = TextEditingController();
  final emailController = TextEditingController();
  final userPController = TextEditingController();
  final userCController = TextEditingController();
  final ageController = TextEditingController();
  final teachUNameController = TextEditingController();

  regUser(String uemail, String upass, String uname, String cuname,String ca,String tuname) {
    loading();
    Map<String, dynamic> parentJsonMap = {
      'email': uemail,
      'password': upass,
      'uname': uname,
      'salt': "",
      'Parent_id': "",
      "pD": "",
      "age": "",
      "cuname": cuname,
      "tuname": tuname
    };

    Map<String, dynamic> playerJsonMap = {
      'uname': cuname,
      'age': "",
      'Parent_id':""
    };

    Map<String,dynamic> teacherJsonMap = {
      'email' : "",
      'password' : "",
      'uname' : tuname,
      'class_num' : "",
      'age_group' : "",
      'salt': "",
      'Teacher_id': "",
      "tD":""
    };

    if(ca != '') {
      playerJsonMap["age"] = ca;
      parentJsonMap["age"] = ca;
    }
    if(ca == '') {
      playerJsonMap["age"] = '';
      parentJsonMap["age"] = '';
    }
      if(tuname == "") {
        print("Registering Parent w/ player...");
        String pJsonString = json.encode(parentJsonMap);
        String plJsonString = json.encode(playerJsonMap);
        regParent(pJsonString,plJsonString,tuname);
      }
      if(tuname != "") {
        print("Registering Parent and appropriate Teacher w/ player...");
        String pJsonString = json.encode(parentJsonMap);
        String plJsonString = json.encode(playerJsonMap);
        String tJsonString = json.encode(teacherJsonMap);
        regParent(pJsonString, plJsonString,tJsonString);
      }
  }

  void regParent(String pJS,String plJS,String tJS) async {
    int r = 1;
    final resp = await http.get('https://braintrainapi.com/btapi/parents');
    //If http.get is successful
    if (resp.statusCode == 200) {
      print("Parent Request #$r");
      r++;
      print("Successful connection to Parent BT API Endpoint");
      List btjson = json.decode(resp.body.toString());
      List<checkDB.Parents> parsList = checkDB.createParentsList(btjson);
      var tot_par = parsList.length;

      //Check parent emails and usernames
      Map padecoded = jsonDecode(pJS);
      for (int i = 0; i < tot_par; i++) {
        if (parsList[i].email == padecoded["email"]) {
          print("Parent email already exists,registration incomplete");
          notLoading();
          //put prompt here for parent email already exists
          return;
        }
        if (parsList[i].username == padecoded["uname"]) {
          print("Parent username already exists,registration incomplete");
          notLoading();
          //put prompt here for parent username already exists
          return;
        }
      }

      //Check player username
      final resp2 = await http.get('https://braintrainapi.com/btapi/players');
      if (resp2.statusCode == 200) {
        print("Player Request #$r");
        r++;
        print("Successful connection to Player BT API Endpoint");
        List btjson = json.decode(resp2.body.toString());
        List<Players> playerList = createPlayersList(btjson);
        var tot_par = playerList.length;

        Map playdecoded = jsonDecode(plJS);
        for (int i = 0; i < tot_par; i++) {
          if (playerList[i].username == playdecoded["uname"]) {
            //print(playerList[i].username);
            //print(playdecoded["uname"]);
            print("Player username already exists,registration incomplete");
            notLoading();
            //put prompt here for child username already exists
            return;
          }
        }

        //check teacher username, if exists, POST to server
        if(tJS != "") {
          http.post('https://braintrainapi.com/btapi/parents',
              headers: {"Content-Type": "application/json"}, body: tJS).then((
              response) {
            //print("Response status: ${response.statusCode}");
            //print("Response body: ${response.body}");
            print("Teacher account data registering w/child Complete");
            }
          );
        }

        //BELOW: hash and salt logic for insertion to DB
        int pid;
        String pSalt;

        //salt creation
        pSalt = rnd.randomAlphaNumeric(32);
        padecoded["salt"] = pSalt;

        //Hashing function: SHA 256 + 32 byte salt, will make more robust in future
        var pPass = utf8.encode(padecoded["password"] + pSalt);
        var pHash = sha256.convert(pPass);

        //Prepare hash for POST
        padecoded["password"] = pHash.toString();
        pJS = json.encode(padecoded);

        //register parent with hashed pass, insert child
        http.post('https://braintrainapi.com/btapi/parents',
            headers: {"Content-Type": "application/json"}, body: pJS).then((
            response) {
          print("Response status: ${response.statusCode}");
          print("Response body: ${response.body}");
          print("Parent Registration w/child Complete");
          //Store salt related to parent w/ function
          print("storing salt...");
          parSalt(padecoded, padecoded["email"],pid);

        });
      }
      else {
        print(
            "Unsuccessful connection to BT API, please contact web server admin");
        notLoading();
      }
    }
    else {
      print(
          "Unsuccessful connection to BT API, please contact web server admin");
      notLoading();
    }
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

          //store salt associated with registered parent using POST
          http.post('https://braintrainapi.com/btapi/parents',
              headers: {"Content-Type": "application/json"}, body: pidSalt)
              .then((response) {
            print("Storing of salt w/ PID complete");
            //print("Response status: ${response.statusCode}");
            //print("Response body: ${response.body}");
            notLoading();
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => checkDB.LoginPage()),);
            return;
          });
        }
      }
    }
    else {
      print(
          "Unsuccessful connection to BT API, please contact web server admin");
      notLoading();
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
                        'Logging in',
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

  @override
  void initState(){
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
                            )
                        )
                    ),
                    child: new Container(
                      padding: const EdgeInsets.only(left: 40.0, top: 100, right: 40),
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
                            keyboardType: TextInputType.emailAddress,
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
                          new TextFormField(
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                            ),
                            decoration: new InputDecoration(
                              labelText: "Enter Username",
                            ),
                            keyboardType: TextInputType.text,
                            controller: userPController,
                          ),
                          new TextFormField(
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                            ),
                            decoration: new InputDecoration(
                              labelText: "Enter Child's Username",
                            ),
                            keyboardType: TextInputType.text,
                            controller: userCController,
                          ),
                          new TextFormField(
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                            ),
                            decoration: new InputDecoration(
                              labelText: "Enter Child's Age (optional)",
                            ),
                            keyboardType: TextInputType.text,
                            controller: ageController,
                          ),
                          new SizedBox(height:30),
                          new Text("If you would like a teacher to be aware of your child's " +
                              "progress and activities, please enter the teachers username "
                                 + "below.",
                              textAlign: TextAlign.left,
                              textScaleFactor: 2,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9)),
                          new TextFormField(
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                            ),
                            decoration: new InputDecoration(
                              labelText: "Enter Teacher's Username (optional)",
                            ),
                            keyboardType: TextInputType.text,
                            controller: teachUNameController,
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
                              String ag = ageController.text;
                              String unp = userPController.text;
                              String unc = userCController.text;
                              String tuname = teachUNameController.text;

                              regUser(ema,pass,unp,unc,ag,tuname);
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