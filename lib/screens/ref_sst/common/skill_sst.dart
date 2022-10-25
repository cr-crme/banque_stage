// ignore_for_file: non_constant_identifier_names

import 'package:crcrme_banque_stages/screens/ref_sst/common/risk_sst.dart';

class SkillSST {
  const SkillSST({
    required this.name,
    required this.code,
    required this.criterias,
    required this.tasks,
    required this.risks, //There are sometimes no risks
  });

  final String name;
  final int code;
  final List<String> criterias;
  final List<String> tasks;
  final List<RiskSST> risks;

  @override
  String toString() {
    return '{Competence #$code: $name}';
  }
}
