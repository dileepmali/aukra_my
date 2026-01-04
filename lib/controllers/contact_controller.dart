import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../core/untils/error_types.dart';
import '../models/contact_model.dart';
import '../app/localizations/l10n/app_localizations.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:azlistview/azlistview.dart';
import '../core/untils/string_validator.dart';
import '../core/services/error_service.dart';
import '../core/services/contact_cache_service.dart';

class ContactController extends GetxController {
  // Observable variables
  final RxList<ContactItem> contacts = <ContactItem>[].obs;
  final RxList<ContactItem> filteredContacts = <ContactItem>[].obs;
  final RxList<ContactItem> selectedContacts = <ContactItem>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSelectionMode = false.obs;
  final RxBool isNavigatingToShare = false.obs; // ✅ NEW: Track navigation loading state
  final RxSet<String> contactsWithCheckboxVisible = <String>{}.obs; // Track by phone number instead of index
  final RxBool isPermissionDenied = false.obs; // ✅ NEW: Track permission denied state

  // Pagination variables
  final RxInt currentPage = 0.obs;
  final RxBool hasMoreContacts = true.obs;
  final RxBool isLoadingMore = false.obs;
  static const int contactsPerPage = 5000; // ✅ ULTRA FAST: Load 5000 contacts at once - maximum speed
  List<Contact> allDeviceContacts = [];

  // ✅ OPTIMIZED: Full contact list for instant search
  final RxList<ContactItem> allContactItems = <ContactItem>[].obs;
  final RxBool isSearching = false.obs;

  // ✅ PROGRESSIVE: Loading progress and UX improvements
  final RxDouble loadingProgress = 0.0.obs;
  final RxString loadingStatus = ''.obs;
  final RxInt processedContactCount = 0.obs;
  final RxInt totalContactCount = 0.obs;

  // Search controller
  final TextEditingController searchController = TextEditingController();

  // Callbacks from arguments
  Function(List<ContactItem>)? onContactsSelected;
  Function()? onShareClicked;

  // Store the original fileId to persist across back navigation
  String? originalFileId;
  Map<String, dynamic>? originalArguments;

  // ✅ CACHE: Track if contacts have been loaded once
  bool _contactsLoaded = false;

  // ✅ PUBLIC GETTER: To check if contacts are already loaded
  bool get contactsAlreadyLoaded => _contactsLoaded;

  // ✅ NEW: Incremental refresh - only fetch NEW contacts
  Future<void> refreshContacts() async {
    print("🔄 Incremental refresh triggered - fetching only NEW contacts");

    // ✅ SAVE: Preserve current search query before refresh
    final String currentSearchQuery = searchController.text.trim();
    final bool wasSearching = currentSearchQuery.isNotEmpty;

    if (wasSearching) {
      print("💾 Preserving active search query: '$currentSearchQuery'");
    }

    try {
      // ✅ Step 1: Fetch ALL device contacts to compare
      print("📱 Fetching device contacts to check for new additions...");
      List<Contact> freshDeviceContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: false,
      );

      print("📊 Previous count: ${allDeviceContacts.length}, Current count: ${freshDeviceContacts.length}");

      // ✅ Step 2: Check if there are NEW contacts
      int previousCount = allDeviceContacts.length;
      int currentCount = freshDeviceContacts.length;

      if (currentCount > previousCount) {
        // ✅ NEW CONTACTS FOUND - Process only new ones
        int newContactsCount = currentCount - previousCount;
        print("🆕 Found $newContactsCount NEW contacts - processing incrementally");

        // Get only the new contacts (assuming they're at the end)
        List<Contact> newContacts = freshDeviceContacts.sublist(previousCount);

        // Process new contacts
        List<ContactItem> newContactItems = [];
        for (Contact contact in newContacts) {
          if (contact.displayName.isNotEmpty) {
            final sanitizedName = StringValidator.sanitizeForText(contact.displayName);
            String phoneNumber = '';
            if (contact.phones.isNotEmpty) {
              phoneNumber = StringValidator.sanitizeForText(contact.phones.first.number);
            }

            final newItem = ContactItem(
              name: sanitizedName,
              phone: phoneNumber,
              initials: _getInitials(sanitizedName),
            );

            _assignSingleContactTag(newItem);
            newContactItems.add(newItem);
          }
        }

        // ✅ Add new contacts to existing list (instead of replacing)
        contacts.addAll(newContactItems);
        allContactItems.addAll(newContactItems);

        // Sort the combined list
        _assignContactTags(contacts);

        // Update device contacts list
        allDeviceContacts = freshDeviceContacts;
        totalContactCount.value = freshDeviceContacts.length;

        print("✅ Incremental refresh completed - Added $newContactsCount NEW contacts");
        print("📊 Total contacts now: ${contacts.length}");

      } else if (currentCount < previousCount) {
        // ✅ CONTACTS DELETED - Full reload needed
        print("⚠️ Contacts were deleted (${previousCount - currentCount} removed) - performing full reload");
        _contactsLoaded = false;
        contacts.clear();
        filteredContacts.clear();
        allContactItems.clear();
        allDeviceContacts.clear();
        currentPage.value = 0;
        hasMoreContacts.value = true;
        await loadContacts();

      } else {
        // ✅ NO CHANGES - Just refresh the display
        print("✅ No new contacts found - keeping existing ${contacts.length} contacts");
        filteredContacts.value = List.from(contacts);
      }

      // ✅ RE-APPLY: If user had a search query active, re-run the search
      if (wasSearching) {
        print("🔍 Re-applying search query: '$currentSearchQuery'");
        searchController.text = currentSearchQuery;
        print("✅ Search re-applied - ${filteredContacts.length} results found for '$currentSearchQuery'");
      }

    } catch (e) {
      print("❌ Error during incremental refresh: $e");
      // Fallback to full reload on error
      _contactsLoaded = false;
      contacts.clear();
      filteredContacts.clear();
      allContactItems.clear();
      allDeviceContacts.clear();
      await loadContacts();
    }
  }

  // ✅ PUBLIC METHOD: Clear selection state for new file sharing
  void clearSelectionState() {
    print("🧹 ContactController: Clearing selection state for new file/folder");
    selectedContacts.clear();
    contactsWithCheckboxVisible.clear();
    isSelectionMode.value = false;
    searchController.clear();

    // Reset search state
    isSearching.value = false;
    filteredContacts.value = List.from(contacts);

    print("✅ ContactController: Selection state cleared successfully");
  }

  @override
  void onInit() {
    super.onInit();

    print("🔥🔥🔥 ContactController.onInit() CALLED 🔥🔥🔥");
    print("🔥 _contactsLoaded: $_contactsLoaded");
    print("🔥 contacts.length: ${contacts.length}");

    // Get arguments from navigation
    final arguments = Get.arguments as Map<String, dynamic>? ?? {};
    print("🔥 Arguments received: $arguments");

    // Process arguments without reloading contacts
    _processArguments(arguments);

    // ✅ OPTIMIZE: Load contacts only once on first initialization
    if (!_contactsLoaded) {
      print("📱 ContactController: First time initialization - loading contacts from device");
      print("🔥 Calling loadContacts() from onInit()");
      loadContacts();

      // ✅ FIX: Add listener only once on first load
      searchController.addListener(filterContacts);
      // ✅ FIX: Don't set _contactsLoaded here - set it after successful load
    } else {
      print("✅ ContactController: Reusing existing contacts - no reload needed");
      print("🔥 Skipping loadContacts() - already loaded ${contacts.length} contacts");

      // ✅ FIX: Set isLoading to false immediately when reusing cached contacts
      isLoading.value = false;

      // ✅ FIX: Refresh filtered contacts from cache instead of reloading
      filterContacts();
    }
  }

  // ✅ NEW METHOD: Update arguments without reloading contacts
  void updateArguments(Map<String, dynamic> arguments) {
    print("🔄 ContactController: Updating arguments without reloading contacts");
    print("📊 Current contacts count: ${contacts.length}");

    _processArguments(arguments);
  }

  // ✅ HELPER: Process arguments (extracted for reuse)
  void _processArguments(Map<String, dynamic> arguments) {
    // Update callbacks
    onContactsSelected = arguments['onContactsSelected'];
    onShareClicked = arguments['onShareClicked'];

    // ✅ CLEAR SELECTION: Clear selection if this is a new file/folder (different fileId)
    final newFileId = arguments['fileId']?.toString();
    if (newFileId != null && newFileId != originalFileId) {
      print("🆕 ContactController: New file detected (${originalFileId} → $newFileId), clearing previous selection");
      clearSelectionState();
    }

    // Store original arguments including fileId for persistence
    if (arguments['fileId'] != null) {
      originalFileId = arguments['fileId'].toString();
      originalArguments = Map<String, dynamic>.from(arguments);
      print("📁 ContactController: Updated fileId to: $originalFileId");
    }

    // ✅ RESTORE: Pre-selected contacts from ShareScreen
    final preSelectedContacts = arguments['preSelectedContacts'] as List<dynamic>?;
    if (preSelectedContacts != null) {
      // ✅ FIX: Defer state updates to after build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (preSelectedContacts.isNotEmpty) {
          print("🔄 ContactController: Restoring ${preSelectedContacts.length} pre-selected contacts from ShareScreen");

          try {
            // Clear previous selections and restore new ones
            selectedContacts.clear();
            contactsWithCheckboxVisible.clear();

            final contactItems = preSelectedContacts.cast<ContactItem>();
            selectedContacts.addAll(contactItems);

            // Make checkboxes visible for pre-selected contacts
            for (final contact in contactItems) {
              contactsWithCheckboxVisible.add(contact.phone);
            }

            print("✅ ContactController: Successfully restored ${selectedContacts.length} pre-selected contacts");
          } catch (e) {
            print("❌ ContactController: Error restoring pre-selected contacts: $e");
          }
        } else {
          // ✅ FIX: If preSelectedContacts is empty (all removed in ShareScreen), clear state
          print("🧹 ContactController: No preSelectedContacts (all removed) - clearing state");
          selectedContacts.clear();
          contactsWithCheckboxVisible.clear();
          isSelectionMode.value = false;
        }
      });
    }

    // ✅ FIX: Defer selection mode state update to after build phase
    if (arguments['selectionMode'] == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Only set selection mode if we have contacts selected
        if (selectedContacts.isNotEmpty) {
          isSelectionMode.value = true;
        }
      });
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // ✅ INSTANT LOADING: Load first 100 contacts in 1 second, rest in background
  Future<void> loadContacts() async {
    // ✅ PERFORMANCE TRACKING: Start measuring time
    final loadStartTime = DateTime.now();
    final stopwatch = Stopwatch()..start();

    print("🔥 loadContacts() CALLED - INSTANT LOADING MODE");
    print("⏱️ PERFORMANCE: Load started at ${loadStartTime.toIso8601String()}");
    print("🔥 Current state - isLoading: ${isLoading.value}, _contactsLoaded: $_contactsLoaded");

    isLoading.value = true;
    currentPage.value = 0;
    contacts.clear();
    filteredContacts.clear();
    allContactItems.clear();

    try {
      // Check permission
      final permissionCheckTime = DateTime.now();
      PermissionStatus permissionStatus = await Permission.contacts.status;
      final permissionCheckDuration = DateTime.now().difference(permissionCheckTime);
      print("🔥 Current permission status: $permissionStatus");
      print("⏱️ PERFORMANCE: Permission check took ${permissionCheckDuration.inMilliseconds}ms");

      bool hasPermission = false;

      if (permissionStatus.isGranted) {
        print("✅ Permission already granted");
        hasPermission = true;
      } else if (permissionStatus.isDenied) {
        print("⚠️ Permission denied - requesting...");
        PermissionStatus result = await Permission.contacts.request();
        print("🔥 Permission request result: $result");
        hasPermission = result.isGranted;
      } else if (permissionStatus.isPermanentlyDenied) {
        print("🚫 Permission permanently denied - need to open settings");
        hasPermission = false;
      }

      if (hasPermission) {
        isPermissionDenied.value = false;
        print("✅ Permission GRANTED - Loading contacts");

        // ✅ CACHE CHECK: Try to load from cache first (ULTRA FAST)
        final cacheValid = await ContactCacheService.isCacheValid();

        if (cacheValid) {
          // ✅ CACHE HIT: Load from cache (under 500ms)
          print("⚡ CACHE HIT: Loading contacts from cache...");
          final cacheLoadStart = DateTime.now();

          List<ContactItem> cachedContacts = await ContactCacheService.loadFromCache();

          if (cachedContacts.isNotEmpty) {
            final cacheLoadDuration = DateTime.now().difference(cacheLoadStart);
            print("⚡ INSTANT: Loaded ${cachedContacts.length} contacts from cache in ${cacheLoadDuration.inMilliseconds}ms");

            // Convert cached contacts to device contacts format (for compatibility)
            allDeviceContacts = [];
            for (var contact in cachedContacts) {
              allDeviceContacts.add(Contact(
                id: contact.phone.isNotEmpty ? contact.phone : contact.name,
                displayName: contact.name,
              ));
            }

            // Add to contacts list directly
            contacts.addAll(cachedContacts);
            filteredContacts.value = List.from(contacts);
            totalContactCount.value = cachedContacts.length;

            // Hide loading immediately
            isLoading.value = false;
            _contactsLoaded = true;

            print("✅ CACHE LOADED: Screen interactive in ${cacheLoadDuration.inMilliseconds}ms");

            // ✅ BACKGROUND REFRESH: Update cache in background (don't block UI)
            _refreshCacheInBackground();

            return; // Exit early - cache loaded successfully
          }
        }

        // ✅ CACHE MISS: Load from device (3-8 seconds)
        print("📱 CACHE MISS: Loading contacts from device...");
        final fetchStartTime = DateTime.now();
        print("⏱️ PERFORMANCE: Starting device contact fetch at ${fetchStartTime.toIso8601String()}");

        // ✅ OPTIMIZED: Load contacts with full properties (no better alternative)
        allDeviceContacts = await FlutterContacts.getContacts(
          withProperties: true,  // Need phone numbers
          withThumbnail: false,  // Skip thumbnails
          withPhoto: false,      // Skip photos
        );

        final fetchEndTime = DateTime.now();
        final fetchDuration = fetchEndTime.difference(fetchStartTime);
        print("⏱️ PERFORMANCE: Device contact fetch completed in ${fetchDuration.inMilliseconds}ms");
        print("⏱️ PERFORMANCE: Fetch ended at ${fetchEndTime.toIso8601String()}");

        totalContactCount.value = allDeviceContacts.length;
        print("📱 Fetched ${allDeviceContacts.length} contacts from device");

        // ✅ PERFORMANCE: Measure first batch processing time
        final batchProcessStartTime = DateTime.now();
        print("⏱️ PERFORMANCE: Starting first batch processing at ${batchProcessStartTime.toIso8601String()}");

        // Load first batch
        await _loadContactChunk();

        final batchProcessEndTime = DateTime.now();
        final batchProcessDuration = batchProcessEndTime.difference(batchProcessStartTime);
        print("⏱️ PERFORMANCE: First batch processed in ${batchProcessDuration.inMilliseconds}ms");
        print("⏱️ PERFORMANCE: Batch processing ended at ${batchProcessEndTime.toIso8601String()}");

        // ✅ PERFORMANCE: Measure shimmer hiding time (when UI becomes interactive)
        final shimmerHideTime = DateTime.now();
        final totalTimeUntilShimmerHide = shimmerHideTime.difference(loadStartTime);

        // Hide loading shimmer after first batch
        isLoading.value = false;
        _contactsLoaded = true;

        print("🎯 PERFORMANCE SUMMARY:");
        print("   ⏱️ Total time from start to shimmer hide: ${totalTimeUntilShimmerHide.inMilliseconds}ms");
        print("   ⏱️ Permission check: ${permissionCheckDuration.inMilliseconds}ms");
        print("   ⏱️ Device contact fetch: ${fetchDuration.inMilliseconds}ms");
        print("   ⏱️ First batch processing: ${batchProcessDuration.inMilliseconds}ms");
        print("   📊 First batch size: ${contacts.length} contacts");
        print("   📊 Total contacts: ${allDeviceContacts.length}");
        print("   🚀 Shimmer hidden at: ${shimmerHideTime.toIso8601String()}");
        print("   ✅ Screen is now INTERACTIVE and RESPONSIVE");

        // Auto-load remaining contacts in background
        if (hasMoreContacts.value) {
          print("🔄 Starting background loading of remaining ${allDeviceContacts.length - contacts.length} contacts...");
          _autoLoadAllRemainingContacts();
        }

        // ✅ INSTANT: Skip search index building - search directly from allDeviceContacts
        // Search will be instant anyway using filterContacts() method
        print("🚀 Skipping search index - using direct search for instant results");

        // ✅ SAVE TO CACHE: Save contacts for next time (background task)
        print("💾 Saving contacts to cache for next time...");
        _saveToCacheInBackground();

        final completionTime = DateTime.now();
        final totalLoadTime = completionTime.difference(loadStartTime);
        print("✅ Contact loading completed: ${contacts.length} contacts loaded");
        print("⏱️ PERFORMANCE: Total execution time: ${totalLoadTime.inMilliseconds}ms");

      } else {
        isLoading.value = false;
        isPermissionDenied.value = true;
        _contactsLoaded = false;
        print("❌ Permission DENIED - cannot load contacts");

        if (permissionStatus != PermissionStatus.permanentlyDenied) {
          final context = Get.context;
          final l10n = context != null ? AppLocalizations.of(context) : null;
          AdvancedErrorService.showError(
            l10n?.contactsAccessRequired ?? 'Contacts access is required to load your contacts',
            severity: ErrorSeverity.medium,
            category: ErrorCategory.permission,
          );
        }
      }
    } catch (e, stackTrace) {
      isLoading.value = false;
      _contactsLoaded = false;
      print("❌ Error loading contacts: $e");

      final context = Get.context;
      final l10n = context != null ? AppLocalizations.of(context) : null;
      AdvancedErrorService.showError(
        l10n?.failedToLoadContacts(e.toString()) ?? 'Failed to load contacts: ${e.toString()}',
        severity: ErrorSeverity.medium,
        category: ErrorCategory.general,
      );
    }
  }

  // ✅ NEW: Load contacts silently without showing shimmer (for pull-to-refresh)
  Future<void> _loadContactsSilently() async {
    print("🔄 _loadContactsSilently() CALLED - Loading without shimmer");

    // ✅ DON'T set isLoading = true, to avoid showing shimmer
    currentPage.value = 0;

    try {
      // Check permission status
      PermissionStatus permissionStatus = await Permission.contacts.status;

      if (permissionStatus.isGranted) {
        isPermissionDenied.value = false;

        // Fetch contacts from device
        allDeviceContacts = await FlutterContacts.getContacts(
          withProperties: true,
          withThumbnail: false,
        );

        totalContactCount.value = allDeviceContacts.length;

        // Load first batch
        await _loadContactChunk();

        // Auto-load remaining contacts in background
        if (hasMoreContacts.value) {
          _autoLoadAllRemainingContacts();
        }

        // Build search index for large lists
        if (allDeviceContacts.length > 500) {
          _buildSearchIndexProgressively();
        } else {
          await _loadAllContactItems();
        }

        // Set contacts loaded flag
        _contactsLoaded = true;

        print("✅ Silent refresh completed: ${contacts.length} contacts loaded");
      } else {
        isPermissionDenied.value = true;
        _contactsLoaded = false;
      }
    } catch (e) {
      print("❌ Error in silent contact loading: $e");
      _contactsLoaded = false;
    }
  }

  // Load a chunk of contacts (pagination)
  Future<void> _loadContactChunk() async {
    final startIndex = currentPage.value * contactsPerPage;
    final endIndex = (startIndex + contactsPerPage).clamp(0, allDeviceContacts.length);

    if (startIndex >= allDeviceContacts.length) {
      hasMoreContacts.value = false;
      return;
    }

    // ✅ INSTANT LOADING: Process all contacts at once without delays
    List<ContactItem> newContacts = [];

    // Process all contacts in the chunk directly
    for (int i = startIndex; i < endIndex; i++) {
      final contact = allDeviceContacts[i];

      if (contact.displayName.isNotEmpty) {
        // ✅ FIX: Sanitize contact name to prevent UTF-16 errors
        final sanitizedName = StringValidator.sanitizeForText(contact.displayName);

        String phoneNumber = '';
        if (contact.phones.isNotEmpty) {
          // ✅ FIX: Sanitize phone number as well
          phoneNumber = StringValidator.sanitizeForText(contact.phones.first.number);
        }

        newContacts.add(ContactItem(
          name: sanitizedName,
          phone: phoneNumber,
          initials: _getInitials(sanitizedName),
        ));
      }
    }

    // ✅ FAST: Assign tags inline without sorting (sort later)
    for (var contact in newContacts) {
      _assignSingleContactTag(contact);
    }

    // Add new contacts to the list
    contacts.addAll(newContacts);

    // ✅ INSTANT: Only sort once at the end, not for every batch
    if (!hasMoreContacts.value || endIndex >= allDeviceContacts.length) {
      SuspensionUtil.sortListBySuspensionTag(contacts);
      SuspensionUtil.setShowSuspensionStatus(contacts);
    }

    filteredContacts.value = List.from(contacts);

    // Update pagination state
    currentPage.value++;
    hasMoreContacts.value = endIndex < allDeviceContacts.length;

    print("📋 Loaded chunk: ${newContacts.length} contacts (Total: ${contacts.length})");
  }

  // Load more contacts (for infinite scroll)
  Future<void> loadMoreContacts() async {
    if (isLoadingMore.value || !hasMoreContacts.value) return;

    isLoadingMore.value = true;
    await _loadContactChunk();
    isLoadingMore.value = false;
  }

  // ✅ SCALABLE: Handle unlimited contacts (5K, 10K, 20K+) dynamically with robust error handling
  Future<void> _loadAllContactItems() async {
    allContactItems.clear();

    final totalContacts = allDeviceContacts.length;
    print("📱 Processing $totalContacts contacts (unlimited scale support)...");

    // ✅ PROGRESSIVE: Initialize progress tracking for UX
    totalContactCount.value = totalContacts;
    processedContactCount.value = 0;
    loadingProgress.value = 0.0;
    loadingStatus.value = _getLoadingStatusMessage(totalContacts);

    // ✅ DYNAMIC: Calculate optimal batch size based on device performance and contact count
    int batchSize = _calculateOptimalBatchSize(totalContacts);
    int delayMs = _calculateOptimalDelay(totalContacts);

    print("📊 Auto-optimized: batch=$batchSize, delay=${delayMs}ms for $totalContacts contacts");

    // ✅ ROBUST: Error handling and progress tracking for large contact lists
    int processedContacts = 0;
    int failedContacts = 0;
    List<String> errorDetails = [];

    try {
      for (int i = 0; i < allDeviceContacts.length; i += batchSize) {
        try {
          final batchEnd = (i + batchSize).clamp(0, allDeviceContacts.length);
          final batch = allDeviceContacts.sublist(i, batchEnd);

          List<ContactItem> batchItems = [];

          // Process each contact in the batch with individual error handling
          for (int contactIndex = 0; contactIndex < batch.length; contactIndex++) {
            try {
              final contact = batch[contactIndex];

              // ✅ SAFE: Validate contact data before processing
              if (_isValidContact(contact)) {
                final contactName = StringValidator.sanitizeForText(contact.displayName);
                String phoneNumber = '';

                if (contact.phones.isNotEmpty) {
                  phoneNumber = StringValidator.sanitizeForText(contact.phones.first.number);
                }

                final contactItem = ContactItem(
                  name: contactName,
                  phone: phoneNumber,
                  initials: _getInitials(contactName),
                );

                // ✅ AzListView: Assign tag index
                _assignSingleContactTag(contactItem);

                batchItems.add(contactItem);
                processedContacts++;
              } else {
                failedContacts++;
                if (kDebugMode) {
                  print("⚠️ Skipped invalid contact at index ${i + contactIndex}");
                }
              }
            } catch (contactError, contactStackTrace) {
              failedContacts++;
              final errorMsg = "Contact processing error at index ${i + contactIndex}: $contactError";
              errorDetails.add(errorMsg);

              if (kDebugMode) {
                print("❌ $errorMsg");
              }

            }
          }

          // Add successfully processed batch items
          if (batchItems.isNotEmpty) {
            allContactItems.addAll(batchItems);
          }

          // ✅ PROGRESS: Update real-time progress for UX
          processedContactCount.value = processedContacts;
          final progressPercent = ((i + batchSize) / allDeviceContacts.length * 100).clamp(0, 100);
          loadingProgress.value = progressPercent / 100;

          // ✅ UX: Update loading status based on progress
          if (totalContacts > 1000) {
            loadingStatus.value = "Processing ${processedContacts} of $totalContacts contacts (${progressPercent.toStringAsFixed(0)}%)";
          } else {
            loadingStatus.value = "Loading contacts...";
          }

          print("📄 Batch ${(i ~/ batchSize) + 1}: ${batchItems.length} contacts processed (${progressPercent.toStringAsFixed(1)}% complete)");

          // ✅ DEBUG: Show sample contacts being processed (reduced logging for large lists)
          if (kDebugMode && batchItems.isNotEmpty && totalContacts < 1000) {
            for (int j = 0; j < batchItems.length.clamp(0, 2); j++) {
              final contact = batchItems[j];
              print("   Sample: '${contact.name}' (${contact.phone}) [${contact.initials}]");
            }
          }

          // ✅ NO DELAY: Process contacts instantly for maximum speed
          // Removed all delays for fastest loading

        } catch (batchError, batchStackTrace) {
          // Handle batch-level errors
          final errorMsg = "Batch processing error at batch ${i ~/ batchSize}: $batchError";
          errorDetails.add(errorMsg);
          failedContacts += batchSize; // Assume entire batch failed

          print("❌ $errorMsg");

          // Continue with next batch instead of failing completely
          continue;
        }
      }

      // ✅ COMPLETION: Final processing summary
      print("✅ Contact processing completed:");
      print("   📊 Total processed: $processedContacts contacts");
      print("   📊 Successfully loaded: ${allContactItems.length} contacts");
      print("   ⚠️ Failed/skipped: $failedContacts contacts");

      if (failedContacts > 0) {
        print("   📋 Error summary: ${errorDetails.length} different errors occurred");


      // ✅ DEBUG: Show first few converted contacts (limited for large lists)
      if (kDebugMode && allContactItems.isNotEmpty) {
        final sampleSize = totalContacts > 5000 ? 1 : 3; // Show fewer samples for very large lists
        print("📄 First $sampleSize converted contacts:");
        for (int i = 0; i < allContactItems.length.clamp(0, sampleSize); i++) {
          final contact = allContactItems[i];
          print("   ${i + 1}. '${contact.name}' (${contact.phone}) [${contact.initials}]");
        }
      }

    }
    } catch (fatalError, fatalStackTrace) {
      // Handle fatal errors that prevent any contact processing
      print("💥 FATAL: Contact processing completely failed: $fatalError");


      // Ensure we don't leave the app in a broken state
      if (allContactItems.isEmpty && allDeviceContacts.isNotEmpty) {
        // Fallback: try to load at least a few contacts with minimal processing
        await _fallbackContactLoading();
      }
    }
  }

  // ✅ SCALABLE: Dynamic batch size calculation for unlimited contacts
  int _calculateOptimalBatchSize(int totalContacts) {
    if (totalContacts <= 100) return 25;          // Small: 25 per batch
    if (totalContacts <= 500) return 50;          // Medium: 50 per batch
    if (totalContacts <= 1000) return 75;         // Large: 75 per batch
    if (totalContacts <= 2000) return 100;        // Very Large: 100 per batch
    if (totalContacts <= 5000) return 150;        // Huge: 150 per batch
    if (totalContacts <= 10000) return 200;       // Massive: 200 per batch
    if (totalContacts <= 20000) return 300;       // Enterprise: 300 per batch
    return 400;                                    // Unlimited: 400 per batch
  }

  // ✅ SCALABLE: Dynamic delay calculation to prevent UI blocking
  int _calculateOptimalDelay(int totalContacts) {
    if (totalContacts <= 100) return 5;           // Fast: 5ms delay
    if (totalContacts <= 500) return 10;          // Medium: 10ms delay
    if (totalContacts <= 1000) return 15;         // Large: 15ms delay
    if (totalContacts <= 2000) return 20;         // Very Large: 20ms delay
    if (totalContacts <= 5000) return 25;         // Huge: 25ms delay
    if (totalContacts <= 10000) return 30;        // Massive: 30ms delay
    if (totalContacts <= 20000) return 35;        // Enterprise: 35ms delay
    return 40;                                     // Unlimited: 40ms delay
  }

  // Get initials from name
  String _getInitials(String name) {
    if (name.isEmpty) return '';

    try {
      // ✅ FIX: Use characters to safely handle emojis and special UTF-16 characters
      List<String> nameParts = name.split(' ');

      if (nameParts.length >= 2) {
        // Get first character of first two words safely
        final firstWordChars = nameParts[0].characters;
        final secondWordChars = nameParts[1].characters;

        if (firstWordChars.isNotEmpty && secondWordChars.isNotEmpty) {
          return (firstWordChars.first + secondWordChars.first).toUpperCase();
        }
      }

      // Single word or fallback - get first character safely
      final nameChars = name.characters;
      if (nameChars.isNotEmpty) {
        return nameChars.first.toUpperCase();
      }

      return '';
    } catch (e) {
      // ✅ SAFETY: If any error occurs, return empty string
      if (kDebugMode) {
        print("⚠️ Error generating initials for '$name': $e");
      }
      return '';
    }
  }

  // ✅ AzListView: Assign tag index to contact list and sort alphabetically
  void _assignContactTags(List<ContactItem> contactList) {
    for (var contact in contactList) {
      _assignSingleContactTag(contact);
    }

    // ✅ Sort contacts alphabetically by tag
    SuspensionUtil.sortListBySuspensionTag(contactList);

    // ✅ Show off indexes for special characters
    SuspensionUtil.setShowSuspensionStatus(contactList);

    // Debug: Show tag distribution
    if (kDebugMode && contactList.isNotEmpty) {
      final tagSet = contactList.map((c) => c.tagIndex).toSet();
      print("📑 Assigned tags and sorted ${contactList.length} contacts");
      print("📊 Unique tags found: ${tagSet.join(', ')}");
      print("📝 First 3 contacts: ${contactList.take(3).map((c) => '${c.name}[${c.tagIndex}]').join(', ')}");
    }
  }

  // ✅ AzListView: Assign tag to single contact
  void _assignSingleContactTag(ContactItem contact) {
    String tag = '#';

    if (contact.name.isNotEmpty) {
      try {
        // ✅ FIX: Use characters property to safely handle emojis and special UTF-16 characters
        final characters = contact.name.characters;
        if (characters.isNotEmpty) {
          String firstChar = characters.first.toUpperCase();

          // Check if first character is A-Z
          if (RegExp(r'^[A-Z]$').hasMatch(firstChar)) {
            tag = firstChar;
          } else if (RegExp(r'^[0-9]$').hasMatch(firstChar)) {
            tag = '#'; // Numbers go to # section
          } else {
            tag = '#'; // Special characters and emojis go to # section
          }
        }
      } catch (e) {
        // ✅ SAFETY: If any error occurs, default to # tag
        tag = '#';
        if (kDebugMode) {
          print("⚠️ Error processing contact name '${contact.name}': $e");
        }
      }
    }

    contact.tagIndex = tag;

    // Debug log
    if (kDebugMode && tag != '#') {
      print("📝 Contact: '${contact.name}' -> Tag: '$tag'");
    }
  }

  // ✅ INSTANT: Search through ALL device contacts instantly (no waiting for loading)
  void filterContacts() {
    final query = searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      // No search query - show paginated contacts (already sorted)
      filteredContacts.value = List.from(contacts);
      isSearching.value = false;
    } else {
      // Search mode - search through ALL device contacts instantly
      isSearching.value = true;

      // Start timer to track search performance
      final stopwatch = Stopwatch()..start();

      // ✅ INSTANT SEARCH: Search directly from allDeviceContacts (no waiting for processing)
      print("🔍 Starting INSTANT search for query: '$query'");
      print("🔍 Total device contacts to search: ${allDeviceContacts.length}");

      List<ContactItem> matchedContacts = [];

      // ✅ DIRECT SEARCH: Process and search contacts on-the-fly for instant results
      for (int i = 0; i < allDeviceContacts.length; i++) {
        try {
          final contact = allDeviceContacts[i];

          // ✅ SKIP: Invalid contacts quickly
          if (contact.displayName.trim().isEmpty) continue;

          // ✅ FAST: Process contact data on-demand for search
          final contactName = StringValidator.sanitizeForText(contact.displayName).toLowerCase();
          String contactPhone = '';

          if (contact.phones.isNotEmpty) {
            contactPhone = StringValidator.sanitizeForText(contact.phones.first.number).replaceAll(RegExp(r'[^0-9]'), '');
          }

          final searchQuery = query.toLowerCase();
          final searchPhoneQuery = query.replaceAll(RegExp(r'[^0-9]'), '');

          // ✅ MULTI-CRITERIA: Search in name, words, phone, and initials
          bool nameMatch = contactName.contains(searchQuery);
          bool wordMatch = contactName.split(' ').any((word) => word.startsWith(searchQuery));
          bool phoneMatch = searchPhoneQuery.isNotEmpty && contactPhone.contains(searchPhoneQuery);

          // ✅ INITIALS: Generate initials on-demand for search
          String initials = '';
          if (contactName.isNotEmpty) {
            List<String> nameParts = contactName.split(' ');
            if (nameParts.length >= 2) {
              initials = (nameParts[0][0] + nameParts[1][0]).toLowerCase();
            } else {
              initials = contactName[0].toLowerCase();
            }
          }
          bool initialMatch = initials.contains(searchQuery);

          bool isMatch = nameMatch || wordMatch || phoneMatch || initialMatch;

          // ✅ ADD: Create ContactItem only for matched contacts (performance optimization)
          if (isMatch) {
            final matchedContact = ContactItem(
              name: StringValidator.sanitizeForText(contact.displayName),
              phone: contact.phones.isNotEmpty ? StringValidator.sanitizeForText(contact.phones.first.number) : '',
              initials: _getInitials(StringValidator.sanitizeForText(contact.displayName)),
            );

            // ✅ AzListView: Assign tag for search results
            _assignSingleContactTag(matchedContact);

            matchedContacts.add(matchedContact);

            // ✅ DEBUG: Show matches found (limited logging for performance)
            if (kDebugMode && matchedContacts.length <= 5) {
              print("✅ INSTANT MATCH ${matchedContacts.length}: '${matchedContact.name}' matches '$query'");
            }
          }

        } catch (e) {
          // ✅ SKIP: Failed contacts without stopping search
          if (kDebugMode) {
            print("⚠️ Skipped contact $i during instant search: $e");
          }
          continue;
        }
      }

      // ✅ AzListView: Sort search results alphabetically
      _assignContactTags(matchedContacts);

      filteredContacts.value = matchedContacts;

      stopwatch.stop();
      print("🔍 INSTANT search completed in ${stopwatch.elapsedMilliseconds}ms for query: '$query'");
      print("📊 Results: ${filteredContacts.length} contacts found from ${allDeviceContacts.length} total device contacts");
      print("⚡ INSTANT: Search completed without waiting for contact loading!");

      // Debug: Show first few results
      if (kDebugMode && filteredContacts.isNotEmpty) {
        print("🔍 First 3 instant results:");
        for (int i = 0; i < filteredContacts.length.clamp(0, 3); i++) {
          final contact = filteredContacts[i];
          print("   ${i + 1}. ${contact.name} (${contact.phone})");
        }
      }
    }
  }

  // Toggle contact selection (for checkbox)
  void toggleContactSelection(ContactItem contact, int index) {
    if (selectedContacts.contains(contact)) {
      selectedContacts.remove(contact);
    } else {
      selectedContacts.add(contact);
    }
  }

  // Toggle selection mode (cancel button logic)
  void toggleSelectionMode() {
    isSelectionMode.value = !isSelectionMode.value;
    if (!isSelectionMode.value) {
      selectedContacts.clear();
      contactsWithCheckboxVisible.clear();
    }
  }

  // ✅ FIXED: Enter selection mode with specific contact
  void enterSelectionModeWithContact(ContactItem contact, int index) {
    isSelectionMode.value = true;

    // Keep previously selected contacts visible (track by phone number)
    if (!contactsWithCheckboxVisible.contains(contact.phone)) {
      contactsWithCheckboxVisible.add(contact.phone);
      contactsWithCheckboxVisible.refresh(); // ✅ Force UI update
    }

    // Auto-select the clicked contact if not already
    if (!selectedContacts.contains(contact)) {
      selectedContacts.add(contact);
    }

    print("🔄 enterSelectionModeWithContact: ${contact.name}");
    print("📋 contactsWithCheckboxVisible: ${contactsWithCheckboxVisible.toList()}");
    print("📋 selectedContacts count: ${selectedContacts.length}");
  }

  // Toggle contact checkbox (for selection mode)
  void toggleContactCheckbox(ContactItem contact, int index) {
    if (selectedContacts.contains(contact)) {
      selectedContacts.remove(contact);
      contactsWithCheckboxVisible.remove(contact.phone);
      contactsWithCheckboxVisible.refresh(); // ✅ Force UI update

      // If no contacts left, exit selection mode
      if (selectedContacts.isEmpty) {
        isSelectionMode.value = false;
        contactsWithCheckboxVisible.clear();
      }
    } else {
      selectedContacts.add(contact);
      contactsWithCheckboxVisible.add(contact.phone);
      contactsWithCheckboxVisible.refresh(); // ✅ Force UI update
    }

    print("🔄 toggleContactCheckbox: ${contact.name}");
    print("📋 contactsWithCheckboxVisible: ${contactsWithCheckboxVisible.toList()}");
    print("📋 selectedContacts count: ${selectedContacts.length}");
  }

  // Share selected contacts with validation
  Future<void> shareSelectedContacts() async {
    if (selectedContacts.isEmpty) {
      // ✅ FIX: Removed Get.closeCurrentSnackbar() to prevent LateInitializationError
      // Let GetX handle snackbar lifecycle automatically
      final context = Get.context;
      final l10n = context != null ? AppLocalizations.of(context) : null;
      Get.rawSnackbar(
        message: l10n?.pleaseSelectAtLeastOneContact ?? 'Please select at least one contact to share with',
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        borderRadius: 8,
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
        icon: Icon(
          Icons.error_outline,
          color: Colors.white,
          size: 24,
        ),
      );
      return;
    }

    print("🔄 Sharing ${selectedContacts.length} contacts");

    // Call the onContactsSelected callback first to add contacts
    if (onContactsSelected != null) {
      print("📞 Calling onContactsSelected callback");
      onContactsSelected!(selectedContacts.toList());
    } else {
      print("❌ onContactsSelected callback is null");
    }

    // Then call the onShareClicked callback to trigger API and show dialog
    if (onShareClicked != null) {
      print("🚀 Calling onShareClicked callback");
      onShareClicked!();
    } else {
      print("❌ onShareClicked callback is null");
    }

    // Go back to previous screen
    Get.back();
  }

  // ✅ REMOVED: Contact validation removed to prevent duplicate activity entries
  // Validation will be handled in ShareScreen instead

  // ✅ VALIDATION: Check if contact data is valid before processing
  bool _isValidContact(Contact contact) {
    try {
      // Check if contact has a valid display name
      if (contact.displayName.trim().isEmpty) {
        return false;
      }

      // Check for extremely long names that might cause issues
      if (contact.displayName.length > 200) {
        return false;
      }

      // Validate phone number if present
      if (contact.phones.isNotEmpty) {
        final phoneNumber = contact.phones.first.number;
        if (phoneNumber.length > 50) {
          return false; // Extremely long phone numbers are suspicious
        }
      }

      return true;
    } catch (e) {
      // If validation itself fails, consider contact invalid
      return false;
    }
  }

  // ✅ FALLBACK: Emergency contact loading for when main processing fails
  Future<void> _fallbackContactLoading() async {
    try {
      print("🆘 Attempting fallback contact loading...");

      // Try to load at least first 50 contacts with minimal processing
      final fallbackLimit = 50.clamp(0, allDeviceContacts.length);
      List<ContactItem> fallbackContacts = [];

      for (int i = 0; i < fallbackLimit; i++) {
        try {
          final contact = allDeviceContacts[i];

          if (contact.displayName.isNotEmpty) {
            // ✅ FIX: Use sanitization even in fallback loading
            final name = StringValidator.sanitizeForText(contact.displayName);
            String phone = '';

            if (contact.phones.isNotEmpty) {
              phone = StringValidator.sanitizeForText(contact.phones.first.number);
            }

            fallbackContacts.add(ContactItem(
              name: name,
              phone: phone,
              initials: _getInitials(name), // ✅ FIX: Use safe _getInitials method instead of direct indexing
            ));
          }
        } catch (e) {
          // Skip individual contacts that fail
          continue;
        }
      }

      if (fallbackContacts.isNotEmpty) {
        allContactItems.addAll(fallbackContacts);
        print("🆘 Fallback loading successful: ${fallbackContacts.length} contacts loaded");

        debugPrint('ContactController: Fallback loading saved ${fallbackContacts.length} contacts');
      } else {
        print("🆘 Fallback loading failed: no contacts could be processed");
      }

    } catch (fallbackError) {
      print("💥 Even fallback loading failed: $fallbackError");

    }
  }

  // ✅ UX: Get loading status message based on contact count
  String _getLoadingStatusMessage(int totalContacts) {
    if (totalContacts <= 100) {
      return "Loading contacts...";
    } else if (totalContacts <= 500) {
      return "Loading $totalContacts contacts...";
    } else if (totalContacts <= 1000) {
      return "Processing $totalContacts contacts...";
    } else if (totalContacts <= 2000) {
      return "Processing large contact list ($totalContacts contacts)...";
    } else if (totalContacts <= 5000) {
      return "Processing huge contact list ($totalContacts contacts)...";
    } else if (totalContacts <= 10000) {
      return "Processing massive contact list ($totalContacts contacts)...";
    } else {
      return "Processing unlimited contact list ($totalContacts contacts)...";
    }
  }

  // ✅ PROGRESSIVE: Build search index progressively in background for large lists
  void _buildSearchIndexProgressively() async {
    print("🔄 Building search index progressively for ${allDeviceContacts.length} contacts...");

    loadingStatus.value = "Building search index...";
    totalContactCount.value = allDeviceContacts.length;
    processedContactCount.value = 0;
    loadingProgress.value = 0.0;

    // Build index in small chunks to avoid blocking UI
    const batchSize = 200; // ✅ OPTIMIZED: Increased from 100 to 200 (2x faster)
    int processedContacts = 0;

    try {
      for (int i = 0; i < allDeviceContacts.length; i += batchSize) {
        final batchEnd = (i + batchSize).clamp(0, allDeviceContacts.length);
        final batch = allDeviceContacts.sublist(i, batchEnd);

        List<ContactItem> batchItems = [];

        for (Contact contact in batch) {
          if (_isValidContact(contact)) {
            final contactName = StringValidator.sanitizeForText(contact.displayName);
            String phoneNumber = '';

            if (contact.phones.isNotEmpty) {
              phoneNumber = StringValidator.sanitizeForText(contact.phones.first.number);
            }

            final contactItem = ContactItem(
              name: contactName,
              phone: phoneNumber,
              initials: _getInitials(contactName),
            );

            // ✅ AzListView: Assign tag index
            _assignSingleContactTag(contactItem);

            batchItems.add(contactItem);
            processedContacts++;
          }
        }

        // Add batch to search index
        allContactItems.addAll(batchItems);

        // Update progress
        processedContactCount.value = processedContacts;
        final progressPercent = ((i + batchSize) / allDeviceContacts.length * 100).clamp(0, 100);
        loadingProgress.value = progressPercent / 100;
        loadingStatus.value = "Indexing ${processedContacts} of ${allDeviceContacts.length} contacts (${progressPercent.toStringAsFixed(0)}%)";

        // No delay - instant processing for maximum speed

        print("📄 Search index progress: ${progressPercent.toStringAsFixed(1)}% (${allContactItems.length} contacts indexed)");
      }

      // ✅ COMPLETION: Search index ready
      loadingStatus.value = "Search ready for ${allContactItems.length} contacts";
      loadingProgress.value = 1.0;

      print("✅ Search index completed: ${allContactItems.length} contacts ready for instant search");

    } catch (e, stackTrace) {
      print("❌ Progressive index building failed: $e");
      // Fallback to basic search on loaded contacts
      loadingStatus.value = "Search ready for ${contacts.length} loaded contacts";
    }
  }

  // ✅ AUTO-LOAD: Automatically load all remaining contacts in background (1000-1000 batches)
  void _autoLoadAllRemainingContacts() async {
    print("🚀 Starting auto-load of remaining contacts in background...");
    print("📊 Current loaded: ${contacts.length}, Total: ${allDeviceContacts.length}");

    // ✅ REMOVED: No delay - start loading immediately
    // await Future.delayed(const Duration(milliseconds: 50));

    int loadAttempts = 0;
    const maxAttempts = 50; // Prevent infinite loops (50 * 1000 = 50,000 contacts max)

    while (hasMoreContacts.value && loadAttempts < maxAttempts) {
      try {
        loadAttempts++;
        print("🔄 Auto-loading batch $loadAttempts (${contacts.length}/${allDeviceContacts.length} loaded)");

        // Load next 1000 contacts
        await _loadContactChunk();

        print("✅ Auto-loaded batch $loadAttempts: Total ${contacts.length} contacts now loaded");

        // ✅ REMOVED: No delay between batches for maximum speed
        // await Future.delayed(const Duration(milliseconds: 10));

        // Break if we've loaded enough or if no more contacts
        if (!hasMoreContacts.value) {
          print("🏁 Auto-loading completed: All ${contacts.length} contacts loaded");
          break;
        }

      } catch (e) {
        print("❌ Error in auto-loading batch $loadAttempts: $e");

        // Continue to next batch instead of failing completely
        await Future.delayed(const Duration(milliseconds: 1000));
        continue;
      }
    }

    if (loadAttempts >= maxAttempts) {
      print("⚠️ Auto-loading stopped after $maxAttempts attempts to prevent infinite loop");
    }

    print("🎉 Auto-loading finished: ${contacts.length} total contacts available");
  }

  // ✅ CACHE: Save contacts to cache in background (non-blocking)
  void _saveToCacheInBackground() async {
    try {
      // Wait for all contacts to load
      await Future.delayed(const Duration(milliseconds: 500));

      // Wait for auto-loading to finish
      while (hasMoreContacts.value) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      print("💾 All contacts loaded, saving to cache...");
      await ContactCacheService.saveToCache(contacts.toList());
      print("✅ Cache saved successfully - next load will be under 500ms!");
    } catch (e) {
      print("❌ Error saving contacts to cache: $e");
    }
  }

  // ✅ CACHE: Refresh cache in background without blocking UI
  void _refreshCacheInBackground() async {
    try {
      print("🔄 Background refresh: Checking for new contacts...");

      // Wait a bit before fetching
      await Future.delayed(const Duration(seconds: 2));

      // Fetch fresh contacts from device
      List<Contact> freshContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: false,
        withPhoto: false,
      );

      print("🔍 Comparing: Cache has ${contacts.length}, Device has ${freshContacts.length}");

      // Only update if there are changes
      if (freshContacts.length != allDeviceContacts.length) {
        print("🆕 Found ${freshContacts.length - allDeviceContacts.length} new contacts, updating cache...");

        allDeviceContacts = freshContacts;
        currentPage.value = 0;
        contacts.clear();
        await _loadContactChunk();

        // Save updated contacts to cache
        await ContactCacheService.saveToCache(contacts.toList());
        print("✅ Cache updated with fresh contacts");
      } else {
        print("✅ No changes detected, cache is up to date");
      }
    } catch (e) {
      print("❌ Background refresh error: $e");
    }
  }

  // ✅ PROGRESSIVE: Lazy search that loads more contacts on demand
  void _lazySearch(String query) async {
    print("🔍 Lazy search triggered for query: '$query'");

    // If search index is not complete, search through currently loaded contacts
    if (allContactItems.length < allDeviceContacts.length) {
      print("📄 Search index incomplete (${allContactItems.length}/${allDeviceContacts.length}), searching loaded contacts only");

      // Search through currently available contacts
      List<ContactItem> searchableContacts = [...contacts, ...allContactItems];
      List<ContactItem> matchedContacts = [];

      for (final contact in searchableContacts) {
        final contactName = contact.name.toLowerCase();
        final contactPhone = contact.phone.replaceAll(RegExp(r'[^0-9]'), '');
        final searchQuery = query.toLowerCase();
        final searchPhoneQuery = query.replaceAll(RegExp(r'[^0-9]'), '');

        bool nameMatch = contactName.contains(searchQuery);
        bool wordMatch = contactName.split(' ').any((word) => word.startsWith(searchQuery));
        bool phoneMatch = searchPhoneQuery.isNotEmpty && contactPhone.contains(searchPhoneQuery);
        bool initialMatch = contact.initials.toLowerCase().contains(searchQuery);

        if (nameMatch || wordMatch || phoneMatch || initialMatch) {
          if (!matchedContacts.any((c) => c.name == contact.name && c.phone == contact.phone)) {
            matchedContacts.add(contact);
          }
        }
      }

      filteredContacts.value = matchedContacts;

      // Show hint that more contacts might be available
      if (allContactItems.length < allDeviceContacts.length) {
        print("💡 Hint: ${allDeviceContacts.length - allContactItems.length} more contacts are being indexed for search");
      }
    }
  }
}
