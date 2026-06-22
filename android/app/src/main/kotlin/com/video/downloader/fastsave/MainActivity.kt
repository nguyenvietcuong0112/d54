package com.video.downloader.fastsave

import android.content.ContentUris
import android.content.ContentValues
import android.content.Context
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.provider.OpenableColumns
import android.webkit.MimeTypeMap
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.io.OutputStream

class MainActivity: FlutterActivity() {

    private val CHANNEL = "media_store_audio"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAudioList" -> {
                    val list = getAllAudioFiles()
                    result.success(list)
                }
                "saveAudio" -> {
                    val sourcePath = call.argument<String>("sourcePath")
                    val displayNameArg = call.argument<String>("displayName")
                    val album = call.argument<String>("album") ?: "MyApp"
                    val mimeType = call.argument<String>("mimeType") ?: "audio/mpeg"

                    if (sourcePath.isNullOrEmpty()) {
                        result.error("NO_SOURCE", "sourcePath is null/empty", null)
                        return@setMethodCallHandler
                    }

                    val sourceFile = File(sourcePath)
                    if (!sourceFile.exists()) {
                        result.error("NO_FILE", "Source file not found: $sourcePath", null)
                        return@setMethodCallHandler
                    }

                    val displayName = displayNameArg ?: sourceFile.name

                    try {
                        val contentUri = saveAudioToMediaStore(
                            sourceFile = sourceFile,
                            displayName = displayName,
                            album = album,
                            mimeType = mimeType
                        )
                        if (contentUri != null) {
                            result.success(contentUri.toString())
                        } else {
                            result.error("SAVE_FAILED", "Insert returned null Uri", null)
                        }
                    } catch (e: Exception) {
                        result.error("EXCEPTION", e.message, null)
                    }
                }
                "deleteAudio" -> {
                    val uriString = call.argument<String>("uri")
                    if (uriString.isNullOrEmpty()) {
                        result.error("NO_URI", "Uri is null/empty", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val uri = Uri.parse(uriString)
                        val rows = applicationContext.contentResolver.delete(uri, null, null)
                        if (rows > 0) {
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    } catch (e: Exception) {
                        result.error("EXCEPTION", e.message, null)
                    }
                }
                "renameAudio" -> {
                    val uriStr = call.argument<String>("uri")
                    val newName = call.argument<String>("displayName")

                    if (uriStr.isNullOrEmpty() || newName.isNullOrEmpty()) {
                        result.error("INVALID_ARGS", "uri or newName is null/empty", null)
                        return@setMethodCallHandler
                    }

                    val uri = Uri.parse(uriStr)

// Lấy tên gốc để tìm phần đuôi
                    val projection = arrayOf(MediaStore.MediaColumns.DISPLAY_NAME)
                    val cursor = applicationContext.contentResolver.query(uri, projection, null, null, null)

                    var ext = ""
                    cursor?.use {
                        if (it.moveToFirst()) {
                            val oldName = it.getString(0)
                            ext = oldName.substringAfterLast('.', "")
                        }
                    }

// Nếu file gốc là .opus thì bắt rename kèm .opus
                    val finalName = if (ext.equals("opus", true)) {
                        if (newName.endsWith(".opus", true)) newName else "$newName.opus"
                    } else {
                        newName // để nguyên như cũ
                    }

                    val values = ContentValues().apply {
                        put(MediaStore.MediaColumns.DISPLAY_NAME, finalName)
                    }

                    try {
                        val rows = applicationContext.contentResolver.update(uri, values, null, null)
                        if (rows > 0) {
                            result.success(true)
                        } else {
                            result.error("RENAME_FAILED", "No rows updated", null)
                        }
                    } catch (e: Exception) {
                        result.error("EXCEPTION", e.message, null)
                    }
                }
                "readFileBytes" -> {
                    val uriStr = call.argument<String>("uri")
                    if (uriStr.isNullOrEmpty()) {
                        result.error("NO_URI", "uri is null", null)
                        return@setMethodCallHandler
                    }
                    val uri = Uri.parse(uriStr)
                    val pair = readFileWithName(this, uri) // 👈 dùng this thay vì context
                    if (pair != null) {
                        val map = hashMapOf<String, Any>(
                            "bytes" to pair.first,
                            "fileName" to pair.second
                        )
                        result.success(map)
                    } else {
                        result.error("READ_FAIL", "Could not read file", null)
                    }
                }
                "saveVideo" -> {
                    val sourcePath = call.argument<String>("sourcePath")
                    val displayNameArg = call.argument<String>("displayName")
                    val album = call.argument<String>("album") ?: "VideoToMp3"
                    val mimeType = call.argument<String>("mimeType") ?: "video/mp4"

                    if (sourcePath.isNullOrEmpty()) {
                        result.error("NO_SOURCE", "sourcePath is null/empty", null)
                        return@setMethodCallHandler
                    }

                    val sourceFile = File(sourcePath)
                    if (!sourceFile.exists()) {
                        result.error("NO_FILE", "Source file not found: $sourcePath", null)
                        return@setMethodCallHandler
                    }

                    val displayName = displayNameArg ?: sourceFile.name

                    try {
                        val contentUri = saveVideoToMediaStore(
                            sourceFile = sourceFile,
                            displayName = displayName,
                            album = album,
                        )
                        if (contentUri != null) {
                            result.success(contentUri.toString())
                        } else {
                            result.error("SAVE_FAILED", "Insert returned null Uri", null)
                        }
                    } catch (e: Exception) {
                        result.error("EXCEPTION", e.message, null)
                    }
                }
                "renameMedia" -> {
                    val uriStr = call.argument<String>("uri")
                    val newName = call.argument<String>("newName")

                    if (uriStr.isNullOrEmpty() || newName.isNullOrEmpty()) {
                        result.error("ARGS", "uri or newName is null", null)
                        return@setMethodCallHandler
                    }

                    try {
                        val uri = Uri.parse(uriStr)

                        // Giữ lại extension cũ
                        var extension = ""
                        val projection = arrayOf(MediaStore.MediaColumns.DISPLAY_NAME)
                        val cursor = context.contentResolver.query(uri, projection, null, null, null)
                        cursor?.use {
                            if (it.moveToFirst()) {
                                val oldName = it.getString(0)
                                val dotIndex = oldName.lastIndexOf(".")
                                if (dotIndex != -1) {
                                    extension = oldName.substring(dotIndex) // ".mp4"
                                }
                            }
                        }

                        val newFileName = "$newName$extension"

                        val values = ContentValues().apply {
                            put(MediaStore.MediaColumns.DISPLAY_NAME, newFileName)
                        }

                        val rows = context.contentResolver.update(uri, values, null, null)
                        result.success(rows > 0) // ✅ trả về true/false
                    } catch (e: Exception) {
                        result.error("EXCEPTION", e.message, null)
                    }
                }
                "deleteFile" -> {
                    val uriStr = call.argument<String>("uri")
                    if (uriStr.isNullOrEmpty()) {
                        result.error("NO_URI", "Uri is null", null)
                        return@setMethodCallHandler
                    }
                    val uri = Uri.parse(uriStr)
                    try {
                        val rows = contentResolver.delete(uri, null, null)
                        result.success(rows > 0)
                    } catch (e: Exception) {
                        result.error("DELETE_FAILED", e.message, null)
                    }
                }
                "fileExists" -> {
                    val uriStr = call.argument<String>("uri")
                    if (uriStr.isNullOrEmpty()) {
                        result.error("NO_URI", "Uri is null", null)
                        return@setMethodCallHandler
                    }
                    val uri = Uri.parse(uriStr)
                    val exists = existsInMediaStore(this, uri)
                    result.success(exists)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getAllAudioFiles(): List<Map<String, String>> {
        val audioList = mutableListOf<Map<String, String>>()
        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.DISPLAY_NAME,
            MediaStore.Audio.Media.SIZE,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.MIME_TYPE
        )
        val selection = null;
        val sortOrder = "${MediaStore.Audio.Media.DISPLAY_NAME} ASC"
        val queryUri: Uri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI

        contentResolver.query(queryUri, projection, selection, null, sortOrder)?.use { cursor ->
            val idIndex = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            val nameIndex = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DISPLAY_NAME)
            val sizeIndex = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.SIZE)
            val durationIndex = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
            val mimeIndex = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.MIME_TYPE)

            while (cursor.moveToNext()) {
                val id = cursor.getLong(idIndex)
                val name = cursor.getString(nameIndex)
                val size = cursor.getLong(sizeIndex)        // bytes
                val duration = cursor.getLong(durationIndex) // milliseconds
                val mime = cursor.getString(mimeIndex)
                val uri = ContentUris.withAppendedId(queryUri, id).toString()
                audioList.add(
                    mapOf(
                        "id" to id.toString(),
                        "name" to name,
                        "size" to size.toString(),
                        "duration" to duration.toString(),
                        "mime" to mime,
                        "uri" to uri
                    )
                )
            }
        }
        return audioList
    }

    fun existsInMediaStore(context: Context, uri: Uri): Boolean {
        return try {
            context.contentResolver.query(uri, null, null, null, null).use { cursor ->
                cursor != null && cursor.moveToFirst()
            }
        } catch (e: Exception) {
            false
        }
    }

    private fun saveVideoToMediaStore(
        sourceFile: File,
        displayName: String,
        album: String
    ): Uri? {
        val resolver = applicationContext.contentResolver
        
        // Lấy extension của file nguồn (ví dụ: mp4)
        val sourceExtension = sourceFile.extension.lowercase()
        
        // Đảm bảo displayName có phần mở rộng đúng
        val finalDisplayName = if (sourceExtension.isNotEmpty() && !displayName.endsWith(".$sourceExtension", ignoreCase = true)) {
            "$displayName.$sourceExtension"
        } else {
            displayName
        }
        
        val mimeType = if (sourceExtension.isNotEmpty()) {
            MimeTypeMap.getSingleton().getMimeTypeFromExtension(sourceExtension) ?: "video/mp4"
        } else {
            "video/mp4"
        }

        val contentValues = ContentValues().apply {
            put(MediaStore.Video.Media.DISPLAY_NAME, finalDisplayName)
            put(MediaStore.Video.Media.MIME_TYPE, mimeType)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.Video.Media.IS_PENDING, 1)
                put(MediaStore.Video.Media.RELATIVE_PATH, "Movies/$album")
            } else {
                @Suppress("DEPRECATION")
                put(
                    MediaStore.Video.Media.DATA,
                    File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES), "$album/$finalDisplayName").absolutePath
                )
            }
            put(MediaStore.Video.Media.DATE_ADDED, System.currentTimeMillis() / 1000)
            put(MediaStore.Video.Media.DATE_TAKEN, System.currentTimeMillis())
        }

        val collection = MediaStore.Video.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        val uri = resolver.insert(collection, contentValues)

        uri?.let {
            resolver.openOutputStream(it).use { outputStream ->
                sourceFile.inputStream().use { inputStream ->
                    inputStream.copyTo(outputStream!!)
                }
            }
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val pendingClear = ContentValues().apply {
                    put(MediaStore.Video.Media.IS_PENDING, 0)
                }
                resolver.update(it, pendingClear, null, null)
            }
        }

        return uri
    }

    private fun getMimeType(file: File): String {
        val ext = file.extension.lowercase()
        return if (ext.isNotEmpty()) {
            MimeTypeMap.getSingleton().getMimeTypeFromExtension(ext) ?: "video/*"
        } else {
            "video/*"
        }
    }

    private fun readFileWithName(context: Context, uri: Uri): Pair<ByteArray, String>? {
        return try {
            val contentResolver = context.contentResolver
            val fileName: String = contentResolver.query(uri, null, null, null, null)?.use { cursor ->
                val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                cursor.moveToFirst()
                cursor.getString(nameIndex)
            } ?: "unknown_file"

            val inputStream = contentResolver.openInputStream(uri)
            val bytes = inputStream?.readBytes()
            inputStream?.close()

            if (bytes != null) {
                Pair(bytes, fileName) // first = bytes, second = filename
            } else {
                null
            }
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    private fun saveAudioToMediaStore(
        sourceFile: File,
        displayName: String,
        album: String,
        mimeType: String
    ): Uri? {
        val resolver = applicationContext.contentResolver

        // Thư mục đích: /Music/<album>
        val relativePath = Environment.DIRECTORY_MUSIC + "/" + album

        // Lấy extension của file nguồn (ví dụ: mp3)
        val sourceExtension = sourceFile.extension.lowercase()
        
        // Đảm bảo displayName có phần mở rộng đúng
        val finalDisplayName = if (sourceExtension.isNotEmpty() && !displayName.endsWith(".$sourceExtension", ignoreCase = true)) {
            "$displayName.$sourceExtension"
        } else {
            displayName
        }

        val values = ContentValues().apply {
            put(MediaStore.Audio.Media.DISPLAY_NAME, finalDisplayName)
            put(MediaStore.Audio.Media.MIME_TYPE, mimeType)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.Audio.Media.IS_PENDING, 1) // đặt pending khi đang ghi
                put(MediaStore.Audio.Media.RELATIVE_PATH, relativePath)
            } else {
                // Pre-Android 10: dùng DATA (deprecated) – chỉ khi bạn hỗ trợ SDK cũ
                @Suppress("DEPRECATION")
                put(
                    MediaStore.Audio.Media.DATA,
                    File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MUSIC), "$album/$finalDisplayName").absolutePath
                )
            }
        }

        val collection = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        val itemUri = resolver.insert(collection, values) ?: return null

        // Ghi dữ liệu vào Uri
        resolver.openOutputStream(itemUri)?.use { out: OutputStream ->
            FileInputStream(sourceFile).use { input ->
                val buffer = ByteArray(8 * 1024)
                var bytes: Int
                while (input.read(buffer).also { bytes = it } >= 0) {
                    out.write(buffer, 0, bytes)
                }
                out.flush()
            }
        } ?: throw IllegalStateException("Cannot open output stream for $itemUri")

        // Clear pending flag (Android 10+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val pendingClear = ContentValues().apply {
                put(MediaStore.Audio.Media.IS_PENDING, 0)
            }
            resolver.update(itemUri, pendingClear, null, null)
        }

        return itemUri
    }
}
