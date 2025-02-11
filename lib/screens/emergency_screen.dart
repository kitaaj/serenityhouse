import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatelessWidget {
  final _resources = const [
    {'name': 'Suicide Prevention', 'number': '1-800-273-TALK'},
    {'name': 'Crisis Text Line', 'number': '741741'},
    {'name': 'Domestic Violence', 'number': '1-800-799-SAFE'},
  ];

  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Resources')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Immediate help is available',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _resources.length,
              itemBuilder:
                  (context, index) => ListTile(
                    leading: const Icon(Icons.emergency),
                    title: Text(_resources[index]['name']!),
                    subtitle: Text(_resources[index]['number']!),
                    onTap:
                        () => launchUrl(
                          Uri.parse('tel:${_resources[index]['number']}'),
                        ),
                  ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: TextButton.icon(
                onPressed: null,
                label: const Text(
                  'This is not a replacement for emergency services',
                  style: TextStyle(fontSize: 12),
                ),
                icon: Icon(Icons.info),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
