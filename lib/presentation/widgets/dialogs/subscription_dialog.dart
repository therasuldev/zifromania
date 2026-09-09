import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:zifromania/core/router/route_names.dart';
import 'package:zifromania/domain/entities/enums.dart';
import 'package:zifromania/features/user/data/models/user_model.dart';
import 'package:zifromania/presentation/widgets/animated_button.dart';
import 'package:zifromania/presentation/widgets/animated_icon_button.dart';

class SubscriptionDialog extends StatelessWidget {
  const SubscriptionDialog({
    super.key,
    required this.message,
    required this.user,
    required this.category,
  });

  final String message;
  final UserModel user;
  final GameCategory category;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/scaffold.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black45,
              BlendMode.darken,
            ),
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontFamily: 'Scabber',
                      height: 1.4,
                    ),
                  ),
                  const Spacer(),
                  AnimatedIconButton(
                    onTap: () {
                      context.pop();
                      context.go(RouteNames.home);
                    },
                    icon: SizedBox(height: 32, width: 32, child: Image.asset('assets/icons/delete.png')),
                  ),
                ],
              ),
            ),

            // Message and Button Section

            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Subscription Button
                  AnimatedButton(
                    title: context.tr('subscription.upgrade_premium'),
                    color: Colors.transparent,
                    borderColor: Colors.orange,
                    onTap: () {
                      context.pop();
                      context.push('${RouteNames.subscription}?tab=subscription');
                    },
                    fontSize: 18,
                    fontFamily: 'Scabber',
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                  ),

                  const SizedBox(height: 15),

                  // Watch Ad Button
                  AnimatedButton(
                    title: context.tr('subscription.watch_ad'), // "Watch Ad" və ya "Reklam İzlə"
                    color: Colors.transparent,
                    borderColor: Colors.deepPurpleAccent,
                    onTap: () {
                      context.pop();
                      context.push('${RouteNames.subscription}?tab=coins');
                    },
                    fontSize: 18,
                    fontFamily: 'Scabber',
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                  ),

                  const SizedBox(height: 15),

                  // Watch Ad Button
                  AnimatedButton(
                    title: context.tr('coin.purchase'), // "Watch Ad" və ya "Reklam İzlə"
                    color: Colors.transparent,
                    borderColor: Colors.green,
                    onTap: () {
                      context.pop();
                      context.push('${RouteNames.subscription}?tab=coins');
                    },
                    fontSize: 18,
                    fontFamily: 'Scabber',
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class AppDialog extends StatelessWidget {
  const AppDialog({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/scaffold.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black45,
              BlendMode.darken,
            ),
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedIconButton(
                    onTap: () {
                      context.pop();
                      context.go(RouteNames.home);
                    },
                    icon: SizedBox(height: 32, width: 32, child: Image.asset('assets/icons/delete.png')),
                  ),
                ],
              ),
            ),

            // Message and Button Section

            Padding(
              padding: const EdgeInsets.all(30),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontFamily: 'Scabber',
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
