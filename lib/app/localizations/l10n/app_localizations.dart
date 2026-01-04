import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_as.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_or.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('as'),
    Locale('bn'),
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('kn'),
    Locale('ml'),
    Locale('mr'),
    Locale('or'),
    Locale('pa'),
    Locale('ta'),
    Locale('te')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AnantSpace'**
  String get appTitle;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @byClicking.
  ///
  /// In en, this message translates to:
  /// **'By clicking, you agree to our'**
  String get byClicking;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get enterPhoneNumber;

  /// No description provided for @mobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobileNumber;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @noLanguagesFound.
  ///
  /// In en, this message translates to:
  /// **'No languages found'**
  String get noLanguagesFound;

  /// No description provided for @tryDifferentSearchTerm.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearchTerm;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// No description provided for @resendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtp;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @pleaseEnterOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter OTP'**
  String get pleaseEnterOtp;

  /// No description provided for @invalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get invalidPhoneNumber;

  /// No description provided for @invalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP'**
  String get invalidOtp;

  /// No description provided for @otpSentSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'OTP sent successfully'**
  String get otpSentSuccessfully;

  /// No description provided for @otpVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'OTP verified successfully'**
  String get otpVerifiedSuccessfully;

  /// No description provided for @failedToSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Failed to send OTP'**
  String get failedToSendOtp;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error occurred'**
  String get networkError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'Validation Error'**
  String get validationError;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Authentication Error'**
  String get authError;

  /// No description provided for @permissionError.
  ///
  /// In en, this message translates to:
  /// **'Permission Error'**
  String get permissionError;

  /// No description provided for @storageError.
  ///
  /// In en, this message translates to:
  /// **'Storage Error'**
  String get storageError;

  /// No description provided for @uploadError.
  ///
  /// In en, this message translates to:
  /// **'Upload Error'**
  String get uploadError;

  /// No description provided for @downloadError.
  ///
  /// In en, this message translates to:
  /// **'Download Error'**
  String get downloadError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get serverError;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchFilesAndFolders.
  ///
  /// In en, this message translates to:
  /// **'Search files and folders...'**
  String get searchFilesAndFolders;

  /// No description provided for @recentSearches.
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get recentSearches;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @searchMinChars.
  ///
  /// In en, this message translates to:
  /// **'Type 2+ chars'**
  String get searchMinChars;

  /// No description provided for @searchingFor.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searchingFor;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed'**
  String get searchFailed;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResultsFor;

  /// No description provided for @resultFound.
  ///
  /// In en, this message translates to:
  /// **'{count} result'**
  String resultFound(int count);

  /// No description provided for @resultsFound.
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String resultsFound(int count);

  /// No description provided for @youreOffline.
  ///
  /// In en, this message translates to:
  /// **'You\'re Offline'**
  String get youreOffline;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something Went Wrong'**
  String get somethingWentWrong;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorOccurred;

  /// No description provided for @checkInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and\ntry again to access your cloud files'**
  String get checkInternetConnection;

  /// No description provided for @serversUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Our servers are temporarily\nunavailable. Please try again later'**
  String get serversUnavailable;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @removeAll.
  ///
  /// In en, this message translates to:
  /// **'Remove All'**
  String get removeAll;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get enterName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email'**
  String get enterEmail;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @yesRemove.
  ///
  /// In en, this message translates to:
  /// **'Yes, Remove'**
  String get yesRemove;

  /// No description provided for @removeProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to remove profile picture?'**
  String get removeProfilePicture;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Your Files, One Safe Place'**
  String get onboardingTitle1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Send it in a Snap'**
  String get onboardingTitle2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Locked & Loaded Security'**
  String get onboardingTitle3;

  /// No description provided for @onboardingTitle4.
  ///
  /// In en, this message translates to:
  /// **'Your Cloud Travels With You'**
  String get onboardingTitle4;

  /// No description provided for @onboardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Store all your photos, videos, and documents in the cloud. Access them anything, anywhere - no USB needed.'**
  String get onboardingSubtitle1;

  /// No description provided for @onboardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Share big files instantly with a simple link. No email size limits, no waiting.'**
  String get onboardingSubtitle2;

  /// No description provided for @onboardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'End-to-end encryption keeps your data private. Only you decide who gets in.'**
  String get onboardingSubtitle3;

  /// No description provided for @onboardingSubtitle4.
  ///
  /// In en, this message translates to:
  /// **'Open your files from phone, tablet, or laptop. Always in sync, always updated.'**
  String get onboardingSubtitle4;

  /// No description provided for @phoneValidationOnlyIndian.
  ///
  /// In en, this message translates to:
  /// **'Only Indian numbers supported'**
  String get phoneValidationOnlyIndian;

  /// No description provided for @phoneValidationIndianFormat.
  ///
  /// In en, this message translates to:
  /// **'Number must start with 6-9 and be 10 digits'**
  String get phoneValidationIndianFormat;

  /// No description provided for @phoneValidationInvalidPattern.
  ///
  /// In en, this message translates to:
  /// **'Invalid number pattern'**
  String get phoneValidationInvalidPattern;

  /// No description provided for @phoneValidationInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid mobile number'**
  String get phoneValidationInvalidNumber;

  /// No description provided for @phoneValidationAllSameDigits.
  ///
  /// In en, this message translates to:
  /// **'Invalid number - all digits cannot be same'**
  String get phoneValidationAllSameDigits;

  /// No description provided for @phoneValidationSequentialPattern.
  ///
  /// In en, this message translates to:
  /// **'Invalid number - sequential pattern detected'**
  String get phoneValidationSequentialPattern;

  /// No description provided for @phoneValidationRepeatingPattern.
  ///
  /// In en, this message translates to:
  /// **'Invalid number - repeating pattern detected'**
  String get phoneValidationRepeatingPattern;

  /// No description provided for @phoneValidationTooFewUniqueDigits.
  ///
  /// In en, this message translates to:
  /// **'Invalid number - too few unique digits'**
  String get phoneValidationTooFewUniqueDigits;

  /// No description provided for @phoneValidationTestNumber.
  ///
  /// In en, this message translates to:
  /// **'This is a test number - not allowed'**
  String get phoneValidationTestNumber;

  /// No description provided for @enterOtpSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP sent to'**
  String get enterOtpSentTo;

  /// No description provided for @didntReceiveOtp.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the OTP?'**
  String get didntReceiveOtp;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in'**
  String get resendIn;

  /// No description provided for @sec.
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get sec;

  /// No description provided for @submitOtp.
  ///
  /// In en, this message translates to:
  /// **'Submit OTP'**
  String get submitOtp;

  /// No description provided for @otpVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification Failed'**
  String get otpVerificationFailed;

  /// No description provided for @pleaseEnterComplete4DigitOtp.
  ///
  /// In en, this message translates to:
  /// **'Please enter complete 4-digit OTP'**
  String get pleaseEnterComplete4DigitOtp;

  /// No description provided for @phoneNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberRequired;

  /// No description provided for @verificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get verificationFailed;

  /// No description provided for @invalidOrExpiredOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired OTP'**
  String get invalidOrExpiredOtp;

  /// No description provided for @searchForAnything.
  ///
  /// In en, this message translates to:
  /// **'Search for anything'**
  String get searchForAnything;

  /// No description provided for @yourCloudStorage.
  ///
  /// In en, this message translates to:
  /// **'Your cloud storage'**
  String get yourCloudStorage;

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get files;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @emptyFolder.
  ///
  /// In en, this message translates to:
  /// **'Empty folder'**
  String get emptyFolder;

  /// No description provided for @used.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get used;

  /// No description provided for @freePlan.
  ///
  /// In en, this message translates to:
  /// **'Free Plan'**
  String get freePlan;

  /// No description provided for @recent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get recent;

  /// No description provided for @recentFilesDescription.
  ///
  /// In en, this message translates to:
  /// **'Your recently opened files show up here, so\nyou can jump right back in.'**
  String get recentFilesDescription;

  /// No description provided for @addFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get addFolder;

  /// No description provided for @createSubfolder.
  ///
  /// In en, this message translates to:
  /// **'Subfolder'**
  String get createSubfolder;

  /// No description provided for @uploadFiles.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get uploadFiles;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @scanner.
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get scanner;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @everything.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get everything;

  /// No description provided for @folders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get folders;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get image;

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @videos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get videos;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Docs'**
  String get documents;

  /// No description provided for @audioSound.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audioSound;

  /// No description provided for @audios.
  ///
  /// In en, this message translates to:
  /// **'Audios'**
  String get audios;

  /// No description provided for @otherFiles.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get otherFiles;

  /// No description provided for @others.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get others;

  /// No description provided for @nameAZ.
  ///
  /// In en, this message translates to:
  /// **'Name A-Z'**
  String get nameAZ;

  /// No description provided for @nameZA.
  ///
  /// In en, this message translates to:
  /// **'Name Z-A'**
  String get nameZA;

  /// No description provided for @activityAsc.
  ///
  /// In en, this message translates to:
  /// **'Time ↑'**
  String get activityAsc;

  /// No description provided for @activityDesc.
  ///
  /// In en, this message translates to:
  /// **'Time ↓'**
  String get activityDesc;

  /// No description provided for @action.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get action;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @selectWhatToSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get selectWhatToSearch;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @groupBy.
  ///
  /// In en, this message translates to:
  /// **'Group by'**
  String get groupBy;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareByNumber.
  ///
  /// In en, this message translates to:
  /// **'Share (Shared by number)'**
  String get shareByNumber;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// No description provided for @move.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get move;

  /// No description provided for @downloadToDevice.
  ///
  /// In en, this message translates to:
  /// **'Download to device'**
  String get downloadToDevice;

  /// No description provided for @addToFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favourite'**
  String get addToFavorite;

  /// No description provided for @removeFromFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favourite'**
  String get removeFromFavorite;

  /// No description provided for @lock.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get lock;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @modifiedRecently.
  ///
  /// In en, this message translates to:
  /// **'Modified recently'**
  String get modifiedRecently;

  /// No description provided for @modifiedJustNow.
  ///
  /// In en, this message translates to:
  /// **'Modified just now'**
  String get modifiedJustNow;

  /// No description provided for @modifiedYesterday.
  ///
  /// In en, this message translates to:
  /// **'Modified yesterday'**
  String get modifiedYesterday;

  /// No description provided for @modifiedAgo.
  ///
  /// In en, this message translates to:
  /// **'{time} ago'**
  String modifiedAgo(Object time);

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete {itemName}?'**
  String deleteConfirmMessage(Object itemName);

  /// No description provided for @deleteFolderConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to delete {folderName} folder. This folder contains {itemCount} photos & videos'**
  String deleteFolderConfirmMessage(Object folderName, Object itemCount);

  /// No description provided for @renameSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully renamed {itemName}'**
  String renameSuccess(Object itemName);

  /// No description provided for @addToFavoriteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully added {itemName} to favorites'**
  String addToFavoriteSuccess(Object itemName);

  /// No description provided for @removeFromFavoriteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully removed {itemName} from favorites'**
  String removeFromFavoriteSuccess(Object itemName);

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading {fileName}...'**
  String downloading(Object fileName);

  /// No description provided for @fileDownloadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'File downloaded successfully to Downloads folder'**
  String get fileDownloadedSuccess;

  /// No description provided for @errorControllerNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Controller not available. Please try again.'**
  String get errorControllerNotAvailable;

  /// No description provided for @errorFileDeletionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete file. Please try again.'**
  String get errorFileDeletionFailed;

  /// No description provided for @errorFileUrlNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'File URL not available. Cannot download.'**
  String get errorFileUrlNotAvailable;

  /// No description provided for @errorDownloadsDirectoryAccess.
  ///
  /// In en, this message translates to:
  /// **'Cannot access downloads directory'**
  String get errorDownloadsDirectoryAccess;

  /// No description provided for @errorDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed. Please check your connection and try again.'**
  String get errorDownloadFailed;

  /// No description provided for @successFileSharing.
  ///
  /// In en, this message translates to:
  /// **'File shared successfully'**
  String get successFileSharing;

  /// No description provided for @errorMediaItemNotFound.
  ///
  /// In en, this message translates to:
  /// **'Media item not found. Please try again.'**
  String get errorMediaItemNotFound;

  /// No description provided for @errorFolderDeleteNoController.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete folder - controller not available'**
  String get errorFolderDeleteNoController;

  /// No description provided for @errorFolderDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete folder. Please try again.'**
  String get errorFolderDeleteFailed;

  /// No description provided for @renameFolder.
  ///
  /// In en, this message translates to:
  /// **'Rename Folder'**
  String get renameFolder;

  /// No description provided for @renameFile.
  ///
  /// In en, this message translates to:
  /// **'Rename File'**
  String get renameFile;

  /// No description provided for @enterFolderName.
  ///
  /// In en, this message translates to:
  /// **'Enter folder name'**
  String get enterFolderName;

  /// No description provided for @enterFileName.
  ///
  /// In en, this message translates to:
  /// **'Enter file name'**
  String get enterFileName;

  /// No description provided for @validationErrorNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get validationErrorNameEmpty;

  /// No description provided for @errorFolderRenameFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to rename folder'**
  String get errorFolderRenameFailed;

  /// No description provided for @successFolderRenamed.
  ///
  /// In en, this message translates to:
  /// **'Folder renamed successfully'**
  String get successFolderRenamed;

  /// No description provided for @folderNameUnchanged.
  ///
  /// In en, this message translates to:
  /// **'Folder name is same as current name'**
  String get folderNameUnchanged;

  /// No description provided for @fileNameUnchanged.
  ///
  /// In en, this message translates to:
  /// **'File name is same as current name'**
  String get fileNameUnchanged;

  /// No description provided for @exitConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to exit?'**
  String get exitConfirmationMessage;

  /// No description provided for @yesExit.
  ///
  /// In en, this message translates to:
  /// **'Yes, Exit'**
  String get yesExit;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @deleteDefaultMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get deleteDefaultMessage;

  /// No description provided for @yesDelete.
  ///
  /// In en, this message translates to:
  /// **'Yes, Delete'**
  String get yesDelete;

  /// No description provided for @createFolder.
  ///
  /// In en, this message translates to:
  /// **'Create Folder'**
  String get createFolder;

  /// No description provided for @enterFolderDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter folder description (optional)'**
  String get enterFolderDescription;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @validationErrorFolderNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Folder name cannot be empty'**
  String get validationErrorFolderNameEmpty;

  /// No description provided for @errorFolderCreationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create folder'**
  String get errorFolderCreationFailed;

  /// No description provided for @successFolderCreated.
  ///
  /// In en, this message translates to:
  /// **'Folder created successfully'**
  String get successFolderCreated;

  /// No description provided for @activityHistory.
  ///
  /// In en, this message translates to:
  /// **'Activity History'**
  String get activityHistory;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// No description provided for @noActivitiesFound.
  ///
  /// In en, this message translates to:
  /// **'No activities found'**
  String get noActivitiesFound;

  /// No description provided for @refreshActivities.
  ///
  /// In en, this message translates to:
  /// **'Refresh Activities'**
  String get refreshActivities;

  /// No description provided for @unknownActivity.
  ///
  /// In en, this message translates to:
  /// **'Unknown activity'**
  String get unknownActivity;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(Object count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(Object count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(Object count);

  /// No description provided for @failedToFetchActivityHistory.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch activity history'**
  String get failedToFetchActivityHistory;

  /// No description provided for @activityErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch activity history: {error}'**
  String activityErrorMessage(Object error);

  /// No description provided for @activityLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading activities...'**
  String get activityLoading;

  /// No description provided for @storageLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Storage Limit Reached!'**
  String get storageLimitReached;

  /// No description provided for @storageLimitReachedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your 2GB storage limit is full. Please delete some files to upload more.'**
  String get storageLimitReachedMessage;

  /// No description provided for @storageWarning.
  ///
  /// In en, this message translates to:
  /// **'Storage Warning!'**
  String get storageWarning;

  /// No description provided for @storageWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'Your storage is almost full. Only {remainingGB} GB remaining.'**
  String storageWarningMessage(Object remainingGB);

  /// No description provided for @fileTooLarge.
  ///
  /// In en, this message translates to:
  /// **'File Too Large!'**
  String get fileTooLarge;

  /// No description provided for @fileTooLargeMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{fileName}\" ({fileSizeMB} MB) cannot be uploaded. Only {remainingGB} GB space remaining.'**
  String fileTooLargeMessage(
      Object fileName, Object fileSizeMB, Object remainingGB);

  /// No description provided for @invalidStorageDataFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid storage data format from server'**
  String get invalidStorageDataFormat;

  /// No description provided for @failedToParseStorageData.
  ///
  /// In en, this message translates to:
  /// **'Failed to parse storage data: {error}'**
  String failedToParseStorageData(Object error);

  /// No description provided for @failedToFetchStorageData.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch storage data: {error}'**
  String failedToFetchStorageData(Object error);

  /// No description provided for @contactsAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'Contacts access is required to load your contacts'**
  String get contactsAccessRequired;

  /// No description provided for @failedToLoadContacts.
  ///
  /// In en, this message translates to:
  /// **'Failed to load contacts: {error}'**
  String failedToLoadContacts(Object error);

  /// No description provided for @folderSuccess.
  ///
  /// In en, this message translates to:
  /// **'Folder success'**
  String get folderSuccess;

  /// No description provided for @folderError.
  ///
  /// In en, this message translates to:
  /// **'Folder error'**
  String get folderError;

  /// No description provided for @uploadProgress.
  ///
  /// In en, this message translates to:
  /// **'Upload... {percent}%'**
  String uploadProgress(Object percent);

  /// No description provided for @uploadComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete!'**
  String get uploadComplete;

  /// No description provided for @allComplete.
  ///
  /// In en, this message translates to:
  /// **'All done!'**
  String get allComplete;

  /// No description provided for @fileUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'File uploaded successfully'**
  String get fileUploadSuccess;

  /// No description provided for @fileDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'File deleted successfully'**
  String get fileDeleteSuccess;

  /// No description provided for @uploadCancelled.
  ///
  /// In en, this message translates to:
  /// **'Upload cancelled'**
  String get uploadCancelled;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get uploadFailed;

  /// No description provided for @fileNotFound.
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get fileNotFound;

  /// No description provided for @unsupportedFileType.
  ///
  /// In en, this message translates to:
  /// **'Unsupported file type'**
  String get unsupportedFileType;

  /// No description provided for @folderCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Folder created successfully'**
  String get folderCreatedSuccessfully;

  /// No description provided for @folderDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Folder deleted successfully'**
  String get folderDeletedSuccessfully;

  /// No description provided for @folderUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Folder updated successfully'**
  String get folderUpdatedSuccessfully;

  /// No description provided for @folderNameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name required'**
  String get folderNameCannotBeEmpty;

  /// No description provided for @securePinRequiredForSecureFolders.
  ///
  /// In en, this message translates to:
  /// **'Pin required'**
  String get securePinRequiredForSecureFolders;

  /// No description provided for @fileDeletedSuccessfullyFromFolder.
  ///
  /// In en, this message translates to:
  /// **'File deleted'**
  String get fileDeletedSuccessfullyFromFolder;

  /// No description provided for @subFolderCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Sub-folder created'**
  String get subFolderCreatedSuccessfully;

  /// No description provided for @fileUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get fileUpload;

  /// No description provided for @preparingUpload.
  ///
  /// In en, this message translates to:
  /// **'Preparing...'**
  String get preparingUpload;

  /// No description provided for @uploadingToCloud.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get uploadingToCloud;

  /// No description provided for @finalizingUpload.
  ///
  /// In en, this message translates to:
  /// **'Finalizing...'**
  String get finalizingUpload;

  /// No description provided for @uploadCompleted.
  ///
  /// In en, this message translates to:
  /// **'Done!'**
  String get uploadCompleted;

  /// No description provided for @allUploadsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get allUploadsFailed;

  /// No description provided for @failedToFetchFolders.
  ///
  /// In en, this message translates to:
  /// **'Fetch failed: {error}'**
  String failedToFetchFolders(Object error);

  /// No description provided for @failedToFetchFolderContents.
  ///
  /// In en, this message translates to:
  /// **'Load failed: {error}'**
  String failedToFetchFolderContents(Object error);

  /// No description provided for @failedToCreateFolder.
  ///
  /// In en, this message translates to:
  /// **'Create failed: {error}'**
  String failedToCreateFolder(Object error);

  /// No description provided for @failedToDeleteFolder.
  ///
  /// In en, this message translates to:
  /// **'Delete failed: {error}'**
  String failedToDeleteFolder(Object error);

  /// No description provided for @failedToUpdateFolder.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {error}'**
  String failedToUpdateFolder(Object error);

  /// No description provided for @failedToDeleteFileFromFolder.
  ///
  /// In en, this message translates to:
  /// **'Delete failed: {error}'**
  String failedToDeleteFileFromFolder(Object error);

  /// No description provided for @failedToCreateSubFolder.
  ///
  /// In en, this message translates to:
  /// **'Create failed: {error}'**
  String failedToCreateSubFolder(Object error);

  /// No description provided for @uploadingFile.
  ///
  /// In en, this message translates to:
  /// **'{fileName}...'**
  String uploadingFile(Object fileName);

  /// No description provided for @uploadingFiles.
  ///
  /// In en, this message translates to:
  /// **'{count} files...'**
  String uploadingFiles(Object count);

  /// No description provided for @uploadingProgress.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String uploadingProgress(Object percent);

  /// No description provided for @preparingFiles.
  ///
  /// In en, this message translates to:
  /// **'Prep {count}...'**
  String preparingFiles(Object count);

  /// No description provided for @uploadingMultipleProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total}'**
  String uploadingMultipleProgress(Object completed, Object total);

  /// No description provided for @processingComplete.
  ///
  /// In en, this message translates to:
  /// **'Done {completed}/{total}'**
  String processingComplete(Object completed, Object total);

  /// No description provided for @allFilesUploadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{count} uploaded'**
  String allFilesUploadedSuccessfully(Object count);

  /// No description provided for @partialUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'{completed} ok, {failed} fail'**
  String partialUploadSuccess(Object completed, Object failed);

  /// No description provided for @allFilesUploadFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'{count} failed'**
  String allFilesUploadFailedMessage(Object count);

  /// No description provided for @partialUploadFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'{failed} failed'**
  String partialUploadFailedMessage(Object failed);

  /// No description provided for @uploadSummary.
  ///
  /// In en, this message translates to:
  /// **'Upload Summary'**
  String get uploadSummary;

  /// No description provided for @successfullyUploaded.
  ///
  /// In en, this message translates to:
  /// **'Successfully uploaded'**
  String get successfullyUploaded;

  /// No description provided for @failedToUpload.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload'**
  String get failedToUpload;

  /// No description provided for @alreadyExistsSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped - File already uploaded'**
  String get alreadyExistsSkipped;

  /// No description provided for @error_folder_delete_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete folder'**
  String get error_folder_delete_failed;

  /// No description provided for @noFileToDownload.
  ///
  /// In en, this message translates to:
  /// **'No file to download'**
  String get noFileToDownload;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDenied;

  /// No description provided for @storagePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Storage Permission Required'**
  String get storagePermissionRequired;

  /// No description provided for @failedToDownloadFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to download file: {error}'**
  String failedToDownloadFile(Object error);

  /// No description provided for @downloadComplete.
  ///
  /// In en, this message translates to:
  /// **'Download Complete: {fileName}\nSaved to: {location}'**
  String downloadComplete(Object fileName, Object location);

  /// No description provided for @shareLinkNotFound.
  ///
  /// In en, this message translates to:
  /// **'Share link not found or expired'**
  String get shareLinkNotFound;

  /// No description provided for @shareLinkExpired.
  ///
  /// In en, this message translates to:
  /// **'Share link has expired'**
  String get shareLinkExpired;

  /// No description provided for @notAuthorizedToAccess.
  ///
  /// In en, this message translates to:
  /// **'You are not authorized to access this resource'**
  String get notAuthorizedToAccess;

  /// No description provided for @serverErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Server error occurred'**
  String get serverErrorOccurred;

  /// No description provided for @sharedResourceExpired.
  ///
  /// In en, this message translates to:
  /// **'This shared resource has expired'**
  String get sharedResourceExpired;

  /// No description provided for @failedToLoadSharedResource.
  ///
  /// In en, this message translates to:
  /// **'Failed to load shared resource: {error}'**
  String failedToLoadSharedResource(Object error);

  /// No description provided for @fileIdRequiredToGenerateShareLink.
  ///
  /// In en, this message translates to:
  /// **'File ID is required to generate share link'**
  String get fileIdRequiredToGenerateShareLink;

  /// No description provided for @pleaseSelectAtLeastOneContact.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one contact to share with'**
  String get pleaseSelectAtLeastOneContact;

  /// No description provided for @successfullySharedFileWithContacts.
  ///
  /// In en, this message translates to:
  /// **'Successfully shared {fileName} with {contactCount} contacts'**
  String successfullySharedFileWithContacts(
      Object contactCount, Object fileName);

  /// No description provided for @sharedWithContacts.
  ///
  /// In en, this message translates to:
  /// **'Shared with {contactCount} contacts'**
  String sharedWithContacts(Object contactCount);

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file;

  /// No description provided for @somePhoneNumbersNotRegistered.
  ///
  /// In en, this message translates to:
  /// **'Some phone numbers are not registered: {phoneNumbers}'**
  String somePhoneNumbersNotRegistered(Object phoneNumbers);

  /// No description provided for @failedToGenerateShareLink.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate share link: {error}'**
  String failedToGenerateShareLink(Object error);

  /// No description provided for @unexpectedErrorWhileSharing.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred while sharing: {error}'**
  String unexpectedErrorWhileSharing(Object error);

  /// No description provided for @pleaseGenerateShareLinkFirst.
  ///
  /// In en, this message translates to:
  /// **'Please generate a share link first'**
  String get pleaseGenerateShareLinkFirst;

  /// No description provided for @shareLinkCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Share link copied to clipboard'**
  String get shareLinkCopiedToClipboard;

  /// No description provided for @failedToCopyLinkToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Failed to copy link to clipboard'**
  String get failedToCopyLinkToClipboard;

  /// No description provided for @doYouReallyWantToExit.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to Exit?'**
  String get doYouReallyWantToExit;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @proPlan.
  ///
  /// In en, this message translates to:
  /// **'Pro Plan'**
  String get proPlan;

  /// No description provided for @anantSpaceFree.
  ///
  /// In en, this message translates to:
  /// **'AnantSpace Free'**
  String get anantSpaceFree;

  /// No description provided for @anantSpacePro.
  ///
  /// In en, this message translates to:
  /// **'AnantSpace Pro'**
  String get anantSpacePro;

  /// No description provided for @yourStorage.
  ///
  /// In en, this message translates to:
  /// **'Your storage'**
  String get yourStorage;

  /// No description provided for @percentUsed.
  ///
  /// In en, this message translates to:
  /// **'% Used'**
  String get percentUsed;

  /// No description provided for @buyStorage.
  ///
  /// In en, this message translates to:
  /// **'Buy storage'**
  String get buyStorage;

  /// No description provided for @upgradePlan.
  ///
  /// In en, this message translates to:
  /// **'Upgrade plan'**
  String get upgradePlan;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfile;

  /// No description provided for @privacyPolicyTerms.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy & Terms of usage'**
  String get privacyPolicyTerms;

  /// No description provided for @rateUs.
  ///
  /// In en, this message translates to:
  /// **'Rate us'**
  String get rateUs;

  /// No description provided for @fileIdRequiredToShare.
  ///
  /// In en, this message translates to:
  /// **'File ID is required to share'**
  String get fileIdRequiredToShare;

  /// No description provided for @shareLinkGenerated.
  ///
  /// In en, this message translates to:
  /// **'Share Link Generated'**
  String get shareLinkGenerated;

  /// No description provided for @fileSharedWithContacts.
  ///
  /// In en, this message translates to:
  /// **'Your file \"{fileName}\" has been shared with {contactCount} contact(s).'**
  String fileSharedWithContacts(Object contactCount, Object fileName);

  /// No description provided for @shareLink.
  ///
  /// In en, this message translates to:
  /// **'Share Link:'**
  String get shareLink;

  /// No description provided for @shareScreen.
  ///
  /// In en, this message translates to:
  /// **'Share screen'**
  String get shareScreen;

  /// No description provided for @selectContacts.
  ///
  /// In en, this message translates to:
  /// **'Select Contacts'**
  String get selectContacts;

  /// No description provided for @selectedContacts.
  ///
  /// In en, this message translates to:
  /// **'Selected Contacts'**
  String get selectedContacts;

  /// No description provided for @searchContactsHint.
  ///
  /// In en, this message translates to:
  /// **'Search contacts...'**
  String get searchContactsHint;

  /// No description provided for @shareButton.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareButton;

  /// No description provided for @searchContacts.
  ///
  /// In en, this message translates to:
  /// **'Search contacts...'**
  String get searchContacts;

  /// No description provided for @validating.
  ///
  /// In en, this message translates to:
  /// **'Validating...'**
  String get validating;

  /// No description provided for @shareWithCount.
  ///
  /// In en, this message translates to:
  /// **'Share ({count})'**
  String shareWithCount(Object count);

  /// No description provided for @contactsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} contacts selected'**
  String contactsSelected(Object count);

  /// No description provided for @pleaseSelectContactsToShare.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one contact to share with'**
  String get pleaseSelectContactsToShare;

  /// No description provided for @selectedContactsNoValidPhones.
  ///
  /// In en, this message translates to:
  /// **'Selected contacts do not have valid phone numbers'**
  String get selectedContactsNoValidPhones;

  /// No description provided for @invalidPhoneNumbersNotRegistered.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone numbers: {phoneNumbers}\n\nThese contacts are not registered. Please remove them and try again.'**
  String invalidPhoneNumbersNotRegistered(Object phoneNumbers);

  /// No description provided for @failedToValidateContacts.
  ///
  /// In en, this message translates to:
  /// **'Failed to validate contacts: {error}'**
  String failedToValidateContacts(Object error);

  /// No description provided for @selectDestination.
  ///
  /// In en, this message translates to:
  /// **'Select Destination'**
  String get selectDestination;

  /// No description provided for @noFoldersHere.
  ///
  /// In en, this message translates to:
  /// **'No Folders Here'**
  String get noFoldersHere;

  /// No description provided for @noSubfoldersDescription.
  ///
  /// In en, this message translates to:
  /// **'This location has no subfolders. You can still move items to this location.'**
  String get noSubfoldersDescription;

  /// No description provided for @cantMove.
  ///
  /// In en, this message translates to:
  /// **'Can\'t move'**
  String get cantMove;

  /// No description provided for @moving.
  ///
  /// In en, this message translates to:
  /// **'Moving...'**
  String get moving;

  /// No description provided for @moveHere.
  ///
  /// In en, this message translates to:
  /// **'Move Here'**
  String get moveHere;

  /// No description provided for @pleaseSelectDestinationFolder.
  ///
  /// In en, this message translates to:
  /// **'Please select a destination folder to move your files.'**
  String get pleaseSelectDestinationFolder;

  /// No description provided for @selectedItems.
  ///
  /// In en, this message translates to:
  /// **'Selected Items'**
  String get selectedItems;

  /// No description provided for @myFiles.
  ///
  /// In en, this message translates to:
  /// **'My Files'**
  String get myFiles;

  /// No description provided for @confirmMove.
  ///
  /// In en, this message translates to:
  /// **'Confirm move'**
  String get confirmMove;

  /// No description provided for @areYouSureMoveFiles.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to move these files?'**
  String get areYouSureMoveFiles;

  /// No description provided for @unknownFolder.
  ///
  /// In en, this message translates to:
  /// **'Unknown Folder'**
  String get unknownFolder;

  /// No description provided for @scanDocument.
  ///
  /// In en, this message translates to:
  /// **'Scan document'**
  String get scanDocument;

  /// No description provided for @documentCounter.
  ///
  /// In en, this message translates to:
  /// **'Document {current} of {total}'**
  String documentCounter(Object current, Object total);

  /// No description provided for @savingPdf.
  ///
  /// In en, this message translates to:
  /// **'Saving PDF...'**
  String get savingPdf;

  /// No description provided for @savePdf.
  ///
  /// In en, this message translates to:
  /// **'Save PDF'**
  String get savePdf;

  /// No description provided for @failedToUploadPdf.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload PDF'**
  String get failedToUploadPdf;

  /// No description provided for @enterPdfName.
  ///
  /// In en, this message translates to:
  /// **'Enter PDF Name'**
  String get enterPdfName;

  /// No description provided for @enterPdfNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter PDF Name'**
  String get enterPdfNameHint;

  /// No description provided for @pleaseEnterPdfName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a PDF name'**
  String get pleaseEnterPdfName;

  /// No description provided for @securitySetting.
  ///
  /// In en, this message translates to:
  /// **'Security Setting'**
  String get securitySetting;

  /// No description provided for @biometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Biometric login'**
  String get biometricLogin;

  /// No description provided for @biometricLoginDescription.
  ///
  /// In en, this message translates to:
  /// **'If you enable biometric login your phone\'s biometric is going to use directly to open the app.'**
  String get biometricLoginDescription;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @securePin.
  ///
  /// In en, this message translates to:
  /// **'Secure pin'**
  String get securePin;

  /// No description provided for @changePin.
  ///
  /// In en, this message translates to:
  /// **'Change pin'**
  String get changePin;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @changeSecurityPin.
  ///
  /// In en, this message translates to:
  /// **'Change security pin'**
  String get changeSecurityPin;

  /// No description provided for @changeSecurityPinDescription.
  ///
  /// In en, this message translates to:
  /// **'Change security pin & use these whenever you access a secure folder'**
  String get changeSecurityPinDescription;

  /// No description provided for @sharedFile.
  ///
  /// In en, this message translates to:
  /// **'Shared File'**
  String get sharedFile;

  /// No description provided for @downloadFile.
  ///
  /// In en, this message translates to:
  /// **'Download File'**
  String get downloadFile;

  /// No description provided for @downloadEntireFolder.
  ///
  /// In en, this message translates to:
  /// **'Download Entire Folder'**
  String get downloadEntireFolder;

  /// No description provided for @sharedByMe.
  ///
  /// In en, this message translates to:
  /// **'Shared by Me'**
  String get sharedByMe;

  /// No description provided for @sharedWithMe.
  ///
  /// In en, this message translates to:
  /// **'Shared with Me'**
  String get sharedWithMe;

  /// No description provided for @filesOnly.
  ///
  /// In en, this message translates to:
  /// **'Files Only'**
  String get filesOnly;

  /// No description provided for @foldersOnly.
  ///
  /// In en, this message translates to:
  /// **'Folders Only'**
  String get foldersOnly;

  /// No description provided for @dateShared.
  ///
  /// In en, this message translates to:
  /// **'Date Shared'**
  String get dateShared;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get newestFirst;

  /// No description provided for @oldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get oldestFirst;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @sharedOn.
  ///
  /// In en, this message translates to:
  /// **'Shared on'**
  String get sharedOn;

  /// No description provided for @sharedWith.
  ///
  /// In en, this message translates to:
  /// **'Shared with'**
  String get sharedWith;

  /// No description provided for @sharedBy.
  ///
  /// In en, this message translates to:
  /// **'Shared by'**
  String get sharedBy;

  /// No description provided for @otherPeople.
  ///
  /// In en, this message translates to:
  /// **'other people'**
  String get otherPeople;

  /// No description provided for @sharedWithOtherPeople.
  ///
  /// In en, this message translates to:
  /// **'Shared with {count} other people'**
  String sharedWithOtherPeople(String count);

  /// No description provided for @stopSharing.
  ///
  /// In en, this message translates to:
  /// **'Stop Sharing'**
  String get stopSharing;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @manageShare.
  ///
  /// In en, this message translates to:
  /// **'Manage Share'**
  String get manageShare;

  /// No description provided for @viewRecipients.
  ///
  /// In en, this message translates to:
  /// **'View Recipients'**
  String get viewRecipients;

  /// No description provided for @seeWhoHasAccess.
  ///
  /// In en, this message translates to:
  /// **'See who has access'**
  String get seeWhoHasAccess;

  /// No description provided for @manageRecipientAccess.
  ///
  /// In en, this message translates to:
  /// **'Manage recipient access'**
  String get manageRecipientAccess;

  /// No description provided for @stopSharingConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop Sharing?'**
  String get stopSharingConfirmTitle;

  /// No description provided for @stopSharingConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will revoke access for all recipients. This action cannot be undone.'**
  String get stopSharingConfirmMessage;

  /// No description provided for @removeFromListTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from Your List?'**
  String get removeFromListTitle;

  /// No description provided for @removeFromListMessage.
  ///
  /// In en, this message translates to:
  /// **'You won\'t be able to access \"{itemName}\" anymore.'**
  String removeFromListMessage(String itemName);

  /// No description provided for @stopSharingTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop Sharing?'**
  String get stopSharingTitle;

  /// No description provided for @stopSharingMessage.
  ///
  /// In en, this message translates to:
  /// **'This will revoke access for {name}.'**
  String stopSharingMessage(String name);

  /// No description provided for @stopSharingWithAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop Sharing with All?'**
  String get stopSharingWithAllTitle;

  /// No description provided for @stopSharingWithAllMessage.
  ///
  /// In en, this message translates to:
  /// **'This will revoke access for all {count} recipients.'**
  String stopSharingWithAllMessage(int count);

  /// No description provided for @yesRemoveAll.
  ///
  /// In en, this message translates to:
  /// **'Yes, Remove All'**
  String get yesRemoveAll;

  /// No description provided for @shareIdNotFound.
  ///
  /// In en, this message translates to:
  /// **'Share ID not found'**
  String get shareIdNotFound;

  /// No description provided for @shareIdNotFoundOrEmpty.
  ///
  /// In en, this message translates to:
  /// **'Share ID not found or empty'**
  String get shareIdNotFoundOrEmpty;

  /// No description provided for @accessRevokedForAll.
  ///
  /// In en, this message translates to:
  /// **'Access revoked for all recipients'**
  String get accessRevokedForAll;

  /// No description provided for @removedFromYourList.
  ///
  /// In en, this message translates to:
  /// **'Removed from your list'**
  String get removedFromYourList;

  /// No description provided for @failedToRevokeAccess.
  ///
  /// In en, this message translates to:
  /// **'Failed to revoke access: {error}'**
  String failedToRevokeAccess(String error);

  /// No description provided for @failedToRemove.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove: {error}'**
  String failedToRemove(String error);

  /// No description provided for @fileInfoNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'File information not available'**
  String get fileInfoNotAvailable;

  /// No description provided for @downloadUrlNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Download URL not available'**
  String get downloadUrlNotAvailable;

  /// No description provided for @failedToStartDownloadService.
  ///
  /// In en, this message translates to:
  /// **'Failed to start download service'**
  String get failedToStartDownloadService;

  /// No description provided for @failedToStartDownload.
  ///
  /// In en, this message translates to:
  /// **'Failed to start download: {error}'**
  String failedToStartDownload(String error);

  /// No description provided for @checkNotificationTray.
  ///
  /// In en, this message translates to:
  /// **'Check notification tray for download progress'**
  String get checkNotificationTray;

  /// No description provided for @failedToLoadRecipients.
  ///
  /// In en, this message translates to:
  /// **'Failed to load recipients: {error}'**
  String failedToLoadRecipients(String error);

  /// No description provided for @noRecipientsFound.
  ///
  /// In en, this message translates to:
  /// **'No recipients found'**
  String get noRecipientsFound;

  /// No description provided for @linkCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get linkCopiedToClipboard;

  /// No description provided for @modified.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get modified;

  /// No description provided for @notModified.
  ///
  /// In en, this message translates to:
  /// **'Not modified'**
  String get notModified;

  /// No description provided for @folder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get folder;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// No description provided for @noImagesFound.
  ///
  /// In en, this message translates to:
  /// **'No images found'**
  String get noImagesFound;

  /// No description provided for @noImagesRootDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload your photos and images to see them here'**
  String get noImagesRootDescription;

  /// No description provided for @noImagesFolderDescription.
  ///
  /// In en, this message translates to:
  /// **'This folder doesn\'t contain any images'**
  String get noImagesFolderDescription;

  /// No description provided for @noVideosFound.
  ///
  /// In en, this message translates to:
  /// **'No videos found'**
  String get noVideosFound;

  /// No description provided for @noVideosRootDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload your videos to see them here'**
  String get noVideosRootDescription;

  /// No description provided for @noVideosFolderDescription.
  ///
  /// In en, this message translates to:
  /// **'This folder doesn\'t contain any videos'**
  String get noVideosFolderDescription;

  /// No description provided for @noDocumentsFound.
  ///
  /// In en, this message translates to:
  /// **'No documents found'**
  String get noDocumentsFound;

  /// No description provided for @noDocumentsRootDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload your documents to see them here'**
  String get noDocumentsRootDescription;

  /// No description provided for @noDocumentsFolderDescription.
  ///
  /// In en, this message translates to:
  /// **'This folder doesn\'t contain any documents'**
  String get noDocumentsFolderDescription;

  /// No description provided for @noAudioFound.
  ///
  /// In en, this message translates to:
  /// **'No audio found'**
  String get noAudioFound;

  /// No description provided for @noAudioRootDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload your audio files to see them here'**
  String get noAudioRootDescription;

  /// No description provided for @noAudioFolderDescription.
  ///
  /// In en, this message translates to:
  /// **'This folder doesn\'t contain any audio files'**
  String get noAudioFolderDescription;

  /// No description provided for @noOtherFilesFound.
  ///
  /// In en, this message translates to:
  /// **'No other files found'**
  String get noOtherFilesFound;

  /// No description provided for @noOtherFilesRootDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload files to see them here'**
  String get noOtherFilesRootDescription;

  /// No description provided for @noOtherFilesFolderDescription.
  ///
  /// In en, this message translates to:
  /// **'This folder doesn\'t contain any other files'**
  String get noOtherFilesFolderDescription;

  /// No description provided for @noFoldersFound.
  ///
  /// In en, this message translates to:
  /// **'No folders found'**
  String get noFoldersFound;

  /// No description provided for @noFoldersRootDescription.
  ///
  /// In en, this message translates to:
  /// **'Create folders to organize your files'**
  String get noFoldersRootDescription;

  /// No description provided for @noFoldersFolderDescription.
  ///
  /// In en, this message translates to:
  /// **'This location doesn\'t contain any folders'**
  String get noFoldersFolderDescription;

  /// No description provided for @noContactsSelected.
  ///
  /// In en, this message translates to:
  /// **'No contacts selected'**
  String get noContactsSelected;

  /// No description provided for @noContactsSelectedDescription.
  ///
  /// In en, this message translates to:
  /// **'Select contacts to share files with them'**
  String get noContactsSelectedDescription;

  /// No description provided for @noContactsFound.
  ///
  /// In en, this message translates to:
  /// **'No contacts found'**
  String get noContactsFound;

  /// No description provided for @noContactsFoundDescription.
  ///
  /// In en, this message translates to:
  /// **'No contacts available in your device'**
  String get noContactsFoundDescription;

  /// No description provided for @searchWithContacts.
  ///
  /// In en, this message translates to:
  /// **'Search with contacts'**
  String get searchWithContacts;

  /// No description provided for @contactsCount.
  ///
  /// In en, this message translates to:
  /// **'{loaded} / {total} contacts'**
  String contactsCount(int loaded, int total);

  /// No description provided for @totalContacts.
  ///
  /// In en, this message translates to:
  /// **'{count} contacts'**
  String totalContacts(int count);

  /// No description provided for @searchResultsFound.
  ///
  /// In en, this message translates to:
  /// **'{count} search results found for \'{query}\''**
  String searchResultsFound(int count, String query);

  /// No description provided for @folderNotShared.
  ///
  /// In en, this message translates to:
  /// **'Folder not shared'**
  String get folderNotShared;

  /// No description provided for @folderNotSharedDescription.
  ///
  /// In en, this message translates to:
  /// **'This folder hasn\'t been shared with anyone yet'**
  String get folderNotSharedDescription;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @noResultsFoundDescription.
  ///
  /// In en, this message translates to:
  /// **'Try different keywords or filters'**
  String get noResultsFoundDescription;

  /// No description provided for @nothingToShow.
  ///
  /// In en, this message translates to:
  /// **'Nothing to show'**
  String get nothingToShow;

  /// No description provided for @nothingToShowRootDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload files and folders to get started'**
  String get nothingToShowRootDescription;

  /// No description provided for @nothingToShowFolderDescription.
  ///
  /// In en, this message translates to:
  /// **'This folder is empty'**
  String get nothingToShowFolderDescription;

  /// No description provided for @noSharedByMeFiles.
  ///
  /// In en, this message translates to:
  /// **'No shared files'**
  String get noSharedByMeFiles;

  /// No description provided for @noSharedByMeFilesDescription.
  ///
  /// In en, this message translates to:
  /// **'Files and folders you share with others will appear here'**
  String get noSharedByMeFilesDescription;

  /// No description provided for @noSharedWithMeFiles.
  ///
  /// In en, this message translates to:
  /// **'No shared files'**
  String get noSharedWithMeFiles;

  /// No description provided for @noSharedWithMeFilesDescription.
  ///
  /// In en, this message translates to:
  /// **'Files and folders shared with you will appear here'**
  String get noSharedWithMeFilesDescription;

  /// No description provided for @whoCanAccess.
  ///
  /// In en, this message translates to:
  /// **'Who can access'**
  String get whoCanAccess;

  /// No description provided for @galleryPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Gallery Permission Required'**
  String get galleryPermissionRequired;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera Permission Required'**
  String get cameraPermissionRequired;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @galleryPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'To select and crop photos,\nplease grant access to your gallery'**
  String get galleryPermissionDescription;

  /// No description provided for @cameraPermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'To take photos,\nplease grant camera access'**
  String get cameraPermissionDescription;

  /// No description provided for @storagePermissionDescription.
  ///
  /// In en, this message translates to:
  /// **'To save files,\nplease grant storage access'**
  String get storagePermissionDescription;

  /// No description provided for @permissionDescription.
  ///
  /// In en, this message translates to:
  /// **'Please grant the required permission'**
  String get permissionDescription;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @limitedAccessDetected.
  ///
  /// In en, this message translates to:
  /// **'Limited Access Detected'**
  String get limitedAccessDetected;

  /// No description provided for @grantFullPermissionPhotos.
  ///
  /// In en, this message translates to:
  /// **'Grant full permission to access all photos'**
  String get grantFullPermissionPhotos;

  /// No description provided for @grantFullPermissionAudio.
  ///
  /// In en, this message translates to:
  /// **'Grant full permission to access all audio'**
  String get grantFullPermissionAudio;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @selectAlbum.
  ///
  /// In en, this message translates to:
  /// **'Select Album'**
  String get selectAlbum;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @selectAudio.
  ///
  /// In en, this message translates to:
  /// **'Select Audio'**
  String get selectAudio;

  /// No description provided for @addBusinessShopDetails.
  ///
  /// In en, this message translates to:
  /// **'Add your business/shop &\npersonal details'**
  String get addBusinessShopDetails;

  /// No description provided for @businessShopName.
  ///
  /// In en, this message translates to:
  /// **'Business / Shop name'**
  String get businessShopName;

  /// No description provided for @locationAddress.
  ///
  /// In en, this message translates to:
  /// **'Location / Address'**
  String get locationAddress;

  /// No description provided for @registeredMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Registered mobile number'**
  String get registeredMobileNumber;

  /// No description provided for @ownerMasterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Owner (Master mobile number)'**
  String get ownerMasterMobileNumber;

  /// No description provided for @confirmFinish.
  ///
  /// In en, this message translates to:
  /// **'Confirm & finish'**
  String get confirmFinish;

  /// No description provided for @pleaseEnterValidMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid 10-digit mobile number'**
  String get pleaseEnterValidMobileNumber;

  /// No description provided for @pleaseEnterYourName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterYourName;

  /// No description provided for @pleaseEnterBusinessShopName.
  ///
  /// In en, this message translates to:
  /// **'Please enter business/shop name'**
  String get pleaseEnterBusinessShopName;

  /// No description provided for @pleaseEnterLocationAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter location/address'**
  String get pleaseEnterLocationAddress;

  /// No description provided for @pleaseVerifyOwnerMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Please verify owner mobile number'**
  String get pleaseVerifyOwnerMobileNumber;

  /// No description provided for @detailsSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Details saved successfully'**
  String get detailsSavedSuccessfully;

  /// No description provided for @failedToSaveDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to save details'**
  String get failedToSaveDetails;

  /// No description provided for @inSeconds.
  ///
  /// In en, this message translates to:
  /// **' in {seconds} seconds'**
  String get inSeconds;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'as',
        'bn',
        'en',
        'gu',
        'hi',
        'kn',
        'ml',
        'mr',
        'or',
        'pa',
        'ta',
        'te'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'as':
      return AppLocalizationsAs();
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'ml':
      return AppLocalizationsMl();
    case 'mr':
      return AppLocalizationsMr();
    case 'or':
      return AppLocalizationsOr();
    case 'pa':
      return AppLocalizationsPa();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
