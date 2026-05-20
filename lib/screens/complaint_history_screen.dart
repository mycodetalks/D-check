import 'package:flutter/material.dart';

import '../services/isar_service.dart';

class ComplaintHistoryScreen extends StatefulWidget {
  const ComplaintHistoryScreen({super.key});

  @override
  State<ComplaintHistoryScreen> createState() => _ComplaintHistoryScreenState();
}

class _ComplaintHistoryScreenState extends State<ComplaintHistoryScreen> {
  List<String> _drafts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    final drafts = await IsarService.instance.loadComplaintDrafts();
    if (!mounted) return;
    setState(() {
      _drafts = drafts;
      _isLoading = false;
    });
  }

  Future<void> _clearDrafts() async {
    await IsarService.instance.clearDrafts();
    if (!mounted) return;
    setState(() {
      _drafts = [];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All complaint drafts cleared.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint history'),
        actions: [
          if (!_isLoading && _drafts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear all drafts',
              onPressed: _clearDrafts,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _drafts.isEmpty
                ? const Center(
                    child: Text(
                      'No complaint drafts are saved yet.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    itemCount: _drafts.length,
                    separatorBuilder: (_, __) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      final draft = _drafts[index];
                      final preview = draft.length > 100
                          ? '${draft.substring(0, 100)}…'
                          : draft;

                      return ListTile(
                        title: Text('Draft ${index + 1}'),
                        subtitle: Text(preview),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () => Navigator.of(context).pop(draft),
                      );
                    },
                  ),
      ),
    );
  }
}
