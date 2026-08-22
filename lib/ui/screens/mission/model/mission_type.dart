// lib/screens/mission/mission_type.dart

/// Tipo di missione
enum MissionType {
  giornaliero(
    label: 'Giornaliero',
    dbValue: 'GIORNALIERO',
    xpReward: 30,
    coinReward: 1,
  ),
  settimanale(
    label: 'Settimanale',
    dbValue: 'SETTIMANALE',
    xpReward: 120,
    coinReward: 5,
  ),
  speciale(
    label: 'Speciale',
    dbValue: 'SPECIALE',
    xpReward: 400,
    coinReward: 15,
  );

  const MissionType({
    required this.label,
    required this.dbValue,
    required this.xpReward,
    required this.coinReward,
  });

  final String label;
  final String dbValue;
  final int xpReward;
  final int coinReward;

  /// Converte da stringa DB a enum
  static MissionType fromDbValue(String value) {
    return MissionType.values.firstWhere(
          (type) => type.dbValue.toUpperCase() == value.toUpperCase(),
      orElse: () => MissionType.giornaliero,
    );
  }
}

/// Stato del filtro missioni
enum FilterStatus {
  all('Tutte'),
  inProgress('In corso'),
  completed('Completate');

  const FilterStatus(this.label);
  final String label;
}