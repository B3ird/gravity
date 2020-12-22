import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flame/flame.dart';
import 'package:flame/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sample/gravity-game.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

//APP
void main() {
  runApp(MyApp());
}

class Global {
  static AudioPlayer musicAudioPlayer = AudioPlayer();
  static AudioCache soundAudioPlayer = AudioCache();
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]); //fullscreen
    return MaterialApp(
        color: Colors.black,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.deepOrangeAccent,
          backgroundColor: Colors.black,
        ),
        home: Splash());
  }
}

//SPLASH
class Splash extends StatefulWidget {
  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<Splash> {

  @override
  void initState() {
    Global.soundAudioPlayer.play("audio/splash.mp3", volume: 0.2);
    Timer(Duration(seconds: 4), () {
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()));
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: <Widget>[
          Image.asset(
            "assets/images/bg/splash.png",
            fit: BoxFit.cover,
          ),
          Align(
            child: Text(
              'Version 0.0.1',
              style: TextStyle(color: Colors.grey, fontSize: 12.0),
            ),
            alignment: Alignment.bottomCenter,
          )
        ]));
  }
}

//HOME

//music switch
class MusicSwitch extends StatefulWidget {
  @override
  MusicSwitchState createState() => MusicSwitchState();
}

class MusicSwitchState extends State<MusicSwitch> {
  bool playMusic = false; //default

  void startMusic() {
    if (playMusic) {
      Flame.audio.loopLongAudio('music.mp3', volume: 0.4).then((player) {
        Global.musicAudioPlayer = player;
      });
    }
  }

  @override
  void initState() {
    startMusic();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 32, left: 32),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.audiotrack,
            color: Colors.amber,
          ),
          Switch(
            onChanged: (state) {
              setState(() {
                playMusic = state;
              });
              if (playMusic) {
                startMusic();
              } else {
                Global.musicAudioPlayer.pause();
              }
            },
            value: playMusic,
            activeTrackColor: Colors.amber,
            activeColor: Colors.deepOrangeAccent,
          )
        ],
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.auto_awesome),
          label: Text("About"),
          backgroundColor: Colors.deepOrangeAccent,
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => About()));
          },
        ),
        body: Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage("assets/images/bg/background.png"),
            fit: BoxFit.cover,
          )),
          child: Stack(children: [
            MusicSwitch(),
            Center(
                child: Container(
                    margin: EdgeInsets.all(16),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.asset("assets/images/ui/logo.png", fit: BoxFit.fitWidth),
                          MaterialButton(
                            minWidth: double.infinity,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            color: Colors.amber,
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              "Play",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Global.soundAudioPlayer.play("audio/play.mp3");
                              Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => MyGame()));
                            },
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 16),
                            child: MaterialButton(
                              minWidth: double.infinity,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.amber)),
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                "Score",
                                style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Score()));
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 16),
                            child: MaterialButton(
                              minWidth: double.infinity,
                              padding: EdgeInsets.all(16.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.amber)),
                              child: Text(
                                "Exit",
                                style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                confirmExit(context);
                              },
                            ),
                          ),
                        ])))
          ]),
        ));
  }
}

void confirmExit(BuildContext context) {
  showDialog(
      context: context,
      builder: (_) => AlertDialog(
            backgroundColor: Colors.amber,
            title: Text("Quit game ?"),
            content: Text("Game will be closed"),
            actions: <Widget>[
              MaterialButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              MaterialButton(
                color: Colors.red,
                child: Text('Confirm'),
                onPressed: () {
                  Global.soundAudioPlayer.play("audio/exit.mp3");
                  Global.musicAudioPlayer.stop();
                  SystemNavigator.pop();
                },
              ),
            ],
          ));
}

//GAME TEST

void initFlame() async {
  WidgetsFlutterBinding.ensureInitialized();
  Util flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setOrientation(DeviceOrientation.portraitUp);
}

class MyGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //TEST
    //result : no work better than resize call in game
    var screenSize = MediaQuery.of(context).size;
    // var width = screenSize.width;
    // var height = screenSize.height;
    // print("screensize : " + width.toString() + " " + height.toString());

    initFlame();
    GarvityGame game = GarvityGame(screenSize);

    return Scaffold(
        backgroundColor: Colors.black,
        // CREATE ISSUE WITH HEIGHT
        // appBar: AppBar(
        //   backgroundColor: Colors.transparent,
        //   leading: BackButton(
        //       color: Colors.white,
        //       onPressed: () {
        //         print("close");
        //         Navigator.pop(context, false);
        //       }),
        // ),
        body: Stack(children: <Widget>[
          Container(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: game.onTapDown,
              onPanStart: game.onPanStart,
              onPanUpdate: game.onPanUpdate,
              onPanEnd: game.onPanEnd,
              child: game.widget,
            ),
          ),
          MaterialButton(
              child: Text("Back"),
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ]));
  }
}

//CONTACT FORM
Future<bool> sendMessage(String message, BuildContext context) async {
  var params = Map<String, dynamic>();
  params['name'] = "Flutter game : Gravity";
  params['message'] = message;
  params['mail'] = "gravity@noreply.com";

  http.Response response = await http.post(
    'http://julienmerle.com/public/api/contact.php',
    headers: <String, String>{'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
    body: params,
  );
  if (response.statusCode == 200) {
    print("message sent " + response.body.toString());
    Scaffold.of(context).showSnackBar(SnackBar(content: Text('Message sent !')));
    return true;
  } else {
    print("message NOT sent code " + response.statusCode.toString());
    return false;
    // throw Exception('Failed to send message');
  }
}

class ContactForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(children: <Widget>[
          Text("You can send me a message :", style: TextStyle(fontSize: 20, color: Colors.amber)),
          TextFormField(
            controller: _controller,
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter your message';
              }
              return null;
            },
            cursorColor: Colors.amber,
            decoration: InputDecoration(
                hoverColor: Colors.amber,
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                labelStyle: TextStyle(color: Colors.grey),
                labelText: "Enter your message here..."),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: MaterialButton(
                color: Colors.deepOrangeAccent,
                onPressed: () {
                  // Scaffold.of(context).showSnackBar(SnackBar(content: Text('Sending...')));
                  if (_formKey.currentState.validate()) {
                    FutureBuilder<bool>(
                      future: sendMessage(_controller.text, context),
                      builder: (context, AsyncSnapshot<bool> snapshot) {
                        return Container();
                      },
                    );
                  }
                },
                child: Text('Send')),
          )
        ]));
  }
}

//ABOUT
class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: true,
            //`true` if you want Flutter to automatically add Back Button when needed,
            //or `false` if you want to force your own back button every where
            title: Text('About'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, false),
            )),
        body: Stack(children: <Widget>[
          Container(
              padding: EdgeInsets.all(16),
              child: Column(children: <Widget>[
                Row(children: <Widget>[
                  Image.asset("assets/images/ui/b3ird.png", width: 50, fit: BoxFit.fitWidth),
                  Container(
                      padding: EdgeInsets.only(left: 16),
                      child: Text(
                        "B3ird",
                        style: TextStyle(fontSize: 20, color: Colors.amber),
                      ))
                ]),
                Container(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    "Hello, this is my first flutter app using Flame 2D engine !"
                    "The project was carried out with the aim to learn the flutter basics.",
                    softWrap: true,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 32),
                  child: ContactForm(),
                ),
              ])),
          Align(
              alignment: Alignment.bottomCenter,
              child: MaterialButton(
                  child: Text("Visit my website"),
                  color: Colors.transparent,
                  textColor: Colors.deepOrangeAccent,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Site()));
                  }))
        ]));
  }
}

//SCORE LIST
class ScoreList extends StatelessWidget {
  Future<List<int>> getScores() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> scores = prefs.getStringList("scores");
    if (scores == null) {
      scores = List();
    }
    List<int> scoresInt = List();
    scores.forEach((element) {
      scoresInt.add(int.parse(element));
    });
    scoresInt.sort((a, b) => b.compareTo(a));
    return scoresInt;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>>(
        future: getScores(),
        builder: (context, AsyncSnapshot<List<int>> snapshot) {
          if (snapshot.connectionState == ConnectionState.none && snapshot.hasData == null) {
            //print('project snapshot data is: ${projectSnap.data}');
            return Container();
          }
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              String score = snapshot.data[index].toString() + "pts";
              return Column(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.deepOrangeAccent, width: 2))),
                      child: Text(
                        score,
                        style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
                      )),
                ],
              );
            },
          );
        });
  }
}

class Score extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: true,
            //`true` if you want Flutter to automatically add Back Button when needed,
            //or `false` if you want to force your own back button every where
            title: Text('Score'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, false),
            )),
        body: ScoreList());
  }
}

//WEBVIEW

class Site extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: true,
            //`true` if you want Flutter to automatically add Back Button when needed,
            //or `false` if you want to force your own back button every where
            title: Text('Portfolio'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, false),
            )),
        body: WebView(
          initialUrl: "https://julienmerle.com",
          javascriptMode: JavascriptMode.unrestricted,
        ));
  }
}
