import 'package:flutter/material.dart';
import 'package:trivia_app/features/number_trivia/presentation/pages/number_trivia_page.dart';
import 'package:trivia_app/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Number Trivia',
      theme: ThemeData(
        primaryColor: Colors.cyan,
        accentColor: Colors.cyanAccent,
      ),
      home: NumberTriviaPage(),
    );
  }
}
