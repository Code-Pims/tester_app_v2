import 'package:dojodex_common/extensions/text_extension.dart';
import 'package:dojodex_instructor/blocs/attendance/attendance_bloc.dart';
import 'package:dojodex_instructor/blocs/lesson/lesson_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dojodex_common/ui/ui.dart';
import 'package:shimmer/shimmer.dart';

class AttendanceTable extends StatelessWidget {
  const AttendanceTable({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, attendanceState) {
        if (attendanceState.isFetchingStudents ?? false) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: buildShimmerTable(),
          );
        }

        return SizedBox(
          width: double.infinity,
          child: DataTable(
            showCheckboxColumn: false,
            horizontalMargin: 10,
            columnSpacing: 10,
            decoration: const BoxDecoration(
              color: DojoDexColors.primary,
            ),
            border: const TableBorder(
                horizontalInside: BorderSide(
              color: DojoDexColors.primary,
              style: BorderStyle.solid,
              strokeAlign: 20,
              width: 0.3,
            )),
            headingRowHeight: 40,
            headingTextStyle: context.textTheme.bodySmall?.copyWith(
              color: DojoDexColors.white,
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
            dividerThickness: 0.5,
            showBottomBorder: true,
            dataRowColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return DojoDexColors.success;
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
              ...attendanceState.tableColumns.map(
                (column) => DataColumn(
                  label: Text(column),
                ),
              ),
            ],
            rows: [
              ...attendanceState.students?.map(
                    (student) {
                      return DataRow(
                        selected: attendanceState.isTicked(student.id!),
                        color: _handleColor(
                          student.id!,
                          attendanceState,
                        ),
                        onSelectChanged: (value) {
                          final nearestLessonSchedule = context
                              .read<LessonBloc>()
                              .state
                              .nearestLessonSchedule;
                          if (nearestLessonSchedule == null) {
                            return;
                          }
                          context.read<AttendanceBloc>().add(ToggleStudent(
                              student.id!, nearestLessonSchedule.id!));
                        },
                        cells: [
                          DataCell(
                            Text(student.studentName ?? ""),
                          ),
                          DataCell(
                            Text(student.age ?? ""),
                          ),
                          DataCell(
                            Text(
                              student.currentGrade ?? "",
                            ),
                          ),
                        ],
                      );
                    },
                  ).toList() ??
                  [],
            ],
          ),
        );
      },
    );
  }

  Widget buildShimmerTable() {
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        showCheckboxColumn: false,
        horizontalMargin: 10,
        columnSpacing: 10,
        headingRowHeight: 40,
        columns: List.generate(
          3,
          (index) => DataColumn(
            label: Shimmer.fromColors(
              baseColor: DojoDexColors.primary.withValues(alpha: 0.3),
              highlightColor: DojoDexColors.primary.withValues(alpha: 0.1),
              child: Container(
                width: 100,
                height: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
        rows: List.generate(
          5,
          (index) => DataRow(
            cells: List.generate(
              3,
              (index) => DataCell(
                Shimmer.fromColors(
                  baseColor: DojoDexColors.primary.withValues(alpha: 0.1),
                  highlightColor: DojoDexColors.primary.withValues(alpha: 0.05),
                  child: Container(
                    width: 100,
                    height: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  WidgetStateProperty<Color> _handleColor(
      int studentId, AttendanceState attendanceState) {
    /// Absent last session
    if (!(attendanceState.isPresentLastSession(studentId))) {
      return WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return DojoDexColors.success;
          }
          return const Color.fromARGB(255, 255, 182, 177);
        },
      );
    }

    /// Present today
    if (attendanceState.isPresentToday(studentId)) {
      return WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return DojoDexColors.success;
          }
          return const Color.fromARGB(255, 189, 255, 229);
        },
      );
    }
    return WidgetStateProperty.resolveWith<Color>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return DojoDexColors.success;
        }
        return Colors.white;
      },
    );
  }
}
