import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dojodex_common/dojodex_architecture.dart';
import 'package:dojodex_common/models/lesson_schedule/lesson_schedule.dart';
import 'package:dojodex_instructor/common/routes/route_helper.dart';
import 'package:dojodex_instructor/common/services/club_service.dart';
import 'package:dojodex_instructor/data/repositories/sp_lesson_schedule_repository.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logger/web.dart';

import '../../data/database/sqflite_helper/fetch_lesson_schedules.dart';

part 'lesson_event.dart';

part 'lesson_state.dart';

class LessonBloc extends Bloc<LessonEvent, LessonState> {
  final SupabaseLessonScheduleRepository lessonRepository;

  LessonBloc()
      : lessonRepository = sl<SupabaseLessonScheduleRepository>(),
        super(LessonState.initial()) {
    on<FetchSchedules>(_onFetchSchedules);
    on<ChangeLessonSchedule>(_onSwitchLesson);
    on<CreateSchedule>(_onCreateSchedule);
    on<UpdateSchedule>(_onUpdateSchedule);
    on<DeleteSchedule>(_onDeleteSchedule);
  }

  void _onSwitchLesson(
    ChangeLessonSchedule event,
    Emitter<LessonState> emit,
  ) {
    emit(state.copyWith(selectedLessonSchedule: event.selectedLessonSchedule));
  }

  FutureOr<void> _onFetchSchedules(
    FetchSchedules event,
    Emitter<LessonState> emit,
  ) async {
    emit(state.copyWith(isFetchingSchedules: true));

    try {
      final currentClub = await sl<ClubService>().getCurrentClub();
      if (currentClub == null) {
        emit(state.copyWith(isFetchingSchedules: false));
        return;
      }

      final dbHelper = FetchLessonSchedules();

      final hasInternet = await _checkInternetConnection();
      if (hasInternet) {
        final lessonSchedules = await lessonRepository.fetchMyLessonSchedules(
          clubId: currentClub.id.toString(),
        );

        sl<Logger>().i('Fetched lesson schedules: $lessonSchedules');

        await dbHelper.clearLessonSchedules(currentClub.id!);
        for (var schedule in lessonSchedules!) {
          await dbHelper.insertLessonSchedule(schedule);
        }

        if (lessonSchedules.isNotEmpty) {
          add(ChangeLessonSchedule(lessonSchedules.first));
        }

        emit(state.copyWith(
            isFetchingSchedules: false, lessonSchedules: lessonSchedules));
      } else {
        final localSchedules =
            await dbHelper.getLessonSchedules(currentClub.id!);
        if (localSchedules.isNotEmpty) {
          emit(state.copyWith(
              isFetchingSchedules: false, lessonSchedules: localSchedules));
        }
      }
    } catch (e) {
      emit(state.copyWith(isFetchingSchedules: false));
      sl<Logger>().e(e);
    }
  }

  Future<bool> _checkInternetConnection() async {
    if (await InternetConnection().hasInternetAccess) {
      return true;
    } else {
      return false;
    }
  }

  FutureOr<void> _onCreateSchedule(
    CreateSchedule event,
    Emitter<LessonState> emit,
  ) async {
    try {
      emit(state.copyWith(isCreatingSchedule: true));
      await lessonRepository.createLessonSchedule(
        lessonSchedule: event.lessonSchedule,
      );
      emit(state.copyWith(isCreatingSchedule: false));
      add(const FetchSchedules());
      sl<RouteHelper>().popToPreviousPage();
    } catch (e) {
      emit(state.copyWith(isCreatingSchedule: false));
    }
  }

  FutureOr<void> _onUpdateSchedule(
    UpdateSchedule event,
    Emitter<LessonState> emit,
  ) async {
    try {
      emit(state.copyWith(isUpdatingSchedule: true));
      await lessonRepository.updateLessonSchedule(
        lessonSchedule: event.lessonSchedule,
      );
      emit(state.copyWith(isUpdatingSchedule: false));
      add(const FetchSchedules());
      sl<RouteHelper>().popToPreviousPage();
    } catch (e) {
      emit(state.copyWith(isUpdatingSchedule: false));
    }
  }

  FutureOr<void> _onDeleteSchedule(
    DeleteSchedule event,
    Emitter<LessonState> emit,
  ) async {
    try {
      emit(state.copyWith(isDeletingSchedule: true));

      await lessonRepository.deleteLessonSchedule(
        id: event.lessonScheduleID,
      );
      emit(state.copyWith(isDeletingSchedule: false));
      add(const FetchSchedules());
      sl<RouteHelper>().popToPreviousPage();
    } catch (e) {
      emit(state.copyWith(isDeletingSchedule: false));
    }
  }
}
