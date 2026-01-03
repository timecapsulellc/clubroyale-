class Player {
  final String id;
  final String name;
  final int score;

  Player({required this.id, required this.name, required this.score});

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(id: map['id'], name: map['name'], score: map['score']);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'score': score};
  }
}
