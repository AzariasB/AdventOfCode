package eu.azariasb.tasks

import com.vladsch.flexmark.html2md.converter.FlexmarkHtmlConverter
import org.gradle.api.DefaultTask
import org.gradle.api.tasks.Input
import org.gradle.api.tasks.TaskAction
import java.io.File
import java.net.URI
import java.net.http.HttpClient
import java.net.http.HttpRequest
import java.net.http.HttpResponse

abstract class Download : DefaultTask() {

    @get:Input
    abstract var day: Int

    @get:Input
    abstract var sessionCookie: String

    @TaskAction
    fun download() {
        val year = 2024
        val dayStr = day.toString().padStart(2, '0')
        val projectRoot = System.getProperty("user.dir")
        val userAgent = "${System.getProperty("java.vm.name")}  ${Runtime.version()}"

        ensureDirExists("$projectRoot/puzzles/")

        val puzzleUrl = URI("https://adventofcode.com/${year}/day/${day}")


        val client = HttpClient.newHttpClient()
        val puzzleRequest = HttpRequest.newBuilder()
            .headers(
                "Cookie", "session=$sessionCookie",
                "content-type", "text/html",
                "user-agent", userAgent
            )
            .GET().uri(puzzleUrl).build()

        val contentRegex = Regex("(?i)(?s)<main>(.*)</main>")

        val resp = client.send(puzzleRequest, HttpResponse.BodyHandlers.ofString())
        val exoHtml = contentRegex.find(resp.body())?.let {
            it.value
        } ?: return

        val markdown = FlexmarkHtmlConverter.builder().build().convert(exoHtml)

        File("$projectRoot/puzzles/$dayStr.md").writeText(markdown)
        println("# \uD83C\uDF84 Successfully wrote puzzle to \"data/puzzles/$dayStr.md\".")

        val inputURI = URI("https://adventofcode.com/${year}/day/${day}/input")
        val inputRequest = HttpRequest.newBuilder()
            .headers(
                "Cookie", "session=$sessionCookie",
                "content-type", "text/plain",
                "user-agent", userAgent
            )
            .GET().uri(inputURI).build()
        val inputResp = client.send(inputRequest, HttpResponse.BodyHandlers.ofString()).body()

        File("$projectRoot/src/main/resources/$dayStr.txt").writeText(inputResp)
        println("# \uD83C\uDF84 Successfully wrote puzzle to \"data/inputs/$dayStr.txt\".")
    }
}