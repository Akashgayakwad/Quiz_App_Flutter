import 'dart:core';
import 'package:flutter/material.dart';
import 'package:quizzler/quiz_brain.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';

void main() => runApp(Quizzler());


// class Routes {
//   // Route name constants
//   static const String FormPage = '/';
//   static const String QuizPage = '/quiz';

//   /// The map used to define our routes, needs to be supplied to [MaterialApp]
//   static Map<String, WidgetBuilder> getRoutes() {
//     return {
//       // Routes.FormPage: (context) => Formpage(),
//       Routes.QuizPage: (context) => QuizWidget(),
//     };
//   }
// }

List<String> difficultyLevels = ['Random','Easy','Medium','Hard'];
List<String> categories = ["Random","General Knowledge","Books","Film","Music","Musicals & Theatres",
 "Television","Video Games","Board Games","Science & Nature","Science: Computers","Science: Mathematics",
"Mythology","Sports","Geography","History","Politics","Art","Celebrities","Animals","Vehicles","Comics","Science: Gadgets",
"Japanese Anime & Manga","Cartoon & Animations"
];


List<DropdownMenuItem> itemList(List<String> options)
{
  List<DropdownMenuItem> itemList;
  itemList =options.map((String value) 
    {
      return new DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
  }
  ).toList();
    return itemList;
}

class Quizzler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QuizSelector(),
      // routes: Routes.getRoutes(),
    );
  }
}


class QuizSelector extends StatelessWidget {
  const QuizSelector({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
    decoration: BoxDecoration(
      image: DecorationImage(
          image: AssetImage("images/background.jpg"), 
          fit: BoxFit.cover
          ),
        ),
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.black26,
        title: Text('Select Quiz'),
        centerTitle: true,
      ),
      body: SafeArea(
        child:QuizForm(),
      ),
      ),
    );
  }
}


class QuizForm extends StatefulWidget {
  QuizForm({Key key}) : super(key: key);

  @override
  _QuizFormState createState() => _QuizFormState();
}

class _QuizFormState extends State<QuizForm> {
  var selectedDifficulty=null;

  @override
  var selectedCategory=null;

  Widget build(BuildContext context) {
    return Container(
       decoration: BoxDecoration(
       image: DecorationImage(
           image: AssetImage("images/background.jpg"), 
           fit: BoxFit.cover
           ),
         ),
       child: Center(
           child: Padding(
             padding: const EdgeInsets.symmetric(horizontal:50.0,vertical: 30.0),
             child: Column(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: <Widget>[
                 Image.asset('images/quizbanner2.png',height: 150.0,),
                 DropdownButton(
                   icon:Icon(Icons.keyboard_arrow_down,color: Colors.grey[500],),
                   elevation:3,
                   hint: Text(selectedCategory!=null?selectedCategory:'Select Category',
                     textAlign: TextAlign.center,
                     style: TextStyle(
                       color: Colors.grey[500],
                       fontSize: 20.0,
                     ),
                   ),
                   items: itemList(categories),
                   onChanged: (value){
                     print('Selected category is $value');
                     setState(() {
                       selectedCategory=value;
                     });
                   },
                 ),
                 DropdownButton(
                   icon:Icon(Icons.keyboard_arrow_down,color: Colors.grey[500],),
                   elevation:3,
                   hint: Text(selectedDifficulty!=null?selectedDifficulty:'Select Difficulty',
                     textAlign: TextAlign.center,
                     style: TextStyle(
                       color: Colors.grey[500],
                       fontSize: 20.0,
                     ),
                   ),
                   items: itemList(difficultyLevels),
                   onChanged: (value){
                     print('Selected Diffculty level is $value');
                     setState(() {
                       selectedDifficulty=value;
                     });
                   },
                 ),
                 Padding(
                   padding: EdgeInsets.all(15.0),
                   child: FlatButton(
                     textColor: Colors.white,
                     color: Colors.green,
                     child: Text('Start Quiz',
                       style: TextStyle(
                         color: Colors.white,
                         fontSize: 20.0,
                       ),
                     ),
                     onPressed: () {
                       final player = AudioCache();
                       player.play('start_quiz.ogg');
                       print('lets move to quiz');
                       Navigator.of(context)
                            .push(MaterialPageRoute<Null>(builder: (BuildContext context) {
                          return new QuizWidget();
                        }));
                     },
                   ),
                 ),
               ],
             ),
           ),
         ),
       );
  }
}

class QuizWidget extends StatelessWidget {
  const QuizWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/background.jpg"), 
              fit: BoxFit.cover
              ),
            ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black26,
          title: Text('Quizzler'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: QuizPage(),
          ),
        ),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  bool loadingStatus = true;

  @override
  void initState() {
      print('initializing state');
      callFetch().then((result){
        print('loading set to false');
        setState(() {
        loadingStatus=false;
        print('loading false');
      });
      print('state initailized');
      });
    super.initState();
  }

  Future<bool> callFetch()
  {
    print('loading set to true');
    setState(() {
        loadingStatus=true;
      });
    print('fetching');
    QuizBrain.fetchQuestionsFromAPI();
    print('fetching done');
    return Future.value(true);
  }

  void checkAndUpdate(bool option)
  {
    bool correctAnswer = QuizBrain.getAnswer();
    
    if(option==correctAnswer)
      setState(() {
        final player = AudioCache();
        player.play('correct.wav');
        QuizBrain.incrementCorrectScore();
        QuizBrain.nextQuestion();
      });
    else
      setState(() {
        final player = AudioCache();
        player.play('incorrect.wav');
        QuizBrain.nextQuestion();
      });
  }

  @override
  Widget build(BuildContext context) {
    return 
    Container(
      child: loadingStatus
      ?Center(child: Loading(indicator: BallPulseIndicator(), size: 50.0,color: Colors.white))
      :Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 1,
            child:Padding(
              padding: EdgeInsets.symmetric(vertical:8.0,horizontal: 10.0),
              child: Center(
                child: Text('Question(s) Left: ${QuizBrain.getQuestionsLeft()}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child:Padding(
              padding: EdgeInsets.symmetric(vertical:8.0,horizontal: 10.0),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                  Text('Correct: ${QuizBrain.getCorrectScore()}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                RaisedButton(
                  color: QuizBrain.gameEnd()?Colors.green[300]:Colors.blue[300],
                  onPressed: () {
                    setState(() {
                      loadingStatus=true;
                    });
                    QuizBrain.reset();
                    setState(() {
                      loadingStatus=false;
                    });
                  },
                  child: Text(
                    QuizBrain.gameEnd()
                    ?'Restart'
                    :'Reset',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      ),
                  ),
                ),
                Text('Incorrect: ${QuizBrain.getIncorrectScore()}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                ],),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Center(
                child: 
                QuizBrain.gameEnd()
                ?Text("Quiz Ended\nThanks For Playing!!\nClick reset to play again..",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.0,
                  color: Colors.white,
                ),
                )
                :Text(
                  QuizBrain.getQuestion(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25.0,
                    color: Colors.white,
                  ),
                )
                ,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: FlatButton(
                textColor: Colors.white,
                color: QuizBrain.gameEnd()?Colors.yellow:Colors.green,
                child: Text(
                  QuizBrain.gameEnd()?'Game Ended':'True',
                  style: TextStyle(
                    color: QuizBrain.gameEnd()?Colors.red:Colors.white,
                    fontSize: 20.0,
                  ),
                ),
                onPressed: () {
                  if(!QuizBrain.gameEnd())
                  checkAndUpdate(true);
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: FlatButton(
                color: QuizBrain.gameEnd()?Colors.yellow:Colors.red,
                child: Text(
                  QuizBrain.gameEnd()?'Game Ended':'False',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: QuizBrain.gameEnd()?Colors.red:Colors.white,
                  ),
                ),
                onPressed: () {
                  if(!QuizBrain.gameEnd())
                  checkAndUpdate(false);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}


