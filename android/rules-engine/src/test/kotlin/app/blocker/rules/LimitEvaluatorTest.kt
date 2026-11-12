package app.blocker.rules

import com.google.gson.Gson
import com.google.gson.JsonObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class LimitEvaluatorTest {
    @Test
    fun `blocked when used equals allowance`() {
        assertTrue(LimitEvaluator.isBlocked(allowanceMinutes = 30, usedSeconds = 1800))
    }

    @Test
    fun `not blocked when under allowance`() {
        assertFalse(LimitEvaluator.isBlocked(allowanceMinutes = 30, usedSeconds = 1740))
    }

    @Test
    fun `blocked when used exceeds allowance`() {
        assertTrue(LimitEvaluator.isBlocked(allowanceMinutes = 30, usedSeconds = 1860))
    }

    @Test
    fun `warning when exactly 5 minutes remain`() {
        assertTrue(LimitEvaluator.shouldWarn(allowanceMinutes = 30, usedSeconds = 1500))
    }

    @Test
    fun `no warning when more than 5 minutes remain`() {
        assertFalse(LimitEvaluator.shouldWarn(allowanceMinutes = 30, usedSeconds = 1440))
    }

    @Test
    fun `no warning when already blocked`() {
        assertFalse(LimitEvaluator.shouldWarn(allowanceMinutes = 30, usedSeconds = 1800))
    }

    @Test
    fun `remaining seconds when under limit`() {
        assertEquals(300L, LimitEvaluator.remainingSeconds(allowanceMinutes = 30, usedSeconds = 1500))
    }

    @Test
    fun `remaining seconds is zero when at limit`() {
        assertEquals(0L, LimitEvaluator.remainingSeconds(allowanceMinutes = 30, usedSeconds = 1800))
    }

    @Test
    fun `remaining seconds is zero when over limit`() {
        assertEquals(0L, LimitEvaluator.remainingSeconds(allowanceMinutes = 30, usedSeconds = 2000))
    }

    @Test
    fun `5-minute allowance warns from the start`() {
        assertTrue(LimitEvaluator.shouldWarn(allowanceMinutes = 5, usedSeconds = 0))
    }

    @Test
    fun `zero usage not blocked`() {
        assertFalse(LimitEvaluator.isBlocked(allowanceMinutes = 30, usedSeconds = 0))
        assertEquals(1800L, LimitEvaluator.remainingSeconds(allowanceMinutes = 30, usedSeconds = 0))
    }

    @Test
    fun `test vectors daily limit`() {
        val json = loadTestVector("limits/daily_limit.json")
        val cases = json.getAsJsonArray("cases")

        for (caseElement in cases) {
            val caseObj = caseElement.asJsonObject
            val allowanceMinutes = caseObj.get("allowanceMinutes").asInt
            val usedSeconds = caseObj.get("usedSeconds").asLong
            val expectedBlocked = caseObj.get("expectedBlocked").asBoolean
            val expectedWarning = caseObj.get("expectedWarning").asBoolean
            val expectedRemainingSeconds = caseObj.get("expectedRemainingSeconds").asLong
            val description = caseObj.get("description").asString

            assertEquals(
                "$description (isBlocked)",
                expectedBlocked,
                LimitEvaluator.isBlocked(allowanceMinutes, usedSeconds),
            )
            assertEquals(
                "$description (shouldWarn)",
                expectedWarning,
                LimitEvaluator.shouldWarn(allowanceMinutes, usedSeconds),
            )
            assertEquals(
                "$description (remainingSeconds)",
                expectedRemainingSeconds,
                LimitEvaluator.remainingSeconds(allowanceMinutes, usedSeconds),
            )
        }
    }

    private fun loadTestVector(filename: String): JsonObject {
        val stream =
            this::class.java.classLoader
                .getResourceAsStream(filename)
                ?: throw IllegalArgumentException("Test vector not found: $filename")
        return Gson().fromJson(stream.reader(), JsonObject::class.java)
    }
}
