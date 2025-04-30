import 'package:dojodex_common/dojodex_ui.dart';
import 'package:flutter/material.dart';

import 'coming_soon_page.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final List<MenuItem> menuItems = [
    const MenuItem(title: 'Incident Report', icon: Icons.report_gmailerrorred),
    const MenuItem(
        title: 'Permissions Manager',
        icon: Icons.admin_panel_settings_outlined),
    const MenuItem(title: 'Grading Assistant', icon: Icons.school_outlined),
    const MenuItem(
        title: 'Safeguarding Assistant', icon: Icons.shield_moon_outlined),
    const MenuItem(title: 'Club Manager', icon: Icons.manage_accounts_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              padding: EdgeInsets.zero,
              decoration: const BoxDecoration(color: DojoDexColors.primary),
              child: Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            ...menuItems.map((item) => Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: ListTile(
                    title: Text(item.title),
                    leading: Icon(item.icon,
                        color:
                            DojoDexColors.darkPrimary.withValues(alpha: 0.5)),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ComingSoonPage(title: item.title),
                        ),
                      );
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class MenuItem {
  final IconData icon;
  final String title;

  const MenuItem({required this.icon, required this.title});
}
