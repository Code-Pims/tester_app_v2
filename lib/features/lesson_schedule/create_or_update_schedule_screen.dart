import 'package:dojodex_common/models/club/club.dart';
import 'package:dojodex_common/models/grades/grade.dart';
import 'package:dojodex_common/models/lesson_schedule/lesson_schedule.dart';
import 'package:dojodex_common/ui/ui.dart';
import 'package:dojodex_instructor/blocs/club/club_bloc.dart';
import 'package:dojodex_instructor/blocs/lesson/lesson_bloc.dart';
import 'package:dojodex_instructor/blocs/setting/setting_bloc.dart';
import 'package:dojodex_instructor/common/utils/custom_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CreateOrUpdateScheduleArguments {
  final LessonSchedule? lessonSchedule;

  const CreateOrUpdateScheduleArguments({this.lessonSchedule});
}

class CreateOrUpdateScheduleScreen extends StatefulWidget {
  final LessonSchedule? lessonSchedule;

  CreateOrUpdateScheduleScreen(
      {required CreateOrUpdateScheduleArguments arguments, super.key})
      : lessonSchedule = arguments.lessonSchedule;

  @override
  State<CreateOrUpdateScheduleScreen> createState() =>
      _CreateOrUpdateScheduleScreenState();
}

class _CreateOrUpdateScheduleScreenState
    extends State<CreateOrUpdateScheduleScreen> {
  int? selectedDay;
  String? selectedLocation;
  String? selectedClubAddress;
  String? selectedMinimumGrade;
  String? selectedMaximumGrade;
  String? selectedStartTime;
  String? selectedEndTime;
  late TextEditingController classNameController;
  late TextEditingController minimumAgeTextController;
  late TextEditingController maximumAgeTextController;
  late TextEditingController startTimeTextController;
  late TextEditingController endTimeTextController;

  /// Form key for the form
  late GlobalKey<FormState> _formKey;

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    _maybeInitValues();
    super.initState();
  }

  void _maybeInitValues() {
    final grades = context.read<SettingBloc>().state.gradeLists;

    selectedMinimumGrade = widget.lessonSchedule?.minGrade == null
        ? grades?.first.name
        : findGradeByValue(
                grades ?? [], widget.lessonSchedule!.minGrade.toString())
            ?.name;

    selectedMaximumGrade = widget.lessonSchedule?.maxGrade == null
        ? grades?.last.name
        : findGradeByValue(
                grades ?? [], widget.lessonSchedule!.maxGrade.toString())
            ?.name;

    selectedDay = widget.lessonSchedule?.dayIndex ?? 1;

    selectedStartTime = widget.lessonSchedule?.startTime != null
        ? timeToString(widget.lessonSchedule!.startTime!)
        : null;

    selectedEndTime = widget.lessonSchedule?.endTime != null
        ? timeToString(widget.lessonSchedule!.endTime!)
        : null;

    classNameController = widget.lessonSchedule?.className != null
        ? TextEditingController(
            text: widget.lessonSchedule!.className.toString(),
          )
        : TextEditingController();

    minimumAgeTextController = widget.lessonSchedule?.minAge != null
        ? TextEditingController(
            text: widget.lessonSchedule!.minAge.toString(),
          )
        : TextEditingController();

    maximumAgeTextController = widget.lessonSchedule?.maxAge != null
        ? TextEditingController(
            text: widget.lessonSchedule!.maxAge.toString(),
          )
        : TextEditingController();

    startTimeTextController = widget.lessonSchedule?.startTime != null
        ? TextEditingController(
            text: timeToString(widget.lessonSchedule!.startTime!),
          )
        : TextEditingController();
    endTimeTextController = widget.lessonSchedule?.endTime != null
        ? TextEditingController(
            text: timeToString(widget.lessonSchedule!.endTime!),
          )
        : TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.lessonSchedule?.isUpdate ?? false
            ? const Text("Update Schedule")
            : const Text('Create Schedule'),
        actions: [
          _maybeDeleteSchedule(context),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildClassNameField(),
                const SizedBox(height: 16),
                _buildDayOfTheWeek(),
                const SizedBox(height: 16),
                _buildLocationTextfield(),
                const SizedBox(height: 16),
                _buildStartTimePicker(context),
                const SizedBox(height: 16),
                _buildMinimumAndMaximumAge(),
                const SizedBox(height: 16),
                _buildGradeDropdowns(),
                const SizedBox(height: 40),
                _buildCreateScheduleButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _maybeDeleteSchedule(BuildContext context) {
    if (!(widget.lessonSchedule?.isUpdate ?? false)) {
      return const SizedBox();
    }
    return BlocBuilder<LessonBloc, LessonState>(
      builder: (context, state) {
        if (state.isDeletingSchedule ?? false) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: CupertinoActivityIndicator(),
            ),
          );
        }
        return IconButton(
          onPressed: () {
            context.read<LessonBloc>().add(
                  DeleteSchedule(
                    widget.lessonSchedule!.id!,
                  ),
                );
          },
          icon: const Icon(
            Icons.delete,
            color: DojoDexColors.alert,
          ),
        );
      },
    );
  }

  Widget _buildCreateScheduleButton() {
    return BlocBuilder<SettingBloc, SettingState>(
      builder: (context, state) {
        if (state.isFetchingClubLocations ?? false) {
          return const SizedBox();
        }
        return BlocBuilder<LessonBloc, LessonState>(
          builder: (context, state) {
            if (state.isDeletingSchedule ?? false) {
              return const SizedBox();
            }
            return PrimaryButtonWidget(
              style: ButtonStyles.defaultStyle,
              canonicalButtonName: "Create",
              onPressed: (state.isCreatingSchedule ?? false) ||
                      (state.isUpdatingSchedule ?? false)
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        final grades =
                            context.read<SettingBloc>().state.gradeLists;
                        final currentClub =
                            context.read<ClubBloc>().state.currentClub;
                        if (currentClub == null) {
                          return;
                        }
                        if (grades == null) {
                          return;
                        }

                        final maximumGrade = findGradeByName(
                          grades,
                          selectedMaximumGrade!,
                        );
                        final minimumGrade = findGradeByName(
                          grades,
                          selectedMinimumGrade!,
                        );

                        if (widget.lessonSchedule?.isUpdate ?? false) {
                          /// Update Schedule
                          ///
                          _handleUpdateSchedule(
                            context,
                            currentClub,
                            minimumGrade,
                            maximumGrade,
                          );
                          return;
                        }

                        /// Create Schedule
                        _handleCreateSchedule(
                          context,
                          currentClub,
                          minimumGrade,
                          maximumGrade,
                        );
                      }
                    },
              isLoading: (state.isCreatingSchedule ?? false) ||
                  (state.isUpdatingSchedule ?? false),
              children: [
                Builder(builder: (context) {
                  if (widget.lessonSchedule?.isUpdate ?? false) {
                    return const Text(
                      "Update Schedule",
                    );
                  }
                  return const Text(
                    "Create Schedule",
                  );
                })
              ],
            );
          },
        );
      },
    );
  }

  void _handleUpdateSchedule(
    BuildContext context,
    Club currentClub,
    Grade minimumGrade,
    Grade maximumGrade,
  ) {
    return context.read<LessonBloc>().add(
          UpdateSchedule(
            widget.lessonSchedule!.copyWith(
              className: classNameController.text,
              dayIndex: selectedDay,
              locationName: selectedLocation,
              clubAddress: selectedClubAddress,
              minGrade: minimumGrade.number,
              maxGrade: maximumGrade.number,

              /// The Date should be the current date
              /// parse the time to DateTime
              startTime:
                  DateFormat('HH:mm').parse(selectedStartTime ?? "00:00"),
              endTime: DateFormat('HH:mm').parse(selectedEndTime ?? "00:00"),
              minAge: int.parse(minimumAgeTextController.text),
              maxAge: int.parse(maximumAgeTextController.text),
            ),
          ),
        );
  }

  void _handleCreateSchedule(
    BuildContext context,
    Club currentClub,
    Grade minimumGrade,
    Grade maximumGrade,
  ) {
    context.read<LessonBloc>().add(
          CreateSchedule(
            LessonSchedule(
              clubID: currentClub.id,
              className: classNameController.text,
              dayIndex: selectedDay,
              locationName: selectedLocation,
              clubAddress: selectedClubAddress,
              minGrade: minimumGrade.number,
              maxGrade: maximumGrade.number,

              // / The Date should be the current date
              // / parse the time to DateTime
              startTime:
                  DateFormat('HH:mm').parse(selectedStartTime ?? "00:00"),
              endTime: DateFormat('HH:mm').parse(selectedEndTime ?? "00:00"),
              minAge: int.parse(minimumAgeTextController.text),
              maxAge: int.parse(maximumAgeTextController.text),
            ),
          ),
        );
  }

  Widget _buildClassNameField() {
    return CustomInputLayout(
      label: "Class Name",
      child: CustomTextfield(
        controller: classNameController,
        textFieldName: "Enter Class Name",
        validator: (className) {
          if (className == null || className.isEmpty) {
            return "Class name is required";
          }
          return null;
        },
      ),
    );
  }

  Row _buildMinimumAndMaximumAge() {
    return Row(
      children: [
        Expanded(
          child: CustomInputLayout(
            label: "Minimum Age",
            child: CustomTextfield(
              controller: minimumAgeTextController,
              textFieldName: "Minimum Age",
              isDigitOnly: true,
              validator: (p0) {
                if (p0 == null || p0.isEmpty) {
                  return "Minimum Age is required";
                }
                return null;
              },
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CustomInputLayout(
            label: "Maximum Age",
            child: CustomTextfield(
              controller: maximumAgeTextController,
              isDigitOnly: true,
              textFieldName: "Maximum Age",
              validator: (p0) {
                if (p0 == null || p0.isEmpty) {
                  return "Maximum Age is required";
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  BlocBuilder<LessonBloc, LessonState> _buildDayOfTheWeek() {
    return BlocBuilder<LessonBloc, LessonState>(
      builder: (context, state) {
        return CustomInputLayout(
          label: "Day of the week",
          child: CustomDropdownWidget(
            initialValue: state.getDayName(selectedDay ?? 0),
            items: state.daysOfWeek.map((e) => e).toList(),
            onChanged: (String? value) {
              setState(() {
                selectedDay = state.getDayIndex(value ?? "Monday");
              });
            },
          ),
        );
      },
    );
  }

  TimeOfDay parseTime(String timeString) {
    DateFormat format = DateFormat.Hm(); // "HH:mm" format for 24-hour time
    DateTime dateTime = format.parse(timeString);
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  Widget _buildStartTimePicker(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomInputLayout(
            label: "Start Time",
            child: InkWell(
              onTap: () async {
                /// Time picker
                final value = await showTimePicker(
                  context: context,
                  initialTime:
                      selectedStartTime != null && selectedStartTime != ""
                          ? parseTime(selectedStartTime!)
                          : TimeOfDay(hour: TimeOfDay.now().hour, minute: 0),
                );

                if (value != null) {
                  final now = DateTime.now();
                  final formattedTime = DateFormat('HH:mm').format(DateTime(
                      now.year, now.month, now.day, value.hour, value.minute));
                  setState(() {
                    selectedStartTime = formattedTime;
                  });
                }
              },
              child: AbsorbPointer(
                child: Builder(builder: (context) {
                  startTimeTextController = TextEditingController(
                    text: selectedStartTime,
                  );
                  return CustomTextfield(
                    controller: startTimeTextController,
                    textFieldName: "Start time",
                    validator: (p0) {
                      if (p0 == null || p0.isEmpty) {
                        return "Start time is required";
                      }
                      return null;
                    },
                    suffixIcon: const Icon(Icons.access_time),
                  );
                }),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CustomInputLayout(
            label: "End Time",
            child: InkWell(
              onTap: () async {
                /// Time picker
                final value = await showTimePicker(
                  context: context,
                  initialTime: selectedEndTime != null && selectedEndTime != ""
                      ? parseTime(selectedEndTime!)
                      : TimeOfDay(hour: TimeOfDay.now().hour, minute: 0),
                );

                if (value != null) {
                  final now = DateTime.now();
                  final formattedTime = DateFormat('HH:mm').format(DateTime(
                      now.year, now.month, now.day, value.hour, value.minute));
                  setState(() {
                    selectedEndTime = formattedTime;
                  });
                }
              },
              child: AbsorbPointer(
                child: Builder(builder: (context) {
                  endTimeTextController = TextEditingController(
                    text: selectedEndTime,
                  );
                  return CustomTextfield(
                    controller: endTimeTextController,
                    textFieldName: "End time",
                    validator: (p0) {
                      if (p0 == null || p0.isEmpty) {
                        return "End time is required";
                      }
                      return null;
                    },
                    suffixIcon: const Icon(Icons.access_time),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationTextfield() {
    return BlocBuilder<SettingBloc, SettingState>(
      buildWhen: (previous, current) =>
          previous.clubLocations != current.clubLocations,
      builder: (context, state) {
        return CustomInputLayout(
          label: "Location",
          child: Builder(builder: (context) {
            if (state.isFetchingClubLocations ?? false) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }
            if (state.clubLocations?.isEmpty ?? true) {
              return const SizedBox();
            }

            if (selectedLocation == null) {
              selectedLocation = widget.lessonSchedule?.locationName ??
                  state.clubLocations![0].clubname;

              selectedClubAddress = widget.lessonSchedule?.clubAddress ??
                  state.clubLocations![0].clubAddress;
            }

            return CustomDropdownWidget(
              initialValue: selectedLocation,
              items: state.clubLocations!.map((e) => e.clubname!).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedLocation = value;
                });
              },
            );
          }),
        );
      },
    );
  }

  Widget _buildGradeDropdowns() {
    return BlocBuilder<SettingBloc, SettingState>(
      builder: (context, state) {
        if (state.isFetchingGrades ?? false) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }
        return Row(
          children: [
            Expanded(
              child: CustomInputLayout(
                label: "Minimum Grade",
                child: CustomDropdownWidget(
                  initialValue: selectedMinimumGrade,
                  items: state.gradeLists
                          ?.map((e) => e.name ?? "Unknown")
                          .toList() ??
                      const [],
                  onChanged: (String? value) {
                    setState(() {
                      selectedMinimumGrade = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomInputLayout(
                label: "Maximum Grade",
                child: CustomDropdownWidget(
                  initialValue: selectedMaximumGrade,
                  items: state.gradeLists
                          ?.map((e) => e.name ?? "Unknown")
                          .toList() ??
                      const [],
                  onChanged: (String? value) {
                    setState(() {
                      selectedMaximumGrade = value;
                    });
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
