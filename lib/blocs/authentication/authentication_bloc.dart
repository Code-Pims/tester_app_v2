import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dojodex_instructor/common/services/modal_service.dart';
import 'package:dojodex_instructor/common/services/token_service.dart';
import 'package:dojodex_instructor/common/services/user_service.dart';
import 'package:dojodex_instructor/data/database/database_service.dart';
import 'package:dojodex_instructor/data/database/databases.dart';
import 'package:dojodex_instructor/data/repositories/authentication_repository.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:dojodex_common/exceptions/custom_exceptions.dart';
import 'package:dojodex_common/models/user/user.dart';
import 'package:dojodex_common/ui/ui.dart';
import 'package:dojodex_common/dojodex_architecture.dart';
import 'package:logger/web.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository _authenticationRepository;
  final TokenService tokenService;

  StreamSubscription<User?>? userSubscription;

  AuthenticationBloc()
      : _authenticationRepository = sl<AuthenticationRepository>(),
        tokenService = sl<TokenService>(),
        super(AuthenticationState.initial()) {
    on<RegisterUser>(_onRegisterUser);
    on<LoginUser>(_onLoginUser);
    on<UserStream>(_onUserStream);
    on<UserAsUnAuthenticatedStream>(_onUserAsUnAuthenticatedStream);

    on<FetchSearchedUsers>(_onFetchSearchedUsers);
    on<FetchSearchableUserIds>(_onFetchSearchableUserIds);
  }

  /// close the subscription when the bloc is closed
  @override
  Future<void> close() {
    userSubscription?.cancel();

    return super.close();
  }

  void init() {
    userSubscription?.cancel();
    final userService = sl<UserService>();
    userSubscription = userService.listenToUser().listen(
      (user) {
        if (user == null) {
          add(const UserAsUnAuthenticatedStream());
          return;
        }

        add(UserStream(user));
      },
    );
  }

  FutureOr<void> _onRegisterUser(
    RegisterUser event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(state.copyWith(isRegisteringUser: true));
    try {
      await _authenticationRepository.register(
        username: event.email,
        password: event.password,
      );

      await _loginAndStoreCredentials(
        email: event.email,
        password: event.password,
      );

      final userService = sl<UserService>();
      final user = await userService.getUser();

      if (user?.id == null) {
        throw Exception(
          "User not found",
        );
      }

      await _authenticationRepository.updateMe(
        id: user?.id.toString() ?? "",
        email: event.email,
        lastName: event.lastName,
        firstName: event.firstName,
        isFromRegistration: true,
      );

      await getMeAndUpdateUser();

      emit(state.copyWith(
        isRegisteringUser: false,
      ));
    } on CustomExceptions catch (e) {
      emit(state.copyWith(
        isRegisteringUser: false,
      ));
      await sl<ModalService>().show(
        (modalActions) {
          return DojodexDialog(
            subtitle: e.message,
            actionButtonTitle: "Ok",
            onActionButtonClick: () async {
              modalActions.dismiss();
            },
          );
        },
        barrierDismissible: true,
      );
    }
  }

  FutureOr<void> _onLoginUser(
    LoginUser event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(state.copyWith(isLoggingIn: true));
    try {
      await _loginAndStoreCredentials(
        email: event.email,
        password: event.password,
      );

      emit(state.copyWith(
        isLoggingIn: false,
      ));
    } on CustomExceptions catch (e) {
      emit(state.copyWith(
        isLoggingIn: false,
      ));
      await sl<ModalService>().show(
        (modalActions) {
          return DojodexDialog(
            subtitle: e.message,
            actionButtonTitle: "Ok",
            onActionButtonClick: () async {
              modalActions.dismiss();
            },
          );
        },
        barrierDismissible: true,
      );
    } catch (e) {
      emit(state.copyWith(
        isLoggingIn: false,
      ));
    }
  }

  Future<void> _loginAndStoreCredentials({
    required String email,
    required String password,
  }) async {
    final sessionToken = await _authenticationRepository.login(
      email: email,
      password: password,
    );

    if (sessionToken == null) {
      return;
    }

    await tokenService.persistToken(sessionToken.token!);

    await getMeAndUpdateUser();
  }

  Future<void> getMeAndUpdateUser() async {
    var user = await _authenticationRepository.getMe();

    if (user == null) {
      return;
    }

    user = user.copyWith(
      isAuthenticated: true,
    );

    final databaseService = sl<DatabaseService>();
    await databaseService.insertOrUpdate(
      UserDatabase().name,
      user.id.toString(),
      user.toJson(),
    );
  }

  FutureOr<void> _onUserStream(
    UserStream event,
    Emitter<AuthenticationState> emit,
  ) async {
    if (event.user == state.user) return;

    emit(state.copyWith(
      user: event.user,
    ));
  }

  FutureOr<void> _onUserAsUnAuthenticatedStream(
    UserAsUnAuthenticatedStream event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(state.copyWith(
      user: state.user?.copyWith(
        isAuthenticated: false,
      ),
    ));
  }

  FutureOr<void> _onFetchSearchedUsers(
      FetchSearchedUsers event, Emitter<AuthenticationState> emit) async {
    emit(state.copyWith(
      isFetchingUser: true,
    ));
    try {
      var users = await _authenticationRepository.fetchUsers(
        event.searchValue,
      );

      emit(state.copyWith(
        isFetchingUser: false,
        searchedUsers: users,
      ));
    } catch (e) {
      emit(state.copyWith(
        isFetchingUser: false,
      ));
    }
  }

  FutureOr<void> _onFetchSearchableUserIds(
    FetchSearchableUserIds event,
    Emitter<AuthenticationState> emit,
  ) async {
    try {
      List<String> userIds = [];

      /// repository fetchClubMemberIds
      for (var clubId in event.clubIds) {
        var ids = await _authenticationRepository.fetchClubMemberIds(clubId);
        userIds.addAll(ids ?? []);
      }
      sl<Logger>().i({'UserIds': userIds});

      emit(state.copyWith(
        listOfSearchableUsers: userIds,
      ));
    } catch (e) {
      sl<Logger>().e(e);
    }
  }
}
