import 'tournament.dart';
import 'team.dart';
import 'bettor.dart';
import 'match.dart';
import 'score.dart';
import 'result.dart';
import 'bet.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppData {
  List<Tournament> tournaments = [];
  List<Team> teams = [];
  List<Bettor> bettors = [];

  AppData();

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    Map<String, dynamic> fullData = {
      'teams': teams.map((t) => t.toJson()).toList(),
      'bettors': bettors.map((b) => b.toJson()).toList(),
      'tournaments': tournaments.map((t) => t.toJson()).toList(),
    };

    await prefs.setString('app_data_backup', jsonEncode(fullData));
    print("Données sauvegardées avec succès !");
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('app_data_backup');

    if (jsonString != null) {
      Map<String, dynamic> fullData = jsonDecode(jsonString);
      teams = (fullData['teams'] as List).map((t) => Team.fromJson(t)).toList();
      bettors = (fullData['bettors'] as List).map((b) => Bettor.fromJson(b)).toList();
      tournaments = (fullData['tournaments'] as List).map((t) => Tournament.fromJson(t, teams, bettors)).toList();
      print("Données chargées depuis la sauvegarde !");
    } else {
      initMockData();
      await saveData();
    }
  }

  void initMockData() {
    var ana = Bettor(id: 1, firstName: "Ana", lastName: "Doe");
    var charlie = Bettor(id: 2, firstName: "Charlie", lastName: "Smith");
    var bob = Bettor(id: 3, firstName: "Bob", lastName: "Johnson");
    bettors = [ana, charlie, bob];

    var france = Team(id: 1, name: "France");
    var maroc = Team(id: 2, name: "Maroc");
    var allemagne = Team(id: 3, name: "Allemagne");
    var italie = Team(id: 4, name: "Italie");
    var paraguay = Team(id: 5, name: "Paraguay");
    teams = [france, maroc, allemagne, italie, paraguay];

    var matchFranceMaroc = Match(
      id: 1,
      date: DateTime.now(),
      place: "Stade de France",
      home: france,
      visitors: maroc,
    );

    matchFranceMaroc.bets = [
      Bet(
        id: 1, author: ana, match: matchFranceMaroc,
        result: Result(winner: france, finalScore: Score(home: 3, visitors: 1), halfTimeScore: Score(home: 2, visitors: 1)),
      ),
      Bet(
        id: 2, author: charlie, match: matchFranceMaroc,
        result: Result(winner: maroc, finalScore: Score(home: 3, visitors: 1), halfTimeScore: Score(home: 2, visitors: 1)),
      ),
      Bet(
        id: 3, author: bob, match: matchFranceMaroc,
        result: Result(winner: france, finalScore: Score(home: 2, visitors: 1), halfTimeScore: Score(home: 1, visitors: 1)),
      ),
    ];

    var matchAllemagneItalie = Match(
      id: 2,
      date: DateTime.now().subtract(Duration(days: 1)),
      place: "Berlin",
      home: allemagne,
      visitors: italie,
      result: Result(
        winner: allemagne,
        finalScore: Score(home: 3, visitors: 1),
        halfTimeScore: Score(home: 2, visitors: 1)
      )
    );

    // 4. Création du Tournoi
    tournaments = [
      Tournament(id: 1, name: "Coupe du Monde '26", matches: [matchFranceMaroc, matchAllemagneItalie]),
      Tournament(id: 2, name: "JO '28", matches: []),
      Tournament(id: 3, name: "Ligue 1 25-26", matches: []),
    ];
  }
}