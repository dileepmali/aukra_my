import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../app/constants/app_images.dart';
import '../app/localizations/l10n/app_strings.dart';

class ImageCarouselController extends GetxController {
  // Controllers and state
  PageController? _pageController;
  Timer? _autoScrollTimer;
  final RxInt currentIndex = 0.obs;

  final List<Map<String, String>> onboardingData = [
    {
      'image': AppImages.firstIm,
      'title': 'onboardingTitle1',
      'subtitle': 'onboardingSubtitle1',
    },
    {
      'image': AppImages.secondIm,
      'title': 'onboardingTitle2',
      'subtitle': 'onboardingSubtitle2',
    },
    {
      'image': AppImages.threeIm,
      'title': 'onboardingTitle3',
      'subtitle': 'onboardingSubtitle3',
    },
    {
      'image': AppImages.fourIm,
      'title': 'onboardingTitle4',
      'subtitle': 'onboardingSubtitle4',
    },
  ];

  // Getters
  PageController? get pageController => _pageController;
  int get dataLength => onboardingData.length;
  Map<String, String> get currentData => onboardingData[currentIndex.value];

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  @override
  void onClose() {
    _cleanupResources();
    super.onClose();
  }

  // Initialize page controller and start auto scroll
  void _initializeController() {
    _pageController = PageController();
    startAutoScroll();
  }

  // Start auto-scroll functionality
  void startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (!isClosed && _pageController?.hasClients == true) {
        try {
          final nextIndex = (currentIndex.value + 1) % onboardingData.length;
          _pageController?.animateToPage(
            nextIndex,
            duration: Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
          );
        } catch (e) {
          // Ignore animation errors when widgets are disposed
          debugPrint('Animation error in carousel: $e');
        }
      }
    });
  }

  // Stop auto scroll
  void stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  // Handle manual page changes
  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  // Restart auto scroll after manual interaction
  void restartAutoScroll() {
    stopAutoScroll();
    // Restart after 2 seconds delay
    Timer(Duration(seconds: 2), () {
      if (!isClosed) {
        startAutoScroll();
      }
    });
  }

  // Clean up resources
  void _cleanupResources() {
    _autoScrollTimer?.cancel();
    _pageController?.dispose();
  }

  // Get current title
  String getCurrentTitle([BuildContext? context]) {
    final titleKey = currentData['title'] ?? '';
    // Return the key directly or use provided context for localization
    final ctx = context ?? Get.context;
    if (ctx != null) {
      return AppStrings.getLocalizedString(ctx, (localizations) {
        switch(titleKey) {
          case 'onboardingTitle1':
            return localizations.onboardingTitle1;
          case 'onboardingTitle2':
            return localizations.onboardingTitle2;
          case 'onboardingTitle3':
            return localizations.onboardingTitle3;
          case 'onboardingTitle4':
            return localizations.onboardingTitle4;
          default:
            return 'Loading...';
        }
      });
    }
    return 'Loading...';
  }

  String getCurrentSubtitle([BuildContext? context]) {
    final subtitleKey = currentData['subtitle'] ?? '';
    // Return the key directly or use provided context for localization
    final ctx = context ?? Get.context;
    if (ctx != null) {
      return AppStrings.getLocalizedString(ctx, (localizations) {
        switch(subtitleKey) {
          case 'onboardingSubtitle1':
            return localizations.onboardingSubtitle1;
          case 'onboardingSubtitle2':
            return localizations.onboardingSubtitle2;
          case 'onboardingSubtitle3':
            return localizations.onboardingSubtitle3;
          case 'onboardingSubtitle4':
            return localizations.onboardingSubtitle4;
          default:
            return 'Loading...';
        }
      });
    }
    return 'Loading...';
  }

  // Get current image
  String getCurrentImage() {
    return currentData['image'] ?? AppImages.firstIm;
  }
}