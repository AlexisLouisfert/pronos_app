import 'team.dart';
import 'score.dart';

class Result {
  Team? winner; 
  Score finalScore;
  Score halfTimeScore;

  Result({
    this.winner,
    required this.finalScore,
    required this.halfTimeScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'winnerId': winner?.id, 
      'finalScore': finalScore.toJson(),
      'halfTimeScore': halfTimeScore.toJson(),
    };
  }

  factory Result.fromJson(Map<String, dynamic> json, List<Team> allTeams) {
    Team? w;
    if (json['winnerId'] != null) {
      w = allTeams.firstWhere((t) => t.id == json['winnerId']);
    }
    return Result(
      winner: w,
      finalScore: Score.fromJson(json['finalScore']),
      halfTimeScore: Score.fromJson(json['halfTimeScore']),
    );
  }
}