// Re-export all classes to maintain backward compatibility
export 'custom_app_bar.dart';
export 'models/app_bar_config.dart';
export 'utils/app_bar_helper.dart';

// Backward compatibility typedef
import 'app_bar.dart' as Helper;
import 'custom_app_bar.dart' as NewAppBar;

// Keep the old class name for backward compatibility
typedef CustomResponsiveAppBar = NewAppBar.CustomResponsiveAppBar;
