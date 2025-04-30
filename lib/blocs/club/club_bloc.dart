import 'dart:async';

import 'package:dojodex_common/models/art/art.dart';
import 'package:dojodex_common/models/card_type/card_type.dart';
import 'package:dojodex_common/models/grades/grade.dart';
import 'package:dojodex_common/models/student/student.dart';
import 'package:dojodex_common/services/toast_service.dart';
import 'package:dojodex_common/ui/ui.dart';
import 'package:dojodex_instructor/common/routes/route_helper.dart';
import 'package:dojodex_instructor/common/services/club_service.dart';
import 'package:dojodex_instructor/common/services/user_service.dart';
import 'package:dojodex_instructor/data/database/database_service.dart';
import 'package:dojodex_instructor/data/database/databases.dart';
import 'package:dojodex_instructor/data/repositories/club_repository.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:dojodex_common/models/club/club.dart';
import 'package:dojodex_common/dojodex_architecture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../lesson/lesson_bloc.dart';
import '../setting/setting_bloc.dart';

part 'club_event.dart';

part 'club_state.dart';

class ClubBloc extends Bloc<ClubEvent, ClubState> {
  final ClubRepository clubRepository;

  ClubBloc()
      : clubRepository = sl<ClubRepository>(),
        super(ClubState.initial()) {
    on<FetchClubs>(_onFetchClubs);
    on<SwitchClub>(_onSwitchClub);

    on<FetchClubStudents>(_onFetchClubStudents);
    on<UpdateStudent>(_onUpdateStudent);

    on<FetchGrades>(_onFetchGrades);
    on<FetchMartialArts>(_onFetchMartialArts);
    on<FetchCardTypes>(_onFetchCardTypes);
    on<AddTheoryCard>(_onAddTheoryCard);
  }

  /// close the subscription when the bloc is closed
  @override
  Future<void> close() {
    return super.close();
  }

  FutureOr<void> _onAddTheoryCard(AddTheoryCard event, emit) async {
    try {
      emit(state.copyWith(
          isAddingTheoryCard: true));

      bool successStatus = await clubRepository.addTheoryCard(
        clubId: event.clubId,
        martialArt: event.martialArt,
        question: event.question,
        answer: event.answer,
        minimumGrade: event.minimumGrade,
        cardTypeFilter: event.cardType,
      );
      if(successStatus) {
        event.onSuccess();
      }
      emit(state.copyWith(isAddingTheoryCard: false));
    } catch (e) {
      emit(state.copyWith(isAddingTheoryCard: false));
    }
  }

  FutureOr<void> _onFetchGrades(event, emit) async {
    try {
      emit(state.copyWith(isFetchingGrades: true));
      final grades = await clubRepository.fetchGrades();
      emit(state.copyWith(gradeLists: grades, isFetchingGrades: false));
    } catch (e) {
      emit(state.copyWith(isFetchingGrades: false));
    }
  }

  FutureOr<void> _onFetchMartialArts(
    FetchMartialArts event,
    Emitter<ClubState> emit,
  ) async {
    try {
      emit(state.copyWith(isFetchingMartialArts: true));
      final arts = await clubRepository.fetchArts();
      emit(state.copyWith(martialArtLists: arts, isFetchingMartialArts: false));
    } catch (e) {
      emit(state.copyWith(isFetchingMartialArts: false));
    }
  }

  FutureOr<void> _onFetchCardTypes(
    FetchCardTypes event,
    Emitter<ClubState> emit,
  ) async {
    try {
      emit(state.copyWith(isFetchingCardTypes: true));
      final cardTypes = await clubRepository.fetchCardTypes();
      emit(
          state.copyWith(cardTypeLists: cardTypes, isFetchingCardTypes: false));
    } catch (e) {
      emit(state.copyWith(isFetchingCardTypes: false));
    }
  }

  FutureOr<void> _onFetchClubs(
      FetchClubs event, Emitter<ClubState> emit) async {
    emit(state.copyWith(isFetchingClubs: true));
    try {
      final userService = sl<UserService>();
      final user = await userService.getUser();
      final clubs = await clubRepository.fetchClubs(userId: user?.id);

      if (clubs?.isNotEmpty ?? false) {
        final databaseService = sl<DatabaseService>();

        /// Get the current club in the local database
        /// If the current club is not found, save the first club to the database
        final currentClub = await sl<ClubService>().getCurrentClub();

        if (currentClub == null) {
          if (clubs?.isNotEmpty ?? false) {
            final getDefaultClub = clubs?.first;
            await databaseService.insertOrUpdate(
              CurrentClub().name,
              getDefaultClub!.id.toString(),
              getDefaultClub.toJson(),
            );
            emit(state.copyWith(currentClub: getDefaultClub));
          }
        } else {
          emit(state.copyWith(currentClub: currentClub));
        }
      }

      emit(state.copyWith(isFetchingClubs: false, clubs: clubs));
    } catch (e) {
      emit(state.copyWith(isFetchingClubs: false));
    }
  }

  FutureOr<void> _onFetchClubStudents(
    FetchClubStudents event,
    Emitter<ClubState> emit,
  ) async {
    emit(state.copyWith(isFetchingClubStudents: true));
    try {
      final students = await clubRepository.fetchClubStudents(event.clubId);

      emit(state.copyWith(
          isFetchingClubStudents: false, clubStudents: students));
    } catch (e) {
      emit(state.copyWith(isFetchingClubStudents: false));
    }
  }

  FutureOr<void> _onUpdateStudent(
    UpdateStudent event,
    Emitter<ClubState> emit,
  ) async {
    emit(state.copyWith(isUpdatingStudent: true));
    try {
      await clubRepository.updateStudent(event.student);
      sl<ToastService>().showToast(
        key: const ValueKey("update_student"),
        message: "Student updated successfully",
        style: DojoDexToastStyle.primary,
      );
      sl<RouteHelper>().popToPreviousPage();
      if (event.club.id == null) {
        return;
      }
      add(FetchClubStudents(clubId: event.club.id!));
      emit(state.copyWith(isUpdatingStudent: false));
    } catch (e) {
      emit(state.copyWith(isUpdatingStudent: false));
    }
  }

  FutureOr<void> _onSwitchClub(
    SwitchClub event,
    Emitter<ClubState> emit,
  ) async {
    final databaseService = sl<DatabaseService>();

    /// remove the current club from the database
    await databaseService.deleteAll(CurrentClub().name);
    await databaseService.insertOrUpdate(
      CurrentClub().name,
      event.club.id.toString(),
      event.club.toJson(),
    );

    emit(state.copyWith(currentClub: event.club));

    if (!event.context.mounted) return;

    event.context.read<SettingBloc>().add(const FetchClubLocations());

    event.context.read<LessonBloc>().add(const FetchSchedules());
  }
}
