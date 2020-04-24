// import 'package:http/http.dart' as http;
// import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'web_service.dart';

class Question 
{
  
  bool qAnswer;
  String qText;

  Question({this.qText, this.qAnswer});

  factory Question.fromJson(Map<String,dynamic> json) {
    return Question(
      qText: Uri.decodeComponent(json['question']), 
      qAnswer: json['correct_answer']=="True"?true:false, 
    );
  }

  static Resource<List<Question>> get all 
  {
    
      return Resource(
        url: 'https://opentdb.com/api.php?amount=10&encode=url3986',
        parse: (response) {
          final result = json.decode(response.body); 
          Iterable list = result['results'];
          return list.map((model) => Question.fromJson(model)).toList();
        }
      );

  }

}

class QuizBrain{
  
  static int _questionNumber = 0;

  static int _correctScore = 0;

  static List<Question> _questionBank = [
    // Question(qText:'You can lead a cow down stairs but not up stairs.',qAnswer:false),
    // Question(qText:'Approximately one quarter of human bones are in the feet.',qAnswer:true),
    // Question(qText:'A slug\'s blood is green.',qAnswer:true),
    // Question(qText:'Some cats are actually allergic to humans',qAnswer: true),
    // Question(qText:'You can lead a cow down stairs but not up stairs.',qAnswer: false),
    // Question(qText:'Approximately one quarter of human bones are in the feet.',qAnswer: true),
    // Question(qText:'A slug\'s blood is green.',qAnswer: true),
    // Question(qText:'Buzz Aldrin\'s mother\'s maiden name was \"Moon\".',qAnswer: true),
    // Question(qText:'It is illegal to pee in the Ocean in Portugal.', qAnswer:true),
    // Question(qText:'No piece of square dry paper can be folded in half more than 7 times.',qAnswer:false),
    // Question(qText:'In London, UK, if you happen to die in the House of Parliament, you are technically entitled to a state funeral, because the building is considered too sacred a place.',qAnswer:true),
    // Question(qText:'The loudest sound produced by any animal is 188 decibels. That animal is the African Elephant.',qAnswer:false),
    // Question(qText:'The total surface area of two human lungs is approximately 70 square metres.',qAnswer:true),
    // Question(qText:'Google was originally called \"Backrub\".', qAnswer:true),
    // Question(qText:'Chocolate affects a dog\'s heart and nervous system; a few ounces are enough to kill a small dog.',qAnswer:true),
    // Question(qText:'In West Virginia, USA, if you accidentally hit an animal with your car, you are free to take it home to eat.',qAnswer:true),
  ];
  
  static void nextQuestion()
  {
    if(_questionNumber < _questionBank.length)
      _questionNumber++;
  }

  static String getQuestion()
  {
    return _questionBank[_questionNumber].qText;
  }

  static bool getAnswer()
  {
    return _questionBank[_questionNumber].qAnswer;
  }

  static int getQuestionNumber()
  {
    return _questionNumber;
  }

  static int getNumberOfQuestions()
  {
    return _questionBank.length;
  }

  static int getCorrectScore()
  {
    return _correctScore;
  }

  static void incrementCorrectScore()
  {
    _correctScore++;
  }

  static int getIncorrectScore()
  {
    return _questionNumber - _correctScore;
  }
 
  static int getQuestionsLeft()
  {
    return max(_questionBank.length - _questionNumber-1,0);
  }

  static bool gameEnd()
  {
    if(_questionNumber == (_questionBank.length) )
      return true;
    else
      return false;
  }
  static void reset()
  {
    fetchQuestionsFromAPI();
    _questionNumber = 0;
    _correctScore = 0;
  }

  
  static fetchQuestionsFromAPI()
  {
     Webservice().load(Question.all).then((questions){
       _questionBank = questions;
     });
     print('Questions Fetched');
  }

}