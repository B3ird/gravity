import 'dart:async';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flame/flame.dart';
import 'package:flame/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_sample/gravity-game.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

//APP
void main() {
  runApp(MyApp());
}

class Global {
  static bool musicEnabled = false;
  static String language = "fr";
  static AudioPlayer musicAudioPlayer = AudioPlayer();
  static AudioCache soundAudioPlayer = AudioCache();
  static FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader:
        FileTranslationLoader(useCountryCode: false, fallbackFile: 'en', basePath: 'assets/i18n', forcedLocale: Locale('fr')),
  );
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) async {
    await FlutterI18n.refresh(context, newLocale);
    MyAppState state = context.findAncestorStateOfType<MyAppState>();
    state.changeLanguage(newLocale);
  }

  static Future<Locale> getLocale(BuildContext context) async {
    MyAppState state = context.findAncestorStateOfType<MyAppState>();
    return state._locale;
  }

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Locale _locale = Locale("fr");

  changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

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
      home: Splash(),
      localizationsDelegates: [
        Global.flutterI18nDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      builder: FlutterI18n.rootAppBuilder(),
    );
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
    Timer(Duration(milliseconds: 1700), () {
      setState(() {
        visibilityLogo = true;
      });
    });
    Timer(Duration(seconds: 4), () {
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Home()));
    });
    super.initState();
  }

  bool visibilityLogo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: <Widget>[
          visibilityLogo
              ? Image.asset(
                  "assets/images/bg/splash.png",
                  fit: BoxFit.cover,
                )
              : Container(),
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

//Music switch
class MusicSwitch extends StatefulWidget {
  @override
  MusicSwitchState createState() => MusicSwitchState();
}

class MusicSwitchState extends State<MusicSwitch> {
  bool playMusic = Global.musicEnabled; //default

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
    return Row(
      children: <Widget>[
        Icon(
          Icons.audiotrack,
          color: Colors.amber,
        ),
        Switch(
          onChanged: (state) {
            setState(() {
              playMusic = state;
              Global.musicEnabled = state; //TODO MANAGE IT BETTER
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
    );
  }
}

//HOME

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();

  static void refresh(BuildContext context) async {
    HomeState state = context.findAncestorStateOfType<HomeState>();
    state.refresh();
  }
}

class HomeState extends State<Home> {
  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          padding: EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 16),
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage("assets/images/bg/background.png"),
            fit: BoxFit.cover,
          )),
          child: Stack(children: [
            Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
              Image.asset("assets/images/ui/logo.png", fit: BoxFit.fitWidth),
              MaterialButton(
                minWidth: double.infinity,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.amber,
                padding: EdgeInsets.all(16.0),
                child: Text(
                  FlutterI18n.translate(context, "home.play"),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.amber)),
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    FlutterI18n.translate(context, "home.scores"),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.amber)),
                  child: Text(
                    FlutterI18n.translate(context, "home.help"),
                    style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Help()));
                  },
                ),
              ),
              // Container(
              //   margin: EdgeInsets.only(top: 16),
              //   child: MaterialButton(
              //     minWidth: double.infinity,
              //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.amber)),
              //     padding: EdgeInsets.all(16.0),
              //     child: Text(
              //       FlutterI18n.translate(context, "home.settings"),
              //       style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
              //     ),
              //     onPressed: () {
              //       Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Settings()));
              //     },
              //   ),
              // ),
              Container(
                margin: EdgeInsets.only(top: 16),
                child: MaterialButton(
                  minWidth: double.infinity,
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    FlutterI18n.translate(context, "home.exit"),
                    style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    confirmExit(context);
                  },
                ),
              ),
            ]),
            Align(
              alignment: Alignment.topLeft,
              child: MusicSwitch(),
            ),
            Align(alignment: Alignment.topRight, child: LanguageSwitch()),
          ]),
        ));
  }
}

//Dialog quit

void confirmExit(BuildContext context) {
  showDialog(
      context: context,
      builder: (_) => AlertDialog(
            backgroundColor: Colors.amber,
            title: Text(FlutterI18n.translate(context, "dialog.exit.title")),
            content: Text(FlutterI18n.translate(context, "dialog.exit.desc")),
            actions: <Widget>[
              MaterialButton(
                child: Text(FlutterI18n.translate(context, "dialog.exit.cancel")),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              MaterialButton(
                color: Colors.red,
                child: Text(FlutterI18n.translate(context, "dialog.exit.confirm")),
                onPressed: () {
                  Global.soundAudioPlayer.play("audio/exit.mp3");
                  Global.musicAudioPlayer.stop();
                  SystemNavigator.pop();
                },
              ),
            ],
          ));
}

//GAME

void initFlame() async {
  WidgetsFlutterBinding.ensureInitialized();
  Util flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setOrientation(DeviceOrientation.portraitUp);
}

class MyGame extends StatefulWidget {
  @override
  MyGameState createState() => MyGameState();
}

class MyGameState extends State<MyGame> with WidgetsBindingObserver {

  GarvityGame game;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initFlame();
    game = GarvityGame();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused){
      game.setPause(true);
    } else if (state == AppLifecycleState.resumed){
      game.setPause(false);
    }
  }

  @override
  Widget build(BuildContext context) {

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
              child: Text(FlutterI18n.translate(context, "game.back")),
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ]));
  }
}

//CONTACT FORM

class ContactForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerMessage = TextEditingController();

  Future<bool> sendMessage(BuildContext context) async {
    var params = Map<String, dynamic>();
    params['name'] = _controllerName.text;
    params['message'] = _controllerMessage.text;
    params['mail'] = "gravity@noreply.com";

    http.Response response = await http.post(
      'http://julienmerle.com/public/api/contact.php',
      headers: <String, String>{'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'},
      body: params,
    );
    if (response.statusCode == 200) {
      print("message sent " + response.body.toString());
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(FlutterI18n.translate(context, "contact.sent"))));
      _controllerMessage.text = "";
      return true;
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(FlutterI18n.translate(context, "contact.error"))));
      print("message NOT sent code " + response.statusCode.toString());
      return false;
      // throw Exception('Failed to send message');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(children: <Widget>[
          Align(
            child: Text(FlutterI18n.translate(context, "contact.title"), style: TextStyle(fontSize: 20, color: Colors.amber)),
            alignment: Alignment.centerLeft,
          ),
          TextFormField(
            controller: _controllerName,
            validator: (value) {
              if (value.isEmpty) {
                return FlutterI18n.translate(context, "contact.validation");
              }
              return null;
            },
            keyboardType: TextInputType.name,
            cursorColor: Colors.amber,
            decoration: InputDecoration(
                icon: Icon(
                  Icons.account_box_sharp,
                  color: Colors.grey,
                ),
                hoverColor: Colors.amber,
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                labelStyle: TextStyle(color: Colors.grey),
                labelText: FlutterI18n.translate(context, "contact.name_hint")),
          ),
          TextFormField(
            controller: _controllerMessage,
            validator: (value) {
              if (value.isEmpty) {
                return FlutterI18n.translate(context, "contact.validation");
              }
              return null;
            },
            minLines: 2,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            cursorColor: Colors.amber,
            decoration: InputDecoration(
                icon: Icon(
                  Icons.message,
                  color: Colors.grey,
                ),
                hoverColor: Colors.amber,
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                labelStyle: TextStyle(color: Colors.grey),
                labelText: FlutterI18n.translate(context, "contact.msg_hint")),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: MaterialButton(
                color: Colors.deepOrangeAccent,
                onPressed: () {
                  // Scaffold.of(context).showSnackBar(SnackBar(content: Text('Sending...')));
                  if (_formKey.currentState.validate()) {
                    FutureBuilder<bool>(
                      future: sendMessage(context),
                      builder: (context, AsyncSnapshot<bool> snapshot) {
                        return Container();
                      },
                    );
                  }
                },
                child: Text(FlutterI18n.translate(context, "contact.send"))),
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
            title: Text(FlutterI18n.translate(context, "about.title")),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, false),
            )),
        body: Container(
            padding: EdgeInsets.all(16),
            child: Stack(children: <Widget>[
              Column(children: <Widget>[
                Row(children: <Widget>[
                  Image.asset("assets/images/ui/b3ird.png", width: 30, fit: BoxFit.fitWidth),
                  Container(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        "B3ird",
                        style: TextStyle(fontSize: 20, color: Colors.amber),
                      ))
                ]),
                Container(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    FlutterI18n.translate(context, "about.me"),
                    softWrap: true,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 32),
                  child: ContactForm(),
                ),
              ]),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: MaterialButton(
                      child: Text(FlutterI18n.translate(context, "about.visit")),
                      color: Colors.transparent,
                      textColor: Colors.deepOrangeAccent,
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Site()));
                      }))
            ])));
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
          return snapshot.data.length > 0
              ? ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (context, index) {
                    String score = snapshot.data[index].toString() + "pts";
                    return Container(
                        padding: EdgeInsets.only(top: 16, bottom: 16),
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.deepOrangeAccent, width: 1))),
                        child: Row(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(padding: EdgeInsets.only(left: 16), child: Text("#" + (index + 1).toString())),
                            ),
                            Expanded(
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Container(
                                        padding: EdgeInsets.only(right: 16),
                                        child: Text(
                                          score,
                                          style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold),
                                        )))),
                          ],
                        ));
                  },
                )
              : Padding(
                  padding: EdgeInsets.all(32),
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/characters/player_right.png",
                          width: 30,
                        ),
                        Expanded(
                          child: Container(
                            child: Text(
                              FlutterI18n.translate(context, "scores.empty"),
                              softWrap: true,
                            ),
                            padding: EdgeInsets.only(left: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
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
            title: Text(FlutterI18n.translate(context, "scores.title")),
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

//Language switch
class LanguageSwitch extends StatefulWidget {
  @override
  LanguageSwitchState createState() => LanguageSwitchState();
}

class LanguageSwitchState extends State<LanguageSwitch> {
  String dropdownValue = Global.language.toUpperCase();

  void changeLanguage() async {
    Global.language = dropdownValue.toLowerCase();
    MyApp.setLocale(context, Locale(dropdownValue.toLowerCase()));
    // Home.refresh(context); TODO FIX PARAM SETTINGS ON HOME
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: Icon(
        Icons.flag,
        color: Colors.grey,
      ),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.amber),
      underline: Container(
        height: 2,
        color: Colors.grey,
      ),
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
          changeLanguage();
        });
      },
      items: <String>['FR', 'EN'].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

//OPTION
class Help extends StatefulWidget {
  @override
  createState() {
    return HelpState();
  }
}

class HelpState extends State<Help> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(FlutterI18n.translate(context, "help.title")),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, false),
          )),
      body: Container(
          padding: EdgeInsets.all(16),
          child: Column(children: <Widget>[
            Text(
              FlutterI18n.translate(context, "help.rules"),
              style: TextStyle(fontSize: 20, color: Colors.amber),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Container(
                child: Text(
                  FlutterI18n.translate(context, "help.aim"),
                  softWrap: true,
                ),
                padding: EdgeInsets.only(left: 16),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text(
                FlutterI18n.translate(context, "help.legend"),
                style: TextStyle(fontSize: 20, color: Colors.amber),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Row(children: [
                Image.asset(
                  "assets/images/characters/player_front.png",
                  width: 30,
                ),
                Flexible(
                  child: Container(
                    child: Text(
                      FlutterI18n.translate(context, "help.player"),
                      softWrap: true,
                    ),
                    padding: EdgeInsets.only(left: 16),
                  ),
                ),
              ]),
            ),
            Container(
              padding: EdgeInsets.only(top: 16),
              child: Row(children: [
                Image.asset(
                  "assets/images/props/bonus.png",
                  width: 30,
                ),
                Flexible(
                  child: Container(
                    child: Text(
                      FlutterI18n.translate(context, "help.bonus"),
                      softWrap: true,
                    ),
                    padding: EdgeInsets.only(left: 16),
                  ),
                ),
              ]),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/props/meteor.png",
                    width: 30,
                  ),
                  Flexible(
                    child: Container(
                      child: Text(
                        FlutterI18n.translate(context, "help.meteor"),
                        softWrap: true,
                      ),
                      padding: EdgeInsets.only(left: 16),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/props/sun.png",
                    width: 30,
                  ),
                  Flexible(
                    child: Container(
                      child: Text(
                        FlutterI18n.translate(context, "help.sun"),
                        softWrap: true,
                      ),
                      padding: EdgeInsets.only(left: 16),
                    ),
                  ),
                ],
              ),
            ),
          ])),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.auto_awesome),
        label: Text(FlutterI18n.translate(context, "help.about")),
        backgroundColor: Colors.deepOrangeAccent,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => About()));
        },
      ),
    );
  }
}

//SETTINGS
class Settings extends StatefulWidget {
  @override
  createState() {
    return SettingsState();
  }
}

class SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(FlutterI18n.translate(context, "settings.title")),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, false),
          )),
      body: Container(
          padding: EdgeInsets.all(16),
          child: Stack(children: <Widget>[
            Column(children: <Widget>[
              Row(children: [
                Expanded(child: Text(FlutterI18n.translate(context, "settings.music"))),
                Align(
                  child: MusicSwitch(),
                  alignment: Alignment.centerRight,
                )
              ]),
              Row(children: [
                Expanded(child: Text(FlutterI18n.translate(context, "settings.language"))),
                Align(
                  child: LanguageSwitch(),
                  alignment: Alignment.centerRight,
                )
              ]),
            ]),
            Align(
              child: Text(
                'Version 0.0.1',
                style: TextStyle(color: Colors.grey, fontSize: 12.0),
              ),
              alignment: Alignment.bottomCenter,
            )
          ])),
    );
  }
}
