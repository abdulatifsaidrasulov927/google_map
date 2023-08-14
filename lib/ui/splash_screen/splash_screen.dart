import 'package:flutter/material.dart';
import 'package:google_map/provider/location_provider.dart';
import 'package:google_map/ui/map/map_screen_.dart';
import 'package:google_map/utils/images/app_images.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  _init() async {
    await Future.delayed(const Duration(seconds: 2));
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const MapScreen();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    LocationProvider locationProvider = Provider.of<LocationProvider>(context);
    if (locationProvider.latLong != null) {
      _init();
    }
    return Scaffold(
      body: Center(child: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          return Lottie.asset(AppImages.mapForSplash);
        },
      )),
    );
  }
}
