import 'package:flutter/material.dart';
import 'package:no_screenshot/no_screenshot.dart';

import '../../../common/config.dart';
import '../../../common/config/models/secure_screen_config.dart';
import '../../../services/service_config.dart';

/// Applies whole-app screenshot/recording protection as early as possible
/// (e.g. during app startup, before [SecureScreenMixin] is mounted) so that
/// the splash screen, onboarding and any other pre-dashboard screens are also
/// protected when the feature is enabled for the whole app.
///
/// For the per-screen mode, protection is handled by [SecureScreenMixin] as the
/// user navigates, so this is a no-op.
void applyWholeAppSecureScreen() {
  final config = Configurations.secureScreenConfig;
  if (config.isWholeApp && !ServerConfig().isBuilder) {
    NoScreenshot.instance.screenshotOff();
  }
}

/// Mixin that blocks screenshot & screen recording based on
/// [Configurations.secureScreenConfig].
///
/// - When the feature is disabled (default), screenshots/recording are allowed.
/// - When enabled with an empty `screens` list, the whole app is protected.
///   The protection is also applied early via [applyWholeAppSecureScreen] so it
///   covers the splash screen and onboarding.
/// - When enabled with a non-empty `screens` list, protection is toggled on/off
///   as the user navigates in and out of the listed screens.
mixin SecureScreenMixin<T extends StatefulWidget> on State<T> {
  NoScreenshot get _noScreenshot => NoScreenshot.instance;
  SecureScreenConfig get _kSecureScreenConfig =>
      Configurations.secureScreenConfig;

  /// Do not enable secure screen in builder mode
  bool get _enableSecureScreen =>
      _kSecureScreenConfig.enable && !ServerConfig().isBuilder;
  bool get _isWholeApp => _kSecureScreenConfig.isWholeApp;
  List<String> get _screens => _kSecureScreenConfig.screens;

  bool _isScreenSecured = false;

  @override
  void initState() {
    super.initState();
    if (!_enableSecureScreen) return;

    /// No specific screens configured -> protect the whole app.
    if (_isWholeApp) {
      _setScreenSecured(true);
    }
  }

  /// Toggles the screenshot protection when the active screen changes.
  ///
  /// [screenName] is the route name emitted by the route observer, the same
  /// value used by `SmartChatMixin` (e.g. values from `RouteList`).
  void handleSecureScreen(String? screenName) {
    if (!_enableSecureScreen) return;

    /// Whole-app mode is already handled in [initState].
    if (_isWholeApp) return;

    // if (screenName == null || screenName.isEmpty) return;

    _setScreenSecured(_screens.contains(screenName));
  }

  void _setScreenSecured(bool secure) {
    if (_isScreenSecured == secure) return;
    _isScreenSecured = secure;
    if (secure) {
      _noScreenshot.screenshotOff();
    } else {
      _noScreenshot.screenshotOn();
    }
  }
}
