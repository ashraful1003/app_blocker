enum ChangeDirection { stricter, weaker }

ChangeDirection classifyChange({required bool removingRestriction}) {
  return removingRestriction
      ? ChangeDirection.weaker
      : ChangeDirection.stricter;
}
