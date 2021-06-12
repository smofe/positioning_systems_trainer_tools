import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

/// Service must expose a characteristic with this UUID in order to be able to be configured.
const nameCharacteristicUUID = "eeec3b9b-3f42-46d1-b2bc-bb9ce1eaee35";

class PatientConfig extends StatefulWidget {
  final BluetoothService connectedDeviceService;
  final String deviceName;

  const PatientConfig(
      {Key? key,
      required this.connectedDeviceService,
      required this.deviceName})
      : super(key: key);

  @override
  _PatientConfigState createState() => _PatientConfigState();
}

class _PatientConfigState extends State<PatientConfig> {
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verbunden mit ${widget.deviceName}"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                  hintText: "Gib hier den neuen dPS-Code des Patienten ein."),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                var characteristics =
                    widget.connectedDeviceService.characteristics;
                bool hasNameCharacteristic = false;
                for (BluetoothCharacteristic c in characteristics) {
                  if (c.uuid == Guid(nameCharacteristicUUID)) {
                    hasNameCharacteristic = true;
                    c
                        .write(utf8
                            .encode("patient-${_textEditingController.text}"))
                        .then((value) => Navigator.of(context).pop(true));
                  }
                }
                if (!hasNameCharacteristic) Navigator.of(context).pop(false);
              },
              child: Text("Beacon beschreiben"))
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
