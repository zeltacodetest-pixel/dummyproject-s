import 'package:flutter/widgets.dart';

import 'offline_data_store.dart';
import 'permission_service.dart';
import 'processing_service.dart';

class AppDependencies extends InheritedWidget {
  const AppDependencies({
    super.key,
    required super.child,
    required this.offlineDataStore,
    required this.permissionService,
    required this.processingService,
  });

  final OfflineDataStore offlineDataStore;
  final PermissionService permissionService;
  final ProcessingService processingService;

  static AppDependencies of(BuildContext context) {
    final AppDependencies? dependencies =
        context.dependOnInheritedWidgetOfExactType<AppDependencies>();
    assert(
      dependencies != null,
      'AppDependencies.of() called with a context that does not contain AppDependencies.',
    );
    return dependencies!;
  }

  @override
  bool updateShouldNotify(AppDependencies oldWidget) {
    return offlineDataStore != oldWidget.offlineDataStore ||
        permissionService != oldWidget.permissionService ||
        processingService != oldWidget.processingService;
  }
}
