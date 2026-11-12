package app.blocker.rules

import com.google.gson.Gson
import com.google.gson.JsonObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.DayOfWeek
import java.time.LocalTime

class ScheduleEvaluatorTest {
    @Test
    fun `same-day schedule active during window`() {
        val schedule =
            Schedule(
                startTime = LocalTime.of(9, 0),
                endTime = LocalTime.of(17, 0),
                days = setOf(DayOfWeek.MONDAY),
            )
        assertTrue(ScheduleEvaluator.isActive(schedule, DayOfWeek.MONDAY, LocalTime.of(12, 0)))
    }

    @Test
    fun `same-day schedule inactive outside window`() {
        val schedule =
            Schedule(
                startTime = LocalTime.of(9, 0),
                endTime = LocalTime.of(17, 0),
                days = setOf(DayOfWeek.MONDAY),
            )
        assertFalse(ScheduleEvaluator.isActive(schedule, DayOfWeek.MONDAY, LocalTime.of(18, 0)))
    }

    @Test
    fun `same-day schedule inactive on non-scheduled day`() {
        val schedule =
            Schedule(
                startTime = LocalTime.of(9, 0),
                endTime = LocalTime.of(17, 0),
                days = setOf(DayOfWeek.MONDAY),
            )
        assertFalse(ScheduleEvaluator.isActive(schedule, DayOfWeek.TUESDAY, LocalTime.of(12, 0)))
    }

    @Test
    fun `same-day schedule active at start boundary`() {
        val schedule =
            Schedule(
                startTime = LocalTime.of(9, 0),
                endTime = LocalTime.of(17, 0),
                days = setOf(DayOfWeek.MONDAY),
            )
        assertTrue(ScheduleEvaluator.isActive(schedule, DayOfWeek.MONDAY, LocalTime.of(9, 0)))
    }

    @Test
    fun `same-day schedule inactive at end boundary`() {
        val schedule =
            Schedule(
                startTime = LocalTime.of(9, 0),
                endTime = LocalTime.of(17, 0),
                days = setOf(DayOfWeek.MONDAY),
            )
        assertFalse(ScheduleEvaluator.isActive(schedule, DayOfWeek.MONDAY, LocalTime.of(17, 0)))
    }

    @Test
    fun `overnight active Friday 23-30`() {
        assertTrue(
            ScheduleEvaluator.isActive(weekdayOvernight(), DayOfWeek.FRIDAY, LocalTime.of(23, 30)),
        )
    }

    @Test
    fun `overnight inactive Saturday 07-00`() {
        assertFalse(
            ScheduleEvaluator.isActive(weekdayOvernight(), DayOfWeek.SATURDAY, LocalTime.of(7, 0)),
        )
    }

    @Test
    fun `overnight not started Saturday 22-00`() {
        assertFalse(
            ScheduleEvaluator.isActive(weekdayOvernight(), DayOfWeek.SATURDAY, LocalTime.of(22, 0)),
        )
    }

    @Test
    fun `overnight active Saturday 02-00 continuation of Friday`() {
        assertTrue(
            ScheduleEvaluator.isActive(weekdayOvernight(), DayOfWeek.SATURDAY, LocalTime.of(2, 0)),
        )
    }

    @Test
    fun `overnight inactive Sunday 03-00 Saturday not in days`() {
        assertFalse(
            ScheduleEvaluator.isActive(weekdayOvernight(), DayOfWeek.SUNDAY, LocalTime.of(3, 0)),
        )
    }

    @Test
    fun `overnight Monday 00-30 no Sunday window`() {
        assertFalse(
            ScheduleEvaluator.isActive(weekdayOvernight(), DayOfWeek.MONDAY, LocalTime.of(0, 30)),
        )
    }

    @Test
    fun `overnight active Tuesday 06-59 continuation of Monday`() {
        assertTrue(
            ScheduleEvaluator.isActive(weekdayOvernight(), DayOfWeek.TUESDAY, LocalTime.of(6, 59)),
        )
    }

    @Test
    fun `overnight active at start boundary`() {
        assertTrue(
            ScheduleEvaluator.isActive(weekdayOvernight(), DayOfWeek.FRIDAY, LocalTime.of(22, 0)),
        )
    }

    @Test
    fun `overnight inactive Wednesday daytime`() {
        assertFalse(
            ScheduleEvaluator.isActive(
                weekdayOvernight(),
                DayOfWeek.WEDNESDAY,
                LocalTime.of(12, 0),
            ),
        )
    }

    @Test
    fun `test vectors overnight weekdays`() {
        val json = loadTestVector("overnight_weekdays.json")
        val scheduleObj = json.getAsJsonObject("schedule")
        val schedule =
            Schedule(
                startTime =
                    LocalTime.of(
                        scheduleObj.get("startHour").asInt,
                        scheduleObj.get("startMinute").asInt,
                    ),
                endTime =
                    LocalTime.of(
                        scheduleObj.get("endHour").asInt,
                        scheduleObj.get("endMinute").asInt,
                    ),
                days =
                    scheduleObj
                        .getAsJsonArray("days")
                        .map { DayOfWeek.valueOf(it.asString) }
                        .toSet(),
            )

        val cases = json.getAsJsonArray("cases")
        for (caseElement in cases) {
            val caseObj = caseElement.asJsonObject
            val dayOfWeek = DayOfWeek.valueOf(caseObj.get("dayOfWeek").asString)
            val timeParts = caseObj.get("localDateTime").asString.substringAfter("T")
            val localTime = LocalTime.parse(timeParts)
            val expected = caseObj.get("expected").asBoolean
            val description = caseObj.get("description").asString

            assertEquals(
                description,
                expected,
                ScheduleEvaluator.isActive(schedule, dayOfWeek, localTime),
            )
        }
    }

    private fun weekdayOvernight(): Schedule =
        Schedule(
            startTime = LocalTime.of(22, 0),
            endTime = LocalTime.of(7, 0),
            days =
                setOf(
                    DayOfWeek.MONDAY,
                    DayOfWeek.TUESDAY,
                    DayOfWeek.WEDNESDAY,
                    DayOfWeek.THURSDAY,
                    DayOfWeek.FRIDAY,
                ),
        )

    private fun loadTestVector(filename: String): JsonObject {
        val stream =
            this::class.java.classLoader
                .getResourceAsStream("schedules/$filename")
                ?: throw IllegalArgumentException("Test vector not found: $filename")
        return Gson().fromJson(stream.reader(), JsonObject::class.java)
    }
}
