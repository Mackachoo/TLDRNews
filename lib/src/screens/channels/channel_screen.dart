import 'package:flutter/material.dart';

class ChannelScreen extends StatelessWidget {
  const ChannelScreen({super.key, required this.channel});

  final String channel;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: const TabBarView(
        children: [
          Center(child: Text('Videos')),
          Center(child: Text('Series')),
        ],
      ),
    );
  }
}
