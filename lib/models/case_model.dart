class CaseModel {
  final String title;
  final String description;
  final String route;
  final String category;
  final List<String> evidenceItems;

  const CaseModel({
    required this.title,
    required this.description,
    required this.route,
    required this.category,
    this.evidenceItems = const [],
  });
}
