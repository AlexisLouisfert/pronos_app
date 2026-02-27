import 'package:flutter/material.dart';
import 'bet.dart';
import 'bettor.dart';
import 'match.dart';
import 'team.dart';
import 'tournament.dart';
import 'app_data.dart';

final AppData globalAppData = AppData();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await globalAppData.loadData(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Application de Pronostics',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TournamentsScreen(),
    );
  }
}

class MyBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const MyBottomNavBar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    Widget targetScreen;
    if (index == 0) {
      targetScreen = const TournamentsScreen();
    } else if (index == 1) {
      targetScreen = const MatchesScreen();
    } else {
      targetScreen = const BetsScreen();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => targetScreen),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black, width: 1.5)),
        color: Colors.white,
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events, color: currentIndex == 0 ? Colors.amber : Colors.grey, size: 30),
            label: 'Tournois',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag, color: currentIndex == 1 ? Colors.red : Colors.grey, size: 30),
            label: 'Matchs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on, color: currentIndex == 2 ? Colors.green : Colors.grey, size: 30),
            label: 'Paris',
          ),
        ],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

//écran tournois

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournaments:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: globalAppData.tournaments.length,
          itemBuilder: (context, index) {
            final tournament = globalAppData.tournaments[index];
            return Card(
              color: Colors.red[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.black, width: 1.5)),
              margin: const EdgeInsets.only(bottom: 20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TournamentDetailsScreen(
                        tournament: tournament,
                        bettors: globalAppData.bettors,
                        teams: globalAppData.teams,
                        navIndex: 1,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Center(child: Text(tournament.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500))),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const MyBottomNavBar(currentIndex: 0),
    );
  }
}

//écran matchs

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Match> allMatches = [];
    for (var tournament in globalAppData.tournaments) {
      allMatches.addAll(tournament.matches);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Matchs:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
        backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: allMatches.isEmpty 
          ? const Center(child: Text('Aucun match disponible.'))
          : ListView.builder(
              itemCount: allMatches.length,
              itemBuilder: (context, index) {
                final match = allMatches[index];
                String matchText = '${match.home.name} - ${match.visitors.name}';
                String subText = '';
                
                if (match.result != null) {
                  matchText = '${match.home.name} ${match.result!.finalScore.home} - ${match.result!.finalScore.visitors} ${match.visitors.name}';
                  subText = '(half : ${match.result!.halfTimeScore.home}-${match.result!.halfTimeScore.visitors})';
                }

                return Card(
                  color: Colors.green[200],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.black, width: 1.5)),
                  margin: const EdgeInsets.only(bottom: 15),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MatchBetsScreen(
                            match: match, 
                            bettors: globalAppData.bettors, 
                            navIndex: 2
                          ) 
                        ),
                      );
                    },
                    title: Text(matchText, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: subText.isNotEmpty ? Text(subText, textAlign: TextAlign.center) : null,
                  ),
                );
              },
            ),
      ),
      bottomNavigationBar: const MyBottomNavBar(currentIndex: 1),
    );
  }
}

//écran paris

class BetsScreen extends StatelessWidget {
  const BetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Bet> allBets = [];
    for (var tournament in globalAppData.tournaments) {
      for (var match in tournament.matches) {
        allBets.addAll(match.bets);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Bets:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
        backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: allBets.isEmpty 
          ? const Center(child: Text('Aucun pari effectué.'))
          : ListView.builder(
              itemCount: allBets.length,
              itemBuilder: (context, index) {
                final bet = allBets[index];
                return Card(
                  color: Colors.blue[200],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.black, width: 1.5)),
                  margin: const EdgeInsets.only(bottom: 15),
                  child: ListTile(
                    title: Text('${bet.author.firstName} ${bet.author.lastName} -> ${bet.match.home.name} vs ${bet.match.visitors.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Prono: ${bet.result.winner?.name ?? "Nul"} (${bet.result.finalScore.home}-${bet.result.finalScore.visitors})'),
                  ),
                );
              },
            ),
      ),
      bottomNavigationBar: const MyBottomNavBar(currentIndex: 2),
    );
  }
}

// ecran des matchs en fonction du tournoi

class TournamentDetailsScreen extends StatefulWidget {
  final Tournament tournament;
  final List<Bettor> bettors;
  final List<Team> teams;
  final int navIndex;

  const TournamentDetailsScreen({super.key, required this.tournament, required this.bettors, required this.teams, required this.navIndex});

  @override
  State<TournamentDetailsScreen> createState() => _TournamentDetailsScreenState();
}

class _TournamentDetailsScreenState extends State<TournamentDetailsScreen> {
  void _showAddMatchDialog() async {
    final newMatch = await showDialog<Match>(
      context: context, builder: (context) => AddMatchDialog(teams: widget.teams),
    );
    if (newMatch != null) {
      setState(() { widget.tournament.addMatch(newMatch); });
      globalAppData.saveData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankingMap = widget.tournament.getRanking(widget.bettors);
    final sortedRanking = rankingMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); 

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tournament.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
        backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ranking', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                children: sortedRanking.asMap().entries.map((entry) {
                  int rank = entry.key + 1;
                  Bettor bettor = entry.value.key; 
                  int points = entry.value.value; 
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                      children: [
                        Text('$rank. ${bettor.firstName} ${bettor.lastName}', style: const TextStyle(fontSize: 16)), 
                        Text('${points}pts', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                      ]
                    ),
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 30),
            const Text('Matchs:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.tournament.matches.length,
                itemBuilder: (context, index) {
                  final match = widget.tournament.matches[index];
                  String matchText = '${match.home.name} - ${match.visitors.name}';
                  String subText = '';
                  
                  if (match.result != null) {
                    matchText = '${match.home.name} ${match.result!.finalScore.home} - ${match.result!.finalScore.visitors} ${match.visitors.name}';
                    subText = '(half : ${match.result!.halfTimeScore.home}-${match.result!.halfTimeScore.visitors})';
                  }

                  return Card(
                    color: Colors.green[200],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.black, width: 1.5)),
                    margin: const EdgeInsets.only(bottom: 15),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MatchBetsScreen(
                              match: match, 
                              bettors: widget.bettors, 
                              navIndex: 2 
                            )
                          ),
                        );
                      },
                      title: Text(matchText, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: subText.isNotEmpty ? Text(subText, textAlign: TextAlign.center) : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, size: 20, color: Colors.yellow[700]),
                            onPressed: () async {
                              final didUpdate = await showDialog<bool>(
                                context: context,
                                builder: (context) => EditMatchDialog(match: match),
                              );

                              if (didUpdate == true) {
                                setState(() {});
                                globalAppData.saveData(); 
                              }
                            },
                          ),
                          
                          // Bouton Supprimer
                          IconButton(
                            icon: Icon(Icons.delete_outline, size: 20, color: Colors.blue[300]),
                            onPressed: () {
                              setState(() {
                                widget.tournament.removeMatch(match.id); 
                              });
                              globalAppData.saveData();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMatchDialog, backgroundColor: Colors.green[200],
        shape: const CircleBorder(side: BorderSide(color: Colors.black, width: 1.5)),
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
      bottomNavigationBar: MyBottomNavBar(currentIndex: widget.navIndex), 
    );
  }
}

// écran des paris en fonction d'un match

class MatchBetsScreen extends StatefulWidget {
  final Match match;
  final List<Bettor> bettors;
  final int navIndex;

  const MatchBetsScreen({super.key, required this.match, required this.bettors, required this.navIndex});

  @override
  State<MatchBetsScreen> createState() => _MatchBetsScreenState();
}

class _MatchBetsScreenState extends State<MatchBetsScreen> {
  void _showAddBetDialog() async {
    final newBet = await showDialog<Bet>(
      context: context, builder: (context) => AddBetDialog(match: widget.match, bettors: widget.bettors),
    );
    if (newBet != null) {
      setState(() { widget.match.addBet(newBet);});
      globalAppData.saveData();
    }
  }

  @override
  Widget build(BuildContext context) {
    String finalScoreText = widget.match.result != null 
        ? '${widget.match.result!.finalScore.home} - ${widget.match.result!.finalScore.visitors}' 
        : '? - ?';
        
    String halfTimeText = widget.match.result != null 
        ? '${widget.match.result!.halfTimeScore.home} - ${widget.match.result!.halfTimeScore.visitors}' 
        : '? - ?';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0, foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('${widget.match.home.name} $finalScoreText ${widget.match.visitors.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26), textAlign: TextAlign.center),
            const SizedBox(height: 5), Text('(ht: $halfTimeText)', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),
            const Align(alignment: Alignment.centerLeft, child: Text('Bets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.match.bets.length,
                itemBuilder: (context, index) {
                  final bet = widget.match.bets[index];
                  return Card(
                    color: Colors.blue[200],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.black, width: 1.5)),
                    margin: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
                    child: ListTile(
                      title: Text('${bet.author.firstName} ${bet.author.lastName}: ${bet.result.winner?.name ?? "Nul"}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text('${bet.result.finalScore.home}-${bet.result.finalScore.visitors} (ht: ${bet.result.halfTimeScore.home}-${bet.result.halfTimeScore.visitors})', textAlign: TextAlign.center),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, size: 20, color: Colors.red[300]),
                        onPressed: () {
                          setState(() {
                            widget.match.removeBet(bet.id);
                          });
                          globalAppData.saveData();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBetDialog, backgroundColor: Colors.blue[200],
        shape: const CircleBorder(side: BorderSide(color: Colors.black, width: 1.5)),
        child: const Icon(Icons.add, color: Colors.black, size: 30),
      ),
      bottomNavigationBar: MyBottomNavBar(currentIndex: widget.navIndex), 
    );
  }
}

//modal bet

class AddBetDialog extends StatefulWidget {
  final Match match;
  final List<Bettor> bettors;
  const AddBetDialog({super.key, required this.match, required this.bettors});

  @override
  State<AddBetDialog> createState() => _AddBetDialogState();
}

class _AddBetDialogState extends State<AddBetDialog> {
  Bettor? selectedBettor;
  Team? selectedWinner;
  final TextEditingController finalHomeCtrl = TextEditingController();
  final TextEditingController finalVisitorsCtrl = TextEditingController();
  final TextEditingController halfHomeCtrl = TextEditingController();
  final TextEditingController halfVisitorsCtrl = TextEditingController();

  Widget _buildScoreInput(TextEditingController controller) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.5), borderRadius: BorderRadius.circular(10)),
      child: TextField(
        controller: controller, keyboardType: TextInputType.number, textAlign: TextAlign.center,
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.black, width: 2)),
      title: const Text('Add Bet', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bettor:'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.5), borderRadius: BorderRadius.circular(15)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Bettor>(
                  isExpanded: true, value: selectedBettor, hint: const Text('Select a bettor'),
                  items: widget.bettors.map((b) => DropdownMenuItem(value: b, child: Text(b.firstName + ' ' + b.lastName))).toList(),
                  onChanged: (val) => setState(() => selectedBettor = val),
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text('Winner:'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.5), borderRadius: BorderRadius.circular(15)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Team>(
                  isExpanded: true, value: selectedWinner, hint: const Text('Select winner'),
                  items: [widget.match.home, widget.match.visitors].map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                  onChanged: (val) => setState(() => selectedWinner = val),
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text('Final score:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.match.home.name), const SizedBox(width: 10), _buildScoreInput(finalHomeCtrl),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('-')),
                _buildScoreInput(finalVisitorsCtrl), const SizedBox(width: 10), Text(widget.match.visitors.name),
              ],
            ),
            const SizedBox(height: 15),
            const Text('Half time:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.match.home.name), const SizedBox(width: 10), _buildScoreInput(halfHomeCtrl),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('-')),
                _buildScoreInput(halfVisitorsCtrl), const SizedBox(width: 10), Text(widget.match.visitors.name),
              ],
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.black, width: 1.5)),
          ),
          onPressed: () {
            if (selectedBettor != null && selectedWinner != null && 
                finalHomeCtrl.text.isNotEmpty && finalVisitorsCtrl.text.isNotEmpty && 
                halfHomeCtrl.text.isNotEmpty && halfVisitorsCtrl.text.isNotEmpty) {
              Bet newBet = Bet.createFromInput(
                author: selectedBettor!,
                match: widget.match,
                winner: selectedWinner!,
                finalHome: finalHomeCtrl.text,
                finalVis: finalVisitorsCtrl.text,
                halfHome: halfHomeCtrl.text,
                halfVis: halfVisitorsCtrl.text,
              );
              
              Navigator.pop(context, newBet);
            }
          },
          child: const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: Text('Add Bet', style: TextStyle(fontSize: 16))),
        ),
      ],
    );
  }
}

// modal match add

class AddMatchDialog extends StatefulWidget {
  final List<Team> teams;
  const AddMatchDialog({super.key, required this.teams});

  @override
  State<AddMatchDialog> createState() => _AddMatchDialogState();
}

class _AddMatchDialogState extends State<AddMatchDialog> {
  Team? selectedHome;
  Team? selectedVisitors;
  final TextEditingController finalHomeCtrl = TextEditingController();
  final TextEditingController finalVisitorsCtrl = TextEditingController();
  final TextEditingController halfHomeCtrl = TextEditingController();
  final TextEditingController halfVisitorsCtrl = TextEditingController();

  Widget _buildScoreInput(TextEditingController controller) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.5), borderRadius: BorderRadius.circular(10)),
      child: TextField(
        controller: controller, keyboardType: TextInputType.number, textAlign: TextAlign.center,
        decoration: const InputDecoration(border: InputBorder.none, hintText: '0'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.black, width: 2)),
      title: const Text('Add Match', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Home:'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.5), borderRadius: BorderRadius.circular(15)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Team>(
                  isExpanded: true, value: selectedHome, hint: const Text('Select home team'),
                  items: widget.teams.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                  onChanged: (val) => setState(() => selectedHome = val),
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text('Visitors:'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.5), borderRadius: BorderRadius.circular(15)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Team>(
                  isExpanded: true, value: selectedVisitors, hint: const Text('Select visitor team'),
                  items: widget.teams.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                  onChanged: (val) => setState(() => selectedVisitors = val),
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Text('Final score:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(selectedHome?.name ?? 'Home'), const SizedBox(width: 10), _buildScoreInput(finalHomeCtrl),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('-')),
                _buildScoreInput(finalVisitorsCtrl), const SizedBox(width: 10), Text(selectedVisitors?.name ?? 'Vis.'),
              ],
            ),
            const SizedBox(height: 15),
            const Text('Half time:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(selectedHome?.name ?? 'Home'), const SizedBox(width: 10), _buildScoreInput(halfHomeCtrl),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('-')),
                _buildScoreInput(halfVisitorsCtrl), const SizedBox(width: 10), Text(selectedVisitors?.name ?? 'Vis.'),
              ],
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.black, width: 1.5)),
          ),
          onPressed: () {
            if (selectedHome != null && selectedVisitors != null && selectedHome != selectedVisitors) {
              Match newMatch = Match.createFromInput(
                home: selectedHome!,
                visitors: selectedVisitors!,
                finalHome: finalHomeCtrl.text,
                finalVis: finalVisitorsCtrl.text,
                halfHome: halfHomeCtrl.text,
                halfVis: halfVisitorsCtrl.text,
              );
              Navigator.pop(context, newMatch);
            }
          },
          child: const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: Text('Add Match', style: TextStyle(fontSize: 16))),
        ),
      ],
    );
  }
}

//modal match upadate

class EditMatchDialog extends StatefulWidget {
  final Match match;

  const EditMatchDialog({super.key, required this.match});

  @override
  State<EditMatchDialog> createState() => _EditMatchDialogState();
}

class _EditMatchDialogState extends State<EditMatchDialog> {
  final TextEditingController finalHomeCtrl = TextEditingController();
  final TextEditingController finalVisitorsCtrl = TextEditingController();
  final TextEditingController halfHomeCtrl = TextEditingController();
  final TextEditingController halfVisitorsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.match.result != null) {
      finalHomeCtrl.text = widget.match.result!.finalScore.home.toString();
      finalVisitorsCtrl.text = widget.match.result!.finalScore.visitors.toString();
      halfHomeCtrl.text = widget.match.result!.halfTimeScore.home.toString();
      halfVisitorsCtrl.text = widget.match.result!.halfTimeScore.visitors.toString();
    }
  }

  Widget _buildScoreInput(TextEditingController controller) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.5), borderRadius: BorderRadius.circular(10)),
      child: TextField(
        controller: controller, keyboardType: TextInputType.number, textAlign: TextAlign.center,
        decoration: const InputDecoration(border: InputBorder.none, hintText: '0'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.black, width: 2)),
      title: Text('Edit Match\n${widget.match.home.name} vs ${widget.match.visitors.name}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text('Final score:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.match.home.name), const SizedBox(width: 10), _buildScoreInput(finalHomeCtrl),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('-')),
                _buildScoreInput(finalVisitorsCtrl), const SizedBox(width: 10), Text(widget.match.visitors.name),
              ],
            ),
            const SizedBox(height: 15),
            const Text('Half time:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.match.home.name), const SizedBox(width: 10), _buildScoreInput(halfHomeCtrl),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0), child: Text('-')),
                _buildScoreInput(halfVisitorsCtrl), const SizedBox(width: 10), Text(widget.match.visitors.name),
              ],
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.black, width: 1.5)),
          ),
          onPressed: () {
            widget.match.updateResult(
              finalHome: finalHomeCtrl.text,
              finalVis: finalVisitorsCtrl.text,
              halfHome: halfHomeCtrl.text,
              halfVis: halfVisitorsCtrl.text,
            );
            
            Navigator.pop(context, true);
          },
          child: const Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: Text('Save Changes', style: TextStyle(fontSize: 16))),
        ),
      ],
    );
  }
}