const _maxWrongAttempts = 5;
const _lockoutDuration = Duration(minutes: 15);

/// Tracks consecutive wrong partner-code attempts and the 15-minute lockout
/// that follows the 5th one in a row (FRD FR-08, main rule 4).
///
/// Driven entirely by a monotonic elapsed-time value the caller supplies
/// (per ADR-0003) — this class never reads a clock itself, so changing the
/// phone's wall clock cannot shorten or skip a lockout.
class CodeLockout {
  int _wrongAttempts = 0;
  Duration? _lockedOutAt;

  /// Whether code entry is currently rejected, [now] being the monotonic
  /// elapsed time of the check.
  bool isLockedOut(Duration now) {
    final lockedOutAt = _lockedOutAt;
    if (lockedOutAt == null) return false;
    return now - lockedOutAt < _lockoutDuration;
  }

  /// Records a wrong code entered at the monotonic time [now]. Ignored if
  /// already locked out: a caller must check [isLockedOut] before accepting
  /// any code, and a wrong attempt during lockout must not extend it.
  void recordWrongAttempt(Duration now) {
    if (isLockedOut(now)) return;
    _wrongAttempts++;
    if (_wrongAttempts >= _maxWrongAttempts) {
      _lockedOutAt = now;
    }
  }

  /// Records a correct code entered at the monotonic time [now], resetting
  /// the wrong-attempt counter. Ignored if already locked out: a correct
  /// code must still be rejected for the rest of the lockout window.
  void recordCorrectAttempt(Duration now) {
    if (isLockedOut(now)) return;
    _wrongAttempts = 0;
    _lockedOutAt = null;
  }
}
