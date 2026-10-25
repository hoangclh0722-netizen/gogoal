abstract class Sport {
  const Sport(this.id, this.displayName);

  final String id;
  final String displayName;

  static const all = <Sport>[Football(), Badminton(), Basketball(), Pickleball(), Tennis()];

  static Sport fromId(String id) => all.firstWhere((s) => s.id == id);
}

class Football extends Sport {
  const Football() : super('football', 'Bóng đá');
}

class Badminton extends Sport {
  const Badminton() : super('badminton', 'Cầu lông');
}

class Basketball extends Sport {
  const Basketball() : super('basketball', 'Bóng rổ');
}

class Pickleball extends Sport {
  const Pickleball() : super('pickleball', 'Pickleball');
}

class Tennis extends Sport {
  const Tennis() : super('tennis', 'Tennis');
}
