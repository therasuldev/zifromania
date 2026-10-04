import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zifromania/core/router/app_router.dart';
import 'package:zifromania/core/vergate/vergate_setup.dart';
import 'package:zifromania/features/settings/settings_module.dart';
import 'package:zifromania/features/sound/sound_module.dart';
import 'package:zifromania/shared/constants/app_constants.dart';

class ZifroMania extends ConsumerStatefulWidget {
  const ZifroMania({super.key});

  @override
  ConsumerState<ZifroMania> createState() => _ZifroManiaState();
}

class _ZifroManiaState extends ConsumerState<ZifroMania> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(settingsRepositoryProvider).getMusicEnabled()) {
        ref.read(soundRepositoryProvider).playBackgroundMusic(backgroundMusicAsset);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final soundRepo = ref.read(soundRepositoryProvider);
    final settingsRepo = ref.read(settingsRepositoryProvider);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        soundRepo.pauseBackgroundMusic();
        break;
      case AppLifecycleState.resumed:
        if (settingsRepo.getMusicEnabled()) {
          soundRepo.resumeBackgroundMusic();
        } else {
          soundRepo.stopBackgroundMusic();
        }
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ZifroMania',
      builder: buildVergateGate,
      routerConfig: ref.watch(appRouterProvider),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
    );
  }
}
