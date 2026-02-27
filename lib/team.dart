class Team {
  int id;
  String name;

  Team({
    required this.id, 
    required this.name
  });

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
  
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(id: json['id'], name: json['name']);
  }
}