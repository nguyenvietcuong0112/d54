import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/values/app_colors.dart';

class AdLoadingPage extends StatelessWidget {
  const AdLoadingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2A), // Matches the dark app theme / splash color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/json/loading.json',
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 10),
            Text(
              "Ad is loading...",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
