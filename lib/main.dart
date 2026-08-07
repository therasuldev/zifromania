// lib/main.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zifromania/app.dart';
import 'package:zifromania/firebase_options.dart';
import 'package:zifromania/presentation/providers/bloc_providers.dart';
import 'package:zifromania/presentation/providers/repository_providers.dart';
import 'package:zifromania/services/services_init.dart';
import 'services/sound_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await dotenv.load();
  await initializeServices();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('tr')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MultiRepositoryProvider(
        providers: repositoryProviders,
        child: MultiBlocProvider(
          providers: blocProviders,
          child: ZifroMania(soundService: locator.get<SoundService>()),
        ),
      ),
    ),
  );
}
