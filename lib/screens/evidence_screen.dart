import 'package:flutter/material.dart';

import '../models/case_model.dart';

class EvidenceScreen extends StatefulWidget {
  final CaseModel? caseModel;
  const EvidenceScreen({super.key, this.caseModel});

  @override
  State<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends State<EvidenceScreen> {
  final Set<int> _completed = {};

  @override
  Widget build(BuildContext context) {
    final title = widget.caseModel?.title ?? 'Evidence checklist';
    final evidenceItems = widget.caseModel?.evidenceItems ??
        const [
          'Emails, messages, and written communication',
          'Witness names and contact details',
          'Employment contracts and performance reviews',
          'Company policies and procedures',
        ];
    final doneCount = _completed.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Evidence')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('$doneCount of ${evidenceItems.length} items collected',
              style: const TextStyle(fontSize: 16, color: Colors.black54)),
          const SizedBox(height: 16),
          const Text(
              'Tap to mark the evidence you have already gathered. This checklist helps you keep track of your strongest supporting materials.',
              style: TextStyle(fontSize: 16, height: 1.5)),
          const SizedBox(height: 24),
          ...evidenceItems.asMap().entries.map((entry) {
            return CheckboxListTile(
              value: _completed.contains(entry.key),
              title: Text(entry.value, style: const TextStyle(fontSize: 16)),
              controlAffinity: ListTileControlAffinity.leading,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              tileColor: Theme.of(context).cardColor,
              onChanged: (_) {
                setState(() {
                  if (_completed.contains(entry.key)) {
                    _completed.remove(entry.key);
                  } else {
                    _completed.add(entry.key);
                  }
                });
              },
            );
          }),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: doneCount == evidenceItems.length ? () {} : null,
            child: const Text('All evidence collected'),
          ),
        ],
      ),
    );
  }
}
