import 'package:flutter/material.dart';

import '../models/case_model.dart';

class TriageScreen extends StatelessWidget {
  const TriageScreen({super.key});

  static const _cases = [
    CaseModel(
      title: 'Rights overview',
      description: 'Review your protections under EU discrimination law.',
      route: '/rights',
      category: 'Rights overview',
    ),
    CaseModel(
      title: 'Evidence checklist',
      description: 'Gather the documents that support your case.',
      route: '/evidence',
      category: 'Evidence collection',
      evidenceItems: [
        'Emails, messages, and written communication',
        'Witness names and contact details',
        'Employment contracts and reviews',
      ],
    ),
    CaseModel(
      title: 'File a complaint',
      description: 'Create a complaint draft for review.',
      route: '/complaint',
      category: 'Complaint filing',
    ),
    CaseModel(
      title: 'Chat help',
      description: 'Get instant guidance through a chat flow.',
      route: '/chat',
      category: 'Chat support',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Triage')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Choose a path',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Select the topic that best matches your case so we can provide the right guidance.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),
          ..._cases.map((caseItem) {
            return _RouteCard(
              title: caseItem.title,
              subtitle: caseItem.description,
              routeName: caseItem.route,
              arguments: caseItem,
            );
          }),
          const SizedBox(height: 20),
          Text(
            'Need a refresher?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Use the rights overview or evidence checklist to make sure your next step is based on the strongest information available.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String routeName;
  final Object? arguments;

  const _RouteCard({
    required this.title,
    required this.subtitle,
    required this.routeName,
    this.arguments,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        subtitle: Text(subtitle, style: const TextStyle(height: 1.4)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () =>
            Navigator.of(context).pushNamed(routeName, arguments: arguments),
      ),
    );
  }
}
