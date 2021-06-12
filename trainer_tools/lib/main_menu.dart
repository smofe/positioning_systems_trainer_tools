import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:trainer_tools/bluetooth_device_scanner.dart';
import 'package:trainer_tools/inventory_config.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inventare und Patienten konfigurieren")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/home.svg",
              height: MediaQuery.of(context).size.height / 4,
              width: MediaQuery.of(context).size.width / 3 * 2,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Mit dieser App kannst Du Inventar-Tags und Patienten-Beacons konfigurieren. Wähle aus, was Du konfigurieren möchtest:",
                textAlign: TextAlign.center,
              ),
            ),
            Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => InventoryConfig(),
                              settings:
                                  RouteSettings(name: "inventory_config"))),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.nfc),
                          ),
                          Text("Inventar-Tags"),
                        ],
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => BluetoothDeviceScanner())),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.bluetooth),
                          ),
                          Text("Patienten-Beacons"),
                        ],
                      )),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
