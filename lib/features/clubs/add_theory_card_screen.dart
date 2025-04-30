import 'package:dojodex_common/models/club/club.dart';
import 'package:dojodex_common/ui/ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../blocs/club/club_bloc.dart';
import '../../common/widgets/headers.dart';

class AddTheoryCardScreen extends StatefulWidget {
  const AddTheoryCardScreen({super.key});

  @override
  State<AddTheoryCardScreen> createState() => _AddTheoryCardScreenState();
}

class _AddTheoryCardScreenState extends State<AddTheoryCardScreen> {
  bool _dialogIsOpen = false;
  String? selectedMartialArt;
  String? selectedMinimumGrade;
  List<String> selectedOptions = [];
  TextEditingController questionTextController = TextEditingController();
  TextEditingController answerTextController = TextEditingController();
  late ClubBloc clubBloc;

  Future<void> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? seen = prefs.getBool('seen_theory_intro');

    if (seen == null || !seen) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => showNonDismissibleAlertDialog(context));
      await prefs.setBool('seen_theory_intro', true);
    }
  }

  @override
  void initState() {
    clubBloc = context.read<ClubBloc>();
    clubBloc.add(const FetchCardTypes());
    clubBloc.add(const FetchGrades());
    clubBloc.add(const FetchMartialArts());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DojoDexHeaders.mainAppBar(),
      body: SingleChildScrollView(
        child: BlocBuilder<ClubBloc, ClubState>(builder: (context, state) {
          Club? currentClub = state.currentClub;

          if (currentClub == null) {
            _checkFirstTime();
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    "Please add a club before creating theory cards",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Column(
                  children: [
                    _buildMartialArtsSelection(),
                    const SizedBox(height: 20),
                    _buildQuestionTextField(),
                    const SizedBox(height: 20),
                    _buildAnswerTextField(),
                    const SizedBox(height: 20),
                    _buildGradeDropdowns(),
                    const SizedBox(height: 20),
                    _buildCardTypes(),
                  ],
                ),
                const SizedBox(height: 30),
                BlocBuilder<ClubBloc, ClubState>(
                  builder: (context, clubState) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        void listener() {
                          setState(() {});
                        }

                        final isButtonEnabled = selectedMartialArt != null &&
                            questionTextController.text.isNotEmpty &&
                            answerTextController.text.isNotEmpty &&
                            selectedMinimumGrade != null &&
                            selectedOptions.isNotEmpty;

                        questionTextController.addListener(listener);
                        answerTextController.addListener(listener);

                        return Column(
                          children: [
                            PrimaryButtonWidget(
                              style: ButtonStyles.defaultStyle,
                              canonicalButtonName: "Submit",
                              onPressed: isButtonEnabled
                                  ? () async {
                                      if (!isButtonEnabled) {
                                        return;
                                      }

                                      context.read<ClubBloc>().add(
                                            AddTheoryCard(
                                              clubId: state.currentClub!.id
                                                  .toString(),
                                              martialArt:
                                                  selectedMartialArt ?? "",
                                              question:
                                                  questionTextController.text,
                                              answer: answerTextController.text,
                                              minimumGrade:
                                                  selectedMinimumGrade ?? "",
                                              cardType: selectedOptions.first,
                                              onSuccess: () {
                                                selectedOptions = [];
                                                questionTextController.text =
                                                    "";
                                                answerTextController.text = "";
                                              },
                                            ),
                                          );
                                    }
                                  : null,
                              isLoading: state.isAddingTheoryCard ?? false,
                              children: const [
                                Text(
                                  "Save",
                                )
                              ],
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).padding.bottom + 12),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // Toggle selection for an option
  void toggleSelection(String option) {
    setState(() {
      if (selectedOptions.contains(option)) {
        selectedOptions = [];
      } else {
        selectedOptions = [option];
      }
    });
  }

  CustomInputLayout _buildAnswerTextField() {
    return CustomInputLayout(
      label: "Answer",
      child: CustomTextfield(
        controller: answerTextController,
        textFieldName: "Answer",
        validator: (p0) {
          if (p0 == null || p0.isEmpty) {
            return "Answer is required";
          }
          return null;
        },
      ),
    );
  }

  CustomInputLayout _buildQuestionTextField() {
    return CustomInputLayout(
      label: "Question",
      child: CustomTextfield(
        controller: questionTextController,
        textFieldName: "Question",
        validator: (p0) {
          if (p0 == null || p0.isEmpty) {
            return "Question is required";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildGradeDropdowns() {
    return BlocBuilder<ClubBloc, ClubState>(
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
                  initialValue: state.initialMinimumGrade,
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
          ],
        );
      },
    );
  }

  Widget _buildMartialArtsSelection() {
    return BlocBuilder<ClubBloc, ClubState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, state) {
        if (state.isFetchingMartialArts ?? false) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }
        return CustomInputLayout(
          label: "Martial Arts",
          child: CustomDropdownWidget(
            initialValue: state.initialArtsToStudy,
            items: state.martialArtLists
                    ?.map((e) => e.name ?? "Unknown")
                    .toList() ??
                const [],
            onChanged: (String? value) {
              setState(() {
                selectedMartialArt = value;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildCardTypes() {
    return BlocBuilder<ClubBloc, ClubState>(
      builder: (context, state) {
        if (state.isFetchingCardTypes ?? false) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }

        return SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Card Types'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: state.cardTypeLists?.map((option) {
                      return ChoiceChip(
                        label: Text(option.name ?? "Unknown"),
                        selected: selectedOptions.contains(option.name),
                        onSelected: (bool selected) {
                          toggleSelection(option.name ?? "Unknown");
                        },
                        side: BorderSide(
                          color: selectedOptions.contains(option.name)
                              ? DojoDexColors.primary
                              : DojoDexColors.white,
                        ),
                        checkmarkColor: DojoDexColors.white,
                        selectedColor: DojoDexColors.primary,
                        backgroundColor: DojoDexColors.white,
                        labelStyle: TextStyle(
                          color: selectedOptions.contains(option.name)
                              ? DojoDexColors.white
                              : DojoDexColors.primaryText,
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      );
                    }).toList() ??
                    [],
              ),
            ],
          ),
        );
      },
    );
  }

  void showNonDismissibleAlertDialog(BuildContext context) {
    if (_dialogIsOpen) return;
    _dialogIsOpen = true;
    Future.delayed(const Duration(seconds: 1)).then((_) async {
      if (!context.mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false, // Prevents dismissing by tapping outside
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            contentPadding: const EdgeInsets.all(16), // Reduced padding
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                const Text(
                  "Please add a club first before creating club specific theory items for your students",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: DojoDexColors.secondaryText,
                    fontSize: 16,
                  ), // Adjust font size
                ),
                const SizedBox(height: 16), // Space before button
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor:
                        DojoDexColors.primary.withValues(alpha: 0.9),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      const Text("OK", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
      _dialogIsOpen = false;
    });
  }
}
