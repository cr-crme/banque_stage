import 'package:crcrme_banque_stages/common/models/phone_number.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneNumber', () {
    test('is valid', () {
      expect(PhoneNumber.isValid('8005555555'), isTrue);
      expect(PhoneNumber.isValid('800-555-5555'), isTrue);
      expect(PhoneNumber.isValid('800 555 5555'), isTrue);
      expect(PhoneNumber.isValid('800.555.5555'), isTrue);
      expect(PhoneNumber.isValid('(800) 555-5555'), isTrue);
      expect(PhoneNumber.isValid('(800) 555-5555 poste 1234'), isTrue);
      expect(PhoneNumber.isValid('8005555555 poste 123456'), isTrue);
    });

    test('is invalid', () {
      expect(PhoneNumber.isValid('800-555-555'), isFalse);
      expect(PhoneNumber.isValid('800-555-55555'), isFalse);
      expect(PhoneNumber.isValid('800-555-5555 poste 1234567'), isFalse);
    });

    test('is shown properly', () {
      expect(
          PhoneNumber.fromString('800-555-5555').toString(), '(800) 555-5555');
      expect(
          PhoneNumber.fromString('800 555 5555').toString(), '(800) 555-5555');
      expect(
          PhoneNumber.fromString('800.555.5555').toString(), '(800) 555-5555');
      expect(PhoneNumber.fromString('8005555555').toString(), '(800) 555-5555');
      expect(PhoneNumber.fromString('800-555-5555 poste 123456').toString(),
          '(800) 555-5555 poste 123456');
    });
  });
}
