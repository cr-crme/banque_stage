import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EnterprisesProvider extends FirebaseListProvided<Enterprise> {
  EnterprisesProvider({super.mockMe}) : super(pathToData: 'enterprises') {
    initializeFetchingData();
  }

  static EnterprisesProvider of(BuildContext context, {listen = true}) =>
      Provider.of<EnterprisesProvider>(context, listen: listen);

  @override
  Enterprise deserializeItem(data) {
    return Enterprise.fromSerialized(data);
  }

  void replaceJob(enterprise, Job job) {
    this[enterprise].jobs.replace(job);
    replace(this[enterprise]);
  }
}
