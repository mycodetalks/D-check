import 'package:flutter/material.dart';

import '../models/case_model.dart';
import '../services/isar_service.dart';
import '../services/rag_service.dart';

class ComplaintScreen extends StatefulWidget {
  final CaseModel? caseModel;
  const ComplaintScreen({super.key, this.caseModel});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _controller = TextEditingController();
  String _status = '';
  String _discriminationNote = '';
  int _draftCount = 0;
  bool _loadingDrafts = true;

  @override
  void initState() {
    super.initState();
    _loadSavedDraft();
  }

  Future<void> _loadSavedDraft() async {
    final drafts = await IsarService.instance.loadComplaintDrafts();
    if (!mounted) return;

    setState(() {
      _draftCount = drafts.length;
      if (drafts.isNotEmpty) {
        _controller.text = drafts.last;
        _status = 'Loaded your last saved complaint draft.';
      } else {
        _controller.clear();
        _status = 'No saved complaint draft found yet.';
      }
      _loadingDrafts = false;
    });

    _updateDiscriminationNote(_controller.text);
  }

  Future<void> _submitComplaint() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() {
        _status = 'Please describe your case before proceeding.';
      });
      return;
    }

    await IsarService.instance.saveComplaintDraft(text);
    await _loadSavedDraft();
    _updateDiscriminationNote(text);
    setState(() {
      _status = 'Complaint draft saved locally. You can review it later.';
    });
  }

  Future<void> _clearDraft() async {
    await IsarService.instance.clearDrafts();
    setState(() {
      _controller.clear();
      _draftCount = 0;
      _status = 'Complaint draft cleared.';
      _discriminationNote = '';
    });
  }

  Future<void> _showSavedDrafts() async {
    final selectedDraft =
        await Navigator.of(context).pushNamed('/complaint-history');
    if (selectedDraft is String && mounted) {
      setState(() {
        _controller.text = selectedDraft;
        _status = 'Loaded selected draft from history.';
      });
      _updateDiscriminationNote(selectedDraft);
    }
  }

  void _updateDiscriminationNote(String text) {
    final grounds = RagService.instance.detectDiscriminationGrounds(text);
    final note = grounds.isEmpty
        ? 'No specific discrimination grounds were detected in this draft.'
        : 'Possible discrimination grounds: ${grounds.join(', ')}.';
    if (!mounted) return;
    setState(() {
      _discriminationNote = note;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heading = widget.caseModel?.title ?? 'Complaint';
    final description = widget.caseModel?.description ??
        'Describe the situation clearly so you can prepare a strong complaint.';
    final hintText = widget.caseModel?.category != null
        ? 'Describe the incident for ${widget.caseModel!.category.toLowerCase()}'
        : 'Enter the details of what happened';

    return Scaffold(
      appBar: AppBar(title: const Text('Complaint')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(heading,
              style:
                  const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(fontSize: 16, height: 1.5)),
          const SizedBox(height: 16),
          if (widget.caseModel?.category != null)
            Chip(label: Text(widget.caseModel!.category)),
          const SizedBox(height: 16),
          if (_loadingDrafts)
            const Center(child: CircularProgressIndicator())
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saved drafts: $_draftCount',
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (_draftCount > 0)
                    TextButton(
                      onPressed: _showSavedDrafts,
                      child: const Text('View draft history'),
                    ),
                ],
              ),
            ),
          TextField(
            controller: _controller,
            maxLines: 8,
            onChanged: _updateDiscriminationNote,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_discriminationNote.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _discriminationNote.startsWith('Possible')
                    ? Colors.orange.shade100
                    : Colors.green.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _discriminationNote.startsWith('Possible')
                      ? Colors.orange.shade700
                      : Colors.green.shade700,
                ),
              ),
              child: Text(
                _discriminationNote,
                style: TextStyle(
                  fontSize: 14,
                  color: _discriminationNote.startsWith('Possible')
                      ? Colors.orange.shade900
                      : Colors.green.shade900,
                ),
              ),
            ),
          ElevatedButton(
              onPressed: _submitComplaint, child: const Text('Save draft')),
          const SizedBox(height: 12),
          OutlinedButton(
              onPressed: _clearDraft, child: const Text('Clear draft')),
          const SizedBox(height: 12),
          if (_status.isNotEmpty)
            Text(_status,
                style: const TextStyle(color: Colors.green, fontSize: 16)),
        ],
      ),
    );
  }
}
