const Duration _minAllowance = Duration(minutes: 5);
const Duration _maxAllowance = Duration(hours: 8);
const Duration _warningThreshold = Duration(minutes: 5);

class DailyLimitStatus {
  const DailyLimitStatus({
    required this.isBlocked,
    required this.shouldWarn,
    required this.remaining,
  });

  final bool isBlocked;
  final bool shouldWarn;
  final Duration remaining;
}

DailyLimitStatus evaluateDailyLimit({
  required Duration allowance,
  required Duration usedToday,
}) {
  assert(!allowance.isNegative);
  assert(!usedToday.isNegative);
  final remaining = usedToday >= allowance
      ? Duration.zero
      : allowance - usedToday;
  final blocked = remaining == Duration.zero;
  final warn = !blocked && remaining <= _warningThreshold;

  return DailyLimitStatus(
    isBlocked: blocked,
    shouldWarn: warn,
    remaining: remaining,
  );
}

Duration clampAllowance(Duration allowance) {
  if (allowance < _minAllowance) return _minAllowance;
  if (allowance > _maxAllowance) return _maxAllowance;
  return allowance;
}

// Calendar-day comparison: the caller supplies dates from a trusted source.
// ADR-0003's monotonic clock covers elapsed-time accumulation, not day boundaries.
// The data layer should also verify a monotonic minimum interval since the last
// reset to guard against clock-forward attacks.
bool shouldResetUsage({
  required DateTime lastResetDate,
  required DateTime currentDate,
}) {
  return lastResetDate.year != currentDate.year ||
      lastResetDate.month != currentDate.month ||
      lastResetDate.day != currentDate.day;
}
