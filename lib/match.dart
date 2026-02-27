import 'team.dart';
import 'result.dart';
import 'bet.dart';
import 'bettor.dart';
import 'score.dart';

class Match {
  int id;
  DateTime date;
  String place;
  Team home;
  Team visitors;
  Result? result;
  List<Bet> bets; 

  Match({
    required this.id,
    required this.date,
    required this.place,
    required this.home,
    required this.visitors,
    this.result,
    this.bets = const [],
  });

  void addBet(Bet newBet) {
    bets.add(newBet);
  }

  void removeBet(int betId) {
    bets.removeWhere((b) => b.id == betId);
  }

  static Match createFromInput({
    required Team home,
    required Team visitors,
    required String finalHome,
    required String finalVis,
    required String halfHome,
    required String halfVis,
  }) {
    Result? matchResult;

    if (finalHome.isNotEmpty && finalVis.isNotEmpty && halfHome.isNotEmpty && halfVis.isNotEmpty) {
      Team? winner;
      int fHome = int.parse(finalHome);
      int fVis = int.parse(finalVis);
      
      if (fHome > fVis) winner = home;
      if (fVis > fHome) winner = visitors;

      matchResult = Result(
        winner: winner,
        finalScore: Score(home: fHome, visitors: fVis),
        halfTimeScore: Score(home: int.parse(halfHome), visitors: int.parse(halfVis)),
      );
    }

    return Match(
      id: DateTime.now().millisecondsSinceEpoch,
      date: DateTime.now(),
      place: "TBD",
      home: home,
      visitors: visitors,
      result: matchResult,
      bets: [], 
    );
  }

  void updateResult({
    required String finalHome,
    required String finalVis,
    required String halfHome,
    required String halfVis,
  }) {
    if (finalHome.isNotEmpty && finalVis.isNotEmpty && halfHome.isNotEmpty && halfVis.isNotEmpty) {
      Team? winner;
      int fHome = int.parse(finalHome);
      int fVis = int.parse(finalVis);

      if (fHome > fVis) winner = home;
      if (fVis > fHome) winner = visitors;

      result = Result(
        winner: winner,
        finalScore: Score(home: fHome, visitors: fVis),
        halfTimeScore: Score(home: int.parse(halfHome), visitors: int.parse(halfVis)),
      );
    } else {
      result = null; 
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'place': place,
      'homeId': home.id,
      'visitorsId': visitors.id,
      'result': result?.toJson(),
      'bets': bets.map((b) => b.toJson()).toList(),
    };
  }

  factory Match.fromJson(Map<String, dynamic> json, List<Team> allTeams, List<Bettor> allBettors) {
    Match m = Match(
      id: json['id'],
      date: DateTime.parse(json['date']),
      place: json['place'],
      home: allTeams.firstWhere((t) => t.id == json['homeId']),
      visitors: allTeams.firstWhere((t) => t.id == json['visitorsId']),
      result: json['result'] != null ? Result.fromJson(json['result'], allTeams) : null,
      bets: [],
    );
    if (json['bets'] != null) {
      m.bets = (json['bets'] as List).map((b) => Bet.fromJson(b, m, allBettors, allTeams)).toList();
    }
    return m;
  }
}