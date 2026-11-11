package app.blocker.rules

class RulesEngine {
    fun isBlocked(
        appPackage: String,
        blockedPackages: Set<String>,
    ): Boolean {
        return appPackage in blockedPackages
    }
}
