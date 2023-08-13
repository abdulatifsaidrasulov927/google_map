import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_map/ui/drawer/drawer_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  MapType _type = MapType.none;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<int> _counter;
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng _center = LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  Future<void> _mapType(int count) async {
    final SharedPreferences prefs = await _prefs;
    int mapTypeInt = (prefs.getInt('maptype') ?? 0);
    mapTypeInt = count;
    debugPrint(mapTypeInt.toString());

    setState(() {
      _counter = prefs.setInt('maptype', mapTypeInt).then((bool success) {
        return mapTypeInt;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    late int maytypeint;
    _counter = _prefs.then((SharedPreferences prefs) {
      maytypeint = prefs.getInt('maptype') ?? 0;
      if (maytypeint == 0) {
        setState(() {
          _type = MapType.hybrid;
        });
      } else if (maytypeint == 1) {
        setState(() {
          _type = MapType.terrain;
        });
      } else {
        setState(() {
          _type = MapType.normal;
        });
      }
      return _counter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(children: [
        GoogleMap(
          mapType: _type,
          onMapCreated: _onMapCreated,
          initialCameraPosition: const CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
        ),
        Positioned(
          left: 20,
          top: 20,
          child: ZoomTapAnimation(
            onTap: () {
              _mapType(0);
              setState(() {
                _type = MapType.hybrid;
              });
            },
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(16)),
              child: const Center(
                  child: Text(
                'hybrid',
                style: TextStyle(color: Colors.white, fontSize: 20),
              )),
            ),
          ),
        ),
        Positioned(
          left: 140,
          top: 20,
          child: ZoomTapAnimation(
            onTap: () {
              setState(() {
                _mapType(1);
                _type = MapType.terrain;
              });
            },
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(16)),
              child: const Center(
                child: Text(
                  'terrain',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 260,
          top: 20,
          child: ZoomTapAnimation(
            onTap: () {
              setState(() {
                _mapType(2);
                _type = MapType.normal;
              });
            },
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(16)),
              child: const Center(
                child: Text(
                  'normal',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ),
        ),
        Positioned(
            bottom: 20,
            left: 90,
            right: 90,
            child: ElevatedButton(
                onPressed: () {
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute<void>(
                  //     builder: (BuildContext context) => MapSaveScreen(),
                  //   ),
                  // );
                },
                child: const Center(child: Text('Elevated button'))))
      ]),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Home Screen'),
            ),

            // Container(
            //   child: Text('Home'),
            // ),
            ListTile(
              title: const Text('Home'),
              // selected: _selectedIndex == 0,

              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const DrawerScreen()),
                );
                //  _onItemTapped(0);

                //                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Map'),
              // selected: _selectedIndex == 1,
              onTap: () {
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (context) => const MapSample()),
                // );
                //   _onItemTapped(1);

                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Save'),
              //  selected: _selectedIndex == 2,
              onTap: () {
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (context) => MapSaveScreen()),
                // );
                //  _onItemTapped(2);
                //  Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
