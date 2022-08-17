class League {
  final String leagueId;
  final String summonerId;
  final String summonerName;
  final String queueType;
  final String tier;
  final String rank;
  final int leaguePoints;
  final int wins;
  final int losses;
  final bool hotStreak;
  final bool veteran;
  final bool freshBlood;
  final bool inactive;

  League({
    required this.leagueId,
    required this.queueType,
    required this.tier,
    required this.rank,
    required this.summonerId,
    required this.summonerName,
    required this.leaguePoints,
    required this.wins,
    required this.losses,
    required this.veteran,
    required this.inactive,
    required this.freshBlood,
    required this.hotStreak,
  });

  factory League.fromJson(Map<String, dynamic> json) {
    return League(
      leagueId: json['leagueId'],
      queueType: json['queueType'],
      tier: json['tier'],
      rank: json['rank'],
      summonerId: json['summonerId'],
      summonerName: json['summonerName'],
      leaguePoints: json['leaguePoints'],
      wins: json['wins'],
      losses: json['losses'],
      veteran: json['veteran'],
      inactive: json['inactive'],
      freshBlood: json['freshBlood'],
      hotStreak: json['hotStreak'],
    );
  }
}