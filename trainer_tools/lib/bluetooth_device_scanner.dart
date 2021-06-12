import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:trainer_tools/patient_config.dart';

/// Beacons must expose a service with this UUID in order to be able to be configured.
const beaconServiceUUID = "aab96cca-3d21-4374-ba0d-28c9954f1221";

class BluetoothDeviceScanner extends StatefulWidget {
  const BluetoothDeviceScanner({Key? key}) : super(key: key);

  @override
  _BluetoothDeviceScannerState createState() => _BluetoothDeviceScannerState();
}

class _BluetoothDeviceScannerState extends State<BluetoothDeviceScanner> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  late RefreshController _refreshController;
  List<ScanResult> _detectedDevices = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();

    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (!_detectedDevices.contains(r)) {
          setState(() {
            _detectedDevices.add(r);
          });
        }
      }
    });

    _refreshController = RefreshController(initialRefresh: true);
  }

  void _startScan() async {
    if (isScanning) await flutterBlue.stopScan();

    setState(() {
      isScanning = true;
      _detectedDevices = [];
    });

    flutterBlue.connectedDevices.then((devices) => devices.forEach((device) {
          device.disconnect();
        }));

    flutterBlue
        .startScan(timeout: Duration(seconds: 10), allowDuplicates: false)
        .then((value) {
      setState(() {
        isScanning = false;
      });
      _refreshController.refreshCompleted();
    });
  }

  @override
  void dispose() {
    flutterBlue.stopScan();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Patienten konfigurieren")),
      body: SmartRefresher(
        enablePullDown: true,
        header: _buildRefreshHeader(),
        controller: _refreshController,
        onRefresh: () => _startScan(),
        child: ListView(children: [
          _buildDescriptionTexts(),
          _buildDetectedDevicesList(),
        ]),
      ),
    );
  }

  Widget _buildRefreshHeader() {
    return WaterDropHeader(
      refresh: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingIndicator(indicatorType: Indicator.ballScaleMultiple),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text("Scanne Bluetooth-Geräte..."),
          )
        ],
      ),
      complete: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check),
          Text("Scan beendet."),
        ],
      ),
      idleIcon: Icon(Icons.bluetooth, color: Theme.of(context).primaryColor),
      completeDuration: Duration(seconds: 1),
    );
  }

  Widget _buildDescriptionTexts() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Wähle in der Liste den Beacon aus, den du konfigurieren möchtest.",
            textAlign: TextAlign.justify,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
              "Du findest deinen Beacon nicht in der Liste? Ziehe mit dem Finger nach unten, um zu aktualisieren. Taucht er trotzdem nicht auf, versuche das Gerät näher an den Beacon zu halten. Klappt das auch nicht, kannst du den Beacon zurücksetzten.",
              textAlign: TextAlign.justify),
        )
      ],
    );
  }

  Widget _buildDetectedDevicesList() {
    return ListView.builder(
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (c, i) {
        var name = _detectedDevices[i].device.name;
        if (name.isEmpty) name = "Unbekanntes Gerät";
        return GestureDetector(
          onTap: () => _connectToDevice(_detectedDevices[i].device),
          // show only devices that are dPS Beacons.
          child: (name.startsWith("patient-") || name == "dPS Beacon")
              ? Card(
                  child: Center(
                    child: ListTile(
                        leading: Icon(Icons.person),
                        title: Row(children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 32.0),
                            child: Text(name),
                          )
                        ])),
                  ),
                )
              : Container(),
        );
      },
      itemExtent: 100.0,
      itemCount: _detectedDevices.length,
    );
  }

  SnackBar _connectToDeviceSnackBar({required String deviceName}) {
    return SnackBar(
      backgroundColor: Theme.of(context).primaryColor,
      duration: Duration(seconds: 10),
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width / 6,
              height: 20,
              child: LoadingIndicator(
                indicatorType: Indicator.lineScale,
                color: Colors.white,
              )),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text("Verbinde mit $deviceName"),
          )),
        ],
      ),
    );
  }

  void _connectToDevice(BluetoothDevice device) async {
    ScaffoldMessenger.of(context)
        .showSnackBar(_connectToDeviceSnackBar(deviceName: device.name));

    // try to establish connection; disconnect and reconnect on error.
    await device
        .connect(timeout: Duration(seconds: 10))
        .onError((error, stackTrace) async {
      await device.disconnect().then((value) async => await device
          .connect()
          .onError((error, stackTrace) =>
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Theme.of(context).primaryColor,
                content: Text(
                    "Ein unbekannter Fehler ist aufgetreten. Bitte versuch es erneut."),
              ))));
    });

    // check if the beacon is a valid dPS Beacon (exposes service with [beaconServiceUUID]).
    List<BluetoothService> services = await device.discoverServices();
    bool isDPSBeacon = false;
    services.forEach((service) async {
      if (service.uuid == Guid(beaconServiceUUID)) {
        isDPSBeacon = true;
        Navigator.of(context)
            .push(MaterialPageRoute(
                builder: (context) => PatientConfig(
                      connectedDeviceService: service,
                      deviceName: device.name,
                    )))
            .then((wasSuccessful) {
          if (wasSuccessful) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Theme.of(context).primaryColor,
              content: Text("Beacon erfolgreich beschrieben!"),
            ));
            _refreshController.requestRefresh();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Fehler beim schreiben des Beacons."),
              backgroundColor: Theme.of(context).primaryColor,
            ));
          }
          device.disconnect();
        });
      }
    });

    // show a Snackbar that the beacon that the user tried to connect to is no valid dPS beacon.
    if (!isDPSBeacon) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
            backgroundColor: Theme.of(context).primaryColor,
            duration: Duration(seconds: 10),
            content: Text(
                "Verbindung mit diesem Gerät nicht möglich. Handelt es sich dabei um einen dPS Beacon? Falls ja, versuche es erneut. Wenn das Problem besteht, wende Dich bitte an einen Administrator. ")));
      print("disconnect");
      device.disconnect();
    }
  }
}
