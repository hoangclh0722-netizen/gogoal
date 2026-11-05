import 'participant.dart';

sealed class JoinEligibility {
  const JoinEligibility();
}

class Eligible extends JoinEligibility {
  const Eligible();
}

class MatchCancelled extends JoinEligibility {
  const MatchCancelled();
}

class MatchStarted extends JoinEligibility {
  const MatchStarted();
}

class IsHost extends JoinEligibility {
  const IsHost();
}

class AlreadyRequested extends JoinEligibility {
  const AlreadyRequested(this.status);

  final ParticipantStatus status;
}

class MatchFull extends JoinEligibility {
  const MatchFull();
}

class SportNotInProfile extends JoinEligibility {
  const SportNotInProfile();
}

class LevelMismatch extends JoinEligibility {
  const LevelMismatch(this.myLevel);

  final int myLevel;
}
