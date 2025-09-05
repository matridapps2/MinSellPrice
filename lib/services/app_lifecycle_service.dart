import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:minsellprice/services/app_notification_service.dart';

/// Global service to manage app lifecycle and notifications across all screens
class AppLifecycleService with WidgetsBindingObserver {
  static final AppLifecycleService _instance = AppLifecycleService._internal();
  factory AppLifecycleService() => _instance;
  AppLifecycleService._internal();

  bool _isInitialized = false;
  bool _isAppInForeground = true;
  AppNotificationService? _notificationService;
  Timer? _foregroundCheckTimer;
  BuildContext? _currentContext;

  /// Initialize the lifecycle service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Add this service as an observer
    WidgetsBinding.instance.addObserver(this);

    _isInitialized = true;
    log('🔄 AppLifecycleService initialized successfully');
  }

  /// Set current context for notifications
  void setCurrentContext(BuildContext context) {
    _currentContext = context;
    log('📍 Context updated for AppLifecycleService');

    // Initialize notification service with new context
    _initializeNotificationService();
  }

  /// Initialize notification service with current context
  Future<void> _initializeNotificationService() async {
    if (_currentContext == null) return;

    try {
      _notificationService = AppNotificationService();
      await _notificationService!.initialize(_currentContext!);

      // Start automatic notification checking
      await _notificationService!.startAutoNotificationChecking();

      log('✅ Notification service initialized with current context');
    } catch (e) {
      log('❌ Error initializing notification service: $e');
    }
  }

  /// Check for notifications when app comes to foreground
  Future<void> _onAppResumed() async {
    if (_currentContext == null) return;

    log('🔄 App resumed - checking for notifications...');

    try {
      // Re-initialize notification service with current context
      await _initializeNotificationService();

      // Check for notifications immediately
      await _notificationService?.checkForNotificationsOnAppOpen();

      log('✅ App resume notification check completed');
    } catch (e) {
      log('❌ Error checking notifications on app resume: $e');
    }
  }

  /// Check for notifications when any screen opens
  Future<void> checkForNotificationsOnScreenOpen(BuildContext context) async {
    log('🔄 Screen opened - checking for notifications...');

    try {
      // Update current context
      setCurrentContext(context);

      // Check for notifications immediately
      await _notificationService?.checkForNotificationsOnAppOpen();

      log('✅ Screen open notification check completed');
    } catch (e) {
      log('❌ Error checking notifications on screen open: $e');
    }
  }

  /// Start foreground checking timer
  void _startForegroundCheckTimer() {
    _foregroundCheckTimer?.cancel();
    _foregroundCheckTimer =
        Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isAppInForeground && _currentContext != null) {
        _checkForNotificationsInForeground();
      }
    });
    log('⏰ Foreground check timer started');
  }

  /// Stop foreground checking timer
  void _stopForegroundCheckTimer() {
    _foregroundCheckTimer?.cancel();
    _foregroundCheckTimer = null;
    log('⏹️ Foreground check timer stopped');
  }

  /// Check for notifications while app is in foreground
  Future<void> _checkForNotificationsInForeground() async {
    if (_currentContext == null) return;

    try {
      // Use the public method instead of private one
      await _notificationService?.checkForNotificationsOnAppOpen();
    } catch (e) {
      log('❌ Error checking notifications in foreground: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    log('🔄 App lifecycle state changed: $state');

    switch (state) {
      case AppLifecycleState.resumed:
        _isAppInForeground = true;
        _onAppResumed();
        _startForegroundCheckTimer();
        break;

      case AppLifecycleState.paused:
        _isAppInForeground = false;
        _stopForegroundCheckTimer();
        log('⏸️ App paused - stopping notification checks');
        break;

      case AppLifecycleState.detached:
        _isAppInForeground = false;
        _stopForegroundCheckTimer();
        log('🔌 App detached - stopping notification checks');
        break;

      case AppLifecycleState.inactive:
        log('⏳ App inactive');
        break;

      case AppLifecycleState.hidden:
        log('👁️ App hidden');
        break;
    }
  }

  /// Force check for notifications (can be called from any screen)
  Future<void> forceCheckForNotifications(BuildContext context) async {
    log('🔄 Force checking for notifications...');

    try {
      setCurrentContext(context);
      await _notificationService?.checkForNotificationsOnAppOpen();
      log('✅ Force notification check completed');
    } catch (e) {
      log('❌ Error in force notification check: $e');
    }
  }

  /// Get current notification service instance
  AppNotificationService? get notificationService => _notificationService;

  /// Check if app is in foreground
  bool get isAppInForeground => _isAppInForeground;

  /// Dispose resources
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopForegroundCheckTimer();
    _notificationService?.dispose();
    _currentContext = null;
    _isInitialized = false;
    log('🔄 AppLifecycleService disposed');
  }
}
