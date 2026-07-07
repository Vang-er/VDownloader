package com.example.vdownloader

import android.os.Bundle
import android.util.Log
import com.chaquo.python.Python
import com.chaquo.python.android.AndroidPlatform
import io.flutter.embedding.android.FlutterActivity
import java.io.File

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val nativeDir = File(applicationInfo.nativeLibraryDir)

        Log.i("VDownloader", "Native dir = ${nativeDir.absolutePath}")
        Log.i("VDownloader", "filesDir = ${filesDir.absolutePath}")
        Log.i("VDownloader", "codeCacheDir = ${codeCacheDir.absolutePath}")

        try {
            val process = ProcessBuilder(
                "${applicationInfo.nativeLibraryDir}/libffmpeg.so",
                "-version"
            )
                .redirectErrorStream(true)
                .start()

            val output = process.inputStream.bufferedReader().readText()
            val exitCode = process.waitFor()

            Log.i("VDownloader", "Exit code = $exitCode")
            Log.i("VDownloader", output)

        } catch (e: Exception) {
            Log.e("VDownloader", "Failed to execute FFmpeg", e)
        }

        Log.i("VDownloader", "Native directory contents:")

        File(applicationInfo.nativeLibraryDir).listFiles()?.forEach {
            Log.i("VDownloader", it.name)
        }

        try {
            if (!Python.isStarted()) {
                Python.start(AndroidPlatform(this))
            }

            val py = Python.getInstance()
            val backend = py.getModule("backend")

            Thread {
                try {
                    Log.i("VDownloader", "Starting backend...")
                    backend.callAttr("start_server",applicationInfo.nativeLibraryDir)
                } catch (e: Exception) {
                    Log.e("VDownloader", "Backend crashed", e)
                }
            }.start()

        } catch (e: Exception) {
            Log.e("VDownloader", "Python error", e)
        }
    }
}