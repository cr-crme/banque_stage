import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '/common/models/enterprise.dart';
import '/common/models/job.dart';
import '/common/models/job_list.dart';
import '/common/models/teacher.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/providers/schools_provider.dart';
import '/common/providers/teachers_provider.dart';
import '/common/widgets/activity_type_cards.dart';
import '/common/widgets/dialogs/confirm_pop_dialog.dart';
import '/common/widgets/disponibility_circle.dart';
import '/common/widgets/form_fields/activity_types_picker_form_field.dart';
import '/common/widgets/form_fields/share_with_picker_form_field.dart';
import '/misc/form_service.dart';
import 'widgets/sub_title.dart';

class EnterpriseAboutPage extends StatefulWidget {
  const EnterpriseAboutPage({
    super.key,
    required this.enterprise,
  });

  final Enterprise enterprise;

  @override
  State<EnterpriseAboutPage> createState() => EnterpriseAboutPageState();
}

class EnterpriseAboutPageState extends State<EnterpriseAboutPage> {
  final _formKey = GlobalKey<FormState>();

  String? _name;
  Set<String> _activityTypes = {};
  String? _shareWith;

  bool _editing = false;
  bool get editing => _editing;

  void toggleEdit() {
    if (!_editing) {
      setState(() => _editing = true);
      return;
    }

    if (!FormService.validateForm(_formKey, save: true)) {
      return;
    }

    context.read<EnterprisesProvider>().replace(
          widget.enterprise.copyWith(
            name: _name,
            activityTypes: _activityTypes,
            shareWith: _shareWith,
          ),
        );

    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => ConfirmPopDialog.show(context, editing: editing),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _GeneralInformation(
                  enterprise: widget.enterprise,
                  editMode: _editing,
                  onSaved: (name) => _name = name),
              _AvailablePlace(
                enterprise: widget.enterprise,
                editMode: _editing,
              ),
              _ActivityType(
                  enterprise: widget.enterprise,
                  editMode: _editing,
                  onSaved: (activityTypes) => _activityTypes = activityTypes!),
              _RecrutedBy(enterprise: widget.enterprise),
              _SharingLevel(
                  enterprise: widget.enterprise,
                  editingMode: _editing,
                  onSaved: (shareWith) => _shareWith = shareWith),
            ],
          ),
        ),
      ),
    );
  }
}

class _GeneralInformation extends StatelessWidget {
  const _GeneralInformation(
      {required this.enterprise,
      required this.editMode,
      required this.onSaved});

  final Enterprise enterprise;
  final bool editMode;
  final Function(String?) onSaved;

  @override
  Widget build(BuildContext context) {
    return editMode
        ? Column(
            children: [
              const SubTitle('Nom de l\'entreprise'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller:
                            TextEditingController(text: enterprise.name),
                        enabled: editMode,
                        onSaved: onSaved,
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        : Container();
  }
}

class _AvailablePlace extends StatelessWidget {
  const _AvailablePlace({
    required this.enterprise,
    required this.editMode,
  });

  final Enterprise enterprise;
  final bool editMode;

  void _modifyNumberOfAvailableJobs(context, Job job, {required int change}) {
    final jobs = JobList();
    for (final jobTp in enterprise.jobs) {
      jobs.add(jobTp.id == job.id
          ? jobTp.copyWith(positionsOffered: jobTp.positionsOffered + change)
          : job);
    }
    EnterprisesProvider.of(context).replace(enterprise.copyWith(jobs: jobs));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SubTitle('Places de stage disponibles'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: enterprise.jobs
                .map(
                  (job) => ListTile(
                    visualDensity: VisualDensity.compact,
                    leading: DisponibilityCircle(
                      positionsOffered: job.positionsOffered,
                      positionsOccupied: job.positionsOccupied(context),
                    ),
                    title: Text(job.specialization.idWithName),
                    trailing: editMode
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed:
                                      job.positionsRemaining(context) == 0
                                          ? null
                                          : () => _modifyNumberOfAvailableJobs(
                                              context, job, change: -1),
                                  icon: Icon(Icons.remove,
                                      color:
                                          job.positionsRemaining(context) == 0
                                              ? Colors.grey
                                              : Colors.black)),
                              Text(job.positionsOffered.toString()),
                              IconButton(
                                  onPressed: () => _modifyNumberOfAvailableJobs(
                                      context, job, change: 1),
                                  icon: const Icon(Icons.add,
                                      color: Colors.black)),
                            ],
                          )
                        : Text(
                            '${job.positionsRemaining(context)} / ${job.positionsOffered}'),
                  ),
                )
                .toList(),
          ),
        )
      ],
    );
  }
}

class _ActivityType extends StatelessWidget {
  const _ActivityType(
      {required this.enterprise,
      required this.editMode,
      required this.onSaved});

  final Enterprise enterprise;
  final bool editMode;
  final Function(Set<String>?) onSaved;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SubTitle('Types d\'activités'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Visibility(
                visible: !editMode,
                child:
                    ActivityTypeCards(activityTypes: enterprise.activityTypes),
              ),
              Visibility(
                visible: editMode,
                child: ActivityTypesPickerFormField(
                  initialValue: enterprise.activityTypes,
                  onSaved: onSaved,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _RecrutedBy extends StatelessWidget {
  const _RecrutedBy({required this.enterprise});

  final Enterprise enterprise;

  void _sendEmail(Teacher teacher) {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: teacher.email!,
    );
    launchUrl(emailLaunchUri);
  }

  @override
  Widget build(BuildContext context) {
    final schools = SchoolsProvider.of(context);
    final teachers = TeachersProvider.of(context);

    final teacher = teachers.fromId(enterprise.recrutedBy);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Entreprise recrutée par :'),
        GestureDetector(
          onTap: teacher.email == null ? null : () => _sendEmail(teacher),
          child: Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Row(
              children: [
                Text(
                  teacher.fullName,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        decoration: teacher.email == null
                            ? null
                            : TextDecoration.underline,
                        color: teacher.email == null ? null : Colors.blue,
                      ),
                ),
                Flexible(
                  child: Text(
                    ' - ${schools.fromId(teacher.schoolId).name}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _SharingLevel extends StatelessWidget {
  const _SharingLevel(
      {required this.enterprise,
      required this.editingMode,
      required this.onSaved});

  final Enterprise enterprise;
  final bool editingMode;
  final Function(String?) onSaved;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            'Partage de l\'entreprise',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Visibility(
                visible: !editingMode,
                child: Text(
                  enterprise.shareWith,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Visibility(
                visible: editingMode,
                child: ShareWithPickerFormField(
                  initialValue: enterprise.shareWith,
                  onSaved: onSaved,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
