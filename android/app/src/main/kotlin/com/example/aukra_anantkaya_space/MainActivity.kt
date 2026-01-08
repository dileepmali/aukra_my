package com.example.aukra_anantkaya_space

import android.Manifest
import android.content.pm.PackageManager
import android.database.Cursor
import android.provider.ContactsContract
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.aukra/contacts"
    private val PERMISSION_REQUEST_CODE = 1001
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getContacts" -> {
                    Log.d("NativeContacts", "📱 getContacts called from Flutter")
                    getContacts(result)
                }
                "hasContactPermission" -> {
                    result.success(checkContactPermission())
                }
                "requestContactPermission" -> {
                    pendingResult = result
                    requestContactPermission()
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun checkContactPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.READ_CONTACTS
        ) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestContactPermission() {
        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.READ_CONTACTS),
            PERMISSION_REQUEST_CODE
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode == PERMISSION_REQUEST_CODE) {
            val granted = grantResults.isNotEmpty() &&
                         grantResults[0] == PackageManager.PERMISSION_GRANTED
            pendingResult?.success(granted)
            pendingResult = null
        }
    }

    private fun getContacts(result: MethodChannel.Result) {
        if (!checkContactPermission()) {
            Log.w("NativeContacts", "⚠️ READ_CONTACTS permission not granted")
            result.error("PERMISSION_DENIED", "READ_CONTACTS permission not granted", null)
            return
        }

        try {
            Log.d("NativeContacts", "🔍 Querying Android ContactsContract...")

            // Use LinkedHashMap to deduplicate by contact ID and keep first phone number
            val contactsMap = LinkedHashMap<String, Map<String, String>>()

            val projection = arrayOf(
                ContactsContract.CommonDataKinds.Phone.CONTACT_ID,
                ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
                ContactsContract.CommonDataKinds.Phone.NUMBER
            )

            val cursor: Cursor? = contentResolver.query(
                ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                projection,
                null,
                null,
                ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME + " ASC"
            )

            cursor?.use {
                val contactIdIndex = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.CONTACT_ID)
                val nameIndex = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME)
                val phoneIndex = it.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER)

                if (contactIdIndex == -1 || nameIndex == -1 || phoneIndex == -1) {
                    Log.e("NativeContacts", "❌ Column indices not found")
                    result.error("COLUMN_ERROR", "Failed to find contact columns", null)
                    return
                }

                var totalRows = 0
                while (it.moveToNext()) {
                    val contactId = it.getString(contactIdIndex) ?: ""
                    val name = it.getString(nameIndex) ?: ""
                    val rawPhone = it.getString(phoneIndex) ?: ""

                    totalRows++

                    // Clean phone number: remove spaces, dashes, parentheses, and other formatting
                    val cleanPhone = rawPhone.replace(Regex("[^0-9+]"), "")

                    // Only add if contact ID not already in map (keeps first phone number only)
                    if (name.isNotEmpty() && !contactsMap.containsKey(contactId)) {
                        contactsMap[contactId] = mapOf(
                            "name" to name,
                            "phone" to cleanPhone
                        )
                    }
                }

                Log.d("NativeContacts", "📊 Total rows: $totalRows, Unique contacts: ${contactsMap.size}")

                // Log first 5 unique contacts for debugging
                contactsMap.values.take(5).forEachIndexed { index, contact ->
                    Log.d("NativeContacts", "📋 Contact ${index + 1}: Name='${contact["name"]}', Phone='${contact["phone"]}'")
                }
            }

            // Convert map to list
            val contacts = contactsMap.values.toList()
            Log.d("NativeContacts", "✅ Successfully fetched ${contacts.size} unique contacts from Android")

            result.success(contacts)

        } catch (e: Exception) {
            Log.e("NativeContacts", "❌ Error fetching contacts: ${e.message}")
            e.printStackTrace()
            result.error("FETCH_ERROR", "Failed to fetch contacts: ${e.message}", null)
        }
    }
}
