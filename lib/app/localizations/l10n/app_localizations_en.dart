// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AnantSpace';

  @override
  String get welcome => 'Welcome';

  @override
  String get byClicking => 'By clicking, you agree to our';

  @override
  String get termsConditions => 'Terms & Conditions';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get enterPhoneNumber => 'Number';

  @override
  String get mobileNumber => 'Mobile Number';

  @override
  String get continueText => 'Continue';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get noLanguagesFound => 'No languages found';

  @override
  String get tryDifferentSearchTerm => 'Try a different search term';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String get verifyOtp => 'Verify OTP';

  @override
  String get resendOtp => 'Resend OTP';

  @override
  String get pleaseEnterPhoneNumber => 'Please enter phone number';

  @override
  String get pleaseEnterOtp => 'Please enter OTP';

  @override
  String get invalidPhoneNumber => 'Invalid phone number';

  @override
  String get invalidOtp => 'Invalid OTP';

  @override
  String get otpSentSuccessfully => 'OTP sent successfully';

  @override
  String get otpVerifiedSuccessfully => 'OTP verified successfully';

  @override
  String get failedToSendOtp => 'Failed to send OTP';

  @override
  String get networkError => 'Network error occurred';

  @override
  String get tryAgain => 'Try again';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get validationError => 'Validation Error';

  @override
  String get authError => 'Authentication Error';

  @override
  String get permissionError => 'Permission Error';

  @override
  String get storageError => 'Storage Error';

  @override
  String get uploadError => 'Upload Error';

  @override
  String get downloadError => 'Download Error';

  @override
  String get serverError => 'Server Error';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get close => 'Close';

  @override
  String get open => 'Open';

  @override
  String get search => 'Search';

  @override
  String get searchFilesAndFolders => 'Search files and folders...';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get clearAll => 'Clear all';

  @override
  String get searchMinChars => 'Type 2+ chars';

  @override
  String get searchingFor => 'Searching...';

  @override
  String get searchFailed => 'Search failed';

  @override
  String get noResultsFor => 'No results';

  @override
  String resultFound(int count) {
    return '$count result';
  }

  @override
  String resultsFound(int count) {
    return '$count results';
  }

  @override
  String get youreOffline => 'You\'re Offline';

  @override
  String get somethingWentWrong => 'Something Went Wrong';

  @override
  String get errorOccurred => 'Error';

  @override
  String get checkInternetConnection =>
      'Check your internet connection and\ntry again to access your cloud files';

  @override
  String get serversUnavailable =>
      'Our servers are temporarily\nunavailable. Please try again later';

  @override
  String get anErrorOccurred => 'An error occurred';

  @override
  String get reload => 'Reload';

  @override
  String get filter => 'Filter';

  @override
  String get filters => 'Filters';

  @override
  String get sort => 'Sort';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get logout => 'Logout';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get remove => 'Remove';

  @override
  String get removeAll => 'Remove All';

  @override
  String get change => 'Change';

  @override
  String get name => 'Name';

  @override
  String get enterName => 'Enter name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get enterEmail => 'Enter email';

  @override
  String get gallery => 'Gallery';

  @override
  String get yesRemove => 'Yes, Remove';

  @override
  String get removeProfilePicture =>
      'Do you really want to remove profile picture?';

  @override
  String get onboardingTitle1 => 'Digital Leader';

  @override
  String get onboardingTitle2 => 'Auto Reminders';

  @override
  String get onboardingTitle3 => 'Quick Reports';

  @override
  String get onboardingTitle4 => 'Secure & Private';

  @override
  String get onboardingSubtitle1 =>
      'Easily record all sales, expenses, and dues in one secure place.';

  @override
  String get onboardingSubtitle2 =>
      'Send payment reminders via SMS or WhatsApp and get paid faster.';

  @override
  String get onboardingSubtitle3 =>
      'See profit, loss and outstanding balances in just a few taps.';

  @override
  String get onboardingSubtitle4 =>
      'Your records are encrypted and accessible only to you.';

  @override
  String get phoneValidationOnlyIndian => 'Only Indian numbers supported';

  @override
  String get phoneValidationIndianFormat =>
      'Number must start with 6-9 and be 10 digits';

  @override
  String get phoneValidationInvalidPattern => 'Invalid number pattern';

  @override
  String get phoneValidationInvalidNumber => 'Invalid mobile number';

  @override
  String get phoneValidationAllSameDigits =>
      'Invalid number - all digits cannot be same';

  @override
  String get phoneValidationSequentialPattern =>
      'Invalid number - sequential pattern detected';

  @override
  String get phoneValidationRepeatingPattern =>
      'Invalid number - repeating pattern detected';

  @override
  String get phoneValidationTooFewUniqueDigits =>
      'Invalid number - too few unique digits';

  @override
  String get phoneValidationTestNumber => 'This is a test number - not allowed';

  @override
  String get enterOtpSentTo => 'Enter the OTP sent to';

  @override
  String get didntReceiveOtp => 'Didn\'t receive the OTP?';

  @override
  String get resendIn => 'Resend in';

  @override
  String get sec => 'sec';

  @override
  String get submitOtp => 'Submit OTP';

  @override
  String get otpVerificationFailed => 'OTP Verification Failed';

  @override
  String get pleaseEnterComplete4DigitOtp =>
      'Please enter complete 4-digit OTP';

  @override
  String get phoneNumberRequired => 'Phone number is required';

  @override
  String get verificationFailed => 'Verification failed';

  @override
  String get invalidOrExpiredOtp => 'Invalid or expired OTP';

  @override
  String get searchForAnything => 'Search for anything';

  @override
  String get yourCloudStorage => 'Your cloud storage';

  @override
  String get files => 'Files';

  @override
  String get items => 'items';

  @override
  String get emptyFolder => 'Empty folder';

  @override
  String get used => 'Used';

  @override
  String get freePlan => 'Free Plan';

  @override
  String get recent => 'Recent';

  @override
  String get recentFilesDescription =>
      'Your recently opened files show up here, so\nyou can jump right back in.';

  @override
  String get addFolder => 'Folder';

  @override
  String get createSubfolder => 'Subfolder';

  @override
  String get uploadFiles => 'Upload';

  @override
  String get camera => 'Camera';

  @override
  String get scanner => 'Scanner';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get security => 'Security';

  @override
  String get theme => 'Theme';

  @override
  String get everything => 'All';

  @override
  String get folders => 'Folders';

  @override
  String get image => 'Images';

  @override
  String get images => 'Images';

  @override
  String get videos => 'Videos';

  @override
  String get documents => 'Docs';

  @override
  String get audioSound => 'Audio';

  @override
  String get audios => 'Audios';

  @override
  String get otherFiles => 'Others';

  @override
  String get others => 'Others';

  @override
  String get nameAZ => 'Name A-Z';

  @override
  String get nameZA => 'Name Z-A';

  @override
  String get activityAsc => 'Time ↑';

  @override
  String get activityDesc => 'Time ↓';

  @override
  String get action => 'Action';

  @override
  String get created => 'Created';

  @override
  String get actions => 'Actions';

  @override
  String get selectWhatToSearch => 'Search';

  @override
  String get goBack => 'Go back';

  @override
  String get apply => 'Apply';

  @override
  String get sortBy => 'Sort by';

  @override
  String get groupBy => 'Group by';

  @override
  String get share => 'Share';

  @override
  String get shareByNumber => 'Share (Shared by number)';

  @override
  String get rename => 'Rename';

  @override
  String get copyLink => 'Copy Link';

  @override
  String get move => 'Move';

  @override
  String get downloadToDevice => 'Download to device';

  @override
  String get addToFavorite => 'Add to favourite';

  @override
  String get removeFromFavorite => 'Remove from favourite';

  @override
  String get lock => 'Lock';

  @override
  String get unlock => 'Unlock';

  @override
  String get modifiedRecently => 'Modified recently';

  @override
  String get modifiedJustNow => 'Modified just now';

  @override
  String get modifiedYesterday => 'Modified yesterday';

  @override
  String modifiedAgo(Object time) {
    return '$time ago';
  }

  @override
  String deleteConfirmMessage(Object itemName) {
    return 'Do you really want to delete $itemName?';
  }

  @override
  String deleteFolderConfirmMessage(Object folderName, Object itemCount) {
    return 'Do you really want to delete $folderName folder. This folder contains $itemCount photos & videos';
  }

  @override
  String renameSuccess(Object itemName) {
    return 'Successfully renamed $itemName';
  }

  @override
  String addToFavoriteSuccess(Object itemName) {
    return 'Successfully added $itemName to favorites';
  }

  @override
  String removeFromFavoriteSuccess(Object itemName) {
    return 'Successfully removed $itemName from favorites';
  }

  @override
  String downloading(Object fileName) {
    return 'Downloading $fileName...';
  }

  @override
  String get fileDownloadedSuccess =>
      'File downloaded successfully to Downloads folder';

  @override
  String get errorControllerNotAvailable =>
      'Controller not available. Please try again.';

  @override
  String get errorFileDeletionFailed =>
      'Failed to delete file. Please try again.';

  @override
  String get errorFileUrlNotAvailable =>
      'File URL not available. Cannot download.';

  @override
  String get errorDownloadsDirectoryAccess =>
      'Cannot access downloads directory';

  @override
  String get errorDownloadFailed =>
      'Download failed. Please check your connection and try again.';

  @override
  String get successFileSharing => 'File shared successfully';

  @override
  String get errorMediaItemNotFound =>
      'Media item not found. Please try again.';

  @override
  String get errorFolderDeleteNoController =>
      'Unable to delete folder - controller not available';

  @override
  String get errorFolderDeleteFailed =>
      'Failed to delete folder. Please try again.';

  @override
  String get renameFolder => 'Rename Folder';

  @override
  String get renameFile => 'Rename File';

  @override
  String get enterFolderName => 'Enter folder name';

  @override
  String get enterFileName => 'Enter file name';

  @override
  String get validationErrorNameEmpty => 'Name cannot be empty';

  @override
  String get errorFolderRenameFailed => 'Failed to rename folder';

  @override
  String get successFolderRenamed => 'Folder renamed successfully';

  @override
  String get folderNameUnchanged => 'Folder name is same as current name';

  @override
  String get fileNameUnchanged => 'File name is same as current name';

  @override
  String get exitConfirmationMessage => 'Do you really want to exit?';

  @override
  String get yesExit => 'Yes, Exit';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get deleteDefaultMessage =>
      'Are you sure you want to delete this item?';

  @override
  String get yesDelete => 'Yes, Delete';

  @override
  String get createFolder => 'Create Folder';

  @override
  String get enterFolderDescription => 'Enter folder description (optional)';

  @override
  String get create => 'Create';

  @override
  String get validationErrorFolderNameEmpty => 'Folder name cannot be empty';

  @override
  String get errorFolderCreationFailed => 'Failed to create folder';

  @override
  String get successFolderCreated => 'Folder created successfully';

  @override
  String get activityHistory => 'Activity History';

  @override
  String get activities => 'Activities';

  @override
  String get noActivitiesFound => 'No activities found';

  @override
  String get refreshActivities => 'Refresh Activities';

  @override
  String get unknownActivity => 'Unknown activity';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(Object count) {
    return '${count}m ago';
  }

  @override
  String hoursAgo(Object count) {
    return '${count}h ago';
  }

  @override
  String daysAgo(Object count) {
    return '${count}d ago';
  }

  @override
  String get failedToFetchActivityHistory => 'Failed to fetch activity history';

  @override
  String activityErrorMessage(Object error) {
    return 'Failed to fetch activity history: $error';
  }

  @override
  String get activityLoading => 'Loading activities...';

  @override
  String get storageLimitReached => 'Storage Limit Reached!';

  @override
  String get storageLimitReachedMessage =>
      'Your 2GB storage limit is full. Please delete some files to upload more.';

  @override
  String get storageWarning => 'Storage Warning!';

  @override
  String storageWarningMessage(Object remainingGB) {
    return 'Your storage is almost full. Only $remainingGB GB remaining.';
  }

  @override
  String get fileTooLarge => 'File Too Large!';

  @override
  String fileTooLargeMessage(
      Object fileName, Object fileSizeMB, Object remainingGB) {
    return '\"$fileName\" ($fileSizeMB MB) cannot be uploaded. Only $remainingGB GB space remaining.';
  }

  @override
  String get invalidStorageDataFormat =>
      'Invalid storage data format from server';

  @override
  String failedToParseStorageData(Object error) {
    return 'Failed to parse storage data: $error';
  }

  @override
  String failedToFetchStorageData(Object error) {
    return 'Failed to fetch storage data: $error';
  }

  @override
  String get contactsAccessRequired =>
      'Contacts access is required to load your contacts';

  @override
  String failedToLoadContacts(Object error) {
    return 'Failed to load contacts: $error';
  }

  @override
  String get folderSuccess => 'Folder success';

  @override
  String get folderError => 'Folder error';

  @override
  String uploadProgress(Object percent) {
    return 'Upload... $percent%';
  }

  @override
  String get uploadComplete => 'Complete!';

  @override
  String get allComplete => 'All done!';

  @override
  String get fileUploadSuccess => 'File uploaded successfully';

  @override
  String get fileDeleteSuccess => 'File deleted successfully';

  @override
  String get uploadCancelled => 'Upload cancelled';

  @override
  String get uploadFailed => 'Upload failed';

  @override
  String get fileNotFound => 'File not found';

  @override
  String get unsupportedFileType => 'Unsupported file type';

  @override
  String get folderCreatedSuccessfully => 'Folder created successfully';

  @override
  String get folderDeletedSuccessfully => 'Folder deleted successfully';

  @override
  String get folderUpdatedSuccessfully => 'Folder updated successfully';

  @override
  String get folderNameCannotBeEmpty => 'Name required';

  @override
  String get securePinRequiredForSecureFolders => 'Pin required';

  @override
  String get fileDeletedSuccessfullyFromFolder => 'File deleted';

  @override
  String get subFolderCreatedSuccessfully => 'Sub-folder created';

  @override
  String get fileUpload => 'Upload';

  @override
  String get preparingUpload => 'Preparing...';

  @override
  String get uploadingToCloud => 'Uploading...';

  @override
  String get finalizingUpload => 'Finalizing...';

  @override
  String get uploadCompleted => 'Done!';

  @override
  String get allUploadsFailed => 'Failed';

  @override
  String failedToFetchFolders(Object error) {
    return 'Fetch failed: $error';
  }

  @override
  String failedToFetchFolderContents(Object error) {
    return 'Load failed: $error';
  }

  @override
  String failedToCreateFolder(Object error) {
    return 'Create failed: $error';
  }

  @override
  String failedToDeleteFolder(Object error) {
    return 'Delete failed: $error';
  }

  @override
  String failedToUpdateFolder(Object error) {
    return 'Update failed: $error';
  }

  @override
  String failedToDeleteFileFromFolder(Object error) {
    return 'Delete failed: $error';
  }

  @override
  String failedToCreateSubFolder(Object error) {
    return 'Create failed: $error';
  }

  @override
  String uploadingFile(Object fileName) {
    return '$fileName...';
  }

  @override
  String uploadingFiles(Object count) {
    return '$count files...';
  }

  @override
  String uploadingProgress(Object percent) {
    return '$percent%';
  }

  @override
  String preparingFiles(Object count) {
    return 'Prep $count...';
  }

  @override
  String uploadingMultipleProgress(Object completed, Object total) {
    return '$completed/$total';
  }

  @override
  String processingComplete(Object completed, Object total) {
    return 'Done $completed/$total';
  }

  @override
  String allFilesUploadedSuccessfully(Object count) {
    return '$count uploaded';
  }

  @override
  String partialUploadSuccess(Object completed, Object failed) {
    return '$completed ok, $failed fail';
  }

  @override
  String allFilesUploadFailedMessage(Object count) {
    return '$count failed';
  }

  @override
  String partialUploadFailedMessage(Object failed) {
    return '$failed failed';
  }

  @override
  String get uploadSummary => 'Upload Summary';

  @override
  String get successfullyUploaded => 'Successfully uploaded';

  @override
  String get failedToUpload => 'Failed to upload';

  @override
  String get alreadyExistsSkipped => 'Skipped - File already uploaded';

  @override
  String get error_folder_delete_failed => 'Failed to delete folder';

  @override
  String get noFileToDownload => 'No file to download';

  @override
  String get permissionDenied => 'Permission Denied';

  @override
  String get storagePermissionRequired => 'Storage Permission Required';

  @override
  String failedToDownloadFile(Object error) {
    return 'Failed to download file: $error';
  }

  @override
  String downloadComplete(Object fileName, Object location) {
    return 'Download Complete: $fileName\nSaved to: $location';
  }

  @override
  String get shareLinkNotFound => 'Share link not found or expired';

  @override
  String get shareLinkExpired => 'Share link has expired';

  @override
  String get notAuthorizedToAccess =>
      'You are not authorized to access this resource';

  @override
  String get serverErrorOccurred => 'Server error occurred';

  @override
  String get sharedResourceExpired => 'This shared resource has expired';

  @override
  String failedToLoadSharedResource(Object error) {
    return 'Failed to load shared resource: $error';
  }

  @override
  String get fileIdRequiredToGenerateShareLink =>
      'File ID is required to generate share link';

  @override
  String get pleaseSelectAtLeastOneContact =>
      'Please select at least one contact to share with';

  @override
  String successfullySharedFileWithContacts(
      Object contactCount, Object fileName) {
    return 'Successfully shared $fileName with $contactCount contacts';
  }

  @override
  String sharedWithContacts(Object contactCount) {
    return 'Shared with $contactCount contacts';
  }

  @override
  String get file => 'File';

  @override
  String somePhoneNumbersNotRegistered(Object phoneNumbers) {
    return 'Some phone numbers are not registered: $phoneNumbers';
  }

  @override
  String failedToGenerateShareLink(Object error) {
    return 'Failed to generate share link: $error';
  }

  @override
  String unexpectedErrorWhileSharing(Object error) {
    return 'An unexpected error occurred while sharing: $error';
  }

  @override
  String get pleaseGenerateShareLinkFirst =>
      'Please generate a share link first';

  @override
  String get shareLinkCopiedToClipboard => 'Share link copied to clipboard';

  @override
  String get failedToCopyLinkToClipboard => 'Failed to copy link to clipboard';

  @override
  String get doYouReallyWantToExit => 'Do you really want to Exit?';

  @override
  String get home => 'Home';

  @override
  String get proPlan => 'Pro Plan';

  @override
  String get anantSpaceFree => 'AnantSpace Free';

  @override
  String get anantSpacePro => 'AnantSpace Pro';

  @override
  String get yourStorage => 'Your storage';

  @override
  String get percentUsed => '% Used';

  @override
  String get buyStorage => 'Buy storage';

  @override
  String get upgradePlan => 'Upgrade plan';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get privacyPolicyTerms => 'Privacy policy & Terms of usage';

  @override
  String get rateUs => 'Rate us';

  @override
  String get fileIdRequiredToShare => 'File ID is required to share';

  @override
  String get shareLinkGenerated => 'Share Link Generated';

  @override
  String fileSharedWithContacts(Object contactCount, Object fileName) {
    return 'Your file \"$fileName\" has been shared with $contactCount contact(s).';
  }

  @override
  String get shareLink => 'Share Link:';

  @override
  String get shareScreen => 'Share screen';

  @override
  String get selectContacts => 'Select Contacts';

  @override
  String get selectedContacts => 'Selected Contacts';

  @override
  String get searchContactsHint => 'Search contacts...';

  @override
  String get shareButton => 'Share';

  @override
  String get searchContacts => 'Search contacts...';

  @override
  String get validating => 'Validating...';

  @override
  String shareWithCount(Object count) {
    return 'Share ($count)';
  }

  @override
  String contactsSelected(Object count) {
    return '$count contacts selected';
  }

  @override
  String get pleaseSelectContactsToShare =>
      'Please select at least one contact to share with';

  @override
  String get selectedContactsNoValidPhones =>
      'Selected contacts do not have valid phone numbers';

  @override
  String invalidPhoneNumbersNotRegistered(Object phoneNumbers) {
    return 'Invalid phone numbers: $phoneNumbers\n\nThese contacts are not registered. Please remove them and try again.';
  }

  @override
  String failedToValidateContacts(Object error) {
    return 'Failed to validate contacts: $error';
  }

  @override
  String get selectDestination => 'Select Destination';

  @override
  String get noFoldersHere => 'No Folders Here';

  @override
  String get noSubfoldersDescription =>
      'This location has no subfolders. You can still move items to this location.';

  @override
  String get cantMove => 'Can\'t move';

  @override
  String get moving => 'Moving...';

  @override
  String get moveHere => 'Move Here';

  @override
  String get pleaseSelectDestinationFolder =>
      'Please select a destination folder to move your files.';

  @override
  String get selectedItems => 'Selected Items';

  @override
  String get myFiles => 'My Files';

  @override
  String get confirmMove => 'Confirm move';

  @override
  String get areYouSureMoveFiles =>
      'Are you sure you want to move these files?';

  @override
  String get unknownFolder => 'Unknown Folder';

  @override
  String get scanDocument => 'Scan document';

  @override
  String documentCounter(Object current, Object total) {
    return 'Document $current of $total';
  }

  @override
  String get savingPdf => 'Saving PDF...';

  @override
  String get savePdf => 'Save PDF';

  @override
  String get failedToUploadPdf => 'Failed to upload PDF';

  @override
  String get enterPdfName => 'Enter PDF Name';

  @override
  String get enterPdfNameHint => 'Enter PDF Name';

  @override
  String get pleaseEnterPdfName => 'Please enter a PDF name';

  @override
  String get securitySetting => 'Security Setting';

  @override
  String get biometricLogin => 'Biometric login';

  @override
  String get biometricLoginDescription =>
      'If you enable biometric login your phone\'s biometric is going to use directly to open the app.';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get securePin => 'Secure pin';

  @override
  String get changePin => 'Change pin';

  @override
  String get show => 'Show';

  @override
  String get hide => 'Hide';

  @override
  String get changeSecurityPin => 'Change security pin';

  @override
  String get changeSecurityPinDescription =>
      'Change security pin & use these whenever you access a secure folder';

  @override
  String get sharedFile => 'Shared File';

  @override
  String get downloadFile => 'Download File';

  @override
  String get downloadEntireFolder => 'Download Entire Folder';

  @override
  String get sharedByMe => 'Shared by Me';

  @override
  String get sharedWithMe => 'Shared with Me';

  @override
  String get filesOnly => 'Files Only';

  @override
  String get foldersOnly => 'Folders Only';

  @override
  String get dateShared => 'Date Shared';

  @override
  String get newestFirst => 'Newest First';

  @override
  String get oldestFirst => 'Oldest First';

  @override
  String get order => 'Order';

  @override
  String get sharedOn => 'Shared on';

  @override
  String get sharedWith => 'Shared with';

  @override
  String get sharedBy => 'Shared by';

  @override
  String get otherPeople => 'other people';

  @override
  String sharedWithOtherPeople(String count) {
    return 'Shared with $count other people';
  }

  @override
  String get stopSharing => 'Stop Sharing';

  @override
  String get unknown => 'Unknown';

  @override
  String get manageShare => 'Manage Share';

  @override
  String get viewRecipients => 'View Recipients';

  @override
  String get seeWhoHasAccess => 'See who has access';

  @override
  String get manageRecipientAccess => 'Manage recipient access';

  @override
  String get stopSharingConfirmTitle => 'Stop Sharing?';

  @override
  String get stopSharingConfirmMessage =>
      'This will revoke access for all recipients. This action cannot be undone.';

  @override
  String get removeFromListTitle => 'Remove from Your List?';

  @override
  String removeFromListMessage(String itemName) {
    return 'You won\'t be able to access \"$itemName\" anymore.';
  }

  @override
  String get stopSharingTitle => 'Stop Sharing?';

  @override
  String stopSharingMessage(String name) {
    return 'This will revoke access for $name.';
  }

  @override
  String get stopSharingWithAllTitle => 'Stop Sharing with All?';

  @override
  String stopSharingWithAllMessage(int count) {
    return 'This will revoke access for all $count recipients.';
  }

  @override
  String get yesRemoveAll => 'Yes, Remove All';

  @override
  String get shareIdNotFound => 'Share ID not found';

  @override
  String get shareIdNotFoundOrEmpty => 'Share ID not found or empty';

  @override
  String get accessRevokedForAll => 'Access revoked for all recipients';

  @override
  String get removedFromYourList => 'Removed from your list';

  @override
  String failedToRevokeAccess(String error) {
    return 'Failed to revoke access: $error';
  }

  @override
  String failedToRemove(String error) {
    return 'Failed to remove: $error';
  }

  @override
  String get fileInfoNotAvailable => 'File information not available';

  @override
  String get downloadUrlNotAvailable => 'Download URL not available';

  @override
  String get failedToStartDownloadService => 'Failed to start download service';

  @override
  String failedToStartDownload(String error) {
    return 'Failed to start download: $error';
  }

  @override
  String get checkNotificationTray =>
      'Check notification tray for download progress';

  @override
  String failedToLoadRecipients(String error) {
    return 'Failed to load recipients: $error';
  }

  @override
  String get noRecipientsFound => 'No recipients found';

  @override
  String get linkCopiedToClipboard => 'Link copied to clipboard';

  @override
  String get modified => 'Modified';

  @override
  String get notModified => 'Not modified';

  @override
  String get folder => 'Folder';

  @override
  String get item => 'Item';

  @override
  String get noImagesFound => 'No images found';

  @override
  String get noImagesRootDescription =>
      'Upload your photos and images to see them here';

  @override
  String get noImagesFolderDescription =>
      'This folder doesn\'t contain any images';

  @override
  String get noVideosFound => 'No videos found';

  @override
  String get noVideosRootDescription => 'Upload your videos to see them here';

  @override
  String get noVideosFolderDescription =>
      'This folder doesn\'t contain any videos';

  @override
  String get noDocumentsFound => 'No documents found';

  @override
  String get noDocumentsRootDescription =>
      'Upload your documents to see them here';

  @override
  String get noDocumentsFolderDescription =>
      'This folder doesn\'t contain any documents';

  @override
  String get noAudioFound => 'No audio found';

  @override
  String get noAudioRootDescription =>
      'Upload your audio files to see them here';

  @override
  String get noAudioFolderDescription =>
      'This folder doesn\'t contain any audio files';

  @override
  String get noOtherFilesFound => 'No other files found';

  @override
  String get noOtherFilesRootDescription => 'Upload files to see them here';

  @override
  String get noOtherFilesFolderDescription =>
      'This folder doesn\'t contain any other files';

  @override
  String get noFoldersFound => 'No folders found';

  @override
  String get noFoldersRootDescription =>
      'Create folders to organize your files';

  @override
  String get noFoldersFolderDescription =>
      'This location doesn\'t contain any folders';

  @override
  String get noContactsSelected => 'No contacts selected';

  @override
  String get noContactsSelectedDescription =>
      'Select contacts to share files with them';

  @override
  String get noContactsFound => 'No contacts found';

  @override
  String get noContactsFoundDescription =>
      'No contacts available in your device';

  @override
  String get searchWithContacts => 'Search with contacts';

  @override
  String contactsCount(int loaded, int total) {
    return '$loaded / $total contacts';
  }

  @override
  String totalContacts(int count) {
    return '$count contacts';
  }

  @override
  String searchResultsFound(int count, String query) {
    return '$count search results found for \'$query\'';
  }

  @override
  String get folderNotShared => 'Folder not shared';

  @override
  String get folderNotSharedDescription =>
      'This folder hasn\'t been shared with anyone yet';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get noResultsFoundDescription => 'Try different keywords or filters';

  @override
  String get nothingToShow => 'Nothing to show';

  @override
  String get nothingToShowRootDescription =>
      'Upload files and folders to get started';

  @override
  String get nothingToShowFolderDescription => 'This folder is empty';

  @override
  String get noSharedByMeFiles => 'No shared files';

  @override
  String get noSharedByMeFilesDescription =>
      'Files and folders you share with others will appear here';

  @override
  String get noSharedWithMeFiles => 'No shared files';

  @override
  String get noSharedWithMeFilesDescription =>
      'Files and folders shared with you will appear here';

  @override
  String get whoCanAccess => 'Who can access';

  @override
  String get galleryPermissionRequired => 'Gallery Permission Required';

  @override
  String get cameraPermissionRequired => 'Camera Permission Required';

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get galleryPermissionDescription =>
      'To select and crop photos,\nplease grant access to your gallery';

  @override
  String get cameraPermissionDescription =>
      'To take photos,\nplease grant camera access';

  @override
  String get storagePermissionDescription =>
      'To save files,\nplease grant storage access';

  @override
  String get permissionDescription => 'Please grant the required permission';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get limitedAccessDetected => 'Limited Access Detected';

  @override
  String get grantFullPermissionPhotos =>
      'Grant full permission to access all photos';

  @override
  String get grantFullPermissionAudio =>
      'Grant full permission to access all audio';

  @override
  String get notNow => 'Not Now';

  @override
  String get selectAlbum => 'Select Album';

  @override
  String get selectAll => 'Select All';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get selectAudio => 'Select Audio';

  @override
  String get addBusinessShopDetails =>
      'Add your business/shop details and\npersonal details';

  @override
  String get businessShopName => 'Business / Shop Name';

  @override
  String get locationAddress => 'Location / Address';

  @override
  String get registeredMobileNumber => 'Registered Mobile Number';

  @override
  String get ownerMasterMobileNumber => 'Owner (Master Mobile Number)';

  @override
  String get confirmFinish => 'Confirm & Finish';

  @override
  String get pleaseEnterValidMobileNumber =>
      'Please enter a valid 10-digit mobile number';

  @override
  String get pleaseEnterYourName => 'Please enter your name';

  @override
  String get pleaseEnterBusinessShopName =>
      'Please enter business/shop name';

  @override
  String get pleaseEnterLocationAddress => 'Please enter location/address';

  @override
  String get pleaseVerifyOwnerMobileNumber =>
      'Please verify owner mobile number';

  @override
  String get detailsSavedSuccessfully => 'Details saved successfully';

  @override
  String get failedToSaveDetails => 'Failed to save details';

  @override
  String get inSeconds => ' in {seconds} seconds';
}
