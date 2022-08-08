import '/common/models/job.dart';
import '/misc/custom_containers/list_serializable.dart';

class JobList extends ListSerializable<Job> {
  JobList() : super();
  JobList.fromSerialized(Map<String, dynamic> map) : super.fromSerialized(map);

  @override
  Job deserializeItem(map) {
    return Job.fromSerialized(
        (map as Map).map((key, value) => MapEntry(key.toString(), value)));
  }
}
