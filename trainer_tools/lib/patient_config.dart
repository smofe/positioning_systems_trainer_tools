import 'package:flutter/material.dart';

class PatientConfig extends StatefulWidget {
  const PatientConfig({Key? key}) : super(key: key);

  @override
  _PatientConfigState createState() => _PatientConfigState();
}

class _PatientConfigState extends State<PatientConfig> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Patienten konfigurieren")),
      body: Container(),
    );
  }
}
