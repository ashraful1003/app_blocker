package app.blocker.rules

import java.time.DayOfWeek
import java.time.LocalTime

data class Schedule(
    val startTime: LocalTime,
    val endTime: LocalTime,
    val days: Set<DayOfWeek>,
)

object ScheduleEvaluator {
    fun isActive(
        schedule: Schedule,
        dayOfWeek: DayOfWeek,
        localTime: LocalTime,
    ): Boolean {
        val isOvernight = schedule.startTime >= schedule.endTime

        return if (isOvernight) {
            isActiveOvernight(schedule, dayOfWeek, localTime)
        } else {
            isActiveSameDay(schedule, dayOfWeek, localTime)
        }
    }

    private fun isActiveSameDay(
        schedule: Schedule,
        dayOfWeek: DayOfWeek,
        localTime: LocalTime,
    ): Boolean {
        if (dayOfWeek !in schedule.days) return false
        return localTime >= schedule.startTime && localTime < schedule.endTime
    }

    private fun isActiveOvernight(
        schedule: Schedule,
        dayOfWeek: DayOfWeek,
        localTime: LocalTime,
    ): Boolean {
        if (localTime >= schedule.startTime && dayOfWeek in schedule.days) {
            return true
        }
        val previousDay = dayOfWeek.minus(1)
        if (localTime < schedule.endTime && previousDay in schedule.days) {
            return true
        }
        return false
    }
}
