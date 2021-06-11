import 'package:flutter/material.dart';

import 'main_menu.dart';

void main() {
  runApp(TrainerTools());
}

class TrainerTools extends StatelessWidget {
  const TrainerTools({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "dPS digital - trainer tools",
      home: MainMenu(),
    );
  }
}
