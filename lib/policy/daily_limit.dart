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

bool shouldResetUsage({
  required DateTime lastResetDate,
  required DateTime currentDate,
}) {
  return lastResetDate.year != currentDate.year ||
      lastResetDate.month != currentDate.month ||
      lastResetDate.day != currentDate.day;
}
