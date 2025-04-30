import 'package:flutter_bloc/flutter_bloc.dart';

enum BottomNavigationEvent { home, courses, workshop, journal }

class BaseCubit extends Cubit<int> {
  BaseCubit() : super(0);

  void selectTab(int index) {
    emit(index);
  }
}
