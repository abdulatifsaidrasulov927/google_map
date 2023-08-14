import 'package:flutter/material.dart';
import 'package:google_map/provider/address_call_provider.dart';
import 'package:google_map/utils/constants/constants.dart';
import 'package:provider/provider.dart';

class AddressKindSelector extends StatefulWidget {
  const AddressKindSelector({Key? key}) : super(key: key);

  @override
  State<AddressKindSelector> createState() => _AddressKindSelectorState();
}

class _AddressKindSelectorState extends State<AddressKindSelector> {
  String dropdownValue = kindList.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      dropdownColor: Colors.transparent,
      value: dropdownValue,
      elevation: 16,
      style: const TextStyle(color: Colors.white),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
        });

        context.read<AddressCallProvider>().updateKind(dropdownValue);
      },
      items: kindList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Container(
              width: 80,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: const LinearGradient(
                    colors: [Color(0xff3dc1fd), Color(0xff026b9b)],
                    stops: [0, 1],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )),
              child: Text(value)),
        );
      }).toList(),
    );
  }
}
