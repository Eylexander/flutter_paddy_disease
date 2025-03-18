class ClassifierCategory {
  final String label;
  final double score;

  ClassifierCategory(this.label, this.score);

  @override
  String toString() => 'Category{label: $label, score: $score}';
}
