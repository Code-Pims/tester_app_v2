import 'package:dojodex_common/ui/ui.dart';
import 'package:dojodex_instructor/common/widgets/app_bar_widget.dart';
import 'package:flutter/material.dart';

class DojoDexHeaders {
  static PreferredSizeWidget mainAppBar({
    bool? isBackButtonVisible,
    bool? isDrawerVisible,
  }) {
    // final routerContext = sl<MainRouter>().key.currentContext;
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      title: AppBarWidget(
        isDrawerVisible: isDrawerVisible,
      ),
      toolbarHeight: 70,
      backgroundColor: DojoDexColors.primary,
      shadowColor: DojoDexColors.gray5,
      elevation: 4,
      leading: (isBackButtonVisible ?? false) ? const BackButton() : null,
    );
  }

  static Widget mainHeader({
    required Widget title,
  }) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: title,
        ),
      ],
    );
  }
}
