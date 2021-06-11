import 'package:flutter/material.dart';
import 'package:trainer_tools/inventory_config.dart';
import 'package:trainer_tools/patient_config.dart';

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
            ElevatedButton(
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => InventoryConfig())),
                child: Text("Inventar-Tags konfigurieren")),
            ElevatedButton(
                onPressed: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => PatientConfig())),
                child: Text("Patienten-Beacon konfigurieren"))
          ],
        ),
      ),
    );
  }
}
