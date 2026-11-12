package app.blocker.rules

object LimitEvaluator {
    private const val WARNING_THRESHOLD_SECONDS = 5L * 60

    fun isBlocked(
        allowanceMinutes: Int,
        usedSeconds: Long,
    ): Boolean = remainingSeconds(allowanceMinutes, usedSeconds) <= 0

    fun shouldWarn(
        allowanceMinutes: Int,
        usedSeconds: Long,
    ): Boolean {
        val remaining = remainingSeconds(allowanceMinutes, usedSeconds)
        return remaining > 0 && remaining <= WARNING_THRESHOLD_SECONDS
    }

    fun remainingSeconds(
        allowanceMinutes: Int,
        usedSeconds: Long,
    ): Long {
        val allowanceSeconds = allowanceMinutes.toLong() * 60
        return maxOf(0L, allowanceSeconds - usedSeconds)
    }
}
