import 'package:blocker/policy/change_direction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('classifyChange', () {
    test('adding a restriction is stricter', () {
      expect(
        classifyChange(removingRestriction: false),
        ChangeDirection.stricter,
      );
    });

    test('removing a restriction is weaker', () {
      expect(classifyChange(removingRestriction: true), ChangeDirection.weaker);
    });
  });
}
