import 'package:flutter/material.dart';
import 'package:google_map/ui/map/map_screen_.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({
    super.key,
  });

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  // int _selectedIndex = 0;
  // static const TextStyle optionStyle =
  //     TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  // static const List<Widget> _widgetOptions = <Widget>[
  //   Text(
  //     'Index 0: Home',
  //     style: optionStyle,
  //   ),
  //   Text(
  //     'Index 1: Business',
  //     style: optionStyle,
  //   ),
  //   Text(
  //     'Index 2: School',
  //     style: optionStyle,
  //   ),
  // ];

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.green[700],
          title: const Text('Drawer screen')),
      backgroundColor: Colors.white,
      body: const Center(
          child: Text(
        'Drawer screen',
        style: TextStyle(color: Colors.black),
      )),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green[700],
              ),
              child: const Text(
                'Abudlatif Saidrasulov',
                style: TextStyle(color: Colors.white),
              ),
            ),

            // Container(
            //   child: Text('Home'),
            // ),
            ListTile(
              title: const Text('Home'),
              // selected: _selectedIndex == 0,

              onTap: () {
                // Navigator.pushReplacement(
                //   context,
                //   MaterialPageRoute(builder: (context) => DrawerScreen()),
                // );
                //  _onItemTapped(0);

                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Map'),
              // selected: _selectedIndex == 1,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MapScreen()),
                );
                //   _onItemTapped(1);

                //  Navigator.pop(context);
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
