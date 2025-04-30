import 'package:dojodex_common/dojodex_extensions.dart';
import 'package:dojodex_common/models/attendance/attendance.dart';
import 'package:dojodex_common/models/lesson_schedule/lesson_schedule.dart';
import 'package:dojodex_common/models/student/student.dart';
import 'package:dojodex_common/ui/app_colors.dart';
import 'package:dojodex_common/ui/widgets/textfields/custom_input_layout.dart';
import 'package:dojodex_common/ui/widgets/textfields/custom_textfield_widget.dart';
import 'package:dojodex_instructor/blocs/setting/setting_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  _AttendanceReportScreenState createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  DateTime startDate = DateTime(DateTime.now().year, 1, 1);
  DateTime endDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  List<Map<String, dynamic>> attendanceData = [];
  bool _isNeedToRefreshAttendanceData = true;

  int getAttendedClassNumber(int studentId, List<Attendance> allAttendeesList,
      DateTime startDate, DateTime endDate) {
    return allAttendeesList
        .where((attendees) =>
            attendees.studentId == studentId &&
            attendees.createdAt != null &&
            attendees.createdAt!
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            attendees.createdAt!.isBefore(endDate.add(const Duration(days: 1))))
        .length;
  }

  List<Map<String, dynamic>> getAllAttendanceTableData(
      List<Student> students,
      List<LessonSchedule> lessonSchedules,
      List<Attendance> allAttendeesList,
      DateTime startDate,
      DateTime endDate,
      int weeks) {
    List<Map<String, dynamic>> attendanceData = [];

    for (var student in students) {
      int possibleLessons = 0;
      int attendedLessons = 0;

      int? studentAge = int.tryParse(student.age ?? '');
      int? studentGrade = int.tryParse(student.gradeNumber ?? '');

      if (studentAge == null || studentGrade == null) {
        continue;
      }

      for (var lesson in lessonSchedules) {
        if ((lesson.minAge == null || studentAge >= lesson.minAge!) &&
            (lesson.maxAge == null || studentAge <= lesson.maxAge!) &&
            (lesson.minGrade == null || studentGrade >= lesson.minGrade!) &&
            (lesson.maxGrade == null || studentGrade <= lesson.maxGrade!)) {
          possibleLessons += weeks;
        }
      }

      attendedLessons += getAttendedClassNumber(
          int.parse(student.userId!), allAttendeesList, startDate, endDate);

      attendanceData.add({
        'name': student.studentName ?? 'Unknown',
        'possible': possibleLessons,
        'attended': attendedLessons,
      });
    }

    return attendanceData;
  }

  String sortedColumn = 'name';
  bool isAscending = true;

  void _sortTable(String column) {
    setState(() {
      if (sortedColumn == column) {
        isAscending = !isAscending;
      } else {
        sortedColumn = column;
        isAscending = true;
      }
      attendanceData.sort((a, b) {
        if (isAscending) {
          return a[column].compareTo(b[column]);
        } else {
          return b[column].compareTo(a[column]);
        }
      });
    });
  }

  int getWeeksBetweenSelectedDateRange() {
    int daysDifference = DateTime.parse(endDateController.text)
        .difference(DateTime.parse(startDateController.text))
        .inDays;
    int numberOfWeeks = (daysDifference / 7).ceil();

    return numberOfWeeks;
  }

  @override
  void initState() {
    context.read<SettingBloc>().add(const FetchAllStudentsFromClub());

    startDateController.text = DateFormat('yyyy-MM-dd').format(startDate);
    endDateController.text = DateFormat('yyyy-MM-dd').format(endDate);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Attendance Report")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStartDateField(),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: _buildEndDateField(),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<SettingBloc, SettingState>(
                builder: (context, attendanceState) {
              if (attendanceState.isFetchingStudents ?? false) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: buildShimmerTable(),
                );
              }

              int currentWeekNumber = getWeeksBetweenSelectedDateRange();

              if (_isNeedToRefreshAttendanceData) {
                attendanceData = [];

                attendanceData = getAllAttendanceTableData(
                  attendanceState.students ?? [],
                  attendanceState.allLessonSchedulesOfSelectedClub ?? [],
                  attendanceState.allAttendeesData ?? [],
                  DateTime.parse(startDateController.text),
                  DateTime.parse(endDateController.text),
                  currentWeekNumber,
                );

                if (attendanceData.isNotEmpty) {
                  _isNeedToRefreshAttendanceData = false;
                }
              }

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DataTable(
                    headingRowColor: WidgetStateColor.resolveWith(
                        (states) => DojoDexColors.primary),
                    dataRowColor: WidgetStateColor.resolveWith((states) =>
                        DojoDexColors.primary.withValues(alpha: 0.3)),
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
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    dividerThickness: 0.5,
                    showBottomBorder: true,
                    sortAscending: isAscending,
                    dataTextStyle: context.textTheme.bodySmall?.copyWith(
                      color: DojoDexColors.primaryText,
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                    ),
                    columns: [
                      DataColumn(
                        label: Row(
                          children: [
                            const Text('Name'),
                            Icon(
                              sortedColumn == 'name'
                                  ? (isAscending
                                      ? Icons.arrow_drop_down_outlined
                                      : Icons.arrow_drop_up_outlined)
                                  : Icons.arrow_drop_up_outlined,
                              size: 20,
                              color: DojoDexColors.white,
                            ),
                          ],
                        ),
                        onSort: (i, _) => _sortTable('name'),
                      ),
                      DataColumn(
                        label: Row(
                          children: [
                            const Text('Classes Possible'),
                            Icon(
                              sortedColumn == 'possible'
                                  ? (isAscending
                                      ? Icons.arrow_drop_down_outlined
                                      : Icons.arrow_drop_up_outlined)
                                  : Icons.arrow_drop_up_outlined,
                              size: 20,
                              color: DojoDexColors.white,
                            ),
                          ],
                        ),
                        onSort: (i, _) => _sortTable('possible'),
                      ),
                      DataColumn(
                        label: Row(
                          children: [
                            const Text('Classes Attended'),
                            Icon(
                              sortedColumn == 'attended'
                                  ? (isAscending
                                      ? Icons.arrow_drop_down_outlined
                                      : Icons.arrow_drop_up_outlined)
                                  : Icons.arrow_drop_up_outlined,
                              size: 20,
                              color: DojoDexColors.white,
                            ),
                          ],
                        ),
                        onSort: (i, _) => _sortTable('attended'),
                      ),
                    ],
                    rows: attendanceData.map((data) {
                      return DataRow(cells: [
                        DataCell(Text(data['name'])),
                        DataCell(Text(data['possible'].toString())),
                        DataCell(Text(data['attended'].toString())),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            }),
          )
        ],
      ),
    );
  }

  CustomInputLayout _buildStartDateField() {
    return CustomInputLayout(
      label: "Start Date",
      child: CustomTextfield(
        controller: startDateController,
        textFieldName: "Select",
        readOnly: true,
        suffixIcon: const Icon(Icons.calendar_today),
        onChanged: (value) {
          FocusScope.of(context).unfocus();
        },
        onTap: () async {
          _isNeedToRefreshAttendanceData = true;

          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime(DateTime.now().year, 1, 1),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );

          if (pickedDate != null &&
              pickedDate.isBefore(DateTime.parse(endDateController.text))) {
            String formattedDate =
                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
            setState(() {
              startDateController.text = formattedDate;
            });
          } else {
            if (pickedDate != null) {
              Fluttertoast.showToast(
                  msg: "Oops! The start date must be before the end date",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP,
                  timeInSecForIosWeb: 5,
                  backgroundColor: DojoDexColors.primary,
                  textColor: Colors.white,
                  fontSize: 16.0);
            }
          }
        },
      ),
    );
  }

  CustomInputLayout _buildEndDateField() {
    return CustomInputLayout(
      label: "End Date",
      child: CustomTextfield(
        controller: endDateController,
        textFieldName: "Select",
        suffixIcon: const Icon(Icons.calendar_today),
        readOnly: true,
        onChanged: (value) {
          FocusScope.of(context).unfocus();
        },
        onTap: () async {
          _isNeedToRefreshAttendanceData = true;

          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );

          if (pickedDate != null &&
              pickedDate.isAfter(DateTime.parse(startDateController.text))) {
            String formattedDate =
                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
            setState(() {
              endDateController.text = formattedDate;
            });
          } else {
            if (pickedDate != null) {
              Fluttertoast.showToast(
                msg: "Oops! The end date must be after the start date",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 5,
                backgroundColor: DojoDexColors.primary,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }
          }
        },
      ),
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
}
