import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      theme: FlexColorScheme.light(scheme: FlexScheme.indigo)
          .toTheme
          .copyWith(textTheme: GoogleFonts.oxygenTextTheme()),
      home: MainMenu(),
    );
  }
}
