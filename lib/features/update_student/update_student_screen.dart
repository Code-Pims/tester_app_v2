import 'package:dojodex_common/models/club/club.dart';
import 'package:dojodex_common/models/grades/grade.dart';
import 'package:dojodex_common/models/student/student.dart';
import 'package:dojodex_common/configs/grade_config.dart';
import 'package:dojodex_common/ui/ui.dart';
import 'package:dojodex_instructor/blocs/club/club_bloc.dart';
import 'package:dojodex_instructor/common/utils/custom_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateStudentArguments {
  final Student student;
  final Club club;

  const UpdateStudentArguments({
    required this.student,
    required this.club,
  });
}

class UpdateStudentScreen extends StatefulWidget {
  final Student student;
  final Club club;

  UpdateStudentScreen({required UpdateStudentArguments arguments, super.key})
      : student = arguments.student,
        club = arguments.club;

  @override
  State<UpdateStudentScreen> createState() => _UpdateStudentScreenState();
}

class _UpdateStudentScreenState extends State<UpdateStudentScreen> {
  /// [Student]
  late TextEditingController _studentNameController;

  /// Student Status
  /// Dropdown
  /// ["pending", "current", "previous", "on hold"]
  final List<String> _studentStatusDropdown = [
    "Pending",
    "Current",
    "Previous",
    "On Hold",
    "Instructor",
    "Assistant",
  ];

  String? _studentStatus = "Pending";

  String? currentGrade;

  final List<Grade> grades = GradesConfig.grades;

  /// Form key for the form
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _studentNameController =
        TextEditingController(text: widget.student.studentName);
    _studentStatus = widget.student.studentStatus;

    currentGrade = widget.student.gradeNumber;

    if (currentGrade != "" && currentGrade != null) {
      final grade = findGradeByValue(grades, currentGrade!);

      currentGrade = grade?.name;
    }

    if (currentGrade == "") {
      currentGrade = null;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const SizedBox(),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    /// Student Name
                    CustomInputLayout(
                      label: "Name",
                      child: CustomTextfield(
                        controller: _studentNameController,
                        textFieldName: "Name",
                        validator: (p0) {
                          if (p0 == null || p0.isEmpty) {
                            return "Name is required";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomInputLayout(
                      label: "Status",
                      child: CustomDropdownWidget(
                        initialValue: _studentStatus,
                        items: _studentStatusDropdown.map((e) => e).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _studentStatus = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomInputLayout(
                      label: "Current Grade",
                      child: CustomDropdownWidget(
                        initialValue: currentGrade,
                        items: grades.map((e) => e.name ?? "").toList(),
                        onChanged: (String? value) {
                          setState(() {
                            currentGrade = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    BlocBuilder<ClubBloc, ClubState>(
                      builder: (context, state) {
                        return PrimaryButtonWidget(
                          style: ButtonStyles.defaultStyle,
                          canonicalButtonName: "Update Student",
                          onPressed: state.isUpdatingStudent ?? false
                              ? null
                              : () {
                                  Grade? grade;
                                  if (currentGrade?.isNotEmpty ?? false) {
                                    grade =
                                        findGradeByName(grades, currentGrade!);
                                  }
                                  if (_formKey.currentState!.validate()) {
                                    context.read<ClubBloc>().add(
                                          UpdateStudent(
                                            student: Student(
                                              id: widget.student.id,
                                              studentName:
                                                  _studentNameController.text,
                                              studentStatus: _studentStatus,
                                              currentGrade:
                                                  grade?.number.toString(),
                                            ),
                                            club: Club(
                                              id: widget.club.id,
                                            ),
                                          ),
                                        );
                                  }
                                },
                          isLoading: state.isUpdatingStudent,
                          children: const [
                            Text(
                              "Update Student",
                            )
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
