import 'package:flutter/material.dart';

abstract class Screen extends StatelessWidget {
  const Screen({super.key});

  AppBar? get appbar;
  Widget? get navbar;
}
