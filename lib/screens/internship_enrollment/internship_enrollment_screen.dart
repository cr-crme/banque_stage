import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/models/person.dart';
import 'package:crcrme_banque_stages/common/models/phone_number.dart';
import 'package:crcrme_banque_stages/common/models/visiting_priority.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/confirm_pop_dialog.dart';
import 'package:crcrme_banque_stages/common/widgets/scrollable_stepper.dart';
import 'package:crcrme_banque_stages/misc/form_service.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'steps/general_informations_step.dart';
import 'steps/schedule_step.dart';

class InternshipEnrollmentScreen extends StatefulWidget {
  const InternshipEnrollmentScreen({
    super.key,
    required this.enterpriseId,
  });

  final String enterpriseId;

  @override
  State<InternshipEnrollmentScreen> createState() =>
      _InternshipEnrollmentScreenState();
}

class _InternshipEnrollmentScreenState
    extends State<InternshipEnrollmentScreen> {
  final _scrollController = ScrollController();

  final _generalInfoKey = GlobalKey<GeneralInformationsStepState>();
  final _scheduleKey = GlobalKey<ScheduleStepState>();

  int _currentStep = 0;
  final List<StepState> _stepStatus = [StepState.indexed, StepState.indexed];

  void _previousStep() {
    if (_currentStep == 0) return;
    _currentStep -= 1;
    _scrollController.jumpTo(0);
    setState(() {});
  }

  void _nextStep() async {
    final formKeys = [
      _generalInfoKey.currentState!.formKey,
      _scheduleKey.currentState!.formKey,
    ];

    bool isAllValid = true;
    if (_currentStep >= 0) {
      final isValid = FormService.validateForm(formKeys[0]);
      isAllValid = isAllValid && isValid;
      _stepStatus[0] = isValid ? StepState.complete : StepState.error;
    }
    if (_currentStep >= 1) {
      final isValid = FormService.validateForm(formKeys[1]);
      isAllValid = isAllValid && isValid;
      _stepStatus[1] = isValid ? StepState.complete : StepState.error;
    }
    setState(() {});

    if (!isAllValid) return;

    if (_currentStep != 1) {
      _currentStep += 1;
      _scrollController.jumpTo(0);
      setState(() {});
      return;
    }

    // Submit
    _generalInfoKey.currentState!.formKey.currentState!.save();
    _scheduleKey.currentState!.formKey.currentState!.save();
    final enterprise = EnterprisesProvider.of(context, listen: false)
        .fromId(_generalInfoKey.currentState!.enterprise!.id);

    final internship = Internship(
      versionDate: DateTime.now(),
      studentId: _generalInfoKey.currentState!.student!.id,
      signatoryTeacherId:
          TeachersProvider.of(context, listen: false).currentTeacherId,
      extraSupervisingTeacherIds: [],
      enterpriseId: _generalInfoKey.currentState!.enterprise!.id,
      jobId: enterprise.jobs
          .firstWhere((job) =>
              job.specialization ==
              _generalInfoKey.currentState!.primaryJob!.specialization)
          .id,
      extraSpecializationsId: _generalInfoKey.currentState!.extraSpecializations
          .map<String>((e) => e!.id)
          .toList(),
      supervisor: Person(
          firstName: _generalInfoKey.currentState!.supervisorFirstName!,
          lastName: _generalInfoKey.currentState!.supervisorLastName!,
          email: _generalInfoKey.currentState!.supervisorEmail ?? '',
          phone: PhoneNumber.fromString(
              _generalInfoKey.currentState!.supervisorPhone)),
      date: _scheduleKey.currentState!.scheduleController.dateRange!,
      expectedLength: _scheduleKey.currentState!.intershipLength,
      achievedLength: 0,
      weeklySchedules:
          _scheduleKey.currentState!.scheduleController.weeklySchedules,
      visitingPriority: VisitingPriority.low,
    );

    InternshipsProvider.of(context, listen: false).add(internship);

    final student = StudentsProvider.studentsInMyGroups(context, listen: false)
        .firstWhere((e) => e.id == _generalInfoKey.currentState!.student!.id);
    await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              content: Text(
                  '${student.fullName} a bien été inscrit comme stagiaire chez ${enterprise.name}.'
                  '\n\nVous pouvez maintenant accéder aux documents administratifs du stage.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Ok'),
                )
              ],
            ));

    if (!mounted) return;
    Navigator.pop(context);
    GoRouter.of(context).pushNamed(
      Screens.student,
      params: Screens.params(internship.studentId),
      queryParams: Screens.queryParams(pageIndex: '1'),
    );
  }

  void _cancel() async {
    final navigator = Navigator.of(context);
    final answer = await ConfirmExitDialog.show(context,
        content: const Text('Toutes les modifications seront perdues.'));
    if (!mounted || !answer) return;

    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final enterprises = EnterprisesProvider.of(context);
    if ((!enterprises.hasId(widget.enterpriseId))) {
      return Container();
    }

    final enterprise = enterprises.fromId(widget.enterpriseId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Inscrire un stagiaire chez\n${enterprise.name}'),
        leading:
            IconButton(onPressed: _cancel, icon: const Icon(Icons.arrow_back)),
      ),
      body: WillPopScope(
        onWillPop: () async {
          _cancel();
          return false;
        },
        child: ScrollableStepper(
          type: StepperType.horizontal,
          scrollController: _scrollController,
          currentStep: _currentStep,
          onTapContinue: _nextStep,
          onStepTapped: (int tapped) {
            setState(() {
              _currentStep = tapped;
              _scrollController.jumpTo(0);
            });
          },
          onTapCancel: _cancel,
          steps: [
            Step(
              state: _stepStatus[0],
              isActive: _currentStep == 0,
              title: const Text('Général'),
              content: GeneralInformationsStep(
                  key: _generalInfoKey, enterprise: enterprise),
            ),
            Step(
              state: _stepStatus[1],
              isActive: _currentStep == 1,
              title: const Text('Horaire'),
              content: ScheduleStep(key: _scheduleKey),
            ),
          ],
          controlsBuilder: _controlBuilder,
        ),
      ),
    );
  }

  Widget _controlBuilder(BuildContext context, ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_currentStep != 0)
            OutlinedButton(
                onPressed: _previousStep, child: const Text('Précédent')),
          const SizedBox(width: 20),
          TextButton(
            onPressed: details.onStepContinue,
            child: _currentStep == 1
                ? const Text('Confirmer')
                : const Text('Suivant'),
          )
        ],
      ),
    );
  }
}
