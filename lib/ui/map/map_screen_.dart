import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_map/model/user_address.dart';
import 'package:google_map/provider/address_call_provider.dart';
import 'package:google_map/provider/location_provider.dart';
import 'package:google_map/provider/user_locations_provider.dart';
import 'package:google_map/ui/map/widgets/address_kind_selector.dart';
import 'package:google_map/ui/map/widgets/address_lang_selector.dart';
import 'package:google_map/ui/map/widgets/save_button.dart';
import 'package:google_map/utils/images/app_images.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  late CameraPosition initralCamreaPosition;
  late CameraPosition currentCameraPosition;
  bool onCameraMoveStarted = false;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  MapType _type = MapType.none;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<int> _counter;

  // ignore: unused_field
  static const LatLng _center = LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _mapControll({required double lat, required double lot}) {
    LocationProvider locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    initralCamreaPosition = CameraPosition(target: LatLng(lat, lot), zoom: 13);
    currentCameraPosition = CameraPosition(target: LatLng(lat, lot), zoom: 13);

    locationProvider.updateLatLong(LatLng(lot, lat));
    _followDateMove(cameraPosition: currentCameraPosition);
    setState(() {});
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
    LocationProvider locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    initralCamreaPosition =
        CameraPosition(target: locationProvider.latLong!, zoom: 13);
    currentCameraPosition =
        CameraPosition(target: locationProvider.latLong!, zoom: 13);
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
    List<UserAddress> userAddresses =
        Provider.of<UserLocationsProvider>(context).addresses;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Map',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(children: [
        GoogleMap(
            onCameraMove: (CameraPosition cameraPosition) {
              currentCameraPosition = cameraPosition;
            },
            onCameraIdle: () {
              debugPrint(
                  "CURRENT CAMERA POSITION : ${currentCameraPosition.target.latitude}");
              context
                  .read<AddressCallProvider>()
                  .getAddressByLatLong(latLng: currentCameraPosition.target);
              setState(() {
                onCameraMoveStarted = false;
              });
              debugPrint('Move finished');
            },
            liteModeEnabled: false,
            myLocationEnabled: false,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            mapType: _type,
            onCameraMoveStarted: () {
              setState(() {
                onCameraMoveStarted = true;
              });
              debugPrint('Move Started');
            },
            onMapCreated: _onMapCreated,
            initialCameraPosition: initralCamreaPosition),
        Align(
          child: Icon(
            Icons.location_pin,
            color: Colors.red,
            size: onCameraMoveStarted ? 50 : 32,
          ),
        ),
        Positioned(
          left: 10,
          right: 10,
          top: 10,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade600,
                  spreadRadius: 1,
                  blurRadius: 15,
                  offset: const Offset(5, 5),
                ),
                const BoxShadow(
                    color: Colors.white,
                    offset: Offset(-5, -5),
                    blurRadius: 15,
                    spreadRadius: 1),
              ],
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 154, 204, 245),
                  Color.fromARGB(255, 10, 223, 251)
                ],
                stops: [0, 1],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              color: Colors.white,
            ),
            child: Center(
              child: Text(
                context.watch<AddressCallProvider>().scrolledAddressText,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 100,
          right: 100,
          child: Visibility(
            visible: context.watch<AddressCallProvider>().canSaveAddress(),
            child: SaveButton(onTap: () {
              final snackBar = SnackBar(
                content: const Text('save yor address'),
                action: SnackBarAction(
                  label: 'ok',
                  onPressed: () {
                    // Some code to undo the change.
                  },
                ),
              );
              AddressCallProvider adp =
                  Provider.of<AddressCallProvider>(context, listen: false);
              context.read<UserLocationsProvider>().insertUserAddress(
                  UserAddress(
                      lat: currentCameraPosition.target.latitude,
                      long: currentCameraPosition.target.longitude,
                      address: adp.scrolledAddressText,
                      created: DateTime.now().toString()));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }),
          ),
        ),
      ]),
      endDrawer: Container(
        height: double.infinity,
        width: 300,
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            const Align(
              alignment: Alignment.topCenter,
              child: Text(
                'Map type',
              ),
            ),
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 140,
                  ),
                  ZoomTapAnimation(
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade600,
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 5),
                            ),
                            BoxShadow(
                              color: Colors.grey.shade300,
                              offset: const Offset(-5, 0),
                            ),
                            BoxShadow(
                              color: Colors.grey.shade300,
                              offset: const Offset(5, 0),
                            )
                          ],
                          border: Border.all(color: Colors.white, width: 2),
                          gradient: const LinearGradient(
                            colors: [Color(0xff2196f3), Color(0xff00bcd4)],
                            stops: [0, 1],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                          borderRadius: BorderRadius.circular(16)),
                      child: const Center(
                        child: Text(
                          'normal',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  ZoomTapAnimation(
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade600,
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 5),
                            ),
                            BoxShadow(
                              color: Colors.grey.shade300,
                              offset: const Offset(-5, 0),
                            ),
                            BoxShadow(
                              color: Colors.grey.shade300,
                              offset: const Offset(5, 0),
                            )
                          ],
                          border: Border.all(color: Colors.white, width: 2),
                          gradient: const LinearGradient(
                            colors: [Color(0xff2196f3), Color(0xff00bcd4)],
                            stops: [0, 1],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16)),
                      child: const Center(
                        child: Text(
                          'terrain',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  ZoomTapAnimation(
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade600,
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 5),
                            ),
                            BoxShadow(
                              color: Colors.grey.shade300,
                              offset: const Offset(-5, 0),
                            ),
                            BoxShadow(
                              color: Colors.grey.shade300,
                              offset: const Offset(5, 0),
                            )
                          ],
                          border: Border.all(color: Colors.white, width: 2),
                          gradient: const LinearGradient(
                            colors: [Color(0xff2196f3), Color(0xff00bcd4)],
                            stops: [0, 1],
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                          ),
                          borderRadius: BorderRadius.circular(16)),
                      child: const Center(
                          child: Text(
                        'hybrid',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      )),
                    ),
                  ),
                ],
              ),
            ),
            const Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                AddressKindSelector(),
                SizedBox(
                  width: 20,
                ),
                AddressLangSelector(),
                SizedBox(
                  width: 20,
                )
              ],
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  if (userAddresses.isEmpty)
                    Center(child: Lottie.asset(AppImages.emtyForData)),
                  ...List.generate(userAddresses.length, (index) {
                    UserAddress userAddress = userAddresses[index];
                    return Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (v) {
                              setState(() {
                                context
                                    .read<UserLocationsProvider>()
                                    .deleteUserAddress(userAddress.id!);
                              });
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete_sharp,
                            label: 'Delate',
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ZoomTapAnimation(
                            onTap: () {
                              context
                                  .read<AddressCallProvider>()
                                  .getAddressByLatLong(
                                      latLng: LatLng(
                                          userAddress.lat, userAddress.long));

                              context.read<LocationProvider>().updateLatLong(
                                  LatLng(userAddress.lat, userAddress.long));
                              _mapControll(
                                  lat: userAddress.lat, lot: userAddress.long);
                              _followDateMove(
                                  cameraPosition: currentCameraPosition);
                              Navigator.pop(context);
                            },
                            child: Center(
                              child: Container(
                                height: 90,
                                width: 260,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.shade600,
                                      spreadRadius: 1,
                                      blurRadius: 15,
                                      offset: const Offset(5, 5),
                                    ),
                                    const BoxShadow(
                                        color: Colors.white,
                                        offset: Offset(-5, -5),
                                        blurRadius: 15,
                                        spreadRadius: 1),
                                  ],
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xff064170),
                                      Color(0xff89f2ff)
                                    ],
                                    stops: [0, 1],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  runAlignment: WrapAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                        userAddress.address,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    );
                  })
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _followMe(cameraPosition: initralCamreaPosition);
        },
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.fmd_good_sharp),
      ),
    );
  }

  Future<void> _followMe({required CameraPosition cameraPosition}) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  Future<void> _followDateMove({required CameraPosition cameraPosition}) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }
}
//  return ListTile(
//                       onTap: () {
//                         context.read<AddressCallProvider>().getAddressByLatLong(
//                             latLng: LatLng(userAddress.lat, userAddress.long));

//                         context.read<LocationProvider>().updateLatLong(
//                             LatLng(userAddress.lat, userAddress.long));
//                       },
//                       title: Text(userAddress.address),
//                       subtitle: Text(
//                           "Lat: ${userAddress.lat} and Longt:${userAddress.long}"),
//                     );