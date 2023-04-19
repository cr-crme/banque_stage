import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/common/providers/internships_provider.dart';
import '/common/providers/students_provider.dart';
import '/common/widgets/sub_title.dart';
import 'attitude_evaluation_form_controller.dart';

class AttitudeEvaluationScreen extends StatefulWidget {
  const AttitudeEvaluationScreen({super.key, required this.internshipId});

  final String internshipId;

  @override
  State<AttitudeEvaluationScreen> createState() =>
      _AttitudeEvaluationScreenState();
}

class _AttitudeEvaluationScreenState extends State<AttitudeEvaluationScreen> {
  int _currentStep = 0;
  final List<StepState> _stepStatus = [
    StepState.indexed,
    StepState.indexed,
    StepState.indexed,
    StepState.indexed,
  ];
  late final _formController = AttitudeEvaluationFormController(context,
      internshipId: widget.internshipId);

  void _previousStep() {
    if (_currentStep == 0) return;

    _currentStep -= 1;
    setState(() {});
  }

  void _nextStep() {
    if (_currentStep == 3) return;
    _stepStatus[_currentStep] = StepState.complete;

    _currentStep += 1;
    setState(() {});
  }

  Widget _controlBuilder(BuildContext context, ControlsDetails details) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Expanded(child: SizedBox()),
          if (_currentStep != 0)
            OutlinedButton(
                onPressed: _previousStep, child: const Text('Précédent')),
          const SizedBox(
            width: 20,
          ),
          TextButton(
            onPressed: details.onStepContinue,
            child: _currentStep == 3
                ? const Text('Soumettre')
                : const Text('Suivant'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final internship = InternshipsProvider.of(context)[widget.internshipId];
    final allStudents = StudentsProvider.of(context);
    if (!allStudents.hasId(internship.studentId)) return Container();
    final student = allStudents[internship.studentId];

    return Scaffold(
        appBar: AppBar(
          title: Text(
              'Évaluation de ${student.fullName}\nC2. Attitudes et comportements'),
        ),
        body: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: _nextStep,
          onStepTapped: (int tapped) => setState(() => _currentStep = tapped),
          onStepCancel: () => Navigator.pop(context),
          steps: [
            Step(
              label: const Text('Détails'),
              title: Container(),
              state: _stepStatus[0],
              isActive: _currentStep == 0,
              content:
                  _AttitudeGeneralDetailsStep(formController: _formController),
            ),
            Step(
              label: const Text('Attitudes'),
              title: Container(),
              state: _stepStatus[1],
              isActive: _currentStep == 1,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AttitudeRadioChoices(
                      title: '1. ${Inattendance.title}',
                      formController: _formController,
                      elements: Inattendance.values),
                  _AttitudeRadioChoices(
                      title: '2. ${Ponctuality.title}',
                      formController: _formController,
                      elements: Ponctuality.values),
                  _AttitudeRadioChoices(
                      title: '3. ${Sociability.title}',
                      formController: _formController,
                      elements: Sociability.values),
                  _AttitudeRadioChoices(
                      title: '4. ${Politeness.title}',
                      formController: _formController,
                      elements: Politeness.values),
                  _AttitudeRadioChoices(
                      title: '5. ${Motivation.title}',
                      formController: _formController,
                      elements: Motivation.values),
                  _AttitudeRadioChoices(
                      title: '6. ${DressCode.title}',
                      formController: _formController,
                      elements: DressCode.values),
                ],
              ),
            ),
            Step(
                label: const Text('Rendement'),
                title: Container(),
                state: _stepStatus[2],
                isActive: _currentStep == 2,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _AttitudeRadioChoices(
                        title: '7. ${QualityOfWork.title}',
                        formController: _formController,
                        elements: QualityOfWork.values),
                    _AttitudeRadioChoices(
                        title: '8. ${Productivity.title}',
                        formController: _formController,
                        elements: Productivity.values),
                    _AttitudeRadioChoices(
                        title: '9. ${Autonomy.title}',
                        formController: _formController,
                        elements: Autonomy.values),
                    _AttitudeRadioChoices(
                        title: '10. ${Cautiousness.title}',
                        formController: _formController,
                        elements: Cautiousness.values),
                  ],
                )),
            Step(
              label: const Text('Commentaires'),
              title: Container(),
              state: _stepStatus[3],
              isActive: _currentStep == 3,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AttitudeRadioChoices(
                      title: '11. ${GeneralAppreciation.title}',
                      formController: _formController,
                      elements: GeneralAppreciation.values),
                  _Comments(formController: _formController),
                ],
              ),
            )
          ],
          controlsBuilder: _controlBuilder,
        ));
  }
}

class _AttitudeGeneralDetailsStep extends StatelessWidget {
  const _AttitudeGeneralDetailsStep({
    required this.formController,
  });

  final AttitudeEvaluationFormController formController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EvaluationDate(formController: formController),
        _PersonAtMeeting(formController: formController),
      ],
    );
  }
}

class _EvaluationDate extends StatefulWidget {
  const _EvaluationDate({required this.formController});

  final AttitudeEvaluationFormController formController;
  @override
  State<_EvaluationDate> createState() => _EvaluationDateState();
}

class _EvaluationDateState extends State<_EvaluationDate> {
  void _promptDate(context) async {
    final newDate = await showDatePicker(
      helpText: 'Sélectionner les dates',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
      context: context,
      initialEntryMode: DatePickerEntryMode.input,
      initialDate: widget.formController.evaluationDate,
      firstDate: DateTime(DateTime.now().year),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (newDate == null) return;

    widget.formController.evaluationDate = newDate;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Date de l\'évaluation'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Text(DateFormat('dd MMMM yyyy', 'fr_CA')
                  .format(widget.formController.evaluationDate)),
              IconButton(
                icon: const Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.blue,
                ),
                onPressed: () => _promptDate(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PersonAtMeeting extends StatefulWidget {
  const _PersonAtMeeting({required this.formController});

  final AttitudeEvaluationFormController formController;
  @override
  State<_PersonAtMeeting> createState() => _PersonAtMeetingState();
}

class _PersonAtMeetingState extends State<_PersonAtMeeting> {
  Widget _buildCheckTile(
      {required String title,
      required bool value,
      required Function(bool?) onChanged}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 3 / 4,
      child: CheckboxListTile(
        visualDensity: VisualDensity.compact,
        controlAffinity: ListTileControlAffinity.leading,
        value: value,
        onChanged: onChanged,
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Personnes présentes lors de l\'évaluation'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...widget.formController.wereAtMeeting.keys
                  .map((person) => _buildCheckTile(
                      title: person,
                      value: widget.formController.wereAtMeeting[person]!,
                      onChanged: (newValue) => setState(() => widget
                          .formController.wereAtMeeting[person] = newValue!)))
                  .toList(),
              _buildCheckTile(
                  title: 'Autre',
                  value: widget.formController.withOtherAtMeeting,
                  onChanged: (newValue) => setState(() =>
                      widget.formController.withOtherAtMeeting = newValue!)),
              Visibility(
                visible: widget.formController.withOtherAtMeeting,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Précisez : ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      TextFormField(
                        controller:
                            widget.formController.othersAtMeetingController,
                        maxLines: null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AttitudeRadioChoices extends StatefulWidget {
  const _AttitudeRadioChoices({
    required this.title,
    required this.formController,
    required this.elements,
  });

  final String title;
  final AttitudeEvaluationFormController formController;
  final List<AttitudeCategoryEnum> elements;

  @override
  State<_AttitudeRadioChoices> createState() => _AttitudeRadioChoicesState();
}

class _AttitudeRadioChoicesState extends State<_AttitudeRadioChoices> {
  @override
  void initState() {
    super.initState();
    widget.formController.responses[widget.elements[0].runtimeType] = null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubTitle(widget.title),
        ...widget.elements.map((e) => RadioListTile<AttitudeCategoryEnum>(
            dense: true,
            visualDensity: VisualDensity.compact,
            title: Text(e.name),
            value: e,
            groupValue: widget.formController.responses[e.runtimeType],
            onChanged: (newValue) => setState(() =>
                widget.formController.responses[e.runtimeType] = newValue!))),
      ],
    );
  }
}

class _Comments extends StatelessWidget {
  const _Comments({required this.formController});

  final AttitudeEvaluationFormController formController;

  @override
  Widget build(BuildContext context) {
    const spacing = 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: SubTitle('12. Autres commentaires'),
        ),
        TextFormField(
          controller: formController.commentsController,
          maxLines: null,
        ),
      ],
    );
  }
}
