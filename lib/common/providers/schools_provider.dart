import 'package:crcrme_banque_stages/common/models/school.dart';
import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class SchoolsProvider extends FirebaseListProvided<School> {
  SchoolsProvider({super.mockMe}) : super(pathToData: 'schools') {
    initializeFetchingData();
  }

  static SchoolsProvider of(BuildContext context, {listen = false}) =>
      Provider.of<SchoolsProvider>(context, listen: listen);

  @override
  School deserializeItem(data) {
    return School.fromSerialized(data);
  }
}
