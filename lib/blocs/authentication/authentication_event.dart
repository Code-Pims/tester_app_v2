part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends BlocEvent {
  const AuthenticationEvent();
}

/// Register user
class RegisterUser extends AuthenticationEvent {
  final String email;
  final String password;
  final String firstName;
  final String lastName;

  const RegisterUser({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });

  @override
  List<Object> get props => [
        email,
        password,
        firstName,
        lastName,
      ];
}

/// Login user
class LoginUser extends AuthenticationEvent {
  final String email;
  final String password;

  const LoginUser({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [
        email,
        password,
      ];
}

/// Login user
class UserStream extends AuthenticationEvent {
  final User? user;

  const UserStream(this.user);
  @override
  List<Object> get props => [];
}

/// Login user
class UserAsUnAuthenticatedStream extends AuthenticationEvent {
  const UserAsUnAuthenticatedStream();
  @override
  List<Object> get props => [];
}

class ListenToLocalUser extends AuthenticationEvent {
  const ListenToLocalUser();
  @override
  List<Object> get props => [];
}

class FetchSearchedUsers extends AuthenticationEvent {
  final String? searchValue;
  const FetchSearchedUsers(
    this.searchValue,
  );
  @override
  List<Object?> get props => [
        searchValue,
      ];
}

class FetchSearchableUserIds extends AuthenticationEvent {
  final List<String> clubIds;
  const FetchSearchableUserIds(
    this.clubIds,
  );
  @override
  List<Object> get props => [
        clubIds,
      ];
}
