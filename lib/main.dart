import 'package:flutter/material.dart';
import 'package:google_map/provider/address_call_provider.dart';
import 'package:google_map/provider/location_provider.dart';
import 'package:google_map/provider/user_locations_provider.dart';
import 'package:google_map/servis/api_service.dart';
import 'package:google_map/ui/splash_screen/splash_screen.dart';

import 'package:provider/provider.dart';

Future<void> main() async {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => UserLocationsProvider()),
      ChangeNotifierProvider(create: (context) => LocationProvider()),
      ChangeNotifierProvider(
          create: (context) => AddressCallProvider(apiService: ApiService())),
    ],
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
