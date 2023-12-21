import 'package:crcrme_banque_stages/common/providers/auth_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/initialize_program.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils.dart';
import '../utils.dart';

void main() {
  group('TeachersProvider', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    initializeProgram(useDatabaseEmulator: true, mockFirebase: true);

    test('"currentTeacherId" works', () {
      final teachers = TeachersProvider(mockMe: true);
      expect(() => teachers.currentTeacherId, throwsException);

      teachers.initializeAuth(AuthProvider(mockMe: true));
      expect(teachers.currentTeacherId, 'Mock User');
    });

    test('"getCurrentTeacher" works', () {
      final teachers = TeachersProvider(mockMe: true);
      expect(teachers.currentTeacher.firstName, 'Error');

      final auth = AuthProvider(mockMe: true);
      teachers.initializeAuth(auth);
      teachers.add(dummyTeacher());
      expect(teachers.currentTeacher.firstName, 'Error');

      teachers.add(dummyTeacher(id: auth.currentUser!.uid));
      expect(teachers.currentTeacher.firstName, 'Pierre');
    });

    test('"deserializeItem" works', () {
      final teachers = TeachersProvider(mockMe: true);
      final teacher = teachers.deserializeItem(dummyTeacher().serialize());

      expect(teacher.firstName, 'Pierre');
      expect(teacher.middleName, 'Jean');
      expect(teacher.lastName, 'Jacques');
      expect(teacher.schoolId, 'schoolId');
      expect(teacher.email, 'peter.john.jakob@test.com');
      expect(teacher.groups, ['101', '102']);
    });

    testWidgets('can get "of" context', (tester) async {
      final context = await tester.contextWithNotifiers(withTeachers: true);
      final teachers = TeachersProvider.of(context, listen: false);
      expect(teachers, isNotNull);
    });
  });
}
