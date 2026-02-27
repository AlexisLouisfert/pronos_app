import 'bettor.dart';
import 'match.dart';
import 'result.dart';
import 'team.dart';
import 'score.dart';

class Bet {
  int id;
  Bettor author;
  Match match;
  Result result;

  Bet({
    required this.id,
    required this.author,
    required this.match,
    required this.result,
  });

  static Bet createFromInput({
    required Bettor author,
    required Match match,
    required Team winner,
    required String finalHome,
    required String finalVis,
    required String halfHome,
    required String halfVis,
  }) {
    return Bet(
      id: DateTime.now().millisecondsSinceEpoch,
      author: author,
      match: match,
      result: Result(
        winner: winner,
        finalScore: Score(home: int.parse(finalHome), visitors: int.parse(finalVis)),
        halfTimeScore: Score(home: int.parse(halfHome), visitors: int.parse(halfVis)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': author.id, 
      'result': result.toJson(),
    };
  }

  factory Bet.fromJson(Map<String, dynamic> json, Match parentMatch, List<Bettor> allBettors, List<Team> allTeams) {
    return Bet(
      id: json['id'],
      author: allBettors.firstWhere((b) => b.id == json['authorId']),
      match: parentMatch,
      result: Result.fromJson(json['result'], allTeams),
    );
  }
}