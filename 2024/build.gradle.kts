import eu.azariasb.tasks.Download
import eu.azariasb.tasks.Scaffold
import java.time.LocalDate

plugins {
    id("application")
    kotlin("jvm") version "2.0.20"
}

group = "eu.azariasb.adventofocde"
version = "1.0"

repositories {
    mavenCentral()
}

dependencies {
    testImplementation(kotlin("test"))
    implementation(gradleApi())
}

kotlin {
    jvmToolchain(22)
}

tasks.test {
    useJUnitPlatform()
}

tasks.register<Download>("download") {
    day = (properties["day"] as String).toIntOrNull() ?: LocalDate.now().dayOfMonth
    sessionCookie = System.getenv("ADVENT_OF_CODE_SESSION")
}

tasks.register<Scaffold>("scaffold") {
    dependsOn("download")
    day = (properties["day"] as String).toIntOrNull() ?: LocalDate.now().dayOfMonth

}