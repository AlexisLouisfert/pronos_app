import 'match.dart';
import 'team.dart';
import 'bettor.dart';

class Tournament {
  int id;
  String name;
  List<Match> matches;

  Tournament({
    required this.id,
    required this.name,
    this.matches = const [],
  });

  void addMatch(Match newMatch) {
    matches.add(newMatch);
  }

  void removeMatch(int matchId) {
    matches.removeWhere((m) => m.id == matchId);
  }

  //le ranking correspond au nombre de points gagnés par chaque joueur lors des matchs d'un meme tournoi (donc le classement sera différent selon le tournoi)
  Map<Bettor, int> getRanking(List<Bettor> allBettors) {
    Map<Bettor, int> scores = {for (var bettor in allBettors) bettor: 0};
    for (var match in matches) {
      if (match.result != null) {
        for (var bet in match.bets) {
          int pointsGagnes = 0;
          bool exactScore = (bet.result.finalScore.home == match.result!.finalScore.home) && (bet.result.finalScore.visitors == match.result!.finalScore.visitors);
          bool goodWinner = bet.result.winner?.id == match.result!.winner?.id;

          if (exactScore) {
            pointsGagnes = 3; 
          } else if (goodWinner) {
            pointsGagnes = 1; 
          }
          scores[bet.author] = (scores[bet.author] ?? 0) + pointsGagnes;
        }
      }
    }
    return scores;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'matches': matches.map((m) => m.toJson()).toList(),
    };
  }

  factory Tournament.fromJson(Map<String, dynamic> json, List<Team> allTeams, List<Bettor> allBettors) {
    return Tournament(
      id: json['id'],
      name: json['name'],
      matches: (json['matches'] as List).map((m) => Match.fromJson(m, allTeams, allBettors)).toList(),
    );
  }
}