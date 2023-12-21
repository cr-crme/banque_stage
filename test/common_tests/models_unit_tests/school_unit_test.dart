import 'package:crcrme_banque_stages/common/models/address.dart';
import 'package:crcrme_banque_stages/common/models/school.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

void main() {
  group('School', () {
    test('"copyWith" changes the requested elements', () {
      final school = dummySchool();

      final schoolSame = school.copyWith();
      expect(schoolSame.id, school.id);
      expect(schoolSame.name, school.name);
      expect(schoolSame.address, school.address);

      final schoolDifferent = school.copyWith(
        id: 'newId',
        name: 'newName',
        address: dummyAddress().copyWith(id: 'newAddressId'),
      );

      expect(schoolDifferent.id, 'newId');
      expect(schoolDifferent.name, 'newName');
      expect(schoolDifferent.address.id, 'newAddressId');
    });

    test('serialization and deserialization works', () {
      final school = dummySchool();
      final serialized = school.serialize();
      final deserialized = School.fromSerialized(serialized);

      expect(serialized, {
        'id': school.id,
        'name': school.name,
        'address': school.address.serialize(),
      });

      expect(deserialized.id, school.id);
      expect(deserialized.name, school.name);
      expect(deserialized.address.id, school.address.id);

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized = School.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.name, 'Unnamed school');
      expect(emptyDeserialized.address.toString(), Address.empty.toString());
    });
  });
}
