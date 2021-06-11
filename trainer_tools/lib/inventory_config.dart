import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:numberpicker/numberpicker.dart';

class InventoryConfig extends StatefulWidget {
  const InventoryConfig({Key? key}) : super(key: key);

  @override
  _InventoryConfigState createState() => _InventoryConfigState();
}

class _InventoryConfigState extends State<InventoryConfig> {
  int _selectedID = 0;
  bool _write = false;

  @override
  void initState() {
    super.initState();
    _initializeNFCManager();
  }

  void _initializeNFCManager() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (isAvailable) {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          Ndef? ndef = Ndef.from(tag);
          if (ndef != null) {
            if (_write) {
              ndef.write(
                  NdefMessage([NdefRecord.createText("entity-$_selectedID")]));
              setState(() {
                _write = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Tag erfolgreich beschrieben!")));
              Navigator.of(context).pop();
            } else {
              _scannedNdefTagDialog(ndef);
            }
          }
        },
      );
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("NFC wird nicht unterstüztz"),
                content: Text(
                    "Dein Gerät unterstützt leider kein NFC. Daher kannst Du mit diesem Gerät keine Inventar-Tags bearbeiten"),
              ));
    }
  }

  void _scannedNdefTagDialog(Ndef ndef) {
    final rawMessage = ndef.cachedMessage?.records.first.payload;
    var parsedMessage;
    var entityID;
    if (rawMessage != null) {
      parsedMessage = utf8.decode(rawMessage.toList().sublist(3));
      if (parsedMessage.startsWith("entity-")) {
        entityID = int.tryParse(parsedMessage.split("-")[1]);
        if (entityID != null)
          setState(() {
            _selectedID = entityID;
          });
      }
    }
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                    title: Text("NFC-Chip erkannt"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        (entityID != null)
                            ? Text(
                                "Dieser NFC-Chip kodiert derzeit bereits das Inventar mit der ID $entityID. Möchtest Du ihn wirklich überschreiben?\n\n")
                            : (parsedMessage != null)
                                ? Column(
                                    children: [
                                      Text(
                                          "Dieser NFC-Chip enthält derzeit die Daten:"),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          "$parsedMessage",
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                        Text(
                            "Wähle die ID des Inventars aus, mit dem der Tag beschrieben werden soll."),
                        NumberPicker(
                          value: _selectedID,
                          minValue: 0,
                          maxValue: 9999,
                          onChanged: (value) {
                            setState(() => _selectedID = value);
                          },
                          axis: Axis.horizontal,
                        )
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          setState(() => _write = true);
                          Navigator.of(context).pop();
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text("Schreibe Daten..."),
                                    content: Text(
                                        "Scanne nun den Tag erneut ein, um ihn zu beschreiben."),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          "Abbrechen",
                                          style: TextStyle(
                                              color:
                                                  Theme.of(context).errorColor),
                                        ),
                                      ),
                                    ],
                                  ));
                        },
                        child: Text("Tag beschreiben"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Abbrechen",
                          style: TextStyle(color: Theme.of(context).errorColor),
                        ),
                      ),
                    ],
                  ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inventare konfigurieren")),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(
                Icons.nfc,
                size: MediaQuery.of(context).size.width / 2,
              ),
              Text(
                "Um ein Inventar zu konfigurieren, scanne dieses zunächst ein, indem Du dein Gerät an den NFC-Chip hälst. Danach kannst Du die ID des Inventars auswählen und auf den Chip übertragen.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
