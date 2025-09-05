import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:minsellprice/services/app_lifecycle_service.dart';

/// Mixin to add notification checking functionality to any screen
mixin NotificationMixin<T extends StatefulWidget> on State<T> {
  AppLifecycleService? _lifecycleService;

  @override
  void initState() {
    super.initState();
    _initializeNotificationChecking();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateContextForNotifications();
  }

  /// Initialize notification checking for this screen
  void _initializeNotificationChecking() {
    try {
      _lifecycleService = AppLifecycleService();

      // Check for notifications when this screen opens
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForNotificationsOnScreenOpen();
      });

      log('✅ Notification checking initialized for ${widget.runtimeType}');
    } catch (e) {
      log('❌ Error initializing notification checking: $e');
    }
  }

  /// Update context for notifications
  void _updateContextForNotifications() {
    try {
      _lifecycleService?.setCurrentContext(context);
      log('📍 Context updated for ${widget.runtimeType}');
    } catch (e) {
      log('❌ Error updating context: $e');
    }
  }

  /// Check for notifications when screen opens
  Future<void> _checkForNotificationsOnScreenOpen() async {
    try {
      await _lifecycleService?.checkForNotificationsOnScreenOpen(context);
      log('✅ Notification check completed for ${widget.runtimeType}');
    } catch (e) {
      log('❌ Error checking notifications for ${widget.runtimeType}: $e');
    }
  }

  /// Force check for notifications (can be called manually)
  Future<void> forceCheckForNotifications() async {
    try {
      await _lifecycleService?.forceCheckForNotifications(context);
      log('✅ Force notification check completed for ${widget.runtimeType}');
    } catch (e) {
      log('❌ Error in force notification check for ${widget.runtimeType}: $e');
    }
  }

  /// Check if app is in foreground
  bool get isAppInForeground => _lifecycleService?.isAppInForeground ?? false;

  @override
  void dispose() {
    // Don't dispose the lifecycle service as it's a singleton
    super.dispose();
  }
}
