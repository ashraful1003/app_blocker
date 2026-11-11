package app.blocker.rules

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class RulesEngineTest {
    @Test
    fun `blocked package is reported as blocked`() {
        val engine = RulesEngine()
        val blocked = setOf("com.instagram.android")
        assertTrue(engine.isBlocked("com.instagram.android", blocked))
    }

    @Test
    fun `unblocked package is not blocked`() {
        val engine = RulesEngine()
        val blocked = setOf("com.instagram.android")
        assertFalse(engine.isBlocked("com.example.safe", blocked))
    }
}
