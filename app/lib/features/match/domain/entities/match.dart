import 'geo_point.dart';

class Venue {
  const Venue({required this.name, required this.district});

  final String name;
  final String district;
}

class Host {
  const Host({required this.displayName, required this.rep});

  final String displayName;
  final double rep;
}

class Match {
  const Match({
    required this.id,
    required this.title,
    required this.sportId,
    required this.format,
    required this.playersTotal,
    required this.slotsNeeded,
    required this.slotsFilled,
    required this.isFull,
    required this.levelMin,
    required this.levelMax,
    required this.startAt,
    required this.venue,
    required this.geo,
    required this.district,
    required this.costPerPerson,
    required this.host,
  });

  final String id;
  final String title;
  final String sportId;
  final String format;
  final int playersTotal;
  final int slotsNeeded;
  final int slotsFilled;
  final bool isFull;
  final int levelMin;
  final int levelMax;
  final DateTime startAt;
  final Venue venue;
  final GeoPoint geo;
  final String district;
  final int costPerPerson;
  final Host host;

  int get slotsLeft => slotsNeeded - slotsFilled;

  double? distanceFrom(GeoPoint? origin) => origin?.distanceTo(geo);
}
