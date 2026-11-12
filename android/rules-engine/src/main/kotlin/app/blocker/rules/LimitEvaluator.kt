package app.blocker.rules

object LimitEvaluator {
    private const val WARNING_THRESHOLD_SECONDS = 5L * 60

    fun isBlocked(
        allowanceMinutes: Int,
        usedSeconds: Long,
    ): Boolean {
        require(allowanceMinutes >= 0)
        require(usedSeconds >= 0)
        return remainingSeconds(allowanceMinutes, usedSeconds) <= 0
    }

    fun shouldWarn(
        allowanceMinutes: Int,
        usedSeconds: Long,
    ): Boolean {
        require(allowanceMinutes >= 0)
        require(usedSeconds >= 0)
        val remaining = remainingSeconds(allowanceMinutes, usedSeconds)
        return remaining > 0 && remaining <= WARNING_THRESHOLD_SECONDS
    }

    fun remainingSeconds(
        allowanceMinutes: Int,
        usedSeconds: Long,
    ): Long {
        require(allowanceMinutes >= 0)
        require(usedSeconds >= 0)
        val allowanceSeconds = allowanceMinutes.toLong() * 60
        return maxOf(0L, allowanceSeconds - usedSeconds)
    }
}
