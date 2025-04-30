part of 'authentication_bloc.dart';

class AuthenticationState extends BlocState {
  final bool? isLoggingIn;
  final bool? isRegisteringUser;
  final User? user;
  final Exception? error;
  final bool? isFetchingUser;
  final List<User>? searchedUsers;
  final List<String>? listOfSearchableUsers;

  const AuthenticationState({
    this.isLoggingIn,
    this.isRegisteringUser,
    this.user,
    this.error,
    this.isFetchingUser,
    this.searchedUsers = const [],
    this.listOfSearchableUsers,
  });

  @override
  List<Object?> get props => [
        isLoggingIn,
        isRegisteringUser,
        user,
        error,
        isFetchingUser,
        searchedUsers,
        listOfSearchableUsers,
      ];

  AuthenticationState copyWith({
    bool? isLoggingIn,
    bool? isRegisteringUser,
    User? user,
    bool? isIntentToLogout,
    Exception? error,
    bool? isFetchingUser,
    List<User>? searchedUsers,
    List<String>? listOfSearchableUsers,
  }) {
    return AuthenticationState(
      isLoggingIn: isLoggingIn ?? this.isLoggingIn,
      isRegisteringUser: isRegisteringUser ?? this.isRegisteringUser,
      user: user ?? this.user,
      error: error ?? this.error,
      isFetchingUser: isFetchingUser ?? this.isFetchingUser,
      searchedUsers: searchedUsers ?? this.searchedUsers,
      listOfSearchableUsers:
          listOfSearchableUsers ?? this.listOfSearchableUsers,
    );
  }

  factory AuthenticationState.initial() {
    return const AuthenticationState(
      isLoggingIn: false,
      isRegisteringUser: false,
      user: null,
      error: null,
      isFetchingUser: false,
      searchedUsers: [],
      listOfSearchableUsers: [],
    );
  }

  /// List of searchable user
  /// Filter the searched users
  /// by filtering from the list of searchable users
  List<User>? get searchableUsers {
    return searchedUsers?.where((element) {
      return listOfSearchableUsers?.contains(element.id.toString()) ?? false;
    }).toList();
  }
}
