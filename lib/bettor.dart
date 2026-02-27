class Bettor {
  int id;
  String firstName;
  String lastName;

  Bettor({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  Map<String, dynamic> toJson() => {'id': id, 'firstName': firstName, 'lastName': lastName};
  
  factory Bettor.fromJson(Map<String, dynamic> json) {
    return Bettor(id: json['id'], firstName: json['firstName'], lastName: json['lastName']);
  }
}