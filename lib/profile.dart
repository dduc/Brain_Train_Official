import 'package:flutter/material.dart';

//get relevant user info
import 'package:brain_train_official/main.dart' as login;

// BT API related Imports
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

// general user experience imports
import 'package:brain_train_official/parent_edit.dart';
import 'package:brain_train_official/child_edit.dart';

@override
Widget build(BuildContext context) {
  return new MaterialApp(
    home: new userProfile(),
    theme: new ThemeData(primarySwatch: Colors.indigo),
  );
}

//Parent object constructor for json data
class Game {
  final int player_id;
  final int stars;
  final DateTime startTime;
  final DateTime endTime;

  Game({this.player_id, this.stars, this.startTime, this.endTime});
}

//take raw json info from API and make new Parent object list
List<Game> createGameList(List data) {
  List<Game> list = new List();
  for (int i = 0; i < data.length; i++) {
    Game gameData = new Game(
        stars: data[i]["stars"],
        player_id: data[i]["Player_id"],
        startTime: DateTime.parse(data[i]["start_time"]),
        endTime: DateTime.parse(data[i]["end_time"]));
    list.add(gameData);
  }
  return list;
}

//get the parent response from the BT REST API
Future<List<Game>> getAssocGames() async {
  try {
    final resp =
        await http.get('https://braintrainapi.com/btapi/player_associations');
    //If http.get is successful
    if (resp.statusCode == 200) {
      print("Successful connection to player associations endpoint in BT API");
      List btjson = json.decode(resp.body.toString());

      if (btjson.isEmpty) {
        print('No parent API data');
        return List<Game>();
      }
      List<Game> gamesList = createGameList(btjson);
      return gamesList;
    } else {
      throw Exception('Failed to retrieve API data');
    }
  } on SocketException catch (e) {
    print(e);
    return List<Game>();
  }
}

//get the parent response from the BT REST API
Future<List<Game>> getLangGames() async {
  try {
    final resp =
        await http.get('https://braintrainapi.com/btapi/player_languages');
    //If http.get is successful
    if (resp.statusCode == 200) {
      print("Successful connection to player languages endpoint in BT API");
      List btjson = json.decode(resp.body.toString());

      if (btjson.isEmpty) {
        print('No parent API data');
        return List<Game>();
      }
      List<Game> gamesList = createGameList(btjson);
      return gamesList;
    } else {
      throw Exception('Failed to retrieve API data');
    }
  } on SocketException catch (e) {
    print(e);
    return List<Game>();
  }
}

//get the parent response from the BT REST API
Future<List<Game>> getMathGames() async {
  try {
    final resp = await http.get('https://braintrainapi.com/btapi/player_maths');
    //If http.get is successful
    if (resp.statusCode == 200) {
      print("Successful connection to player maths endpoint in BT API");
      List btjson = json.decode(resp.body.toString());

      if (btjson.isEmpty) {
        print('No parent API data');
        return List<Game>();
      }
      List<Game> gamesList = createGameList(btjson);
      return gamesList;
    } else {
      throw Exception('Failed to retrieve API data');
    }
  } on SocketException catch (e) {
    print(e);
    return List<Game>();
  }
}

//get the parent response from the BT REST API
Future<List<Game>> getMemorizationGames() async {
  try {
    final resp =
        await http.get('https://braintrainapi.com/btapi/player_memorizations');
    //If http.get is successful
    if (resp.statusCode == 200) {
      print("Successful connection to player memorizations endpoint in BT API");
      List btjson = json.decode(resp.body.toString());

      if (btjson.isEmpty) {
        print('No parent API data');
        return List<Game>();
      }
      List<Game> gamesList = createGameList(btjson);
      return gamesList;
    } else {
      throw Exception('Failed to retrieve API data');
    }
  } on SocketException catch (e) {
    print(e);
    return List<Game>();
  }
}

//get the parent response from the BT REST API
Future<List<Game>> getMotorSkillsGames() async {
  try {
    final resp =
        await http.get('https://braintrainapi.com/btapi/player_motor_skillss');
    //If http.get is successful
    if (resp.statusCode == 200) {
      print("Successful connection to player motor skills endpoint in BT API");
      List btjson = json.decode(resp.body.toString());

      if (btjson.isEmpty) {
        print('No parent API data');
        return List<Game>();
      }
      List<Game> gamesList = createGameList(btjson);
      return gamesList;
    } else {
      throw Exception('Failed to retrieve API data');
    }
  } on SocketException catch (e) {
    print(e);
    return List<Game>();
  }
}

class userProfile extends StatefulWidget {
  @override
  userProfileState createState() {
    return new userProfileState();
  }
}

/*
   These variables are saved across app navigation when active.
   They keep track of which child the parent has active for game progress tracking
   It is not saved when app is closed completely, because it then defaults to
   first child.
*/
List<Color> color = [];
List<bool> toggle = [];
String activeChild = '';
String activeChildID = '';
bool someData = false;
String scuname = '';
String scage = '';
List<String> cuname = [];
List<String> cage = [];
List<String> cid = [];

//parent info
String email = "";
String uname = "";


class userProfileState extends State<userProfile>
    with SingleTickerProviderStateMixin {


  //teacher info
  String temail;
  String tuname;
  String tagegroup;
  String tclassnum;

  //parent child info
  int current_cid = 0;

  //teacher child info
  List<String> tcuname = [];
  List<String> tcage = [];
  List<String> tcid = [];

  bool loadCircle = false;
  bool loadCirc = false;

  //init child game info
  String total_stars = '';
  String total_hours = '';
  String total_minutes = '';
  String total_seconds = '';

  String total_assoc_stars = '';
  String total_lang_stars = '';
  String total_math_stars = '';
  String total_mem_stars = '';
  String total_mot_stars = '';

  String total_assoc_hours = '';
  String total_assoc_minutes = '';
  String total_assoc_seconds = '';

  String total_lang_hours = '';
  String total_lang_minutes = '';
  String total_lang_seconds = '';

  String total_math_hours = '';
  String total_math_minutes = '';
  String total_math_seconds = '';

  String total_mem_hours = '';
  String total_mem_minutes = '';
  String total_mem_seconds = '';

  String total_mot_hours = '';
  String total_mot_minutes = '';
  String total_mot_seconds = '';

  int highest_skill_stars = 0;
  int lowest_skill_stars = 0;
  List<String> highest_skill = [];
  List<String> lowest_skill = [];
  String highest_skill_formatted = '';
  String lowest_skill_formatted = '';

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
    loading();

    if (login.MyApp.pemail != '') {
      print("Parent logging in");
      email = login.MyApp.pemail;
      uname = login.MyApp.puname;
      cuname = login.MyApp.cuname;
      cage = login.MyApp.cage;
      cid = login.MyApp.cid;
    }

    if (login.MyApp.temail != '') {
      print("Teacher logging in");
      temail = login.MyApp.temail;
      tuname = login.MyApp.tuname;
      tcuname = login.MyApp.tcuname;
      tcage = login.MyApp.tcage;
      tcid = login.MyApp.tcid;
      tagegroup = login.MyApp.tagegroup;
      tclassnum = login.MyApp.tclassnum;
    }


    if (color.isEmpty && login.MyApp.pemail != '') {
      color = [];
      print("Empty color");
      color.insert(0, Colors.green);
      for (int i = 0; i < cid.length; i++) {
        toggle.add(false);
        color.insert(i + 1, Colors.grey);
      }
      activeChild = cuname[0];
      activeChildID = cid[0];
    }
    if (color.isEmpty && login.MyApp.temail != '') {
      color = [];
      print("empty color and teacher");
      if(tcid.isNotEmpty) {
        print("teacher with students");
        for (int i = 0; i < tcid.length; i++) {
          toggle.add(true);
          color.insert(i, Colors.green);
        }
      }
      if (tcid.isEmpty) {
        print("teacher with no students");
        updateProfile("0");
        return;
      }
    }

    //grab first registered child's info
    //parent with kids, always executes
    if(login.MyApp.pemail != '') {
      print("parent with kids");
      updateProfile(cid[0]);
    }
    //teacher with kids, sometimes executes
    if(login.MyApp.temail != '' && tcid != null) {
      print("teacher with students");
      updateProfile(tcid[0]);
    }
  }

  dispose() {
    super.dispose();

    //empty lists and reset data when backing out of profile page
    //this allows for kid info to update every time profile is opened
    highest_skill = [];
    lowest_skill = [];
    tcage = [];
    tcuname = [];
    tcid = [];
    someData = false;
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
                margin: const EdgeInsets.only(top: 260),
                child: new Column(
                    children:<Widget> [
                      new Container(
                        margin: const EdgeInsets.only(left: 65),
                        //color: Colors.cyan[50],
                        child: new Image.asset("assets/animated-train-image-0031.gif"),
                      ),
                      new Text(
                        'Retrieving Child Data',
                        style: new TextStyle(
                            color: Colors.white,
                            fontSize: 25.0
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

  //loading screen logic
  newData() {
    setState(() {
      loadCirc = true;
    });
  }

  noNewData() {
    setState(() {
      loadCirc = false;
    });
  }

  //green bubble logic for tracking kids
  nottoggled(ind) {
    setState(() {
      toggle[ind] = true;

      activatedChild(cuname[ind], cid[ind]);
      for (int i = 0; i < toggle.length; i++) {
        if (ind != i) {
          toggle[i] = false;
        }
      }
    });
  }

  nottoggledColor(ind) {
    setState(() {
      color[ind] = Colors.green;
      for (int i = 0; i < color.length; i++) {
        if (ind != i) {
          color[i] = Colors.grey;
        }
      }
    });
  }

  //logic for text display of what kid is being tracked
  activatedChild(cuname, cid) {
    setState(() {
      activeChild = cuname;
      activeChildID = cid;
    });
  }

  //Function to load all child game data
  Future<List> getChildInfo(String childID) async {
    //childID has data
    if(childID != "0") {
      print("getting child info for parent");
      current_cid = int.parse(childID);

      //get info from all APIs for child
      final List<Game> assoc = await getAssocGames();
      final List<Game> lang = await getLangGames();
      final List<Game> math = await getMathGames();
      final List<Game> mem = await getMemorizationGames();
      final List<Game> mot = await getMotorSkillsGames();

      //init stars earned for each skill involved with games
      int assocTotalStars = 0;
      int langTotalStars = 0;
      int mathTotalStars = 0;
      int memTotalStars = 0;
      int motTotalStars = 0;
      List<int> AllStars = [];

      //init total time for each skill involved with games
      int assocTotalTime = 0;
      int langTotalTime = 0;
      int memTotalTime = 0;
      int mathTotalTime = 0;
      int motTotalTime = 0;

      //get association data for specific child
      for (int i = 0; i < assoc.length; i++) {
        if (assoc[i].player_id.toString() == childID) {
          assocTotalStars = assocTotalStars + assoc[i].stars;
          DateTime start = assoc[i].startTime;
          DateTime end = assoc[i].endTime;
          Duration timePlayed = end.difference(start);
          assocTotalTime += timePlayed.inMilliseconds;
        }
      }
      total_assoc_stars = assocTotalStars.toString();
      AllStars.add(assocTotalStars);

      //get language data for specific child
      for (int i = 0; i < lang.length; i++) {
        if (lang[i].player_id.toString() == childID) {
          langTotalStars = langTotalStars + lang[i].stars;
          DateTime start = lang[i].startTime;
          DateTime end = lang[i].endTime;
          Duration timePlayed = end.difference(start);
          langTotalTime += timePlayed.inMilliseconds;
        }
      }
      total_lang_stars = langTotalStars.toString();
      AllStars.add(langTotalStars);

      //get math data for specific child
      for (int i = 0; i < math.length; i++) {
        if (math[i].player_id.toString() == childID) {
          mathTotalStars = mathTotalStars + math[i].stars;
          DateTime start = math[i].startTime;
          DateTime end = math[i].endTime;
          Duration timePlayed = end.difference(start);
          mathTotalTime += timePlayed.inMilliseconds;
        }
      }
      total_math_stars = mathTotalStars.toString();
      AllStars.add(mathTotalStars);

      //get memorization data for specific child
      for (int i = 0; i < mem.length; i++) {
        if (mem[i].player_id.toString() == childID) {
          memTotalStars = memTotalStars + mem[i].stars;
          DateTime start = mem[i].startTime;
          DateTime end = mem[i].endTime;
          Duration timePlayed = end.difference(start);
          memTotalTime += timePlayed.inMilliseconds;
        }
      }
      total_mem_stars = memTotalStars.toString();
      AllStars.add(memTotalStars);

      //get motor skills data for specific child
      for (int i = 0; i < mot.length; i++) {
        if (mot[i].player_id.toString() == childID) {
          motTotalStars = motTotalStars + mot[i].stars;
          DateTime start = mot[i].startTime;
          DateTime end = mot[i].endTime;
          Duration timePlayed = end.difference(start);
          motTotalTime += timePlayed.inMilliseconds;
        }
      }
      total_mot_stars = motTotalStars.toString();
      AllStars.add(motTotalStars);

      //get total time played among all games
      int allGameTime = assocTotalTime +
          memTotalTime +
          langTotalTime +
          motTotalTime +
          mathTotalTime;

      //time conversions
      const int minutesPerHour = 60;
      const int secondsPerMinute = 60;
      const int millisecondsPerSecond = 1000;
      const int millisecondsPerMinute =
      (millisecondsPerSecond * secondsPerMinute);
      const int millisecondsPerHour = (millisecondsPerMinute * minutesPerHour);

      int hours = allGameTime ~/ millisecondsPerHour;
      int minutes = allGameTime ~/ millisecondsPerMinute;
      int seconds = allGameTime ~/ millisecondsPerSecond;

      //get all stars earned across games for text display
      total_stars = (assocTotalStars +
          mathTotalStars +
          memTotalStars +
          motTotalStars +
          langTotalStars)
          .toString();

      //Setup overall time for formatting
      Duration total_time =
      new Duration(hours: hours, minutes: minutes, seconds: seconds);

      //Format all times for display on app (parsing, converting, etc)
      String totalTime = total_time.toString();
      List<String> times = totalTime.split(":");

      List<String> hoursForm = times[2].split(".");
      times[2] = hoursForm[0];

      //remove all leading 0's
      if (times[1][0] == "0") {
        times[1] = times[1][1];
      }

      if (times[2][0] == "0") {
        times[2] = times[2][1];
      }

      //insert formatted time data into widget vars
      total_hours = times[0];
      total_minutes = times[1];
      total_seconds = times[2];

      int assoc_hours = assocTotalTime ~/ millisecondsPerHour;
      int assoc_minutes = assocTotalTime ~/ millisecondsPerMinute;
      int assoc_seconds = assocTotalTime ~/ millisecondsPerSecond;

      //Setup overall time for formatting
      Duration total_assoc_time = new Duration(
          hours: assoc_hours, minutes: assoc_minutes, seconds: assoc_seconds);

      //Format all times for display on app (parsing, converting, etc)
      String totalAssocTime = total_assoc_time.toString();
      List<String> assocTimes = totalAssocTime.split(":");

      List<String> assocHoursForm = assocTimes[2].split(".");
      assocTimes[2] = assocHoursForm[0];

      if (assocTimes[1][0] == "0") {
        assocTimes[1] = assocTimes[1][1];
      }

      if (assocTimes[2][0] == "0") {
        assocTimes[2] = assocTimes[2][1];
      }

      //insert formatted time data into widget vars
      total_assoc_hours = assocTimes[0];
      total_assoc_minutes = assocTimes[1];
      total_assoc_seconds = assocTimes[2];

      int lang_hours = langTotalTime ~/ millisecondsPerHour;
      int lang_minutes = langTotalTime ~/ millisecondsPerMinute;
      int lang_seconds = langTotalTime ~/ millisecondsPerSecond;

      //Setup overall time for formatting
      Duration total_lang_time = new Duration(
          hours: lang_hours, minutes: lang_minutes, seconds: lang_seconds);

      //Format all times for display on app (parsing, converting, etc)
      String totalLangTime = total_lang_time.toString();
      List<String> langTimes = totalLangTime.split(":");

      List<String> langHoursForm = langTimes[2].split(".");
      langTimes[2] = langHoursForm[0];

      if (langTimes[1][0] == "0") {
        langTimes[1] = langTimes[1][1];
      }

      if (langTimes[2][0] == "0") {
        langTimes[2] = langTimes[2][1];
      }

      //insert formatted time data into widget vars
      total_lang_hours = langTimes[0];
      total_lang_minutes = langTimes[1];
      total_lang_seconds = langTimes[2];

      int mem_hours = memTotalTime ~/ millisecondsPerHour;
      int mem_minutes = memTotalTime ~/ millisecondsPerMinute;
      int mem_seconds = memTotalTime ~/ millisecondsPerSecond;

      //Setup overall time for formatting
      Duration total_mem_time = new Duration(
          hours: mem_hours, minutes: mem_minutes, seconds: mem_seconds);

      //Format all times for display on app (parsing, converting, etc)
      String totalMemTime = total_mem_time.toString();
      List<String> memTimes = totalMemTime.split(":");

      List<String> memHoursForm = memTimes[2].split(".");
      memTimes[2] = memHoursForm[0];

      if (memTimes[1][0] == "0") {
        memTimes[1] = memTimes[1][1];
      }

      if (memTimes[2][0] == "0") {
        memTimes[2] = memTimes[2][1];
      }

      //insert formatted time data into widget vars
      total_mem_hours = memTimes[0];
      total_mem_minutes = memTimes[1];
      total_mem_seconds = memTimes[2];

      int math_hours = mathTotalTime ~/ millisecondsPerHour;
      int math_minutes = mathTotalTime ~/ millisecondsPerMinute;
      int math_seconds = mathTotalTime ~/ millisecondsPerSecond;

      //Setup overall time for formatting
      Duration total_math_time = new Duration(
          hours: math_hours, minutes: math_minutes, seconds: math_seconds);

      //Format all times for display on app (parsing, converting, etc)
      String totalMathTime = total_math_time.toString();
      List<String> mathTimes = totalMathTime.split(":");

      List<String> mathHoursForm = mathTimes[2].split(".");
      mathTimes[2] = mathHoursForm[0];

      if (mathTimes[1][0] == "0") {
        mathTimes[1] = mathTimes[1][1];
      }

      if (mathTimes[2][0] == "0") {
        mathTimes[2] = mathTimes[2][1];
      }

      //insert formatted time data into widget vars
      total_math_hours = mathTimes[0];
      total_math_minutes = mathTimes[1];
      total_math_seconds = mathTimes[2];

      int mot_hours = motTotalTime ~/ millisecondsPerHour;
      int mot_minutes = motTotalTime ~/ millisecondsPerMinute;
      int mot_seconds = motTotalTime ~/ millisecondsPerSecond;

      //Setup overall time for formatting
      Duration total_mot_time = new Duration(
          hours: mot_hours, minutes: mot_minutes, seconds: mot_seconds);

      //Format all times for display on app (parsing, converting, etc)
      String totalMotTime = total_mot_time.toString();
      List<String> motTimes = totalMotTime.split(":");

      List<String> motHoursForm = motTimes[2].split(".");
      motTimes[2] = motHoursForm[0];

      if (motTimes[1][0] == "0") {
        motTimes[1] = motTimes[1][1];
      }

      if (motTimes[2][0] == "0") {
        motTimes[2] = motTimes[2][1];
      }

      //insert formatted time data into widget vars
      total_mot_hours = motTimes[0];
      total_mot_minutes = motTimes[1];
      total_mot_seconds = motTimes[2];

      AllStars.sort();
      highest_skill_stars = AllStars[AllStars.length - 1];
      lowest_skill_stars = AllStars[0];

      //logic to add more skills to list if they have same highest number of stars
      if (highest_skill_stars == assocTotalStars) {
        highest_skill.add("Association");
      }

      if (highest_skill_stars == mathTotalStars) {
        highest_skill.add("Math");
      }

      if (highest_skill_stars == langTotalStars) {
        highest_skill.add("Language");
      }

      if (highest_skill_stars == memTotalStars) {
        highest_skill.add("Memorization");
      }

      if (highest_skill_stars == motTotalStars) {
        highest_skill.add("Motor Skills");
      }

      //logic for more than one as highest
      if (highest_skill.length > 1) {
        highest_skill.insert(0, "(tie)");
      }

      String highSkill = highest_skill.toString();
      highSkill = highSkill.replaceFirst(",", "", 0);
      highSkill = highSkill.replaceAll("]", "");
      highSkill = highSkill.replaceAll("[", "");
      highest_skill_formatted = highSkill;

      if (lowest_skill_stars == assocTotalStars) {
        lowest_skill.add("Association");
      }
      if (lowest_skill_stars == mathTotalStars) {
        lowest_skill.add("Math");
      }
      if (lowest_skill_stars == langTotalStars) {
        lowest_skill.add("Language");
      }
      if (lowest_skill_stars == memTotalStars) {
        lowest_skill.add("Memorization");
      }
      if (lowest_skill_stars == motTotalStars) {
        lowest_skill.add("Motor Skills");
      }
      if (lowest_skill.length > 1) {
        lowest_skill.insert(0, "(tie)");
      }

      //remove brackets and commas for user friendly display
      String lowSkill = lowest_skill.toString();
      lowSkill = lowSkill.replaceFirst(",", "", 0);
      lowSkill = lowSkill.replaceAll("]", "");
      lowSkill = lowSkill.replaceAll("[", "");
      lowest_skill_formatted = lowSkill;
      //for logic purposes
      List<String> data = ["data"];
      return data;
    }
    if(childID == "0") {
      print("teacher with no kids");
      List<String> noData = [];
      return noData;
    }
  }

  //Called every time user opens profile
  void updateProfile(String cid) {
    final kids = getChildInfo(cid);
    kids.then((data) {
      notLoading();
      //only set someData var to be true if return val of function
      //isn't null/empty
      if(data.isNotEmpty) {
        setState(() {
          someData = true;
        }
        );
      }
    }
    );
  }

  //functions to cycle through different children
  void prevChild(int n) {
    if(tcid.isEmpty) {
      if (n <= 3) {
        newData();
        current_cid = int.parse(cid[n - 1]);
        highest_skill = [];
        lowest_skill = [];

        final kids = getChildInfo(cid[n - 1].toString());
        kids.then((data) {
          noNewData();
        });
      }
    }

    if(tcid.isNotEmpty) {
      if (n <= 3) {
        newData();
        current_cid = int.parse(tcid[n - 1]);
        highest_skill = [];
        lowest_skill = [];

        final kids = getChildInfo(tcid[n - 1].toString());
        kids.then((data) {
          noNewData();
        });
      }
    }
  }

  void nextChild(int n) {
    if(tcid.isEmpty) {
      if (n <= 3) {
        newData();
        current_cid = int.parse(cid[n + 1]);
        highest_skill = [];
        lowest_skill = [];

        final kids = getChildInfo(cid[n + 1].toString());
        kids.then((data) {
          noNewData();
        });
      }
    }

    if(tcid.isNotEmpty) {
      if (n <= 3) {
        newData();
        current_cid = int.parse(tcid[n + 1]);
        highest_skill = [];
        lowest_skill = [];

        final kids = getChildInfo(tcid[n + 1].toString());
        kids.then((data) {
          noNewData();
        });
      }
    }
  }

  //Widget to dynamically display how many children parent/teacher has
  Widget displayChildrenInfo(sW, sH, numOfChildren, context,sD,cun,cag,color) {
    //parent with kids (given)
    if(sD == true && tcid.isEmpty) {
      return new Row(children: <Widget>[
        new Container(
            width: sW,
            height: sH / 5,
            padding: EdgeInsets.all(10),
            child: new ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: numOfChildren,
                itemBuilder: (context, int index) {
                  return new Row(children: <Widget>[
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new PhysicalModel(
                          shape: BoxShape.circle,
                          borderRadius: new BorderRadius.all(
                              Radius.circular(15)),
                          color: color[index],
                          child: new IconButton(
                              icon: new Icon(
                                  const IconData(59389,
                                      fontFamily: 'MaterialIcons'),
                                  size: 33),
                              color: Colors.black,
                              onPressed: () {
                                if (toggle[index] == true) {
                                  //do nothing, since that toggle is already set
                                } else {
                                  nottoggled(index);
                                  nottoggledColor(index);
                                }
                              }),
                        ),
                        new SizedBox(height: 10),
                        new Container(
                          child: new RichText(
                            textAlign: TextAlign.left,
                            textScaleFactor: 1.5,
                            text: new TextSpan(
                              text: "Username:    ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 9),
                              children: <TextSpan>[
                                new TextSpan(
                                    text: cun[index].toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 8))
                              ],
                            ),
                          ),
                        ),
                        new SizedBox(height: 10),
                        new Container(
                          child: new RichText(
                            textAlign: TextAlign.left,
                            textScaleFactor: 1.5,
                            text: new TextSpan(
                              text: "Age:               ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 9),
                              children: <TextSpan>[
                                new TextSpan(
                                    text: cag[index].toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 8))
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    VerticalDivider(color: Colors.black)
                  ]);
                })),
      ]);
    }
    //teacher with students attached
    else if (sD == true) {
      print("sD == true");
      return new Row(children: <Widget>[
        new Container(
            width: sW,
            height: sH / 5.5,
            padding: EdgeInsets.only(left:10,right:10,bottom:10,top:0),
            child: new ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: numOfChildren,
                itemBuilder: (context, int index) {
                  return new Row(children: <Widget>[
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new PhysicalModel(
                          shape: BoxShape.circle,
                          borderRadius: new BorderRadius.all(
                              Radius.circular(15)),
                          color: color[index],
                          child: new IconButton(
                              icon: new Icon(
                                  const IconData(59389,
                                      fontFamily: 'MaterialIcons'),
                                  size: 33),
                              color: Colors.black,
                              onPressed: () {
                                if (toggle[index] == true) {
                                  //do nothing, since that toggle is already set
                                } else {
                                  nottoggled(index);
                                  nottoggledColor(index);
                                }
                              }),
                        ),
                        new SizedBox(height: 10),
                        new Container(
                          child: new RichText(
                            textAlign: TextAlign.left,
                            textScaleFactor: 1.5,
                            text: new TextSpan(
                              text: "Username:    ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 9),
                              children: <TextSpan>[
                                new TextSpan(
                                    text: cun[index].toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 8))
                              ],
                            ),
                          ),
                        ),
                        new SizedBox(height: 10),
                        new Container(
                          child: new RichText(
                            textAlign: TextAlign.left,
                            textScaleFactor: 1.5,
                            text: new TextSpan(
                              text: "Age:               ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 9),
                              children: <TextSpan>[
                                new TextSpan(
                                    text: cag[index].toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 8))
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    VerticalDivider(color: Colors.black)
                  ]);
                })),
      ]);
    }
    //teacher with no students attached
    else {
      return new Row();
    }
  }

  Widget displayChildrenNames(sW,sH,cID,curr_cid,sD) {
    print("displayChildrenNames");
    if(cid.isNotEmpty) {
      print("cid.isNotEmpty");
      if (sD == true) {
        print("sD == true");
        return new Row(children: <Widget>[
          new Container(
              color: Colors.lightBlueAccent,
              width: sW,
              height: sH / 11,
              padding: EdgeInsets.only(top: 15, bottom: 15),
              child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    new IconButton(
                        icon: new Icon(
                            IconData(58848,
                                fontFamily: 'MaterialIcons'),
                            size: 35),
                        padding: EdgeInsets.only(bottom: 35),
                        disabledColor: Colors.black,
                        onPressed: () {
                          if (cID.indexOf(curr_cid.toString()) ==
                              0) {
                            return;
                          }
                          prevChild(
                              cID.indexOf(curr_cid.toString()));
                        }),
                    new Text(
                        cuname[cID.indexOf(curr_cid.toString())]
                            .toString() +
                            "'s Game Progress",
                        textAlign: TextAlign.center,
                        textScaleFactor: 2,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 10)),
                    new IconButton(
                        icon: new Icon(
                            const IconData(58849,
                                fontFamily: 'MaterialIcons'),
                            size: 35),
                        padding: EdgeInsets.only(bottom: 35),
                        disabledColor: Colors.black,
                        onPressed: () {
                          if (cID.indexOf(curr_cid.toString()) ==
                              (cID.length - 1)) {
                            return;
                          }
                          nextChild(
                              cID.indexOf(curr_cid.toString()));
                        }),
                  ])),
        ]);
      }
    }
    if(cid.isEmpty) {
      print("cid.isEmpty");
      if (tcid.isNotEmpty) {
        print("tcid.isNotEmpty");
        return new Row(children: <Widget>[
          new Container(
              color: Colors.lightBlueAccent,
              width: sW,
              height: sH / 11,
              padding: EdgeInsets.only(top: 15, bottom: 15),
              child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    new IconButton(
                        icon: new Icon(
                            IconData(58848,
                                fontFamily: 'MaterialIcons'),
                            size: 35),
                        padding: EdgeInsets.only(bottom: 35),
                        disabledColor: Colors.black,
                        onPressed: () {
                          if (cID.indexOf(curr_cid.toString()) ==
                              0) {
                            return;
                          }
                          prevChild(
                              cID.indexOf(curr_cid.toString()));
                        }),
                    new Text(
                        tcuname[cID.indexOf(curr_cid.toString())]
                            .toString() +
                            "'s Game Progress",
                        textAlign: TextAlign.center,
                        textScaleFactor: 2,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 10)),
                    new IconButton(
                        icon: new Icon(
                            const IconData(58849,
                                fontFamily: 'MaterialIcons'),
                            size: 35),
                        padding: EdgeInsets.only(bottom: 35),
                        disabledColor: Colors.black,
                        onPressed: () {
                          if (cID.indexOf(curr_cid.toString()) ==
                              (cID.length - 1)) {
                            return;
                          }
                          nextChild(
                              cID.indexOf(curr_cid.toString()));
                        }),
                  ])),
        ]);
      }
      else {
        print("some Data is false");
        return new Row();
      }
    }
  }

  Widget parentOrTeacherGameInfo(sW,sH) {
    //parent game info
    if (cid.isNotEmpty && login.MyApp.pemail != '') {
      print("parent game info");
      return new Row(children: <Widget>[
        new Container(
            color: Colors.cyan[100],
            width: sW,
            height: sH / 3.279,
            child: new ListView(
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  new Text("(Scroll for more info)",
                      textAlign: TextAlign.center,
                      textScaleFactor: 1,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  new SizedBox(height: 20),
                  new Text("Total Stars",
                      textAlign: TextAlign.center,
                      textScaleFactor: 2,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17)),
                  new Icon(
                      const IconData(59448,
                          fontFamily: 'MaterialIcons'),
                      size: 100,
                      color: Colors.yellow),
                  new Text(total_stars,
                      textAlign: TextAlign.center,
                      textScaleFactor: 2,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12)),
                  new SizedBox(height: 20),
                  Divider(color: Colors.black),
                  new SizedBox(height: 20),
                  new Text("Total Time Played",
                      textAlign: TextAlign.center,
                      textScaleFactor: 2,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17)),
                  new Icon(
                      const IconData(58405,
                          fontFamily: 'MaterialIcons'),
                      size: 80),
                  new Text(
                      total_hours.toString() +
                          " hours " +
                          total_minutes.toString() +
                          " minutes " +
                          total_seconds.toString() +
                          " seconds ",
                      textAlign: TextAlign.center,
                      textScaleFactor: 2,
                      style: TextStyle(fontSize: 9)),
                  new SizedBox(height: 20),
                  Divider(color: Colors.black),
                  new SizedBox(height: 20),
                  new Text("Skill with Most Stars",
                      textAlign: TextAlign.center,
                      textScaleFactor: 2,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17)),
                  new SizedBox(height: 20),
                  new Text(highest_skill_formatted,
                      textAlign: TextAlign.center,
                      textScaleFactor: 2,
                      style: TextStyle(fontSize: 9)),
                  new SizedBox(height: 20),
                  Divider(color: Colors.black),
                  new SizedBox(height: 20),
                  new Text("Skill with Least Stars",
                      textAlign: TextAlign.center,
                      textScaleFactor: 2,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17)),
                  new SizedBox(height: 20),
                  new Text(lowest_skill_formatted,
                      textAlign: TextAlign.center,
                      textScaleFactor: 2,
                      style: TextStyle(fontSize: 9)),
                  new SizedBox(height: 20),
                  Divider(color: Colors.black),
                  new SizedBox(height: 20),
                  new Text("Association",
                      textAlign: TextAlign.center,
                      textScaleFactor: 2,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17)),
                  new Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text(total_assoc_stars,
                            textAlign: TextAlign.center,
                            textScaleFactor: 2,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                        new Icon(
                            const IconData(59448,
                                fontFamily: 'MaterialIcons'),
                            size: 30,
                            color: Colors.yellow),
                      ]),
                  new Text(
                      "Total Time: " +
                          total_assoc_hours.toString() +
                          " hours " +
                          total_assoc_minutes.toString() +
                          " minutes " +
                          total_assoc_seconds.toString() +
                          " seconds ",
                      textAlign: TextAlign.center,
                      textScaleFactor: 2,
                      style: TextStyle(fontSize: 9)),
                  new SizedBox(height: 20),
                  Divider(color: Colors.black),
                  new SizedBox(height: 20),
                  new Text("Language",
                      textAlign: TextAlign.center,
                      textScaleFactor: 2,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17)),
                  new Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text(total_lang_stars,
                            textAlign: TextAlign.center,
                            textScaleFactor: 2,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                        new Icon(
                            const IconData(59448,
                                fontFamily: 'MaterialIcons'),
                            size: 30,
                            color: Colors.yellow),
                      ]),
                  new Text(
                      "Total Time: " +
                          total_lang_hours.toString() +
                          " hours " +
                          total_lang_minutes.toString() +
                          " minutes " +
                          total_lang_seconds.toString() +
                          " seconds ",
                      textAlign: TextAlign.center,
                      textScaleFactor: 2,
                      style: TextStyle(fontSize: 9)),
                  new SizedBox(height: 20),
                  Divider(color: Colors.black),
                  new SizedBox(height: 20),
                  new Text("Math",
                      textAlign: TextAlign.center,
                      textScaleFactor: 2,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17)),
                  new Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text(total_math_stars,
                            textAlign: TextAlign.center,
                            textScaleFactor: 2,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                        new Icon(
                            const IconData(59448,
                                fontFamily: 'MaterialIcons'),
                            size: 30,
                            color: Colors.yellow),
                      ]),
                  new Text(
                      "Total Time: " +
                          total_math_hours.toString() +
                          " hours " +
                          total_math_minutes.toString() +
                          " minutes " +
                          total_math_seconds.toString() +
                          " seconds ",
                      textAlign: TextAlign.center,
                      textScaleFactor: 2,
                      style: TextStyle(fontSize: 9)),
                  new SizedBox(height: 20),
                  Divider(color: Colors.black),
                  new SizedBox(height: 20),
                  new Text("Memorization",
                      textAlign: TextAlign.center,
                      textScaleFactor: 2,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17)),
                  new Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text(total_mem_stars,
                            textAlign: TextAlign.center,
                            textScaleFactor: 2,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                        new Icon(
                            const IconData(59448,
                                fontFamily: 'MaterialIcons'),
                            size: 30,
                            color: Colors.yellow),
                      ]),
                  new Text(
                      "Total Time: " +
                          total_mem_hours.toString() +
                          " hours " +
                          total_mem_minutes.toString() +
                          " minutes " +
                          total_mem_seconds.toString() +
                          " seconds ",
                      textAlign: TextAlign.center,
                      textScaleFactor: 2,
                      style: TextStyle(fontSize: 9)),
                  new SizedBox(height: 20),
                  Divider(color: Colors.black),
                  new SizedBox(height: 20),
                  new Text("Motor Skills",
                      textAlign: TextAlign.center,
                      textScaleFactor: 2,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17)),
                  new Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Text(total_mot_stars,
                            textAlign: TextAlign.center,
                            textScaleFactor: 2,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                        new Icon(
                            const IconData(59448,
                                fontFamily: 'MaterialIcons'),
                            size: 30,
                            color: Colors.yellow),
                      ]),
                  new Text(
                      "Total Time: " +
                          total_mot_hours.toString() +
                          " hours " +
                          total_mot_minutes.toString() +
                          " minutes " +
                          total_mot_seconds.toString() +
                          " seconds ",
                      textAlign: TextAlign.center,
                      textScaleFactor: 2,
                      style: TextStyle(fontSize: 9)),
                  Divider(color: Colors.black),
                ])),
      ]);
    }

    //teacher with kids game info
    if(cid.isEmpty && login.MyApp.temail != '') {
      print("teacher game info");
      if (tcid.isNotEmpty) {
        return new Row(children: <Widget>[
          new Container(
              color: Colors.cyan[100],
              width: sW,
              height: sH / 3.03,
              child: new ListView(
                  scrollDirection: Axis.vertical,
                  children: <Widget>[
                    new Text("(Scroll for more info)",
                        textAlign: TextAlign.center,
                        textScaleFactor: 1,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    new SizedBox(height: 20),
                    new Text("Total Stars",
                        textAlign: TextAlign.center,
                        textScaleFactor: 2,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17)),
                    new Icon(
                        const IconData(59448,
                            fontFamily: 'MaterialIcons'),
                        size: 100,
                        color: Colors.yellow),
                    new Text(total_stars,
                        textAlign: TextAlign.center,
                        textScaleFactor: 2,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                    new SizedBox(height: 20),
                    Divider(color: Colors.black),
                    new SizedBox(height: 20),
                    new Text("Total Time Played",
                        textAlign: TextAlign.center,
                        textScaleFactor: 2,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17)),
                    new Icon(
                        const IconData(58405,
                            fontFamily: 'MaterialIcons'),
                        size: 80),
                    new Text(
                        total_hours.toString() +
                            " hours " +
                            total_minutes.toString() +
                            " minutes " +
                            total_seconds.toString() +
                            " seconds ",
                        textAlign: TextAlign.center,
                        textScaleFactor: 2,
                        style: TextStyle(fontSize: 9)),
                    new SizedBox(height: 20),
                    Divider(color: Colors.black),
                    new SizedBox(height: 20),
                    new Text("Skill with Most Stars",
                        textAlign: TextAlign.center,
                        textScaleFactor: 2,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17)),
                    new SizedBox(height: 20),
                    new Text(highest_skill_formatted,
                        textAlign: TextAlign.center,
                        textScaleFactor: 2,
                        style: TextStyle(fontSize: 9)),
                    new SizedBox(height: 20),
                    Divider(color: Colors.black),
                    new SizedBox(height: 20),
                    new Text("Skill with Least Stars",
                        textAlign: TextAlign.center,
                        textScaleFactor: 2,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17)),
                    new SizedBox(height: 20),
                    new Text(lowest_skill_formatted,
                        textAlign: TextAlign.center,
                        textScaleFactor: 2,
                        style: TextStyle(fontSize: 9)),
                    new SizedBox(height: 20),
                    Divider(color: Colors.black),
                    new SizedBox(height: 20),
                    new Text("Association",
                        textAlign: TextAlign.center,
                        textScaleFactor: 2,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17)),
                    new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text(total_assoc_stars,
                              textAlign: TextAlign.center,
                              textScaleFactor: 2,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                          new Icon(
                              const IconData(59448,
                                  fontFamily: 'MaterialIcons'),
                              size: 30,
                              color: Colors.yellow),
                        ]),
                    new Text(
                        "Total Time: " +
                            total_assoc_hours.toString() +
                            " hours " +
                            total_assoc_minutes.toString() +
                            " minutes " +
                            total_assoc_seconds.toString() +
                            " seconds ",
                        textAlign: TextAlign.center,
                        textScaleFactor: 2,
                        style: TextStyle(fontSize: 9)),
                    new SizedBox(height: 20),
                    Divider(color: Colors.black),
                    new SizedBox(height: 20),
                    new Text("Language",
                        textAlign: TextAlign.center,
                        textScaleFactor: 2,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17)),
                    new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text(total_lang_stars,
                              textAlign: TextAlign.center,
                              textScaleFactor: 2,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                          new Icon(
                              const IconData(59448,
                                  fontFamily: 'MaterialIcons'),
                              size: 30,
                              color: Colors.yellow),
                        ]),
                    new Text(
                        "Total Time: " +
                            total_lang_hours.toString() +
                            " hours " +
                            total_lang_minutes.toString() +
                            " minutes " +
                            total_lang_seconds.toString() +
                            " seconds ",
                        textAlign: TextAlign.center,
                        textScaleFactor: 2,
                        style: TextStyle(fontSize: 9)),
                    new SizedBox(height: 20),
                    Divider(color: Colors.black),
                    new SizedBox(height: 20),
                    new Text("Math",
                        textAlign: TextAlign.center,
                        textScaleFactor: 2,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17)),
                    new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text(total_math_stars,
                              textAlign: TextAlign.center,
                              textScaleFactor: 2,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                          new Icon(
                              const IconData(59448,
                                  fontFamily: 'MaterialIcons'),
                              size: 30,
                              color: Colors.yellow),
                        ]),
                    new Text(
                        "Total Time: " +
                            total_math_hours.toString() +
                            " hours " +
                            total_math_minutes.toString() +
                            " minutes " +
                            total_math_seconds.toString() +
                            " seconds ",
                        textAlign: TextAlign.center,
                        textScaleFactor: 2,
                        style: TextStyle(fontSize: 9)),
                    new SizedBox(height: 20),
                    Divider(color: Colors.black),
                    new SizedBox(height: 20),
                    new Text("Memorization",
                        textAlign: TextAlign.center,
                        textScaleFactor: 2,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17)),
                    new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text(total_mem_stars,
                              textAlign: TextAlign.center,
                              textScaleFactor: 2,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                          new Icon(
                              const IconData(59448,
                                  fontFamily: 'MaterialIcons'),
                              size: 30,
                              color: Colors.yellow),
                        ]),
                    new Text(
                        "Total Time: " +
                            total_mem_hours.toString() +
                            " hours " +
                            total_mem_minutes.toString() +
                            " minutes " +
                            total_mem_seconds.toString() +
                            " seconds ",
                        textAlign: TextAlign.center,
                        textScaleFactor: 2,
                        style: TextStyle(fontSize: 9)),
                    new SizedBox(height: 20),
                    Divider(color: Colors.black),
                    new SizedBox(height: 20),
                    new Text("Motor Skills",
                        textAlign: TextAlign.center,
                        textScaleFactor: 2,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17)),
                    new Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Text(total_mot_stars,
                              textAlign: TextAlign.center,
                              textScaleFactor: 2,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                          new Icon(
                              const IconData(59448,
                                  fontFamily: 'MaterialIcons'),
                              size: 30,
                              color: Colors.yellow),
                        ]),
                    new Text(
                        "Total Time: " +
                            total_mot_hours.toString() +
                            " hours " +
                            total_mot_minutes.toString() +
                            " minutes " +
                            total_mot_seconds.toString() +
                            " seconds ",
                        textAlign: TextAlign.center,
                        textScaleFactor: 2,
                        style: TextStyle(fontSize: 9)),
                    Divider(color: Colors.black),
                  ])),
        ]);
      }

    }
    //teacher with no kids
    else {
      return new Row();
    }
  }

  Widget displayChildrenGameInfo(sW,sH,sD) {
    if (sD == true) {
      print("sD == true");
      return parentOrTeacherGameInfo(sW,sH);
    }
      else {
        print("no children game info");
        return new Row();
      }
  }

  Widget showTracker(sW,sH,cID,activeChild,sD) {
    //Show tracker for parents
    if (cid.isNotEmpty && cID.isEmpty) {
      print("parent Tracker");
      print("cID.isNotEmpty");
        return new Text(
            "Tracking " + activeChild + "'s Game Activity",
            textAlign: TextAlign.left,
            textScaleFactor: 2,
            style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 6));
    }
    //don't show tracker for teachers
    else if (sD == true) {
      print("empty row teachers");
      return new Container();
    }

    //teachers with no child attached to their account
    else {
      print("no children data");
      return new Row(children: <Widget>[
        new Container(
            width: sW/1.2,
            height: 0,
            padding: EdgeInsets.all(10),
            child: new Text("No children have been assigned to your account. A parent must,from their account,assign your username to the child they choose to have monitored by you.")
        )
      ]
      );
    }
  }

  Widget displayUserInfo(sW,sH) {
    if(login.MyApp.pemail != '' && login.MyApp.temail == '') {
      print("parent info");
      return new Scaffold(
          body: loadCircle
              ? loadingScreen()
              :
          //Welcome user
          new Column(children: <Widget>[
            new Row(children: <Widget>[
              new Container(
                color: Colors.lightBlueAccent,
                width: sW,
                height: sH / 10,
                alignment: Alignment(-0.9, 0.6),
                child: new Text("Hello, " + uname,
                    textScaleFactor: 2,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ]),
            new Row(children: <Widget>[
              new Container(
                  width: sW,
                  height: sH / 6,
                  padding: EdgeInsets.only(top:0,left:10,right:10,bottom:0),
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Row(children: <Widget>[
                          new Text("Parent Information    ",
                              textAlign: TextAlign.left,
                              textScaleFactor: 2,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9)),
                          new IconButton(icon: new Icon(const IconData(58313,
                              fontFamily: 'MaterialIcons')),onPressed:() {
                            Navigator.push(context,
                              MaterialPageRoute(builder: (context) => parentEdit()),);
                          }
                          ),
                        ]),
                        Divider(color: Colors.black),
                        new RichText(
                          textScaleFactor: 1.5,
                          text: new TextSpan(
                            text: "Email:            ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 10),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: email,
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 9))
                            ],
                          ),
                        ),
                        new SizedBox(height: 10),
                        new RichText(
                          textScaleFactor: 1.5,
                          text: new TextSpan(
                            text: "Username:   ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 10),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: uname,
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 9))
                            ],
                          ),
                        ),
                      ])),
            ]),
            new Row(children: <Widget>[
              new Container(
                  width: sW,
                  height: sH / 7.3,
                  padding: EdgeInsets.only(
                      left: 10, top: 10, right: 10, bottom: 0),
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Row(children: <Widget>[
                          new Text("Child Information      ",
                              textAlign: TextAlign.left,
                              textScaleFactor: 2,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9)),
                          new IconButton(icon: new Icon(const IconData(58313,
                              fontFamily: 'MaterialIcons')),onPressed:() {
                            Navigator.push(context,
                              MaterialPageRoute(builder: (context) => childEdit()),);
                          }
                          ),
                          new SizedBox(width: 35),
                          new Text("Add Child",
                              textScaleFactor: 2,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 8)),
                          new Icon(
                              const IconData(57671,
                                  fontFamily: 'MaterialIcons'),
                              size: 30),
                        ]),
                        //new SizedBox(height: 20),
                        Divider(color: Colors.black),
                        showTracker(sW,sH,tcid,activeChild,someData),
                      ])),
            ]),
            displayChildrenInfo(sW, sH, cid.length, context, someData,cuname,cage,color),
            displayChildrenNames(sW, sH, cid, current_cid, someData),
            displayChildrenGameInfo(sW, sH, someData)
          ]));
    }
    if (login.MyApp.temail != '' && login.MyApp.pemail == '') {
      print("teacher info");
      return new Scaffold(
          body: loadCircle
              ? loadingScreen()
              :
          //Welcome user
          new Column(children: <Widget>[
            new Row(children: <Widget>[
              new Container(
                color: Colors.lightBlueAccent,
                width: sW,
                height: sH / 10,
                alignment: Alignment(-0.9, 0.6),
                child: new Text("Hello, " + tuname,
                    textScaleFactor: 2,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ]),
            new Row(children: <Widget>[
              new Container(
                  width: sW,
                  height: sH / 4.5,
                  padding: EdgeInsets.all(10),
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Row(children: <Widget>[
                          new Text("Teacher Information    ",
                              textAlign: TextAlign.left,
                              textScaleFactor: 2,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9)),
                          new Icon(const IconData(58313,
                              fontFamily: 'MaterialIcons')),
                        ]),
                        Divider(color: Colors.black),
                        new RichText(
                          textScaleFactor: 1.5,
                          text: new TextSpan(
                            text: "Email:                   ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 10),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: temail,
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 9))
                            ],
                          ),
                        ),
                        new SizedBox(height: 5),
                        new RichText(
                          textScaleFactor: 1.5,
                          text: new TextSpan(
                            text: "Username:          ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 10),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: tuname,
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 9))
                            ],
                          ),
                        ),
                        new SizedBox(height: 5),
                        new RichText(
                          textScaleFactor: 1.5,
                          text: new TextSpan(
                            text: "Class Number:   ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 10),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: tclassnum,
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 9))
                            ],
                          ),
                        ),
                        new SizedBox(height: 5),
                        new RichText(
                          textScaleFactor: 1.5,
                          text: new TextSpan(
                            text: "Age Group:         ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 10),
                            children: <TextSpan>[
                              new TextSpan(
                                  text: tagegroup,
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 9))
                            ],
                          ),
                        ),
                      ])),
            ]),
            new Row(children: <Widget>[
              new Container(
                  width: sW,
                  height: sH / 13.5,
                  padding: EdgeInsets.only(
                      left: 10, top: 10, right: 10, bottom: 3),
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Row(children: <Widget>[
                          new Text("Child Information      ",
                              textAlign: TextAlign.left,
                              textScaleFactor: 2,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9)),
                        ]),
                        Divider(color: Colors.black),
                        showTracker(sW,sH,tcid,activeChild,someData),
                      ])),
            ]),
            displayChildrenInfo(sW, sH, tcid.length, context, someData,tcuname,tcage,color),
            displayChildrenNames(sW, sH, tcid, current_cid, someData),
            displayChildrenGameInfo(sW, sH, someData)
          ]));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    //function to display whole profile page
    return displayUserInfo(screenWidth,screenHeight);
  }
}
