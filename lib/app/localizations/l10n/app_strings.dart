import 'package:flutter/material.dart';
import 'app_localizations.dart';
import 'translate.dart';

class AppStrings {
  // Delegate to Translate class
  static void init(BuildContext context) {
    Translate.init(context);
  }

  static AppLocalizations get current => Translate.current;

  // App Info


  // Loading Messages
  static String get welcome => current.welcome;
  static String get loading => current.loading;

  // Onboarding


  // Language Selection
  static String get selectLanguage => current.selectLanguage;

  // Navigation & Actions
  static String get next => current.next;
  static String get back => current.back;


  // Authentication
  static String get login => current.login;
  static String get enterOtpSentTo => current.enterOtpSentTo;
  static String get didntReceiveOtp => current.didntReceiveOtp;
  static String get resendOtp => current.resendOtp;
  static String get resendIn => current.resendIn;
  static String get sec => current.sec;
  static String get submitOtp => current.submitOtp;
  static String get otpVerificationFailed => current.otpVerificationFailed;
  static String get pleaseEnterComplete4DigitOtp => current.pleaseEnterComplete4DigitOtp;
  static String get phoneNumberRequired => current.phoneNumberRequired;
  static String get verificationFailed => current.verificationFailed;
  static String get invalidOrExpiredOtp => current.invalidOrExpiredOtp;

  // Navigation Items

  static String get profile => current.profile;
  static String get settings => current.settings;

  // User Actions
  static String get logout => current.logout;
  static String get yes => current.yes;
  static String get no => current.no;
  static String get cancel => current.cancel;
  static String get save => current.save;

  // File Operations
  static String get delete => current.delete;

  // Media & Upload Operations
  static String get image => current.image;
  static String get videos => current.videos;
  static String get audioSound => current.audioSound;
  static String get documents => current.documents;
  static String get camera => current.camera;
  static String get scanner => current.scanner;
  static String get createFolder => current.createFolder;
  static String get gallery => current.gallery;

  // Success/Error Messages

  static String get networkError => current.networkError;


  // Helper method to get localized string with context
  static String getLocalizedString(BuildContext context, String Function(AppLocalizations) getter) {
    final localizations = AppLocalizations.of(context);
    if (localizations != null) {
      return getter(localizations);
    }
    return '';
  }
}