
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../core/api/global_api_function.dart';

class OtpVerifyController extends GetxController {
  final otp = List.filled(4, '').obs;
  final List<TextEditingController> controllers =
  List.generate(4, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

  RxBool isLoading = false.obs;
  RxBool isResendAvailable = false.obs;
  RxInt resendTimer = 30.obs;
  RxBool isOtpExpired = false.obs;
  late String phoneNumber;
  Timer? _resendCooldownTimer;
  Timer? _clipboardMonitorTimer;
  late ApiFetcher apiFetcher;

  // 🔥 NEW: Flag to track if OTP came from clipboard (not manual typing)
  RxBool isClipboardOtp = false.obs;

  void setPhoneNumber(String number) {
    phoneNumber = number;
  }

  @override
  void onInit() {
    super.onInit();
    apiFetcher = ApiFetcher();
  }

  void initializeOtpScreen() {
    startResendCooldown();
    // 🔥 FIX: Don't clear clipboard on init - user might have already copied OTP
    // Just start monitoring directly
    startClipboardMonitoring();
  }

  void updateOtp(String value, int index) {
    otp[index] = value;
    otp.refresh();
    if (value.isNotEmpty && index < 3) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
    checkAndAutoVerify();
  }

  void checkAndAutoVerify() {
    if (isOtpExpired.value || isLoading.value) return;
    String otpString = getOtpString();
    bool isComplete = otp.every((d) => d.trim().isNotEmpty);
    if (otpString.length == 4 && isComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performAutoSubmission(); // ✅ सिर्फ callback कॉल होगा
      });
    }
  }

  String getOtpString() => otp.join('');

  /// ✅ Resend OTP API call - Same as number_verify_screen.dart send-otp
  Future<void> sendOtp() async {
    try {
      isLoading.value = true;
      debugPrint('📤 Resending OTP to: $phoneNumber');

      // Format phone number (remove +91 if present)
      String phone = phoneNumber.trim();
      if (phone.startsWith("+91")) {
        phone = phone.substring(3);
      }

      // ✅ Use 'mobileNumber' key to match send-otp API
      final payload = {'mobileNumber': phone};

      debugPrint('📡 Calling send-otp API with payload: $payload');

      // ✅ Call send-otp endpoint (same as number_verify_screen.dart)
      await apiFetcher.request(
        url: 'api/auth/send-otp',
        method: 'POST',
        body: payload,
        requireAuth: false,
      );

      if (apiFetcher.errorMessage == null && apiFetcher.data != null) {
        debugPrint('✅ OTP resent successfully: ${apiFetcher.data}');

        // Reset timer and clear old OTP
        startResendCooldown();
      } else {
        debugPrint('❌ API Error: ${apiFetcher.errorMessage}');
        throw Exception(apiFetcher.errorMessage ?? 'Failed to resend OTP');
      }
    } catch (e) {
      debugPrint('💥 Exception in sendOtp: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ❌ Deprecated verifyOtp() हटा दिया गया
  // ✅ अब हमेशा Screen का _handleVerifyOtp() API कॉल करेगा

  void startResendCooldown() {
    isResendAvailable.value = false;
    isOtpExpired.value = false;
    resendTimer.value = 30;
    clearOtp();
    _resendCooldownTimer?.cancel();
    _resendCooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value <= 0) {
        isResendAvailable.value = true;
        isOtpExpired.value = true;
        isLoading.value = false;
        debugPrint('⏰ OTP EXPIRED after 30 seconds');
        timer.cancel();
        _resendCooldownTimer = null;
      } else {
        resendTimer.value = resendTimer.value - 1;
      }
    });
  }

  Future<void> resendOtp() async {
    if (!isResendAvailable.value) return;

    // Immediately clear old OTP and keyboard suggestions when user clicks resend
    debugPrint('🚮 Resend clicked - Immediately clearing old OTP and keyboard suggestions');
    clearOtp();

    // Also clear clipboard to remove any old OTP suggestions
    await Clipboard.setData(const ClipboardData(text: ''));
    _lastClipboardContent = '';

    // Send new OTP
    await sendOtp();
  }

  void clearOtp() {
    // Prevent operations if controller is closed
    if (isClosed) return;

    // Clear clipboard to remove keyboard suggestions
    try {
      Clipboard.setData(const ClipboardData(text: ''));
    } catch (e) {
      debugPrint('⚠️ Error clearing clipboard: $e');
    }

    for (int i = 0; i < controllers.length; i++) {
      try {
        controllers[i].value = TextEditingValue.empty;
        controllers[i].clear();
        focusNodes[i].unfocus();
      } catch (e) {
        debugPrint('⚠️ Error clearing controller $i: $e');
      }
    }

    for (int i = 0; i < otp.length; i++) {
      otp[i] = '';
    }

    // Only refresh if not closed
    if (!isClosed) {
      otp.refresh();
    }

    // Clear clipboard content tracking to allow fresh detection
    _lastClipboardContent = '';
  }

  void fillOtpDirectly(String otpString) {
    if (otpString.length >= 4) {
      String truncatedOtp = otpString.substring(0, 4);
      debugPrint('🔄 Filling OTP directly from clipboard: $truncatedOtp');

      // 🔥 CRITICAL FIX: Fill all 4 digits FIRST, then set flag and refresh
      // This ensures when ever() listener triggers, all 4 digits are already filled
      for (int i = 0; i < 4; i++) {
        otp[i] = truncatedOtp[i];
      }

      // 🔥 Set flag AFTER filling all digits
      isClipboardOtp.value = true;

      // 🔥 Trigger reactive update ONCE with all 4 digits filled
      otp.refresh();

      debugPrint('✅ OTP filled in controller: ${getOtpString()}');
      debugPrint('   isClipboardOtp: ${isClipboardOtp.value}');
      debugPrint('   Screen ever() listener will auto-fill Pinput and submit');
    }
  }

  String? _lastClipboardContent = '';

  Future<void> checkClipboardForOtp() async {
    try {
      ClipboardData? clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData != null && clipboardData.text != null) {
        String clipText = clipboardData.text!.trim();

        if (clipText == _lastClipboardContent) return;
        _lastClipboardContent = clipText;

        if (clipText.isEmpty || clipText.length < 4) return;

        List<RegExp> otpPatterns = [
          // Exact 4 digits only (highest priority)
          RegExp(r'^\d{4}$'),
          
          // WhatsApp/SMS patterns - common formats
          RegExp(r'(?:otp|code|verification|verify|pin|sms)\s*(?:is|code|number)?\s*:?\s*(\d{4})', caseSensitive: false),
          RegExp(r'(\d{4})\s*(?:is\s*your|is\s*the|verification|otp|code|pin)', caseSensitive: false),
          
          // "Your OTP is 1234" variations
          RegExp(r'(?:your|the|hi|hello)?\s*(?:otp|code|verification|verify|pin)\s*(?:is|code|number)?\s*:?\s*(\d{4})', caseSensitive: false),
          
          // WhatsApp specific patterns
          RegExp(r'(?:whatsapp|wa)\s*(?:code|otp|verification)?\s*:?\s*(\d{4})', caseSensitive: false),
          
          // Indian format patterns
          RegExp(r'(\d{4})\s*(?:है|आपका|verification|code)', caseSensitive: false),
          
          // Generic patterns with word boundaries
          RegExp(r'\b(\d{4})\s*(?:is|for|verification|otp)', caseSensitive: false),
          RegExp(r'(?:code|otp)\s*(\d{4})', caseSensitive: false),
          
          // Any 4 consecutive digits (lowest priority)
          RegExp(r'\b(\d{4})\b'),
        ];

        String? extractedOtp;
        for (RegExp pattern in otpPatterns) {
          Match? match = pattern.firstMatch(clipText);
          if (match != null) {
            // Safe group extraction - check if group exists first
            if (match.groupCount > 0 && match.group(1) != null) {
              extractedOtp = match.group(1);
            } else {
              extractedOtp = match.group(0);
            }
            break;
          }
        }

        if (extractedOtp != null && RegExp(r'^\d{4}$').hasMatch(extractedOtp)) {
          debugPrint('🎯 VALID OTP DETECTED FROM CLIPBOARD: $extractedOtp');

          // Fill OTP directly (triggers screen's ever() listener)
          fillOtpDirectly(extractedOtp);

          // Clear clipboard after detection
          await Clipboard.setData(const ClipboardData(text: ''));
          debugPrint('🧹 Clipboard cleared after OTP detection');
        }
      }
    } catch (e) {
      debugPrint('❗ Error checking clipboard for OTP: $e');
    }
  }

  // Clear clipboard and start fresh monitoring
  Future<void> clearClipboardAndStartMonitoring() async {
    debugPrint('🧹 Clearing clipboard and starting fresh monitoring...');
    try {
      // Clear clipboard first
      await Clipboard.setData(const ClipboardData(text: ''));
      // Reset clipboard tracking
      _lastClipboardContent = '';
      debugPrint('✅ Clipboard cleared successfully');
    } catch (e) {
      debugPrint('⚠️ Could not clear clipboard: $e');
    }

    // Start monitoring
    startClipboardMonitoring();
  }

  void startClipboardMonitoring() {
    debugPrint('🚀 Starting clipboard monitoring for OTP detection...');
    _clipboardMonitorTimer?.cancel();
    _clipboardMonitorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      checkClipboardForOtp();
    });
    debugPrint('✅ Clipboard monitoring started successfully! Checking every 500ms');
  }

  // Auto submission callback
  Function()? onAutoSubmit;

  void setAutoSubmitCallback(Function() callback) {
    onAutoSubmit = callback;
  }

  void _performAutoSubmission() {
    if (onAutoSubmit != null && getOtpString().length == 4) {
      debugPrint('⚡ Executing auto-submit callback');
      onAutoSubmit!(); // ✅ Screen का _handleVerifyOtp() कॉल होगा
    } else {
      debugPrint('⚠️ Auto-submit callback not set or OTP incomplete');
    }
  }

  // Method to clear OTP immediately (e.g., on logout or when user navigates away)
  void clearOtpImmediately() {
    debugPrint('🚪 User logout/navigation - Immediately clearing all OTP data and keyboard suggestions');

    // Stop all timers
    _resendCooldownTimer?.cancel();
    _clipboardMonitorTimer?.cancel();

    // Clear all OTP data and keyboard suggestions
    clearOtp();

    // Reset all state
    isLoading.value = false;
    isResendAvailable.value = false;
    isOtpExpired.value = false;
    resendTimer.value = 30;

    debugPrint('✅ All OTP data cleared on logout/navigation');
  }

  @override
  void onClose() {
    // Clear everything when controller is disposed
    clearOtpImmediately();
    controllers.forEach((c) => c.dispose());
    focusNodes.forEach((f) => f.dispose());
    super.onClose();
  }
}
