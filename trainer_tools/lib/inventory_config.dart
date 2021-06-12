import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
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
              _writeToNdefTag(ndef);
            } else {
              _scannedNdefTag(ndef);
            }
          }
        },
      );
    } else {
      _showNfcNotSupportedDialog();
    }
  }

  void _writeToNdefTag(Ndef ndef) {
    ndef.write(NdefMessage([NdefRecord.createText("entity-$_selectedID")]));
    setState(() {
      _write = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Tag erfolgreich beschrieben!"),
      backgroundColor: Theme.of(context).primaryColor,
    ));
    Navigator.of(context).pop();
  }

  void _scannedNdefTag(Ndef ndef) {
    Navigator.of(context)
        .popUntil((route) => route.settings.name == "inventory_config");
    final rawMessage = ndef.cachedMessage?.records.first.payload;
    String? parsedMessage;
    int? entityID;
    if (rawMessage != null) {
      parsedMessage = utf8.decode(rawMessage.toList().sublist(3));
      if (parsedMessage.startsWith("entity-")) {
        entityID = int.tryParse(parsedMessage.split("-")[1]);
        if (entityID != null)
          setState(() {
            _selectedID = entityID!;
          });
      }
    }
    _showConfigureTagDialog(tagEntityID: entityID, tagData: parsedMessage);
  }

  void _showNfcNotSupportedDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("NFC wird nicht unterstüztz"),
              content: Text(
                  "Dein Gerät unterstützt leider kein NFC. Daher kannst Du mit diesem Gerät keine Inventar-Tags bearbeiten"),
            ));
  }

  void _showConfigureTagDialog({required int? tagEntityID, String? tagData}) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                    title: Text("NFC-Chip erkannt"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        (tagEntityID != null)
                            ? Text(
                                "Auf diesem NFC-Chip ist bereits das Inventar mit der ID $tagEntityID kodiert. Möchtest Du ihn wirklich überschreiben?\n\n")
                            : (tagData != null)
                                ? Column(
                                    children: [
                                      Text(
                                          "Dieser NFC-Chip enthält derzeit die Daten:"),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          "$tagData",
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
                          _showWaitingToWriteDialog();
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

  void _showWaitingToWriteDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Schreibe Daten..."),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Scanne nun den Tag erneut ein, um ihn zu beschreiben."),
                  SizedBox(
                      width: 100,
                      height: 100,
                      child: LoadingIndicator(
                        indicatorType: Indicator.ballClipRotateMultiple,
                      ))
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _write = false;
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "Abbrechen",
                    style: TextStyle(color: Theme.of(context).errorColor),
                  ),
                ),
              ],
            )).then((value) => _write = false);
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
                "Um ein Inventar zu konfigurieren, scanne dieses zunächst ein, indem Du dein Gerät an den NFC-Chip hältst. "
                "Danach kannst Du die ID des Inventars auswählen und auf den Chip übertragen.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
