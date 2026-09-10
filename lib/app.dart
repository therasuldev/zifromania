import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zifromania/core/router/app_router.dart';
import 'package:zifromania/domain/entities/constant.dart';
import 'package:zifromania/features/settings/settings_module.dart';
import 'package:zifromania/features/sound/sound_module.dart';

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

    // Arxa fon musiqisini başlatmaq
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(soundRepositoryProvider).playBackgroundMusic('sounds/zifromania_background.mp3');
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
        }
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Sound lifecycle cleanup ref.onDispose daxilində idarə olunmalıdır
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ZifroMania',
      scaffoldMessengerKey: scaffoldMessengerKey,
      routerConfig: ref.watch(appRouterProvider),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
    );
  }
}
