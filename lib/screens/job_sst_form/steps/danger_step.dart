import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/question_with_checkbox_list.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/question_with_radio_bool.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/question_with_text.dart';
import 'package:flutter/material.dart';

class DangerStep extends StatefulWidget {
  const DangerStep({
    super.key,
    required this.job,
  });

  final Job job;

  @override
  State<DangerStep> createState() => DangerStepState();
}

class DangerStepState extends State<DangerStep> {
  final formKey = GlobalKey<FormState>();

  bool isProfessor = true;

  String? dangerousSituations;
  List<String>? equipmentRequired;
  String? pastIncidents;
  String? incidentContact;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            QuestionWithText(
              initialValue: widget.job.dangerousSituations,
              question:
                  '1. Quelles sont les situations de travail qui pourraient être '
                  'dangereuses pour mon élève? Comment faudrait-il l\'y préparer?',
              onSaved: (text) => dangerousSituations = text,
            ),
            QuestionWithCheckboxList(
              initialChoices: widget.job.equipmentRequired.toSet(),
              choicesQuestion:
                  '2. Est-ce que l\'élève devra porter un des équipements de '
                  'protection individuelle suivants?',
              choices: const {
                'Chaussures à semelles antidérapantes',
                'Chaussures de sécurité',
                'Lunettes de sécurité',
                'Protections auditives (p. ex. bouchons)',
                'Masque',
                'Casque',
                'Gants',
              },
              onSavedChoices: (choices) =>
                  equipmentRequired = choices?.toList(),
            ),
            QuestionWithRadioBool(
              initialChoice: widget.job.pastIncidents.isNotEmpty,
              initialText: widget.job.pastIncidents,
              choiceQuestion:
                  '3. Est-ce qu\'il y a déjà eu des incidents ou des accidents du '
                  'travail au poste que l\'élève occupera en stage?',
              textQuestion: 'Pouvez-vous me raconter ce qu\'il s\'est passé?',
              onSavedText: (text) => pastIncidents = text,
            ),
            QuestionWithText(
              initialValue: widget.job.incidentContact,
              question:
                  '4. À quelle personne dans l\'entreprise, l\'élève doit-il '
                  's\'adresser en cas de blessure ou d\'incident?',
              onSaved: (text) => incidentContact = text,
            ),
          ],
        ),
      ),
    );
  }
}
