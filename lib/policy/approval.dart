import 'package:blocker/policy/change_direction.dart';

bool requiresApproval({
  required SettingsChangeKind change,
  required bool strictModeOn,
}) {
  if (!strictModeOn) return false;
  return classifyChange(change) == ChangeDirection.weaker;
}

class ApprovalGate {
  bool _hasApproval = false;

  bool get hasUnusedApproval => _hasApproval;

  void grantApproval() {
    _hasApproval = true;
  }

  void useApproval() {
    if (!_hasApproval) {
      throw StateError('No unused approval to consume');
    }
    _hasApproval = false;
  }
}
