import 'dart:convert';

import 'package:flutter/services.dart';

class RagService {
  RagService._();
  static final RagService instance = RagService._();

  final List<Map<String, dynamic>> _corpus = [];
  final Map<String, dynamic> _jurisdictions = {};
  bool _initialized = false;

  Future<void> loadCorpus() async {
    final corpusJson =
        await rootBundle.loadString('assets/eu_legal_corpus.json');
    final jurisdictionsJson =
        await rootBundle.loadString('assets/jurisdictions.json');

    final corpusData = json.decode(corpusJson) as List<dynamic>;
    _corpus
      ..clear()
      ..addAll(corpusData.cast<Map<String, dynamic>>());

    _jurisdictions
      ..clear()
      ..addAll(json.decode(jurisdictionsJson) as Map<String, dynamic>);

    _initialized = true;
  }

  String answer(String query) {
    _ensureInitialized();
    final normalized = query.toLowerCase();
    final words =
        normalized.split(RegExp(r'\W+')).where((w) => w.isNotEmpty).toSet();

    final scored = _corpus
        .map((item) {
          final title = (item['title'] as String).toLowerCase();
          final text = (item['text'] as String).toLowerCase();
          final keywords =
              (item['keywords'] as List<dynamic>).join(' ').toLowerCase();
          var score = 0;

          for (final word in words) {
            if (title.contains(word)) score += 5;
            if (text.contains(word)) score += 2;
            if (keywords.contains(word)) score += 4;
          }

          if (item['directive'] != null &&
              (item['directive'] as String)
                  .toLowerCase()
                  .contains(normalized)) {
            score += 6;
          }

          return {'score': score, 'item': item};
        })
        .where((result) => result['score'] as int > 0)
        .toList();

    if (scored.isEmpty) {
      return 'I could not find an exact match in the legal corpus. Please try asking about a specific discrimination ground, directive, or evidence topic.';
    }

    scored.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
    final best = scored.first['item'] as Map<String, dynamic>;
    final title = best['title'] as String;
    final text = best['text'] as String;
    final article = best['article'] as String?;
    final directive = best['directive'] as String?;

    return [
      if (directive != null && directive.isNotEmpty) '$directive — $title',
      if (article != null && article.isNotEmpty) 'Article: $article',
      text,
    ].join('\n\n');
  }

  List<Map<String, dynamic>> listJurisdictions() {
    _ensureInitialized();
    final jurisdictions = _jurisdictions['jurisdictions'] as List<dynamic>?;
    return jurisdictions == null
        ? []
        : jurisdictions.cast<Map<String, dynamic>>();
  }

  Map<String, dynamic>? jurisdictionByCode(String code) {
    _ensureInitialized();
    return listJurisdictions().firstWhere(
      (entry) =>
          (entry['country_code'] as String).toLowerCase() == code.toLowerCase(),
      orElse: () => {},
    );
  }

  List<String> detectDiscriminationGrounds(String query) {
    _ensureInitialized();
    final normalized = query.toLowerCase();
    final words =
        normalized.split(RegExp(r'\W+')).where((w) => w.isNotEmpty).toSet();

    const grounds = {
      'Age': ['age', 'ageism', 'older', 'younger'],
      'Disability': ['disability', 'disabled', 'condition', 'impairment'],
      'Gender': ['gender', 'sex', 'female', 'male', 'woman', 'man'],
      'Race': ['race', 'racial', 'ethnic', 'ethnicity', 'skin'],
      'Religion': ['religion', 'religious', 'belief'],
      'Sexual orientation': [
        'sexual orientation',
        'orientation',
        'gay',
        'lesbian',
        'bisexual',
        'trans',
        'queer'
      ],
      'Nationality': ['nationality', 'national'],
      'Pregnancy': ['pregnancy', 'pregnant', 'maternity'],
      'Marital status': ['marriage', 'married', 'divorce'],
      'Political opinion': ['political', 'opinion'],
    };

    final matched = <String>{};

    for (final entry in grounds.entries) {
      for (final keyword in entry.value) {
        if (normalized.contains(keyword)) {
          matched.add(entry.key);
          break;
        }
      }
    }

    for (final item in _corpus) {
      final title = (item['title'] as String).toLowerCase();
      final text = (item['text'] as String).toLowerCase();
      for (final entry in grounds.entries) {
        for (final keyword in entry.value) {
          if (title.contains(keyword) || text.contains(keyword)) {
            if (words.any((w) => title.contains(w) || text.contains(w))) {
              matched.add(entry.key);
              break;
            }
          }
        }
      }
    }

    return matched.toList()..sort();
  }

  bool isPossibleDiscrimination(String query) {
    return detectDiscriminationGrounds(query).isNotEmpty;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('RagService has not been initialized.');
    }
  }
}
