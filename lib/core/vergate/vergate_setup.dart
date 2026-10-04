import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vergate/vergate.dart';

/// Remote Config parameter that holds the whole Vergate JSON.
const _remoteConfigKey = 'vergate_config';

/// Loads the version rules from Firebase Remote Config.
///
/// Firebase must be initialized before the first check runs.
final _remoteConfigSource = CallbackSource(() async {
  final rc = FirebaseRemoteConfig.instance;

  await rc.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      // Short interval in debug so console changes appear immediately.
      minimumFetchInterval: kDebugMode ? Duration.zero : const Duration(minutes: 15),
    ),
  );
  // An empty config means "no rules", so the app is never blocked
  // if the parameter is missing.
  await rc.setDefaults({_remoteConfigKey: '{}'});
  await rc.fetchAndActivate();

  return VergateConfig.fromJsonString(rc.getString(_remoteConfigKey));
});

/// The single app-wide controller.
final VergateController vergate = VergateController(
  source: _remoteConfigSource,
  // Report failures, but never block the user because of them.
  onError: (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: false);
  },
);

/// Texts of the update and maintenance screens (Azerbaijani).
final vergateStrings = VergateStrings(
  updateTitle: 'vergate.updateTitle'.tr(),
  forceUpdateMessage: 'vergate.forceUpdateMessage'.tr(),
  softUpdateMessage: 'vergate.softUpdateMessage'.tr(),
  updateNow: 'vergate.updateNow'.tr(),
  remindLater: 'vergate.remindLater'.tr(),
  skipVersion: 'vergate.skipVersion'.tr(),
  whatsNew: 'vergate.whatsNew'.tr(),
  bannerTitle: 'vergate.bannerTitle'.tr(),
  bannerAction: 'vergate.bannerAction'.tr(),
  dismissLabel: 'vergate.dismissLabel'.tr(),
  maintenanceTitle: 'vergate.maintenanceTitle'.tr(),
  maintenanceMessage: 'vergate.maintenanceMessage'.tr(),
  maintenanceCountdownLabel: 'vergate.maintenanceCountdownLabel'.tr(),
  daysSuffix: 'vergate.daysSuffix'.tr(),
);

/// Brand styling. Replace the color with your app's primary color.
const vergateTheme = VergateTheme(
  primaryColor: Color(0xFF1E88E5),
  cornerRadius: 24,
);

/// Wraps [child] with the version gate. Use it in `MaterialApp.builder`.
Widget buildVergateGate(BuildContext context, Widget? child) {
  return VergateGate(
    controller: vergate,
    theme: vergateTheme,
    strings: vergateStrings,
    softUpdateStyle: VergateSoftUpdateStyle.dialog,
    onUpdateTap: (status) => FirebaseAnalytics.instance.logEvent(
      name: 'vergate_update_tap',
      parameters: {'kind': status is VergateForceUpdate ? 'force' : 'soft'},
    ),
    onLaterTap: (_) {
      FirebaseAnalytics.instance.logEvent(name: 'vergate_update_later');
    },
    onSkipTap: (_) {
      FirebaseAnalytics.instance.logEvent(name: 'vergate_update_skip');
    },
    child: child ?? const SizedBox.shrink(),
  );
}
