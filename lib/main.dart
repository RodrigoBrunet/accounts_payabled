import 'package:accounts_payable/resources/theme/my_theme.dart';
import 'package:flutter/material.dart';
import 'views/account_payabled_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: myTheme,
      home: const AccountPayabledPage(),
    );
  }
}
