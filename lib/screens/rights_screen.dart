import 'package:flutter/material.dart';

import '../models/case_model.dart';

class RightsScreen extends StatelessWidget {
  final CaseModel? caseModel;
  const RightsScreen({super.key, this.caseModel});

  @override
  Widget build(BuildContext context) {
    final title = caseModel?.title ?? 'General discrimination rights';
    final category = caseModel?.category ?? 'General rights';

    return Scaffold(
      appBar: AppBar(title: const Text('Rights')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Chip(label: Text(category)),
          const SizedBox(height: 16),
          const Text(
            'EU law protects individuals from discrimination in employment, services, and public life based on age, gender, race, religion, disability, and sexual orientation.',
            style: TextStyle(fontSize: 16, height: 1.6),
          ),
          const SizedBox(height: 24),
          const Text('Key protections',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          const _BulletItem(text: 'Right to equal treatment'),
          const _BulletItem(text: 'Right to complain about harassment'),
          const _BulletItem(text: 'Right to access remedies and support'),
          const SizedBox(height: 24),
          const Text('What you can do next',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          const _BulletItem(
              text: 'Compare your situation with EU discrimination policies'),
          const _BulletItem(text: 'Gather evidence before filing a complaint'),
          const _BulletItem(
              text: 'Reach out to support or legal advice channels'),
        ],
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  const _BulletItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 18)),
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 16, height: 1.5))),
        ],
      ),
    );
  }
}
