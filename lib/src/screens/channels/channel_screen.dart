import 'package:flutter/material.dart';

class ChannelScreen extends StatelessWidget {
  const ChannelScreen({super.key, required this.channel});

  final String channel;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: TabBar(
          tabs: [
            Tab(text: 'Videos'),
            Tab(text: 'Series'),
          ],
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Videos')),
            Center(child: Text('Series')),
          ],
        ),
      ),
    );
  }
}
