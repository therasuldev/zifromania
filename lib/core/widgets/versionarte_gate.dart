import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:versionarte/versionarte.dart';

class VersionarteGate extends StatefulWidget {
  final Widget child;
  const VersionarteGate({super.key, required this.child});

  @override
  State<VersionarteGate> createState() => _VersionarteGateState();
}

class _VersionarteGateState extends State<VersionarteGate> {
  bool _checking = true;
  late VersionarteResult _result;

  @override
  void initState() {
    super.initState();
    _checkVersion();
  }

  Future<void> _checkVersion() async {
    await FirebaseRemoteConfig.instance.fetchAndActivate();

    _result = await Versionarte.check(
      versionarteProvider: const RemoteConfigVersionarteProvider(
        keyName: 'versionarte', // Remote Config parametr adı
        initializeInternally: true, // çünki Firebase artıq init olunub
      ),
    );
    if (!mounted) return;
    setState(() => _checking = false);
    _handleStatus();
  }

  void _handleStatus() {
    switch (_result.status) {
      case VersionarteStatus.inactive:
        _showMaintenance(_result.getMessageForLanguage('en'));
        break;
      case VersionarteStatus.forcedUpdate:
        _showForcedUpdate();
        break;
      case VersionarteStatus.outdated:
        _showOptionalUpdate();
        break;
      default:
        break;
    }
  }

  Future<void> _showForcedUpdate() => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Yeniləmə məcburidir'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: const Text(
              'Davam etmək üçün son versiyanı quraşdırın.',
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Versionarte.launchDownloadUrl(_result.downloadUrls!),
                child: const Text('Yenilə'),
              ),
            ),
          ],
        ),
      );

  Future<void> _showOptionalUpdate() => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Yeni versiya mövcuddur'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: const Text(
              'İstəsəniz indi yeniləyə bilərsiniz.',
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Versionarte.launchDownloadUrl(_result.downloadUrls!),
                  child: const Text('Yenilə'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Sonra'),
                ),
              ],
            ),
          ],
        ),
      );

  Future<void> _showMaintenance(String? msg) => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('Texniki işlər'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              msg ?? 'Tətbiq müvəqqəti deaktivdir.',
              textAlign: TextAlign.center,
              softWrap: true,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Material(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return widget.child;
  }
}
