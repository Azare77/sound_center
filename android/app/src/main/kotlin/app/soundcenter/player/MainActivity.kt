package app.soundcenter.player

import android.app.Activity
import android.app.RecoverableSecurityException
import android.content.Intent
import android.content.IntentSender
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.IOException

class MainActivity : AudioServiceActivity() {

    private val channelName = "scoped_storage_writer"
    private val requestCodeWrite = 2024

    // کاری که منتظر نتیجه‌ی دیالوگ سیستمی است
    private var pendingResult: MethodChannel.Result? = null

    // اگر درخواست از مسیر RecoverableSecurityException (API 29) آمده باشد،
    // باید بعد از گرفتن اجازه، نوشتن را خودمان ادامه بدهیم
    private var pendingUri: Uri? = null
    private var pendingBytes: ByteArray? = null

    private val ioScope = CoroutineScope(Dispatchers.IO + Job())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "requestWriteAccess" -> {
                    val uriString = call.argument<String>("uri")

                    if (uriString.isNullOrBlank()) {
                        result.error("INVALID_URI", "URI is empty", null)
                        return@setMethodCallHandler
                    }

                    requestWriteAccessExplicit(Uri.parse(uriString), result)
                }

                "writeBytes" -> {
                    val uriString = call.argument<String>("uri")
                    val bytes = call.argument<ByteArray>("bytes")

                    if (uriString.isNullOrBlank() || bytes == null) {
                        result.error("INVALID_ARGUMENT", "Invalid URI or bytes", null)
                        return@setMethodCallHandler
                    }

                    if (pendingResult != null) {
                        result.error(
                            "REQUEST_IN_PROGRESS",
                            "Another permission request is active",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    writeBytesInternal(Uri.parse(uriString), bytes, result)
                }

                else -> result.notImplemented()
            }
        }
    }

    // --- مسیر صریح: برای Android 11+، قبل از نوشتن اجازه گرفته می‌شود ---
    private fun requestWriteAccessExplicit(uri: Uri, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            // روی API 29 و پایین‌تر createWriteRequest وجود ندارد؛
            // اجازه در لحظه‌ی نوشتن، از طریق RecoverableSecurityException گرفته می‌شود.
            // پس اینجا همیشه true برمی‌گردانیم تا جریان Dart ادامه پیدا کند.
            result.success(true)
            return
        }

        if (pendingResult != null) {
            result.error("REQUEST_IN_PROGRESS", "Another permission request is active", null)
            return
        }

        try {
            val pendingIntent = MediaStore.createWriteRequest(contentResolver, listOf(uri))
            pendingResult = result
            pendingUri = null
            pendingBytes = null
            startIntentSenderForResult(pendingIntent.intentSender, requestCodeWrite, null, 0, 0, 0)
        } catch (e: IntentSender.SendIntentException) {
            pendingResult = null
            result.error("REQUEST_FAILED", e.message, null)
        } catch (e: Exception) {
            pendingResult = null
            result.error("REQUEST_FAILED", e.message, null)
        }
    }

    // --- نوشتن واقعی؛ روی IO thread، با afall-back خودکار به RecoverableSecurityException ---
    private fun writeBytesInternal(uri: Uri, bytes: ByteArray, result: MethodChannel.Result) {
        ioScope.launch {
            try {
                contentResolver.openOutputStream(uri, "rwt")?.use { out ->
                    out.write(bytes)
                    out.flush()
                } ?: throw IOException("Cannot open output stream")

                withContext(Dispatchers.Main) { result.success(true) }

            } catch (e: RecoverableSecurityException) {
                // فقط API 29 این را پرتاب می‌کند؛ خودِ exception اجازه‌نامه را حمل می‌کند
                withContext(Dispatchers.Main) {
                    if (pendingResult != null) {
                        result.error(
                            "REQUEST_IN_PROGRESS",
                            "Another permission request is active",
                            null
                        )
                        return@withContext
                    }
                    pendingResult = result
                    pendingUri = uri
                    pendingBytes = bytes
                    try {
                        startIntentSenderForResult(
                            e.userAction.actionIntent.intentSender,
                            requestCodeWrite, null, 0, 0, 0
                        )
                    } catch (sendEx: IntentSender.SendIntentException) {
                        pendingResult = null
                        pendingUri = null
                        pendingBytes = null
                        result.error("REQUEST_FAILED", sendEx.message, null)
                    }
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) { result.error("WRITE_FAILED", e.message, null) }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode != requestCodeWrite) return

        val granted = resultCode == Activity.RESULT_OK
        val result = pendingResult
        val uri = pendingUri
        val bytes = pendingBytes

        pendingResult = null
        pendingUri = null
        pendingBytes = null

        if (result == null) return // اکتیویتی recreate شده و کالبک گم رفته؛ سمت Dart با timeout هندل می‌شود

        if (uri != null && bytes != null) {
            // این درخواست از writeBytesInternal (مسیر API 29) آمده بود؛
            // حالا که اجازه گرفته شد، خودمان نوشتن را تمام می‌کنیم
            if (granted) {
                writeBytesInternal(uri, bytes, result)
            } else {
                result.error("PERMISSION_DENIED", "Write permission denied", null)
            }
        } else {
            // این درخواست از requestWriteAccessExplicit (مسیر API 30+) آمده بود
            result.success(granted)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        // اگر Future ای معلق مانده، حداقل خطای واضح بدهیم نه سکوت ابدی
        pendingResult?.error("ACTIVITY_DESTROYED", "Activity was destroyed before result", null)
        pendingResult = null
    }
}