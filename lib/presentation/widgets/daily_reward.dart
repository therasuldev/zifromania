import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zifromania/locator.dart';
import 'package:zifromania/services/daily_reward_service.dart';

class DailyRewardWidget extends StatefulWidget {
  const DailyRewardWidget({super.key});

  @override
  State<DailyRewardWidget> createState() => _DailyRewardWidgetState();
}

class _DailyRewardWidgetState extends State<DailyRewardWidget> {
  final DailyRewardService _rewardService = locator.get<DailyRewardService>();

  bool _isLoading = true;
  bool _isRewardReady = false;
  Duration _timeUntilReady = Duration.zero;
  Timer? _pollTimer;

  static const int _coinsPerClaim = 50; // <-- tweak or pull from config

  @override
  void initState() {
    super.initState();
    _refreshState(); // initial check
    _startPolling(); // keep UI ticking once per minute
  }

  /* --------------------------------------------------------------------- */
  /* Polling helpers */
  /* --------------------------------------------------------------------- */

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) => _refreshState());
  }

  Future<void> _refreshState() async {
    final ready = await _rewardService.isRewardReady();
    final remaining = await _rewardService.timeUntilReady();

    if (!mounted) return;
    setState(() {
      _isRewardReady = ready;
      _timeUntilReady = remaining;
      _isLoading = false;
    });
  }

  /* --------------------------------------------------------------------- */
  /* Claim logic */
  /* --------------------------------------------------------------------- */

  Future<void> _claimReward() async {
    if (!_isRewardReady) return;

    await _rewardService.claimReward();
    // TODO: inject your own user/coin service here
    // final updatedUser = await locator.get<UserService>().addCoins(_coinsPerClaim);

    if (!mounted) return;
    _showRewardClaimedDialog(_coinsPerClaim);
    _refreshState(); // reset UI & countdown
  }

  void _showRewardClaimedDialog(int coins) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mükafat Alındı!'),
        content: Text('$coins coin qazandınız!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  /* --------------------------------------------------------------------- */
  /* UI */
  /* --------------------------------------------------------------------- */

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade100, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Image.asset(
            _isRewardReady ? 'assets/icons/gift_not_opened.png' : 'assets/icons/gift_opened.png',
            height: 60,
            width: 60,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _isLoading
                ? const Text('Yüklənir…')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gündelik Mükafat',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: 'Scabber',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _isRewardReady
                          ? Text(
                              'Pulsuz coinlerinizi almaq üçün toxunun!',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: 'Scabber',
                                color: Colors.grey.shade800,
                              ),
                            )
                          : Text(
                              '${DailyRewardService.formatRemainingTime(_timeUntilReady)} sonra qayıdın',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: 'Scabber',
                                color: Colors.grey.shade800,
                              ),
                            ),
                    ],
                  ),
          ),
          if (_isRewardReady && !_isLoading)
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: _claimReward,
              child: const Text('Collect', style: TextStyle(fontFamily: 'Scabber')),
            )
        ],
      ),
    );
  }
}
