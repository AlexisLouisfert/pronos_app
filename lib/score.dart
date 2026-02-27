class Score {
  int home;
  int visitors;

  Score({
    required this.home,
    required this.visitors,
  });

  Map<String, dynamic> toJson() => {'home': home, 'visitors': visitors};
  
  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(home: json['home'], visitors: json['visitors']);
  }
}