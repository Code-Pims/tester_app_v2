part of 'club_bloc.dart';

abstract class ClubEvent extends BlocEvent {
  const ClubEvent();
}

class FetchClubs extends ClubEvent {
  final bool? forcePull;

  final String? searchValue;

  const FetchClubs({
    this.forcePull,
    this.searchValue,
  });

  @override
  List<Object?> get props => [
        forcePull,
        searchValue,
      ];
}

class FetchClubStudents extends ClubEvent {
  final int clubId;

  const FetchClubStudents({
    required this.clubId,
  });

  @override
  List<Object?> get props => [
        clubId,
      ];
}

class UpdateStudent extends ClubEvent {
  final Student student;
  final Club club;

  const UpdateStudent({
    required this.student,
    required this.club,
  });

  @override
  List<Object?> get props => [
        student,
        club,
      ];
}

class SwitchClub extends ClubEvent {
  final Club club;
  final BuildContext context;

  const SwitchClub({
    required this.club,
    required this.context,
  });

  @override
  List<Object?> get props => [
        club,
        context,
      ];
}

class FetchGrades extends ClubEvent {
  const FetchGrades();

  @override
  List<Object> get props => [];
}

class FetchMartialArts extends ClubEvent {
  const FetchMartialArts();

  @override
  List<Object> get props => [];
}

class FetchCardTypes extends ClubEvent {
  const FetchCardTypes();

  @override
  List<Object> get props => [];
}

class AddTheoryCard extends ClubEvent {
  final String clubId;
  final String martialArt;
  final String question;
  final String answer;
  final String minimumGrade;
  final String cardType;
  final Function onSuccess;

  const AddTheoryCard({
    required this.clubId,
    required this.martialArt,
    required this.question,
    required this.answer,
    required this.minimumGrade,
    required this.cardType,
    required this.onSuccess,
  });

  @override
  List<Object?> get props => [
        clubId,
        martialArt,
        question,
        answer,
        minimumGrade,
        cardType,
        onSuccess,
      ];
}
