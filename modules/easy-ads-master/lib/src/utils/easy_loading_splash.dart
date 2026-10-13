import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EasyLoadingSplash extends StatelessWidget {
  final Widget? customSplash;
  final String? message;

  const EasyLoadingSplash({Key? key, this.customSplash, this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF515151);

    if (customSplash != null) {
      return customSplash!;
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            width: 140,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF232334),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white10,
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 40,
                  width: 40,
                  child: SpinKitThreeBounce(
                    color: textColor,
                    size: 24.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message ?? "Loading ad...",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
