import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../presentations/routes/app_routes.dart';
import '../api/auth_storage.dart';
import '../services/auth_service.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 0;

  @override
  RouteSettings? redirect(String? route) {
    // This is synchronous, so we can't do async check here
    // We'll use a FutureBuilder approach instead
    return null;
  }

  @override
  GetPageBuilder? onPageBuildStart(GetPageBuilder? page) {
    if (page == null) {
      debugPrint('⚠️ AuthMiddleware: Page builder is null');
      return null;
    }

    debugPrint('📄 AuthMiddleware: Wrapping page with auth check');

    // Return a new builder that wraps the original page
    return () => _AuthCheckWrapper(builder: page);
  }
}

/// Wrapper widget that checks authentication before showing the page
class _AuthCheckWrapper extends StatefulWidget {
  final Widget Function() builder;

  const _AuthCheckWrapper({required this.builder});

  @override
  State<_AuthCheckWrapper> createState() => _AuthCheckWrapperState();
}

class _AuthCheckWrapperState extends State<_AuthCheckWrapper> {
  bool _isChecking = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      debugPrint('🔍 AuthMiddleware: Performing auth check...');

      // Try to find or register AuthService
      try {
        Get.find<AuthService>();
      } catch (e) {
        debugPrint('📝 AuthMiddleware: AuthService not found, registering it...');
        Get.put<AuthService>(AuthService(), permanent: true);
      }

      // Check token validity
      final isTokenValid = await AuthStorage.isTokenValid();
      debugPrint('🔑 AuthMiddleware: Token valid: $isTokenValid');

      if (!isTokenValid) {
        debugPrint('❌ AuthMiddleware: Token invalid, redirecting to login');
        // Use post frame callback to avoid navigation during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Get.offAllNamed(AppRoutes.numberVerify);
          }
        });
        return;
      }

      debugPrint('✅ AuthMiddleware: Token valid, showing page');
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
          _isChecking = false;
        });
      }
    } catch (e) {
      debugPrint('❌ AuthMiddleware: Error in auth check: $e');
      // Fallback navigation on error
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Get.offAllNamed(AppRoutes.numberVerify);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      // Show loading indicator while checking
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAuthenticated) {
      // Return empty container while redirecting
      return Container();
    }

    // Authentication successful, build the actual page
    return widget.builder();
  }
}
