import 'package:dojodex_common/extensions/text_extension.dart';
import 'package:dojodex_common/models/club/club.dart';
import 'package:dojodex_common/models/student/student.dart';
import 'package:dojodex_instructor/blocs/club/club_bloc.dart';
import 'package:dojodex_instructor/common/routes/route_helper.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:dojodex_instructor/features/update_student/update_student_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:dojodex_common/ui/ui.dart';

class StudentListsArguments {
  final Club club;

  const StudentListsArguments({required this.club});
}

class StudentListsScreen extends StatefulWidget {
  final Club club;

  StudentListsScreen({required StudentListsArguments arguments, super.key})
      : club = arguments.club;

  @override
  State<StudentListsScreen> createState() => _StudentListsScreenState();
}

class _StudentListsScreenState extends State<StudentListsScreen> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
    ]);
    assert(widget.club.id != null);

    context.read<ClubBloc>().add(FetchClubStudents(clubId: widget.club.id!));
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, dynamic) async {
        if (didPop) {
          await SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
          ]);
          sl<RouteHelper>().popMainToRoot();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.club.title ?? ""),
          leading: IconButton(
            onPressed: () async {
              await SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
              ]);
              sl<RouteHelper>().popMainToRoot();
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SingleChildScrollView(
          child: _buildTableStudentList(),
        ),
      ),
    );
  }

  Widget _buildTableStudentList() {
    return BlocBuilder<ClubBloc, ClubState>(
      builder: (context, state) {
        final clubStudents = state.clubStudents;
        if (state.isFetchingClubStudents ?? false) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: DataTable(
                horizontalMargin: 24,
                columnSpacing: 10,
                decoration: const BoxDecoration(
                  color: DojoDexColors.secondary,
                ),
                border: const TableBorder(
                  horizontalInside: BorderSide(
                    color: DojoDexColors.primary,
                    style: BorderStyle.solid,
                    strokeAlign: 20,
                    width: 0.3,
                  ),
                ),
                headingRowHeight: 40,
                headingTextStyle: context.textTheme.bodySmall?.copyWith(
                  color: DojoDexColors.white,
                  fontWeight: FontWeight.normal,
                  fontSize: 8,
                ),
                dividerThickness: 0.5,
                showBottomBorder: true,
                dataRowColor: WidgetStateProperty.resolveWith<Color>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.08);
                    }
                    return DojoDexColors.white;
                  },
                ),
                dataTextStyle: context.textTheme.bodySmall?.copyWith(
                  color: DojoDexColors.primaryText,
                  fontWeight: FontWeight.normal,
                  fontSize: 11,
                ),
                columns: [
                  DataColumn(
                    label: Text(
                      '',
                      style: _tableHeaderStyle(),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'NAME',
                      style: _tableHeaderStyle(),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'GRADE',
                      style: _tableHeaderStyle(),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'STATUS',
                      style: _tableHeaderStyle(),
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                rows: (state.clubStudents ?? []).map((data) {
                  debugPrint("Get color   ==>   ${data.backgroundColor}");

                  onTap() {
                    _showUpdateStudent(data);
                  }

                  return DataRow(
                    cells: [
                      DataCell(
                        onTap: () => onTap(),
                        Text(
                          /// index number,
                          ((clubStudents?.indexOf(data) ?? 0) + 1).toString(),
                        ),
                      ),
                      DataCell(
                        onTap: () => onTap(),
                        Text(
                          data.studentName ?? '',
                        ),
                      ),
                      DataCell(
                        onTap: () => onTap(),
                        Builder(builder: (context) {
                          var gradeDisplay = "No Grade";
                          if (data.currentGrade != "") {
                            ///

                            // final grade =
                            //     findGradeByName(GradesConfig.grades, student?.currentGrade ?? "");
                            gradeDisplay = "Grade: ${data.currentGrade}";
                          }
                          return Text(
                            gradeDisplay,
                          );
                        }),
                      ),
                      DataCell(
                        onTap: () => onTap(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: data.studentStatus == "Instructor" ||
                                    data.studentStatus == "Assistant"
                                ? const Color.fromARGB(255, 53, 120, 60)
                                : data.backgroundColor,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            data.studentStatus == "Instructor" ||
                                    data.studentStatus == "Assistant"
                                ? "Current"
                                : data.studentStatus ?? '',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: DojoDexColors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                }).toList(),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom),
              color: Colors.white,
            ),
          ],
        );
      },
    );
    // return Column(
    //   children: [
    //     BlocBuilder<ClubBloc, ClubState>(
    //       builder: (context, state) {
    //         if (state.isFetchingClubStudents ?? false) {
    //           return const Center(
    //             child: CircularProgressIndicator(),
    //           );
    //         }
    //         return Column(
    //           children: state.clubStudents
    //                   ?.map((club) => _buildStudentItem(club))
    //                   .toList() ??
    //               [],
    //         );
    //       },
    //     ),
    //   ],
    // );
  }

  TextStyle _tableHeaderStyle() {
    return const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }

  void _showUpdateStudent(Student? student) {
    if (student == null) {
      return;
    }
    sl<RouteHelper>().showUpdateStudent(
      UpdateStudentArguments(student: student, club: widget.club),
    );
  }

// InkWell _buildStudentItem(Student? student) {
//   return InkWell(
//     onTap: () {
//       _showUpdateStudent(student);
//     },
//     child: Container(
//       width: double.infinity,
//       margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(16.0),
//       ),
//       child: Column(
//         children: [
//           _buildStudentNameAndStatus(student, context),
//         ],
//       ),
//     ),
//   );
// }

// Widget _buildStudentNameAndStatus(Student? student, BuildContext context) {
//   var gradeDisplay = "No Grade";
//   if (student?.currentGrade != "") {
//     ///

//     // final grade =
//     //     findGradeByName(GradesConfig.grades, student?.currentGrade ?? "");
//     gradeDisplay = "Grade: ${student?.currentGrade}";
//   }

//   return Row(
//     children: [
//       Expanded(
//         flex: 7,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               student?.studentName ?? '',
//               style: Theme.of(context).textTheme.bodyLarge,
//             ),
//             const SizedBox(height: 4.0),
//             Text(gradeDisplay),
//             const SizedBox(height: 4.0),

//             /// label tag
//             Container(
//               padding:
//                   const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//               decoration: BoxDecoration(
//                 color: student?.backgroundColor,
//                 borderRadius: BorderRadius.circular(8.0),
//               ),
//               child: Text(
//                 student?.studentStatus ?? '',
//                 style: context.textTheme.bodySmall?.copyWith(
//                   color: DojoDexColors.white,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       Expanded(
//         child: IconButton(
//           icon: const Icon(
//             Icons.arrow_forward_ios,
//             color: DojoDexColors.gray4,
//             size: 16,
//           ),
//           onPressed: () {
//             _showUpdateStudent(student);
//           },
//         ),
//       ),
//     ],
//   );
// }
}
