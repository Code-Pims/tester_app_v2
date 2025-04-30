part of 'setting_bloc.dart';

abstract class SettingEvent extends BlocEvent {
  const SettingEvent();
}

class Logout extends SettingEvent {
  const Logout();

  @override
  List<Object> get props => [];
}

class FetchGrades extends SettingEvent {
  const FetchGrades();

  @override
  List<Object> get props => [];
}

class FetchClubLocations extends SettingEvent {
  const FetchClubLocations();

  @override
  List<Object> get props => [];
}

class FetchAllStudentsFromClub extends SettingEvent {
  const FetchAllStudentsFromClub();

  @override
  List<Object> get props => [];
}
