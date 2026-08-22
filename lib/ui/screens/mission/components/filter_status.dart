// lib/screens/mission/components/filter_status.dart

/// Stato del filtro missioni
enum FilterStatus {
  all('Tutte'),
  inProgress('In corso'),
  completed('Completate');

  final String label;
  const FilterStatus(this.label);
}