pluginManagement {
    val localPropsFile = file("local.properties")
    if (localPropsFile.exists()) {
        val properties = java.util.Properties()
        localPropsFile.inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        if (flutterSdkPath != null) {
            includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
        }
    }

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0" apply false
    id("com.android.application") version "9.1.0" apply false
    id("org.jetbrains.kotlin.android") version "2.4.0" apply false
    id("org.jetbrains.kotlin.jvm") version "2.4.0" apply false
}

include(":app")
include(":rules-engine")
