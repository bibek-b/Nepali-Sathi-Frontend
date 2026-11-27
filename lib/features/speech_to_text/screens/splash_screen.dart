import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF16845B),
      body: SizedBox.expand(
        child: Image(
          image: AssetImage('assets/images/splash_image.png'),
          fit: BoxFit.cover,
          alignment: Alignment.center,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}
