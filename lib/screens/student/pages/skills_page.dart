import 'package:collection/collection.dart';
import 'package:crcrme_banque_stages/common/models/internship_evaluation_skill.dart';
import 'package:crcrme_banque_stages/common/models/student.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/itemized_text.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';
import 'package:flutter/material.dart';

class SkillsPage extends StatefulWidget {
  const SkillsPage({super.key, required this.student});

  final Student student;

  @override
  State<SkillsPage> createState() => SkillsPageState();
}

class SkillsPageState extends State<SkillsPage> {
  Map<Specialization, List<SkillEvaluation>> _getAcquiredSkills(
      Map<Specialization, List<SkillEvaluation>> skills) {
    final Map<Specialization, List<SkillEvaluation>> out = {};
    for (final specialization in skills.keys) {
      out[specialization] = [];
      for (final skillEvaluation in skills[specialization]!) {
        if (skillEvaluation.appreciation == SkillAppreciation.acquired) {
          out[specialization]!.add(skillEvaluation);
        }
      }
    }
    return out;
  }

  Map<Specialization, List<SkillEvaluation>> _getToPursuitSkills(
      Map<Specialization, List<SkillEvaluation>> skills) {
    // Make sure no previously acheived evaluation overrides to fail
    final acquired = _getAcquiredSkills(skills);

    final Map<Specialization, List<SkillEvaluation>> out = {};
    for (final specialization in skills.keys) {
      if (!out.containsKey(specialization)) out[specialization] = [];
      for (final skillEvaluation in skills[specialization]!) {
        if (!acquired[specialization]!
                .any((eval) => eval.skillName == skillEvaluation.skillName) &&
            (skillEvaluation.appreciation == SkillAppreciation.toPursuit ||
                skillEvaluation.appreciation == SkillAppreciation.failed)) {
          out[specialization]!.add(skillEvaluation);
        }
      }
    }
    return out;
  }

  Map<Specialization, List<SkillEvaluation>> _getAllStudentSkills(
      BuildContext context) {
    final enterprises = EnterprisesProvider.of(context, listen: false);
    final internships = InternshipsProvider.of(context, listen: false)
        .byStudentId(widget.student.id);

    Map<Specialization, List<SkillEvaluation>> out = {};
    for (final internship in internships) {
      final List<Specialization> specializations = [];

      // Fetch all the specialization of the current internship
      specializations.add(enterprises
          .fromId(internship.enterpriseId)
          .jobs[internship.jobId]
          .specialization);
      specializations.addAll(internship.extraSpecializationsId
          .map((id) => ActivitySectorsService.specialization(id)));

      for (final specialization in specializations) {
        if (!out.containsKey(specialization)) out[specialization] = [];

        for (final evaluation in internship.skillEvaluations) {
          for (final skill in evaluation.skills) {
            if (specialization.skills
                .any((e) => e.idWithName == skill.skillName)) {
              if (out[specialization]!
                  .any((e) => e.skillName == skill.skillName)) {
                final index = out[specialization]!
                    .indexWhere((e) => e.skillName == skill.skillName);
                out[specialization]![index] = skill;
                debugPrint('coucou');
              } else {
                out[specialization]!.add(skill);
              }
            }
          }
        }
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final skills = _getAllStudentSkills(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkillTile(
              title: 'Compétences réussies',
              skills: _getAcquiredSkills(skills)),
          _SkillTile(
              title: 'Compétences à poursuivre',
              skills: _getToPursuitSkills(skills)),
        ],
      ),
    );
  }
}

class _SkillTile extends StatelessWidget {
  const _SkillTile({required this.title, required this.skills});

  final String title;
  final Map<Specialization, List<SkillEvaluation>> skills;

  int _countNumberOfSkills() {
    int cmp = 0;
    for (final specialization in skills.keys) {
      cmp += skills[specialization]!.length;
    }
    return cmp;
  }

  String _skillComplexity(SkillEvaluation skillEvaluation) {
    final specialization =
        ActivitySectorsService.specialization(skillEvaluation.specializationId);
    final skill = specialization.skills
        .firstWhere((skill) => skill.idWithName == skillEvaluation.skillName);
    return skill.complexity;
  }

  List<String> skillsToStrings(Specialization specialization) {
    return skills[specialization]!
        .sorted((a, b) => a.skillName.compareTo(b.skillName))
        .map((skillEvaluation) =>
            '${skillEvaluation.skillName}\u00a0(Niv.${_skillComplexity(skillEvaluation)})')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubTitle(title, bottom: 0),
        SubTitle('Nombre total = ${_countNumberOfSkills()}', top: 0),
        Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: skills.keys
                .map(
                  (specialization) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (skills[specialization]!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Text(
                              specialization.idWithName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ItemizedText(skillsToStrings(specialization)),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
