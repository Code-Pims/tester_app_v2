import 'package:dojodex_instructor/features/attendance_register/attendance_screen.dart';
import 'package:dojodex_instructor/features/clubs/add_theory_card_screen.dart';
import 'package:dojodex_instructor/features/clubs/clubs_list_screen.dart';
import 'package:dojodex_instructor/features/messages/messages_screen.dart';
import 'package:dojodex_instructor/features/settings/settings_screen.dart';
import 'package:dojodex_common/ui/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dojodex_instructor/blocs/app/base_cubit.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    /// Select the first tab
    context.read<BaseCubit>().selectTab(0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BaseCubit, int>(
      builder: (context, currentIndex) {
        return Scaffold(
          body: _buildScreen(currentIndex),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: DojoDexColors.gray1,
            unselectedItemColor: DojoDexColors.gray4,
            currentIndex: currentIndex,
            onTap: (index) {
              context.read<BaseCubit>().selectTab(index);
            },
            items: [
              _buildBottomNavigationBarItem(
                title: "Clubs",
                icon: Icons.group_work_rounded,
              ),
              _buildBottomNavigationBarItem(
                title: "Theory",
                icon: Icons.flash_on,
              ),
              _buildBottomNavigationBarItem(
                title: "Messages",
                icon: Icons.message_rounded,
              ),
              _buildBottomNavigationBarItem(
                title: "Attendance",
                icon: Icons.people_rounded,
              ),
              _buildBottomNavigationBarItem(
                title: "Settings",
                icon: Icons.settings,
              ),
            ],
          ),
        );
      },
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem({
    required String title,
    required IconData icon,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(icon, color: DojoDexColors.gray4),
      activeIcon: Icon(icon, color: DojoDexColors.gray1),
      label: title,
    );
  }

  Widget _buildScreen(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return const ClubsListScreen();
      case 1:
        return const AddTheoryCardScreen();
      case 2:
        return const MessagesScreen();
      case 3:
        return const AttendanceScreen();
      case 4:
        return const SettingsScreen();

      default:
        return const SizedBox();
    }
  }
}
