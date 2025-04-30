part of 'club_bloc.dart';

class ClubState extends BlocState {
  final bool? isFetchingClubs;
  final List<Club>? clubs;
  final Club? currentClub;

  /// students
  final bool? isFetchingClubStudents;
  final List<Student>? clubStudents;
  final bool? isUpdatingStudent;

  /// Grades
  final List<Grade>? gradeLists;
  final bool? isFetchingGrades;

  /// theoryCard
  final bool? isAddingTheoryCard;

  /// Arts to study
  final List<Art>? martialArtLists;
  final bool? isFetchingMartialArts;

  /// Card Type
  final List<CardType>? cardTypeLists;
  final bool? isFetchingCardTypes;

  final String? initialMinimumGrade;
  final String? initialArtsToStudy;

  const ClubState({
    this.isFetchingClubs,
    this.clubs,
    this.currentClub,
    this.isFetchingClubStudents,
    this.clubStudents,
    this.isUpdatingStudent,
    this.gradeLists,
    this.isFetchingGrades,
    this.isAddingTheoryCard,
    this.martialArtLists,
    this.isFetchingMartialArts,
    this.cardTypeLists,
    this.isFetchingCardTypes,
    this.initialMinimumGrade,
    this.initialArtsToStudy,
  });

  @override
  List<Object?> get props => [
        isFetchingClubs,
        clubs,
        currentClub,
        isFetchingClubStudents,
        clubStudents,
        isUpdatingStudent,
        gradeLists,
        isFetchingGrades,
        isAddingTheoryCard,
        martialArtLists,
        isFetchingMartialArts,
        cardTypeLists,
        isFetchingCardTypes,
        initialMinimumGrade,
        initialArtsToStudy,
      ];

  ClubState copyWith({
    bool? isFetchingClubs,
    List<Club>? clubs,
    Club? currentClub,
    bool? isFetchingClubStudents,
    List<Student>? clubStudents,
    bool? isUpdatingStudent,
    List<Grade>? gradeLists,
    bool? isFetchingGrades,
    bool? isAddingTheoryCard,
    List<Art>? martialArtLists,
    bool? isFetchingMartialArts,
    List<CardType>? cardTypeLists,
    bool? isFetchingCardTypes,
    List<String>? initialCardTypes,
    String? initialMinimumGrade,
    String? initialArtsToStudy,
  }) {
    return ClubState(
      isFetchingClubs: isFetchingClubs ?? this.isFetchingClubs,
      clubs: clubs ?? this.clubs,
      currentClub: currentClub ?? this.currentClub,
      isFetchingClubStudents:
          isFetchingClubStudents ?? this.isFetchingClubStudents,
      clubStudents: clubStudents ?? this.clubStudents,
      isUpdatingStudent: isUpdatingStudent ?? this.isUpdatingStudent,
      gradeLists: gradeLists ?? this.gradeLists,
      isFetchingGrades: isFetchingGrades ?? this.isFetchingGrades,
      isAddingTheoryCard: isAddingTheoryCard ?? this.isAddingTheoryCard,
      martialArtLists: martialArtLists ?? this.martialArtLists,
      isFetchingMartialArts:
          isFetchingMartialArts ?? this.isFetchingMartialArts,
      cardTypeLists: cardTypeLists ?? this.cardTypeLists,
      isFetchingCardTypes: isFetchingCardTypes ?? this.isFetchingCardTypes,
      initialMinimumGrade: initialMinimumGrade ?? this.initialMinimumGrade,
      initialArtsToStudy: initialArtsToStudy ?? this.initialArtsToStudy,
    );
  }

  factory ClubState.initial() {
    return const ClubState(
      isFetchingClubs: false,
      currentClub: null,
      clubs: null,
      isFetchingClubStudents: false,
      clubStudents: null,
      isUpdatingStudent: false,
      gradeLists: null,
      isFetchingGrades: false,
      isAddingTheoryCard: false,
      martialArtLists: null,
      isFetchingMartialArts: false,
      cardTypeLists: null,
      isFetchingCardTypes: false,
    );
  }

  List<String>? get myClubIds {
    if (clubs == null) {
      return null;
    }

    /// use for loop to get the club ids
    final List<String> ids = [];
    for (var club in clubs!) {
      ids.add(club.id.toString());
    }
    return ids;
  }
}
